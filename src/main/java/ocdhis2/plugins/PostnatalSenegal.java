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

public class PostnatalSenegal extends DHIS2Plugin {
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
			// Find all patients with a registered delivery in the selected period
			// First we find all Delivery transactions
			conn = SH.getOpenClinicConnection();
			String sql = 	"select a.personid,a.gender,a.dateofbirth,t.updatetime, t.serverid,t.transactionid "+
							" from adminview a, healthrecord h, transactions t, items i where"+
							" a.personid = h.personid and"+
							" h.healthrecordid = t.healthrecordid and"+
							" t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSAS_REGISTRY_POSTNATAL' and "+
							" t.serverid=i.serverid and"+
							" t.transactionid=i.transactionid and"+
							" i.type like 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CPONORDER%' and"+
							" i.value like 'CPoN 3%' and"+
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
					//Now we check if the other CPoN sessions have been attended since the delivery date
					try {
						java.util.Date deliveryDate=SH.parseDate(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_DELIVERYDATE"));
						if(deliveryDate!=null) {
							String sql2 = 	"select count(*) total "+
									" from adminview a, healthrecord h, transactions t, items i where"+
									" a.personid = h.personid and"+
									" h.healthrecordid = t.healthrecordid and"+
									" t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSAS_REGISTRY_POSTNATAL' and "+
									" t.serverid=i.serverid and"+
									" t.transactionid=i.transactionid and"+
									" i.type like 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CPONORDER%' and"+
									" i.value like 'CPoN 2%' and"+
									" t.updatetime>=? and"+
									" t.updatetime<? and"+
									" a.personid=?";
							PreparedStatement ps2 = conn.prepareStatement(sql2);
							ps2.setDate(1, SH.toSQLDate(deliveryDate));
							ps2.setDate(2, SH.toSQLDate(transaction.getUpdateTime()));
							ps2.setInt(3, Integer.parseInt(personid));
							ResultSet rs2 = ps2.executeQuery();
							if(rs2.next() && rs2.getInt("total")>0) {
								rs2.close();
								ps2.close();
								sql2 = 	"select count(*) total "+
										" from adminview a, healthrecord h, transactions t, items i where"+
										" a.personid = h.personid and"+
										" h.healthrecordid = t.healthrecordid and"+
										" t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSAS_REGISTRY_POSTNATAL' and "+
										" t.serverid=i.serverid and"+
										" t.transactionid=i.transactionid and"+
										" i.type like 'be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CPONORDER%' and"+
										" i.value like 'CPoN 1%' and"+
										" t.updatetime>=? and"+
										" t.updatetime<? and"+
										" a.personid=?";
								ps2 = conn.prepareStatement(sql2);
								ps2.setDate(1, SH.toSQLDate(deliveryDate));
								ps2.setDate(2, SH.toSQLDate(transaction.getUpdateTime()));
								ps2.setInt(3, Integer.parseInt(personid));
								rs2 = ps2.executeQuery();
								if(rs2.next() && rs2.getInt("total")>0) {
									SH.syslog("0: "+personid+";"+gender+";"+dateofbirth+";1;"+date+";"+department+";"+encounteruid);
									items.add(personid+";"+gender+";"+dateofbirth+";1;"+date+";"+department+";"+encounteruid);
								}
							}
							rs2.close();
							ps2.close();
						}
					}
					catch(Exception t) {
						t.printStackTrace();
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
		SH.syslog("PostnatalSenegal plugin returned "+items.size()+" items");
		return items;
	}

	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		// TODO Auto-generated method stub
		return null;
	}

}
