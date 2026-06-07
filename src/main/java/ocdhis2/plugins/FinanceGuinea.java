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
import net.admin.AdminPerson;
import ocdhis2.DHIS2Plugin;

public class FinanceGuinea extends DHIS2Plugin {
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
		return null;
	}

	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		Connection conn=null;
		Vector items = new Vector();
		HashSet uniquepatients = new HashSet();
		if(SH.c((String)pluginParameters.get("extended")).equalsIgnoreCase("1")){
			try {
				// Find all patient payments in the period, ventilate by costcenter
				conn = SH.getOpenClinicConnection();
				String sql = "SELECT SUM(oc_debet_amount) patient,SUM(oc_debet_insuraramount+oc_debet_extrainsuraramount) insurer,o.oc_prestation_dhis2code FROM oc_debets d,oc_patientinvoices p,oc_prestations o WHERE"+
								" p.oc_patientinvoice_status='closed' AND"+
								" p.oc_patientinvoice_objectid=REPLACE(oc_debet_patientinvoiceuid,'1.','') and"+
								" o.oc_prestation_objectid=REPLACE(oc_debet_prestationuid,'1.','') and"+
								" oc_debet_date>=? and"+
								" oc_debet_date<? group by o.oc_prestation_dhis2code";
				PreparedStatement ps = conn.prepareStatement(sql);
				ps.setDate(1, SH.toSQLDate(begin));
				ps.setDate(2, SH.toSQLDate(end));
				ResultSet rs = ps.executeQuery();
				int op=0,oi=0;
				while(rs.next()) {
					if(SH.c(rs.getString("oc_prestation_dhis2code")).length()==0 || SH.c(rs.getString("oc_prestation_dhis2code")).equalsIgnoreCase("gn7")) {
						op+=rs.getInt("patient");
						oi+=rs.getInt("insurer");
					}
					else {
						items.add(rs.getInt("patient")+";0;0;1"+rs.getString("oc_prestation_dhis2code"));
						items.add(rs.getInt("insurer")+";0;0;2"+rs.getString("oc_prestation_dhis2code"));
					}
				}
				items.add(op+";0;0;1gn7");
				items.add(oi+";0;0;2gn7");
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
		}
		else {
			try {
				// Find all patient payments in the period
				conn = SH.getOpenClinicConnection();
				String sql = 	"SELECT SUM(oc_wicket_credit_amount) total FROM oc_wicket_credits WHERE oc_wicket_credit_type='patient.payment' and"+
								" oc_wicket_credit_operationdate>=? and"+
								" oc_wicket_credit_operationdate<?";
				PreparedStatement ps = conn.prepareStatement(sql);
				ps.setDate(1, SH.toSQLDate(begin));
				ps.setDate(2, SH.toSQLDate(end));
				ResultSet rs = ps.executeQuery();
				if(rs.next()) {
					items.add(rs.getInt("total")+";0;0;1");			}
				rs.close();
				ps.close();
				// Find all insurer debt in the period
				sql = 	"SELECT SUM(oc_debet_insuraramount+oc_debet_extrainsuraramount) total FROM oc_debets d,oc_patientinvoices p WHERE"+
								" p.oc_patientinvoice_status='closed' AND"+
								" p.oc_patientinvoice_objectid=REPLACE(oc_debet_patientinvoiceuid,'1.','') and"+
								" oc_debet_date>=? and"+
								" oc_debet_date<?";
				ps = conn.prepareStatement(sql);
				ps.setDate(1, SH.toSQLDate(begin));
				ps.setDate(2, SH.toSQLDate(end));
				rs = ps.executeQuery();
				if(rs.next()) {
					items.add(rs.getInt("total")+";0;0;2");
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
		}
		SH.syslog("FinanceGuinea plugin returned "+items.size()+" items");
		for(int n=0;n<items.size();n++) {
			SH.syslog(n+": "+items.elementAt(n));
		}
		return items;	
	}
}
