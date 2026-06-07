package ocdhis2.plugins;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Vector;

import org.dom4j.Element;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.system.Debug;
import be.openclinic.system.SH;
import ocdhis2.DHIS2Plugin;

public class ActiveFamilyPlanningSenegal extends DHIS2Plugin {
	public boolean inArray(String sValue,String sArray){
		return inArray(sValue,sArray,"\\|");
	}
	
	public boolean inArray(String sValue,String sArray,String separator){
		String[] items = sArray.split(separator);
		for(int n=0;n<items.length;n++){
			if(items[n].contains("{like}")) {
				if(sValue.contains(items[n].replaceAll("\\{like\\}", ""))) {
					return true;
				}
			}
			else if(items[n].contains("{notlike}")) {
				if(!sValue.contains(items[n].replaceAll("\\{notlike\\}", ""))) {
					return true;
				}
			}
			else {
				if(sValue.equals(items[n])){
					return true;
				}
			}
		}
		return false;
	}

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		Connection conn=null;
		Vector items = new Vector();
		HashSet uniquepatients = new HashSet();
		try {
			// Find all patients with a registered family planning record in the selected period
			conn = SH.getOpenClinicConnection();
			String sql = 	"select a.personid,a.gender,a.dateofbirth,t.updatetime, t.serverid,t.transactionid "+
							" from adminview a, healthrecord h, transactions t where"+
							" a.personid = h.personid and"+
							" h.healthrecordid = t.healthrecordid and"+
							" t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSAS_REGISTRY_FAMILYPLANNING' and "+
							" t.updatetime>=? and"+
							" t.updatetime<?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setDate(1, SH.toSQLDate(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("familyPlanningToleranceTimeInDays", 730))));
			ps.setDate(2, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				String personid = rs.getString("personid");
				if(!uniquepatients.contains(personid)) {
					String gender = rs.getString("gender");
					String dateofbirth = SH.formatDate(rs.getDate("dateofbirth"));
					String date = new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("updatetime"));
					String department = "";
					String itemid = rs.getString("transactionid");
					//Now we launch the Senegalese algorithm on this transaction
					TransactionVO transaction = TransactionVO.get(rs.getInt("serverid"), rs.getInt("transactionid"));
					//First find the date of the next appointment
					//First match the extra parameters
					boolean bOk=true;
					if(pluginParameters!=null) {
						Enumeration<String> keys = pluginParameters.keys();
						while(keys.hasMoreElements()){
							String key = keys.nextElement();
							String array=(String)pluginParameters.get(key);
							String value=transaction.getItemValue(key);
							SH.syslog("key="+key);
							SH.syslog("array="+array);
							SH.syslog("value="+value);
							if(!inArray(value, array)) {
								bOk=false;
								break;
							}
						}
					}
					if(!bOk) {
						continue;
					}
					Date appointment = SH.parseDate(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_NEXTAPPOINTMENT"));
					if(appointment==null) {
						appointment=transaction.getUpdateTime();
					}
					if(true) {
						//This is an active patient, now get the type of family planning
						// 1 	= Pilules - PP 
						// 2	= Pilules - POP 
						// 3	= Injection - IM 
						// 4	= Injection - SC prestataire
						// 5	= Injection - SC autoinjection
						// 6	= DIU
						// 7	= Implants - 1 capsule
						// 8	= Implants - 2 capsules
						// 9	= Préservatifs - masculin
						// 10	= Préservatifs - féminin
						// 11	= Méthodes naturelles - MAMA
						// 12	= Méthodes naturelles - jour fixe/collier
						// 13	= Méthodes naturelles - MAO
						// 14	= Méthodes naturelles - autres
						// 15	= Anneau vaginal
						
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_CONTRACEPTICEPILL").equalsIgnoreCase("1;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";1;"+date+";"+department+";"+itemid+".1");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_CONTRACEPTICEPILL").equalsIgnoreCase("2;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";2;"+date+";"+department+";"+itemid+".2");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_INJECTION").equalsIgnoreCase("1;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("longFPMethodGracePeriod", 730)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";3;"+date+";"+department+";"+itemid+".3");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_INJECTION").equalsIgnoreCase("2;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("longFPMethodGracePeriod", 730)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";4;"+date+";"+department+";"+itemid+".4");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_INJECTION").equalsIgnoreCase("3;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("longFPMethodGracePeriod", 730)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";5;"+date+";"+department+";"+itemid+".5");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_DIU").length()>0 && "2;3;4;".contains(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_DIU"))){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("longFPMethodGracePeriod", 730)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";6;"+date+";"+department+";"+itemid+".6");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_IMPLANT").equalsIgnoreCase("1;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("longFPMethodGracePeriod", 730)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";7;"+date+";"+department+";"+itemid+".7");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_IMPLANT").equalsIgnoreCase("2;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("longFPMethodGracePeriod", 730)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";8;"+date+";"+department+";"+itemid+".8");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_OTHERMETHODS").contains("2;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";9;"+date+";"+department+";"+itemid+".9");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_OTHERMETHODS").contains("3;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";10;"+date+";"+department+";"+itemid+".10");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_NATURALMETHOD").contains("1;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";11;"+date+";"+department+";"+itemid+".11");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_NATURALMETHOD").contains("2;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";12;"+date+";"+department+";"+itemid+".12");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_NATURALMETHOD").contains("3;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";13;"+date+";"+department+";"+itemid+".13");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_NATURALMETHOD").contains("4;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";14;"+date+";"+department+";"+itemid+".14");
								uniquepatients.add(personid);
							}
						}
						if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FP_NATURALMETHOD").contains("1;")){
							if(!appointment.before(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("shortFPMethodGracePeriod", 30)))) {
								items.add(personid+";"+gender+";"+dateofbirth+";15;"+date+";"+department+";"+itemid+".15");
								uniquepatients.add(personid);
							}
						}
					}
				}
			}
			rs.close();
			ps.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		finally {
			try {
				if(conn!=null) conn.close();
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}
		SH.syslog("DeliveriesSenegal plugin returned "+items.size()+" items");
		for(int n=0;n<items.size();n++) {
			SH.syslog(n+": "+items.elementAt(n));
		}
		return items;
	}

	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		// TODO Auto-generated method stub
		return null;
	}

}
