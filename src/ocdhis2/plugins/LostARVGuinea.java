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

public class LostARVGuinea extends DHIS2Plugin {
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
							" t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSHP_HIVSCREENING' and "+
							" t.updatetime<? and t.updatetime>=? and not exists (select * from transactions tt where tt.healthrecordid=t.healthrecordid and"+
							" tt.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSHP_HIVSCREENING' and"+
							" tt.updatetime>=?)";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setDate(1, SH.toSQLDate(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("ARVToleranceTimeInDays", 120))));
			ps.setDate(2, SH.toSQLDate(new java.util.Date(begin.getTime()-SH.getTimeDay()*(SH.ci("ARVToleranceTimeInDays", 120)+31))));
			ps.setDate(3, SH.toSQLDate(new java.util.Date(begin.getTime()-SH.getTimeDay()*SH.ci("ARVToleranceTimeInDays", 120))));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				String personid = rs.getString("personid");
				if(!uniquepatients.contains(personid)) {
					String gender = rs.getString("gender");
					String dateofbirth = SH.formatDate(rs.getDate("dateofbirth"));
					String date = new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("updatetime"));
					String department = "";
					String itemid = rs.getString("transactionid");
					//Now we launch the Guinea algorithm on this transaction
					TransactionVO transaction = TransactionVO.get(rs.getInt("serverid"), rs.getInt("transactionid"));
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
					items.add(personid+";"+gender+";"+dateofbirth+";1;"+date+";"+department+";"+itemid+".1");
					uniquepatients.add(personid);
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
		SH.syslog("ARVLostGuinea plugin returned "+items.size()+" items");
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
