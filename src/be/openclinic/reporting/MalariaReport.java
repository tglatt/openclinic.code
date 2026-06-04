package be.openclinic.reporting;

import java.sql.*;
import java.text.ParseException;
import java.util.Base64;
import java.util.Vector;

import org.apache.commons.httpclient.*;
import org.apache.commons.httpclient.methods.PostMethod;
import org.dom4j.*;

import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.RequestedLabAnalysis;
import be.openclinic.system.SH;

public class MalariaReport {
	
	public static String addList(String existingList, String newList) {
		if(newList.length()>0) {
			String[] nl = newList.split(";");
			for(int n=0;n<nl.length;n++) {
				if(nl[n].length()>0 && !existingList.contains(nl[n]+";")) {
					existingList+=nl[n]+";";
				}
			}
		}
		return existingList;
	}
	
	public static Document run() {
		Document doc = DocumentHelper.createDocument();
		Element root = doc.addElement("message");
		root.addAttribute("type", "malariaEncounter");
		//Run through all modified encounters since last run. If this is the first run, then get past year's encounters
		java.util.Date dLastRun = SH.parseDate(SH.cs("malariaReportingLastRun", SH.formatDate(SH.dateAdd(SH.now(), -SH.getTimeDay()*SH.ci("malariaPostRecoverDays", 30)),"yyyyMMddHHmmssSSS")),"yyyyMMddHHmmssSSS");
		Connection conn = SH.getOpenClinicConnection();
		String sSql = "select distinct e.* from oc_encounters e,transactions t, items i where"+
					  " t.ts>? and t.transactionid=i.transactionid and t.serverid=i.serverid and"+
					  " i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID' and"+
					  " e.oc_encounter_objectid=replace(i.value,'"+SH.getServerId()+".','')";
		try {
			int validEncounters=0;
			Vector<String> encounters = new Vector<String>();
			PreparedStatement ps = conn.prepareCall(sSql);
			ps.setTimestamp(1, SH.getSQLTimestamp(dLastRun));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				encounters.add(rs.getInt("oc_encounter_serverid")+"."+rs.getInt("oc_encounter_objectid"));
			}
			rs.close();
			ps.close();
			for(int v=0;v<encounters.size();v++) {
				if(v % 100 ==0) {
					SH.syslog(v+"/"+encounters.size()+" ["+validEncounters+"]");
				}
				boolean bFeverTransaction=false,bMalariaTransaction=false;
				Encounter encounter = Encounter.get(encounters.elementAt(v));
				Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsByEncounter(Integer.parseInt(encounter.getPatientUID()), encounter.getUid());
				for(int n=0;n<transactions.size();n++) {
					TransactionVO transaction = transactions.elementAt(n);
					double temperature = -1;
					try {
						temperature=Double.parseDouble(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE"));
					}
					catch(Exception t) {}
					if(temperature>=38) {
						bFeverTransaction=true;
					}
					if(transaction.getTransactionType().startsWith("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GF_MALARIA_")) {
						bMalariaTransaction=true;
					}
					else if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MALARIA_CARE").equalsIgnoreCase("1;")) {
						bMalariaTransaction=true;
					}
				}
				if(bMalariaTransaction) {
					validEncounters++;
					//Collect all malaria-relevant data from this encounter
					double maxTemperature = -1;
					String signsSeverity="",signsOther="",malariaDiagnosis="",otherDiagnosis="",malariaTreatment="",complicationsTreatment="",rapidtest="",thicksmear="";
					String complicationsNeuro="",complicationsRespiratory="",complicationsDigestive="",complicationsSkin="";
					for(int n=0;n<transactions.size();n++) {
						TransactionVO transaction = transactions.elementAt(n);
						double temperature = -1;
						try {
							temperature=Double.parseDouble(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE"));
							if(temperature<30 || temperature>44) {
								temperature=-1;
							}
						}
						catch(Exception t) {}
						if(temperature>maxTemperature) {
							maxTemperature=temperature;
						}
						complicationsNeuro=addList(complicationsNeuro, transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEUROLOGIC"));
						complicationsRespiratory=addList(complicationsRespiratory, transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESPIRATORY"));
						complicationsDigestive=addList(complicationsDigestive, transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DIGESTIVE"));
						complicationsSkin=addList(complicationsSkin, transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SKIN"));
						signsSeverity=addList(signsSeverity, transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS"));
						signsOther=addList(signsOther, transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS"));
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRESUMEDDIAGNOSIS").equalsIgnoreCase("2;")) {
							malariaDiagnosis="2";
						}
						else if(!malariaDiagnosis.equalsIgnoreCase("2") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRESUMEDDIAGNOSIS").equalsIgnoreCase("1;")) {
							malariaDiagnosis="1";
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERDIAGNOSIS").equalsIgnoreCase("1")) {
							otherDiagnosis="1";
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TREATMENT_ARTESUNATE").equalsIgnoreCase("1;")) {
							malariaTreatment=addList(malariaTreatment,"6;");
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TREATMENT_UNCOMPLICATED").length()>0) {
							malariaTreatment=addList(malariaTreatment,"7;");
						}
						malariaTreatment=addList(malariaTreatment, transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NOTIFICATION_MALARIATREATMENT2"));
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TREATMENT_GLUCOSE").length()>0) {
							complicationsTreatment=addList(complicationsTreatment,"1;");
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TREATMENT_RINGERLACTATE").equalsIgnoreCase("1;")) {
							complicationsTreatment=addList(complicationsTreatment,"2;");
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TREATMENT_ANTIPYRETIC").length()>0) {
							complicationsTreatment=addList(complicationsTreatment,"3;");
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TREATMENT_BLOODTRANSFUSION").equalsIgnoreCase("1;")) {
							complicationsTreatment=addList(complicationsTreatment,"4;");
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TREATMENT_CONVULSIONS").length()>0) {
							complicationsTreatment=addList(complicationsTreatment,"5;");
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TREATMENT_OCYGEN").equalsIgnoreCase("1;")) {
							complicationsTreatment=addList(complicationsTreatment,"6;");
						}
						if(!rapidtest.equalsIgnoreCase("+")) {
							RequestedLabAnalysis analysis=RequestedLabAnalysis.getByLOINC(transaction.getServerId(), transaction.getTransactionId(), "70569-9");
							if(analysis!=null && (analysis.getResultValue().contains("+") || analysis.getResultValue().toLowerCase().contains("pos"))) {
								rapidtest="+";
							}
							else if(analysis!=null && (analysis.getResultValue().contains("-") || analysis.getResultValue().toLowerCase().contains("neg"))) {
								rapidtest="-";
							}
						}
						if(!thicksmear.equalsIgnoreCase("+")) {
							RequestedLabAnalysis analysis=RequestedLabAnalysis.getByLOINC(transaction.getServerId(), transaction.getTransactionId(), "32700-7");
							if(analysis!=null && (analysis.getResultValue().contains("+") || analysis.getResultValue().toLowerCase().contains("pos"))) {
								thicksmear="+";
							}
							else if(analysis!=null && (analysis.getResultValue().contains("-") || analysis.getResultValue().toLowerCase().contains("neg"))) {
								thicksmear="-";
							}
						}
					}
					//Add encounter content to XML document
					Element e = root.addElement("encounter");
					e.addAttribute("site", SH.ci("malariaStatsSite", 0)+"");
					e.addAttribute("id", (encounter.getUid()+"."+encounter.getPatientUID()+"."+encounter.getBegin()).hashCode()+"");
					e.addAttribute("type", "malaria");
					e.addAttribute("begin", SH.formatDate(encounter.getBegin(),"yyyyMMddHHmmss"));
					e.addAttribute("end", SH.formatDate(encounter.getEnd(),"yyyyMMddHHmmss"));
					e.addAttribute("temperature", maxTemperature+"");
					e.addAttribute("severitysigns", signsSeverity);
					e.addAttribute("othersigns", signsOther);
					e.addAttribute("malariadiagnosis", malariaDiagnosis);
					e.addAttribute("otherdiagnosis", otherDiagnosis);
					e.addAttribute("malariatreatment", malariaTreatment);
					e.addAttribute("complicationstreatment", complicationsTreatment);
					e.addAttribute("rapidtest", rapidtest);
					e.addAttribute("thicksmear", thicksmear);
					e.addAttribute("complicationsneuro", complicationsNeuro);
					e.addAttribute("complicationsdigestive", complicationsDigestive);
					e.addAttribute("complicationsskin", complicationsSkin);
					e.addAttribute("complicationsrespiratory", complicationsRespiratory);
					e.addAttribute("gender", encounter.getPatient().gender);
					e.addAttribute("age", encounter.getPatient().getAge()+"");
					e.addAttribute("encountertype", encounter.getType()+"");
					try {
						if(encounter.getType().equalsIgnoreCase("admission") && encounter.getEnd()!=null) {
							e.addAttribute("lengthofstay", encounter.getDurationInDays()+"");
						}
					} catch (ParseException e1) {}
				}
				else if(bFeverTransaction) {
					validEncounters++;
					double maxTemperature = -1;
					String rapidtest="",thicksmear="";
					for(int n=0;n<transactions.size();n++) {
						TransactionVO transaction = transactions.elementAt(n);
						double temperature = -1;
						try {
							temperature=Double.parseDouble(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE"));
							if(temperature<30 || temperature>44) {
								temperature=-1;
							}
						}
						catch(Exception t) {}
						if(temperature>maxTemperature) {
							maxTemperature=temperature;
						}
						if(!rapidtest.equalsIgnoreCase("+")) {
							if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REF_RAPIDTEST").contains("1")) {
								rapidtest="+";
							}
							else {
								RequestedLabAnalysis analysis=RequestedLabAnalysis.getByLOINC(transaction.getServerId(), transaction.getTransactionId(), "70569-9");
								if(analysis!=null && (analysis.getResultValue().contains("+") || analysis.getResultValue().toLowerCase().contains("pos"))) {
									rapidtest="+";
								}
								else if(analysis!=null && (analysis.getResultValue().contains("-") || analysis.getResultValue().toLowerCase().contains("neg"))) {
									rapidtest="-";
								}
							}
						}
						if(!thicksmear.equalsIgnoreCase("+")) {
							if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REF_THICKSMEAR").contains("1")) {
								thicksmear="+";
							}
							else {
								RequestedLabAnalysis analysis=RequestedLabAnalysis.getByLOINC(transaction.getServerId(), transaction.getTransactionId(), "32700-7");
								if(analysis!=null && (analysis.getResultValue().contains("+") || analysis.getResultValue().toLowerCase().contains("pos"))) {
									thicksmear="+";
								}
								else if(analysis!=null && (analysis.getResultValue().contains("-") || analysis.getResultValue().toLowerCase().contains("neg"))) {
									thicksmear="-";
								}
							}
						}
					}
					//Add encounter content to XML document
					Element e = root.addElement("encounter");
					e.addAttribute("id", (encounter.getUid()+"."+encounter.getPatientUID()+"."+encounter.getBegin()).hashCode()+"");
					e.addAttribute("site", SH.ci("malariaStatsSite", 0)+"");
					e.addAttribute("type", "fever");
					e.addAttribute("begin", SH.formatDate(encounter.getBegin(),"yyyyMMddHHmmss"));
					e.addAttribute("end", SH.formatDate(encounter.getEnd(),"yyyyMMddHHmmss"));
					e.addAttribute("temperature", maxTemperature+"");
					e.addAttribute("rapidtest", rapidtest);
					e.addAttribute("thicksmear", thicksmear);
					e.addAttribute("gender", encounter.getPatient().gender);
					e.addAttribute("age", encounter.getPatient().getAge()+"");
					e.addAttribute("encountertype", encounter.getType()+"");
					try {
						if(encounter.getType().equalsIgnoreCase("admission") && encounter.getEnd()!=null) {
							e.addAttribute("lengthofstay", encounter.getDurationInDays()+"");
						}
					} catch (ParseException e1) {}
				}
			}
			SH.syslog(encounters.size()+"/"+encounters.size()+" ["+validEncounters+"]");

		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return doc;
	}
	
	public static void post() {
		if(SH.ci("enableMalariaPosts", 0)==1) {
			java.util.Date now = SH.now();
			Document doc = run();
			HttpClient client = new HttpClient();
			PostMethod method = new PostMethod(SH.cs("malariaStatsURL","http://localhost/openclinic/api/postMalariaData.jsp"));
			NameValuePair[] nvp = new NameValuePair[1];
			nvp[0]= new NameValuePair("xml",doc.asXML());
			method.setRequestBody(nvp);
		   	String authStr = SH.cs("malariaPostStats.username", "nil") + ":" + SH.cs("malariaPostStats.password", "nil");
			String authEncoded = Base64.getEncoder().encodeToString(authStr.getBytes());
		    method.setRequestHeader("Authorization", "Basic "+authEncoded);
		    try{
		    	SH.syslog("Sending data to "+SH.cs("malariaStatsURL","http://localhost/openclinic/api/postMalariaData.jsp"));
				int statusCode = client.executeMethod(method);
				String sResponse=method.getResponseBodyAsString();
				SH.syslog("Malaria stats post response = "+sResponse.replaceAll("\\n","").replaceAll("\\r",""));
				if(sResponse.contains("error='0'")) {
					MedwanQuery.getInstance().setConfigString("malariaReportingLastRun", SH.formatDate(now,"yyyyMMddHHmmssSSS"));
				}
		    }
		    catch(Exception e) {
		    	e.printStackTrace();
		    }
		}
	}

}
