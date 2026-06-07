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

public class HepBSenegal extends DHIS2Plugin {
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
		HashSet uniqueencounters = new HashSet();
		try {
			// First we find all regular vaccinations
			conn = SH.getOpenClinicConnection();
			String sql = 	"select a.personid,a.gender,a.dateofbirth,t.updatetime, t.serverid,t.transactionid "+
							" from adminview a, healthrecord h, transactions t, items i where"+
							" a.personid = h.personid and"+
							" h.healthrecordid = t.healthrecordid and"+
							" t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSAS_REGISTRY_HEALTHYCHILDREN' and "+
							" t.serverid=i.serverid and"+
							" t.transactionid=i.transactionid and"+
							" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINE_HEPB' and"+
							" i.value='1' and"+
							" t.updatetime>=? and"+
							" t.updatetime<?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				String personid = rs.getString("personid");
				String gender = rs.getString("gender");
				String dateofbirth = SH.formatDate(rs.getDate("dateofbirth"));
				String date = new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("updatetime"));
				String department = "";
				String itemid = rs.getString("transactionid");
				TransactionVO transaction = TransactionVO.get(rs.getInt("serverid"), rs.getInt("transactionid"));
				String encounteruid = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
				if(!uniqueencounters.contains(encounteruid)) {
					//First match the extra parameters
					boolean bOk=true;
					if(pluginParameters!=null) {
						Enumeration<String> keys = pluginParameters.keys();
						while(keys.hasMoreElements()){
							String key = keys.nextElement();
							String array=(String)pluginParameters.get(key);
							String value=transaction.getItemValue(key);
							if(!inArray(value, array)) {
								bOk=false;
								break;
							}
						}
					}
					if(!bOk) {
						continue;
					}
					items.add(personid+";"+gender+";"+dateofbirth+";1;"+date+";"+department+";"+encounteruid);
				}
			}
			rs.close();
			ps.close();
			// Then we find all vaccinations with deliveries
			conn = SH.getOpenClinicConnection();
			sql = 	"select a.personid,a.gender,a.dateofbirth,t.updatetime, t.serverid,t.transactionid,i.itemid,i.type "+
							" from adminview a, healthrecord h, transactions t, items i where"+
							" a.personid = h.personid and"+
							" h.healthrecordid = t.healthrecordid and"+
							" t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSAS_REGISTRY_DELIVERIES' and "+
							" t.serverid=i.serverid and"+
							" t.transactionid=i.transactionid and"+
							" i.type like 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED%' and"+
							" i.value like '1;%' and"+
							" t.updatetime>=? and"+
							" t.updatetime<?";
			ps = conn.prepareStatement(sql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			rs = ps.executeQuery();
			while(rs.next()) {
				String personid = rs.getString("personid");
				String gender = rs.getString("gender");
				String dateofbirth = SH.formatDate(rs.getDate("dateofbirth"));
				String date = new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("updatetime"));
				String department = "";
				String itemid = rs.getString("itemid");
				String itemtype=rs.getString("type");
				TransactionVO transaction = TransactionVO.get(rs.getInt("serverid"), rs.getInt("transactionid"));
				String encounteruid = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
				//First match the extra parameters
				boolean bOk=true;
				if(pluginParameters!=null) {
					Enumeration<String> keys = pluginParameters.keys();
					while(keys.hasMoreElements()){
						String key = keys.nextElement();
						String array=(String)pluginParameters.get(key);
						String value=transaction.getItemValue(key);
						if(!inArray(value, array)) {
							bOk=false;
							break;
						}
					}
				}
				if(!bOk) {
					continue;
				}
				if(itemtype.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED")) {
					items.add(personid+";"+transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER")+";"+SH.formatDate(transaction.getUpdateTime())+";1;"+date+";"+department+";"+itemid);
				}
				else if(itemtype.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED_2")) {
					items.add(personid+";"+transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER_2")+";"+SH.formatDate(transaction.getUpdateTime())+";1;"+date+";"+department+";"+itemid);
				}
				else if(itemtype.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED_3")) {
					items.add(personid+";"+transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER_3")+";"+SH.formatDate(transaction.getUpdateTime())+";1;"+date+";"+department+";"+itemid);
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
		SH.syslog("HepBSenegal plugin returned "+items.size()+" items");
		return items;
	}

	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		// TODO Auto-generated method stub
		return null;
	}

}
