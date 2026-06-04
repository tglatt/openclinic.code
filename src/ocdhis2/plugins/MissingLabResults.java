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

public class MissingLabResults extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		Connection conn=null;
		Vector items = new Vector();
		HashSet uniquepatients = new HashSet();
		try {
			// Find all patients with a lab request without results in the selected period
			conn = SH.getOpenClinicConnection();
			String sql = 	"select a.personid,a.gender,a.dateofbirth,t.updatetime,t.transactionid from transactions t,healthrecord h,adminview a where"+
							" h.healthrecordid=t.healthrecordid and"+
							" h.personid=a.personid and"+
							" t.transactiontype='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST' and"+
							" t.updatetime>=? and"+
							" t.updatetime<? and"+
							" not exists (select * from requestedlabanalyses r where "+
							" r.serverid=t.serverid and"+
							" r.transactionid=t.transactionid and"+
							" r.finalvalidationdatetime is not null) and"+
							" exists (select * from requestedlabanalyses r where "+
							" r.serverid=t.serverid and"+
							" r.transactionid=t.transactionid)";
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
		Debug.println("MissingLabResults plugin returned "+items.size()+" items");
		return items;
	}

	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		// TODO Auto-generated method stub
		return null;
	}

}
