package be.openclinic.reporting;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.Vector;

import org.apache.xalan.xsltc.runtime.Hashtable;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.adt.Encounter;
import be.openclinic.finance.Insurance;
import be.openclinic.finance.PatientInvoice;
import be.openclinic.medical.Diagnosis;
import be.openclinic.medical.Prescription;
import be.openclinic.medical.ReasonForEncounter;
import be.openclinic.medical.RequestedLabAnalysis;
import be.openclinic.system.SH;
import net.admin.AdminPerson;
import net.admin.AdminPrivateContact;
import net.admin.User;

public class Register {
	private AdminPerson patient =null;
	private Encounter encounter = null;
	private TransactionVO transaction = null;
	
	public void setTransaction(TransactionVO transaction) {
		this.transaction = transaction;
	}

	private String sWebLanguage=null;
	private int counter=0;
	
	
	public int getCounter() {
		return counter;
	}

	public void setCounter(int counter) {
		this.counter = counter;
	}

	public AdminPerson getPatient() {
		return patient;
	}

	public Encounter getEncounter() {
		return encounter;
	}

	public TransactionVO getTransaction() {
		return transaction;
	}

	public String getsWebLanguage() {
		return sWebLanguage;
	}

	public Register(int serverid,int transactionid, int personid, String language){
		transaction = MedwanQuery.getInstance().loadTransaction(serverid, transactionid);
		patient = AdminPerson.getAdminPerson(personid+"");
		if(transaction!=null && transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID")!=null){
			encounter = Encounter.get(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID"));
			if(encounter==null){
				encounter = Encounter.getActiveEncounterOnDate(new java.sql.Timestamp(transaction.getUpdateTime().getTime()), personid+"");
			}
		}
		sWebLanguage=language;
	}
	
	public String getValue(String source, String name, String translateresult){
		String s ="";
		/*******************************
		 * System
		 *******************************/
		if(source.equalsIgnoreCase("system")){
			if(name.equalsIgnoreCase("id")){
				counter++;
				s=""+counter;
			}
		}
		/*******************************
		 * Diagnosis
		 *******************************/
		else if(source.equalsIgnoreCase("diagnosis")){
			if(name.equalsIgnoreCase("icd10")){
				Collection items = transaction.getItems();
				Iterator iItems = items.iterator();
				while(iItems.hasNext()){
					ItemVO item =(ItemVO)iItems.next();
					if(item.getType().startsWith("ICD10Code")){
						if(s.length()>0){
							s+=", ";
						}
						s+=item.getType().replaceAll("ICD10Code", "")+" "+MedwanQuery.getInstance().getCodeTran(item.getType(), sWebLanguage);
					}
				}
			}
			else if(name.equalsIgnoreCase("icd10withlocalcodes")){
				Collection items = transaction.getItems();
				Iterator iItems = items.iterator();
				while(iItems.hasNext()){
					ItemVO item =(ItemVO)iItems.next();
					if(item.getType().startsWith("ICD10Code")){
						if(s.length()>0){
							s+=", ";
						}
						s+=item.getType().replaceAll("ICD10Code", "")+" "+MedwanQuery.getInstance().getCodeTran(item.getType(), sWebLanguage);
					}
					else if(item.getType().startsWith("ICPCCode") && item.getType().replaceAll("ICPCCode", "").startsWith("J")){
						if(s.length()>0){
							s+=", ";
						}
						s+=item.getType().replaceAll("ICPCCode", "")+" "+MedwanQuery.getInstance().getCodeTran(item.getType(), sWebLanguage);
					}
				}
			}
			else if(name.equalsIgnoreCase("encountericd10")){
				Collection diagnoses = Diagnosis.selectDiagnoses("", "", encounter.getUid(), "", "", "", "", "", "", "", "", "icd10", "");
				Iterator iDiagnoses = diagnoses.iterator();
				while(iDiagnoses.hasNext()){
					Diagnosis diagnosis =(Diagnosis)iDiagnoses.next();
					if(s.length()>0){
						s+=", ";
					}
					s+=diagnosis.getCode()+" "+MedwanQuery.getInstance().getCodeTran("icd10code"+diagnosis.getCode(), sWebLanguage);
				}
			}
			else if(name.equalsIgnoreCase("icpc2")){
				Collection items = transaction.getItems();
				Iterator iItems = items.iterator();
				while(iItems.hasNext()){
					ItemVO item =(ItemVO)iItems.next();
					if(item.getType().startsWith("ICPCCode")){
						if(s.length()>0){
							s+=", ";
						}
						s+=item.getType().replaceAll("ICPCCode", "")+" "+MedwanQuery.getInstance().getCodeTran(item.getType(), sWebLanguage);
					}
				}
			}
		}
		/*******************************
		 * Patient
		 *******************************/
		else if(patient!=null && source.equalsIgnoreCase("patient")){
			if(name.startsWith("fullname")){
				s=patient.getFullName();
			}
			else if(name.startsWith("firstname")){
				s=SH.capitalize(patient.firstname);
			}
			else if(name.startsWith("lastname")){
				s=patient.lastname.toUpperCase();
			}
			else if(name.startsWith("natreg")){
				s=SH.c(patient.getID("natreg"));
			}
			else if(name.startsWith("nationality")){
				s=SH.c(patient.nativeCountry);
			}
			else if(name.startsWith("extends")){
				if(name.split(":").length>1) {
					s=SH.c(patient.getExtendedValue(name.split(":")[1]));
				}
				else {
					s="?";
				}
			}
			else if(name.startsWith("telephones")){
				s=SH.c(patient.getActivePrivate().telephone).trim();
				if(SH.c(patient.getActivePrivate().mobile).length()>0){
					if(s.length()>0) {
						s+=" / ";
					}
					s+=patient.getActivePrivate().mobile;
				}
			}
			else if(name.startsWith("telephone")){
				s=SH.c(patient.getActivePrivate().telephone);
			}
			else if(name.startsWith("civilstatus")) {
				s=ScreenHelper.getTranNoLink("civil.status",patient.comment2,sWebLanguage);
			}
			else if(name.startsWith("profession")) {
				s=patient.getActivePrivate().businessfunction;
			}
			else if(name.startsWith("ageinyears")){
				if(name.split("=").length<2) {
					if(transaction!=null) {
						s=patient.getAgeOnDate(transaction.getUpdateTime())+"";
					}
					else {
						s=patient.getAge()+"";
					}
				}
				else {
					if(name.split("=")[1].split(":")[0].equalsIgnoreCase("lessthan") && patient.getAge()<Double.parseDouble(name.split("=")[1].split(":")[1])) {
						if(transaction!=null) {
							s=patient.getAgeOnDate(transaction.getUpdateTime())+"";
						}
						else {
							s=patient.getAge()+"";
						}
					}
					else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("lessthanorequals") && patient.getAge()<=Double.parseDouble(name.split("=")[1].split(":")[1])) {
						if(transaction!=null) {
							s=patient.getAgeOnDate(transaction.getUpdateTime())+"";
						}
						else {
							s=patient.getAge()+"";
						}
					}
					else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("morethan") && patient.getAge()>Double.parseDouble(name.split("=")[1].split(":")[1])) {
						if(transaction!=null) {
							s=patient.getAgeOnDate(transaction.getUpdateTime())+"";
						}
						else {
							s=patient.getAge()+"";
						}
					}
					else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("morethanorequals") && patient.getAge()>=Double.parseDouble(name.split("=")[1].split(":")[1])) {
						if(transaction!=null) {
							s=patient.getAgeOnDate(transaction.getUpdateTime())+"";
						}
						else {
							s=patient.getAge()+"";
						}
					}
					else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("equals") && patient.getAge()==Double.parseDouble(name.split("=")[1].split(":")[1])) {
						if(transaction!=null) {
							s=patient.getAgeOnDate(transaction.getUpdateTime())+"";
						}
						else {
							s=patient.getAge()+"";
						}
					}
					else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("notequals") && patient.getAge()!=Double.parseDouble(name.split("=")[1].split(":")[1])) {
						if(transaction!=null) {
							s=patient.getAgeOnDate(transaction.getUpdateTime())+"";
						}
						else {
							s=patient.getAge()+"";
						}
					}
				}
			}
			else if(name.startsWith("childage")){
				if(transaction!=null) {
					if(patient.getAgeInMonthsOnDate(transaction.getUpdateTime())>=60) {
						s=patient.getAgeOnDate(transaction.getUpdateTime())+"";
					}
					else if(patient.getAgeInMonthsOnDate(transaction.getUpdateTime())>=1) {
						s=patient.getAgeInMonthsOnDate(transaction.getUpdateTime())+"m";
					}
					else {
						s=patient.getAgeInDaysOnDate(transaction.getUpdateTime())+ScreenHelper.getTranNoLink("register","d",sWebLanguage);
					}
				}
				else {
					if(patient.getAgeInMonths()>=60) {
						s=patient.getAge()+"";
					}
					else if(patient.getAgeInMonths()>=1) {
						s=patient.getAgeInMonths()+"m";
					}
					else {
						s=patient.getAgeInDays()+ScreenHelper.getTranNoLink("register","d",sWebLanguage);
					}
				}
			}
			else if(name.startsWith("nigeragegroup1")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<12) {
					s="A";
				}
				else if(age<60) {
					s="B";
				}
				else if(age<180) {
					s="C";
				}
				else {
					s="D"; 
				}
			}
			else if(name.startsWith("nigeragegroup2")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<228) {
					s="A";
				}
				else {
					s="B";
				}
			}
			else if(name.startsWith("nigeragegroup3")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<228) {
					s="C";
				}
				else if(age<300) {
					s="D";
				}
				else {
					s="E";
				}
			}
			else if(name.startsWith("nigeragegroup4")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<144) {
					s="A";
				}
				else if(age<720) {
					s="B";
				}
				else {
					s="C";
				}
			}
			else if(name.startsWith("nigeragegroup5")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<6) {
					s="A";
				}
				else if(age<12) {
					s="B";
				}
				else if(age<24) {
					s="C";
				}
				else if(age<60) {
					s="D"; 
				}
			}
			else if(name.startsWith("guineaagegroup1")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<12) {
					s="A";
				}
				else if(age<24) {
					s="B";
				}
				else if(age<60) {
					s="C"; 
				}
			}
			else if(name.startsWith("guineaagegroup2")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<60) {
					s="A";
				}
				else {
					s="B";
				}
			}
			else if(name.startsWith("guineaagegroup3")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<240) {
					s="A";
				}
				else {
					s="B";
				}
			}
			else if(name.startsWith("msplsagegroup")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(name.split(":").length>2) {
					int minage=Integer.parseInt(name.split(":")[1]);
					int maxage=Integer.parseInt(name.split(":")[2]);
					if(age>=minage && age<maxage) {
						s="1";
					}
					else {
						s="0";
					}
				}
				else {
					if(age<1) {
						s="A1";
					}
					else if(age<12) {
						s="A2";
					}
					else if(age<60) {
						s="B";
					}
					else if(age<120) {
						s="C";
					}
					else if(age<180) {
						s="D";
					}
					else if(age<216) {
						s="E";
					}
					else if(age<240) {
						s="F";
					}
					else if(age<300) {
						s="G";
					}
					else if(age<360) {
						s="H";
					}
					else if(age<420) {
						s="I";
					}
					else if(age<480) {
						s="J";
					}
					else if(age<540) {
						s="K";
					}
					else if(age<600) {
						s="L";
					}
					else if(age<660) {
						s="M";
					}
					else if(age<720) {
						s="N";
					}
					else if(age<780) {
						s="O";
					}
					else if(age<840) {
						s="P";
					}
					else {
						s="Q";
					}
				}
			}
			else if(name.equalsIgnoreCase("msplsagegroup2")){
				int age = patient.getAgeInMonths();
				if(transaction!=null) {
					age=patient.getAgeInMonthsOnDate(transaction.getUpdateTime());
				}
				if(age<180) {
					s="<15";
				}
				else {
					s=">=15";
				}
			}
			else if(name.startsWith("dateofbirth")){
				s=patient.dateOfBirth;
			}
			else if(name.startsWith("personid")){
				s=patient.personid+"";
			}
			else if(name.startsWith("gender")){
				if(name.split("=").length<2) {
					s=patient.gender;
				}
				else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("contains") && ScreenHelper.checkString(patient.gender).toLowerCase().contains(name.toLowerCase().split("=")[1].split(":")[1])) {
					s=patient.gender;
				}
			}
			else if(name.startsWith("sector")){
				s=patient.getActivePrivate().sector;
			}
			else if(name.startsWith("cell")){
				s=patient.getActivePrivate().cell;
			}
			else if(name.startsWith("city")){
				s=patient.getActivePrivate().city;
			}
			else if(name.startsWith("province")){
				s=patient.getActivePrivate().province;
			}
			else if(name.startsWith("district")){
				s=patient.getActivePrivate().district;
			}
			else if(name.equalsIgnoreCase("comment")){
				s=patient.comment;
			}
			else if(name.equalsIgnoreCase("comment1")){
				s=patient.comment1;
			}
			else if(name.equalsIgnoreCase("comment2")){
				s=patient.comment2;
			}
			else if(name.equalsIgnoreCase("comment3")){
				s=patient.comment3;
			}
			else if(name.equalsIgnoreCase("comment4")){
				s=patient.comment4;
			}
			else if(name.equalsIgnoreCase("comment5")){
				s=patient.comment5;
			}
			else if(name.startsWith("address")){
				if(patient.getActivePrivate()!=null){
					s=patient.getActivePrivate().address;
				}
			}
			else if(name.startsWith("profession")){
				if(patient.getActivePrivate()!=null){
					s=patient.getActivePrivate().businessfunction;
				}
			}
		}
		/*******************************
		 * Transaction
		 *******************************/
		else if(transaction!=null && source.startsWith("transaction")){
			if(name.equalsIgnoreCase("updatetime")){
				s=ScreenHelper.formatDate(transaction.getUpdateTime());
			}
			else if(name.equalsIgnoreCase("id")){
				s=transaction.getTransactionId()+"";
			}
			else if(name.equalsIgnoreCase("year")){
				s=new SimpleDateFormat("yyyy").format(transaction.getUpdateTime())+"";
			}
			else if(name.equalsIgnoreCase("month")){
				s=new SimpleDateFormat("MM").format(transaction.getUpdateTime())+"";
			}
			else if(name.equalsIgnoreCase("user")){
				s=transaction.getUser().getPersonVO().getFullName();
			}
			else if(name.startsWith("labresult")){
				String code = name.split("=")[1];
				RequestedLabAnalysis analysis = RequestedLabAnalysis.get(transaction.getServerId(), transaction.getTransactionId(), code);
				if(analysis!=null && SH.c(analysis.getResultValue()).length()>0) {
					s=analysis.getResultValue()+" "+analysis.getResultUnit();
				}
				else if(analysis!=null && analysis.getResultDate()!=null){
					s="?";
				}
			}
			else if(name.startsWith("labsection")){
				String modifier = name.split("=")[1].split(":")[0];
				String code = name.split("=")[1].split(":")[1];
				int count=0;
				java.util.Hashtable analyses = RequestedLabAnalysis.getLabAnalysesForLabRequest(transaction.getServerId(), transaction.getTransactionId());
				Enumeration eAnalyses = analyses.keys();
				while(eAnalyses.hasMoreElements()) {
					RequestedLabAnalysis analysis = (RequestedLabAnalysis)analyses.get(eAnalyses.nextElement());
					be.openclinic.medical.LabAnalysis lab = be.openclinic.medical.LabAnalysis.getLabAnalysisByLabcode(analysis.getAnalysisCode());
					if(modifier.equalsIgnoreCase("equals") && lab.getSection().equalsIgnoreCase(code)) {
						count++;
					}
					else if(modifier.equalsIgnoreCase("in") && code.contains(lab.getSection())) {
						count++;
					}
					else if(modifier.equalsIgnoreCase("notin") && !code.contains(lab.getSection())) {
						count++;
					}
				}
				s=count+"";
			}
			else if(name.startsWith("loinclabresult")){
				String code = name.split("=")[1].split(":")[0];
				String contains="";
				if(name.split("=")[1].split(":").length>1) {
					contains = name.split("=")[1].split(":")[1];
				}
				RequestedLabAnalysis analysis = RequestedLabAnalysis.getByLOINC(transaction.getServerId(), transaction.getTransactionId(), code);
				if(analysis!=null && SH.c(analysis.getResultValue()).length()>0) {
					if(contains.length()==0 || analysis.getResultValue().toLowerCase().contains(contains)) {
						s=analysis.getResultValue()+" "+analysis.getResultUnit();
					}
				}
				else if(analysis!=null && analysis.getResultDate()!=null){
					s="?";
				}
			}
			else if(name.startsWith("loinclabcomment")){
				String code = name.split("=")[1].split(":")[0];
				String contains="";
				if(name.split("=")[1].split(":").length>1) {
					contains = name.split("=")[1].split(":")[1];
				}
				RequestedLabAnalysis analysis = RequestedLabAnalysis.getByLOINC(transaction.getServerId(), transaction.getTransactionId(), code);
				if(analysis!=null && SH.c(analysis.getResultComment()).length()>0) {
					if(contains.length()==0 || analysis.getResultValue().toLowerCase().contains(contains)) {
						s=analysis.getResultComment();
					}
				}
			}
			else {
				if(s.length()>0) {
					s=",";
				}
				boolean bMustFindLastValue=false;
				if(name.startsWith("!")){
					bMustFindLastValue=true;
					name=name.substring(1);
				}
				if(name.split("=").length<2) {
					String sValue=ScreenHelper.checkString(transaction.getItemValue(name));
					if(sValue.length()==0 && bMustFindLastValue) {
						sValue=findLastItem(transaction,name);
					}
					s = sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " ");
				}
				else {
					try {
						if(name.split("=")[1].split(":")[0].equalsIgnoreCase("contains")) {
							String sValue=ScreenHelper.checkString(transaction.getItemValue(name.split("=")[0]));
							if((sValue.length()==0 || !sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " ").toLowerCase().contains(name.toLowerCase().split("=")[1].split(":")[1])) && bMustFindLastValue) {
								sValue=findLastItem(transaction,name.split("=")[0]);
							}
							if(sValue.length()>0 && sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " ").toLowerCase().contains(name.toLowerCase().split("=")[1].split(":")[1])) {
								s=sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " ");
							}
						}
						else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("in")) {
							String sValue=ScreenHelper.checkString(transaction.getItemValue(name.split("=")[0]));
							if((sValue.length()==0 || !name.toLowerCase().split("=")[1].split(":")[1].contains(sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " ").toLowerCase())) && bMustFindLastValue) {
								sValue=findLastItem(transaction,name.split("=")[0]);
							}
							if(sValue.length()>0 && name.toLowerCase().split("=")[1].split(":")[1].contains(sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " ").toLowerCase())) {
								s=sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " ");
							}
						}
						else {
							String sValue=ScreenHelper.checkString(transaction.getItemValue(name.split("=")[0]));
							double val = Double.parseDouble(sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " "));
							if(name.split("=")[1].split(":")[0].equalsIgnoreCase("lessthan") && val<Double.parseDouble(name.split("=")[1].split(":")[1])) {
								if(name.split("!").length>1) {
									sValue=name.split("!")[1];
								}
								s+=sValue+"";
							}
							if(name.split("=")[1].split(":")[0].equalsIgnoreCase("lessthanorequals") && val<=Double.parseDouble(name.split("=")[1].split(":")[1])) {
								if(name.split("!").length>1) {
									sValue=name.split("!")[1];
								}
								s+=sValue+"";
							}
							else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("between") && val>=Double.parseDouble(name.split("=")[1].split(":")[1]) && val<Double.parseDouble(name.split("=")[1].split(":")[2])) {
								if(name.split("!").length>1) {
									sValue=name.split("!")[1];
								}
								s+=sValue+"";
							}
							else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("morethan") && val>Double.parseDouble(name.split("=")[1].split(":")[1])) {
								if(name.split("!").length>1) {
									sValue=name.split("!")[1];
								}
								s+=sValue+"";
							}
							else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("morethanorequals") && val>=Double.parseDouble(name.split("=")[1].split(":")[1])) {
								if(name.split("!").length>1) {
									sValue=name.split("!")[1];
								}
								s=sValue+"";
							}
							else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("equals") && val==Double.parseDouble(name.split("=")[1].split(":")[1])) {
								if(name.split("!").length>1) {
									sValue=name.split("!")[1];
								}
								s=sValue+"";
							}
							else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("notequals") && val!=Double.parseDouble(name.split("=")[1].split(":")[1])) {
								if(name.split("!").length>1) {
									sValue=name.split("!")[1];
								}
								s=sValue+"";
							}
							
							if(s.length()==0 && bMustFindLastValue) {
								sValue=findLastItem(transaction,name.split("=")[0]);
								val = Double.parseDouble(sValue.replaceAll(";", ",").replaceAll("\r", "").replaceAll("\n", " "));
								if(name.split("=")[1].split(":")[0].equalsIgnoreCase("lessthan") && val<Double.parseDouble(name.split("=")[1].split(":")[1])) {
									if(name.split("!").length>1) {
										sValue=name.split("!")[1];
									}
									s+=sValue+"";
								}
								if(name.split("=")[1].split(":")[0].equalsIgnoreCase("lessthanorequals") && val<=Double.parseDouble(name.split("=")[1].split(":")[1])) {
									if(name.split("!").length>1) {
										sValue=name.split("!")[1];
									}
									s+=sValue+"";
								}
								else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("between") && val>=Double.parseDouble(name.split("=")[1].split(":")[1]) && val<Double.parseDouble(name.split("=")[1].split(":")[2])) {
									if(name.split("!").length>1) {
										sValue=name.split("!")[1];
									}
									s+=sValue+"";
								}
								else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("morethan") && val>Double.parseDouble(name.split("=")[1].split(":")[1])) {
									if(name.split("!").length>1) {
										sValue=name.split("!")[1];
									}
									s+=sValue+"";
								}
								else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("morethanorequals") && val>=Double.parseDouble(name.split("=")[1].split(":")[1])) {
									if(name.split("!").length>1) {
										sValue=name.split("!")[1];
									}
									s=sValue+"";
								}
								else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("equals") && val==Double.parseDouble(name.split("=")[1].split(":")[1])) {
									if(name.split("!").length>1) {
										sValue=name.split("!")[1];
									}
									s=sValue+"";
								}
								else if(name.split("=")[1].split(":")[0].equalsIgnoreCase("notequals") && val!=Double.parseDouble(name.split("=")[1].split(":")[1])) {
									if(name.split("!").length>1) {
										sValue=name.split("!")[1];
									}
									s=sValue+"";
								}
							}
						}
					}
					catch(Exception e) {
						e.printStackTrace();
					}
				}
			}
		}
		/*******************************
		 * Encounter
		 *******************************/
		else if(source.startsWith("encounter") && encounter!=null){
			if(name.equalsIgnoreCase("begin") && encounter.getBegin()!=null){
				s=ScreenHelper.formatDate(encounter.getBegin());
			}
			else if(name.equalsIgnoreCase("end") && encounter.getEnd()!=null){
				s=ScreenHelper.formatDate(encounter.getEnd());
			}
			else if(name.equalsIgnoreCase("duration") && encounter.getBegin()!=null && encounter.getEnd()!=null){
				long day = 24*3600*1000;
				java.util.Date start = ScreenHelper.parseDate(ScreenHelper.formatDate(encounter.getBegin()));
				java.util.Date stop = ScreenHelper.parseDate(ScreenHelper.formatDate(encounter.getEnd()));
				s=((stop.getTime()-start.getTime())/day+1)+"";
			}
			else if(name.equalsIgnoreCase("origin")){
				s=ScreenHelper.checkString(encounter.getOrigin());
			}
			else if(name.equalsIgnoreCase("escort")){
				s=ScreenHelper.checkString(encounter.getEscortName());
			}
			else if(name.equalsIgnoreCase("type")){
				s=ScreenHelper.checkString(encounter.getType());
			}
			else if(name.equalsIgnoreCase("id")){
				s=ScreenHelper.checkString(encounter.getUid());
			}
			else if(name.equalsIgnoreCase("situation")){
				s=ScreenHelper.checkString(encounter.getSituation());
			}
			else if(name.equalsIgnoreCase("service")){
				s=ScreenHelper.checkString(encounter.getServiceUID(transaction.getUpdateDateTime()));
			}
			else if(name.equalsIgnoreCase("outcome")){
				s=ScreenHelper.checkString(encounter.getOutcome());
			}
			else if(name.equalsIgnoreCase("reasonsforencounter")){
				Collection rfes = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounter.getUid());
				Iterator iRfes = rfes.iterator();
				while(iRfes.hasNext()){
					ReasonForEncounter rfe =(ReasonForEncounter)iRfes.next();
					if(s.length()>0){
						s+=", ";
					}
					if(rfe.getCodeType().equalsIgnoreCase("icd10")) {
						s+=rfe.getCode()+" "+MedwanQuery.getInstance().getCodeTran("icd10code"+rfe.getCode(), sWebLanguage);
					}
					else if(rfe.getCodeType().equalsIgnoreCase("icpc")) {
						s+=rfe.getCode()+" "+MedwanQuery.getInstance().getCodeTran("ICPCCode"+rfe.getCode(), sWebLanguage);
					}
				}
			}
		}
		/*******************************
		 * Treatment
		 *******************************/
		else if(source.startsWith("treatment") && encounter!=null){
			Vector prescriptions = Prescription.find(encounter);
			for(int n=0;n<prescriptions.size();n++) {
				if(s.length()>0) {
					s+="{sep}";
				}s+="["+(n+1)+"] ";
				Prescription prescription= (Prescription)prescriptions.elementAt(n);
				if(name.equalsIgnoreCase("drugs")) {
					s+=prescription.getProduct().getName();
				}
				else if(name.equalsIgnoreCase("unit")) {
					s+=ScreenHelper.getTranNoLink("product.unit",prescription.getProduct().getUnit(),sWebLanguage);
				}
				else if(name.equalsIgnoreCase("prescription")) {
					s+=prescription.getUnitsPerTimeUnit()+"/"+prescription.getTimeUnitCount()+" "+ScreenHelper.getTranNoLink("prescription.timeunit",prescription.getTimeUnit(),sWebLanguage);
				}
				else if(name.equalsIgnoreCase("duration")) {
					s+=(1+Math.ceil((prescription.getEnd().getTime()-prescription.getBegin().getTime())/ScreenHelper.getTimeDay()))+ScreenHelper.getTranNoLink("register","d",sWebLanguage);
				}
				else if(name.equalsIgnoreCase("delivered")) {
					s+=prescription.getDeliveredQuantity();
				}
			}
		}
		/*******************************
		 * Financial
		 *******************************/
		else if(source.startsWith("financial") && encounter!=null){
			if(name.equalsIgnoreCase("insurer")) {
				Insurance insurance = Insurance.getDefaultInsuranceForPatient(encounter.getPatientUID());
				if(insurance!=null) {
					s=insurance.getInsurar().getName();
				}
			}
			else if(name.startsWith("activeinsurancenumber")) {
				if(name.split(":").length<2) {
					Insurance insurance = Insurance.getDefaultInsuranceForPatient(encounter.getPatientUID());
					if(insurance!=null) {
						s=insurance.getInsuranceNr();
					}
				}
				else {
					Vector activeinsurances = Insurance.getCurrentInsurances(encounter.getPatientUID());
					for(int n=0;n<activeinsurances.size();n++){
						Insurance insurance = (Insurance)activeinsurances.elementAt(n);
						if(insurance.getInsurarUid().equalsIgnoreCase(SH.cs("insurerUid."+name.split(":")[1],""))) {
							s=insurance.getInsuranceNr();
							break;
						}
					}
				}
			}
			else if(name.startsWith("invoicenumber")) {
				Vector<PatientInvoice> invoices = PatientInvoice.searchInvoices(SH.formatDate(transaction.getUpdateTime()), "", encounter.getPatientUID(), "");
				for(int n=0;n<invoices.size();n++) {
					PatientInvoice invoice = invoices.elementAt(n);
					if(s.length()>0) {
						s+=",";
					}
					s+=invoice.getUid();
				}
			}
		}
		// le String s contient la valeur brute extraite de la source pour le paramètre "name"
		
		if(s.length()>0 && translateresult!=null && translateresult.length()>0){
			// Traduire la valeur brute
			if(translateresult.equalsIgnoreCase("{user}")) {
				s=User.getFullUserName(s);
			}
			else {
				String s2="",s3="";
				for(int n=0;n<s.split(",").length;n++) {
					if(s.split(",")[n].split("=").length>1) {
						s2=s.split(",")[n].split("=")[1]+" x "+ScreenHelper.getTranNoLink(translateresult.split("\\$")[0], s.split(",")[n].split("=")[0], sWebLanguage);
					}
					else { 
						s2=ScreenHelper.getTranNoLink(translateresult.split("\\$")[0], s.split(",")[n], sWebLanguage);
						if(translateresult.split("\\$")[0].split("=").length>1) {
							s2=ScreenHelper.getTranNoLink(translateresult.split("\\$")[0].split("=")[1].split("\\|")[0], translateresult.split("\\$")[0].split("=")[1].split("\\|")[1], sWebLanguage)+": "+ScreenHelper.getTranNoLink(translateresult.split("\\$")[0].split("=")[0], s.split(",")[n], sWebLanguage);
						}
					}
					if(s2.length()>0) {
						if(s3.length()>0) {
							s3+="{sep}";
						}
						s3+=s2;
					}
				}
				s=s3;
			}
		}
		if(translateresult!=null && s.length()>0){
			if(translateresult.split("\\$").length>1) {
				// Mettre un préfixe devant la valeur traduite
				String prefix = translateresult.split("\\$")[1];
				if(prefix.contains("|")) {
					prefix=ScreenHelper.getTranNoLink(prefix.split("\\|")[0],prefix.split("\\|")[1] , sWebLanguage);
				}
				s=prefix+s;
			}
			if(translateresult.split("\\$").length>2) {
				// Mettre un suffixe derrière la valeur traduite
				String suffix = translateresult.split("\\$")[2];
				if(suffix.contains("|")) {
					suffix=ScreenHelper.getTranNoLink(suffix.split("\\|")[0],suffix.split("\\|")[1] , sWebLanguage);
				}
				s=s+suffix;
			}
		}

		return s;
	}
	
	private String findLastItem(TransactionVO tran,String itemtype) {
		String sValue="";
		Connection conn = SH.getOpenClinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select i.value from items i,transactions t where i.transactionid=t.transactionid and t.transactiontype=? and i.type=? and t.healthrecordid=? and t.updatetime<=? order by t.updatetime desc");
			ps.setString(1, tran.getTransactionType());
			ps.setString(2, itemtype);
			ps.setInt(3,MedwanQuery.getInstance().getHealthRecordIdFromPersonId(Integer.parseInt(patient.personid)));
			ps.setTimestamp(4, SH.getSQLTimestamp(tran.getUpdateTime()));
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				sValue=rs.getString("value");
			}
			rs.close();		
			ps.close();
			conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return sValue;
	}
}
