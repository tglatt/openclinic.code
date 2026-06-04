package ocdhis2.plugins;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Vector;

import org.dom4j.Element;

import be.mxs.common.util.system.Debug;
import be.openclinic.system.SH;
import ocdhis2.DHIS2Plugin;

public class Abortions extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		Connection conn=null;
		Vector items = new Vector();
		HashSet uniquepatients = new HashSet();
		try {
			// Find all patients with a registered abortion in the selected period
			// First we find all Delivery transactions with a registered abortion
			conn = SH.getOpenClinicConnection();
			String sql = 	"select a.personid,a.gender,a.dateofbirth,t.updatetime, t.transactionid "+
							" from adminview a, healthrecord h, transactions t, items i where"+
							" a.personid = h.personid and"+
							" h.healthrecordid = t.healthrecordid and"+
							" t.transactionid = i.transactionid and"+
							" t.serverid = i.serverid and"+
							" t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DELIVERY_MSPLS' and "+
							" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ABORTION' and"+
							" i.value='medwan.common.true' and"+
							" t.updatetime>=? and"+
							" t.updatetime<?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				String personid = rs.getString("personid");
				if(!uniquepatients.contains(personid)) {
					String gender = rs.getString("gender");
					String dateofbirth = SH.formatDate(rs.getDate("dateofbirth"));
					String value = "1";
					String date = new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("updatetime"));
					String department = "";
					String itemid = rs.getString("transactionid");
					items.add(personid+";"+gender+";"+dateofbirth+";"+value+";"+date+";"+department+";"+itemid);
					uniquepatients.add(personid);
				}
			}
			rs.close();
			ps.close();
			// Now we add all patients that have an abortion related ICD-10 diagnosis in the same period
			sql = 	"select a.personid,a.gender,a.dateofbirth,d.oc_diagnosis_date,d.oc_diagnosis_objectid "+
					" from oc_diagnoses d, oc_encounters e, adminview a where "+
					" d.oc_diagnosis_date >= ? and"+
					" d.oc_diagnosis_date < ? and"+
					" e.oc_encounter_objectid = replace(oc_diagnosis_encounteruid,'"+SH.getServerId()+".','') and"+
					" a.personid = e.oc_encounter_patientuid and"+
					" oc_diagnosis_codetype='icd10' and"+
					" (oc_diagnosis_code = 'N96' or"+
					" oc_diagnosis_code like 'O03%' or"+
					" oc_diagnosis_code like 'O04%' or"+
					" oc_diagnosis_code like 'O05%' or"+
					" oc_diagnosis_code like 'O06%')";
			ps=conn.prepareStatement(sql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			rs = ps.executeQuery();
			while(rs.next()) {
				String personid = rs.getString("personid");
				if(!uniquepatients.contains(personid)) {
					String gender = rs.getString("gender");
					String dateofbirth = SH.formatDate(rs.getDate("dateofbirth"));
					String value = "1";
					String date = new SimpleDateFormat("yyyyMMddHHmm").format(rs.getTimestamp("oc_diagnosis_date"));
					String department = "";
					String itemid = rs.getString("oc_diagnosis_objectid");
					items.add(personid+";"+gender+";"+dateofbirth+";"+value+";"+date+";"+department+";"+itemid);
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
		Debug.println("Abortions plugin returned "+items.size()+" items");
		return items;
	}

	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		// TODO Auto-generated method stub
		return null;
	}

}
