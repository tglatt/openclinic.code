package be.mxs.common.util.io;

import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.json.JsonObject;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Pointer;
import be.openclinic.system.SH;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class SendInvoicesToOBR {
	
	static Boolean facture_simple =  true; 
	
	public static void main(String[] args) throws SQLException {
		
		//Préparation des paramètres pour se connecter aux bases de données
		String processid=ManagementFactory.getRuntimeMXBean().getName();
		System.out.println(processid+" - Loading primrose configuration "+args[0]);
		try {
			PrimroseLoader.load(args[0], true);
			System.out.println(processid+" - Primrose loaded");
		      facture_simple =  Boolean.parseBoolean(args[1]); 
		}
		catch(Exception e) {
			System.out.println(processid+" - Error - Closing system");
			System.exit(0);
		}
		try {
			MedwanQuery.getInstance(false);
			System.out.println(processid+" - MedwanQuery loaded");
		}
		catch(Exception e) {
			System.out.println(processid+" - Error - Closing system");
			System.exit(0);
		}
		
		java.util.Date begin = new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay() * 
				Integer.parseInt(SH.cs("ObrCountDaysBeforeNow", "5")));
		java.util.Date lastSync = new java.util.Date(Long.parseLong(SH.cs("lastOBRSync", "0")));
		if(lastSync.after(begin)) {
			begin=lastSync;
		}
		
		//execute facture simple///
		ExecuteOperation(begin);
		if(MedwanQuery.getInstance().getConfigInt("enableObrSendAfterSignature")==1) {
			ExecuteOperation(begin);
	     }
		System.exit(0);

	}
	
	
	public static void ExecuteOperation(java.util.Date begin) {
		Connection conn = SH.getOpenClinicConnection();
		
		try {
			System.out.println("Begin : " + begin.toString());
			System.out.println("Type de facture : " + facture_simple);
			System.out.println("Envoie apres verrification : " + MedwanQuery.getInstance().getConfigInt("enableObrSendAfterSignature",0));
		
	
			PreparedStatement ps = null;
			 String selectionstring = "";
			if(SH.cs("setup.database","").equalsIgnoreCase("sqlserver")){
			   selectionstring = " select top 150 * from oc_patientinvoices "
				 		+ " where oc_patientinvoice_status='closed' and "
				 		+ " oc_patientinvoice_updatetime > ? and "
				 		+ " not exists (select * from oc_pointers where oc_pointer_key="
				 		+ " CONCAT('OBR.INV.',oc_patientinvoice_serverid,'.',oc_patientinvoice_objectid)) "
				 		+ " order by oc_patientinvoice_updatetime;";
				
			if(MedwanQuery.getInstance().getConfigInt("enableObrSendAfterSignature",0)==1) {
				selectionstring = " select top 100 * from oc_patientinvoices inv, oc_pointers pointer  "
						+ " where oc_patientinvoice_status='closed'  "
						+ " AND pointer.OC_POINTER_KEY = CONCAT('INVSERVSIGN.',inv.oc_patientinvoice_serverid,'.',inv.oc_patientinvoice_objectid) "
						+ " AND COALESCE(pointer.OC_POINTER_UPDATETIME,'2023-08-01') >  ? "
						+ " and not exists (select * from oc_pointers where oc_pointer_key=CONCAT('OBR.INV.',inv.oc_patientinvoice_serverid,'.',inv.oc_patientinvoice_objectid)) "
						+ " order by oc_patientinvoice_updatetime DESC;";
			     if(!facture_simple) {
			    	 selectionstring = " SELECT top 100 oc_pa.oc_patientinvoice_serverid, oc_pa.oc_patientinvoice_objectid, point.OC_POINTER_UPDATETIME  "
			    	 		+ " FROM oc_patientinvoices oc_pa, OC_SUMMARYINVOICES cons, OC_SUMMARYINVOICEITEMS lien, OC_POINTERS point "
			    	 		+ " WHERE  COALESCE(point.OC_POINTER_UPDATETIME,'2023-08-01')  > ? "
			    	 		+ " and lien.OC_ITEM_PATIENTINVOICEUID = concat( oc_pa.OC_PATIENTINVOICE_SERVERID ,'.' , oc_pa.OC_PATIENTINVOICE_OBJECTID ) "
			    	 		+ " and lien.OC_ITEM_SUMMARYINVOICEUID = concat( cons.OC_SUMMARYINVOICE_SERVERID , '.', cons.OC_SUMMARYINVOICE_OBJECTID ) "
			    	 		+ " AND oc_pointer_key  = CONCAT( 'SUMRESPINVSIGN.', cons.oc_summaryinvoice_serverid ,'.', cons.oc_summaryinvoice_objectid ) "
			    	 		+ " AND not exists (select * from oc_pointers where oc_pointer_key  = CONCAT('OBR.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid));";
			     }
			}
			ps = conn.prepareStatement(selectionstring);
			
			}
			else if(SH.cs("setup.database","").equalsIgnoreCase("mysql")) {
				
				  selectionstring = "select * from oc_patientinvoices "+
						" where oc_patientinvoice_status='closed' and "+
						" oc_patientinvoice_updatetime > ? and "+
						" not exists (select * from oc_pointers where oc_pointer_key="+
						" 'OBR.INV.'||oc_patientinvoice_serverid||'.'||oc_patientinvoice_objectid) order by oc_patientinvoice_updatetime limit 150" ;
			
				if(MedwanQuery.getInstance().getConfigInt("enableObrSendAfterSignature",0)==1) {
					selectionstring = " SELECT inv.* "
							+ " from oc_patientinvoices inv, oc_pointers pointer "
							+ " WHERE  pointer.oc_pointer_key = CONCAT('INVSERVSIGN.',inv.oc_patientinvoice_serverid,'.',inv.oc_patientinvoice_objectid) "
							+ " AND not exists (select * from oc_pointers WHERE oc_pointer_key = CONCAT('OBR.INV.',inv.oc_patientinvoice_serverid,'.',inv.oc_patientinvoice_objectid)) "
							+ " AND oc_patientinvoice_status='closed' "
							+ " AND pointer.oc_pointer_updatetime > ? "
							+ " order by oc_patientinvoice_updatetime DESC LIMIT 150; ";
				
				 if(!facture_simple) {
					selectionstring = " SELECT oc_pa.oc_patientinvoice_serverid, oc_pa.oc_patientinvoice_objectid, point.OC_POINTER_UPDATETIME  "
							+ " FROM oc_patientinvoices oc_pa, OC_SUMMARYINVOICES cons, OC_SUMMARYINVOICEITEMS lien, OC_POINTERS point "
							+ " WHERE  COALESCE(point.OC_POINTER_UPDATETIME,'2023-08-01') > ? "
							+ " and lien.OC_ITEM_PATIENTINVOICEUID = concat( oc_pa.OC_PATIENTINVOICE_SERVERID ,'.' , oc_pa.OC_PATIENTINVOICE_OBJECTID ) "
							+ " and lien.OC_ITEM_SUMMARYINVOICEUID = concat( cons.OC_SUMMARYINVOICE_SERVERID , '.', cons.OC_SUMMARYINVOICE_OBJECTID ) "
							+ " AND oc_pointer_key  = CONCAT( 'SUMRESPINVSIGN.', cons.oc_summaryinvoice_serverid ,'.', cons.oc_summaryinvoice_objectid ) "
							+ " AND not exists (select * from oc_pointers where oc_pointer_key  = CONCAT('OBR.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) "
							+ " LIMIT 100; ";		
				     }
				
				}
				ps = conn.prepareStatement(selectionstring);
			}
			
			ps.setDate(1, new java.sql.Date(begin.getTime()));
			
			ResultSet rs = ps.executeQuery();
			
			System.out.println("Result : " + rs.getRow());
			System.out.println("Request : " + selectionstring);
			
			while(rs.next()) {
				String uid = rs.getString("oc_patientinvoice_serverid")+"."+
							 rs.getString("oc_patientinvoice_objectid");
				JsonObject jsonresult = OBR.addPatientInvoiceGetJSONObject(uid, false);
				
				System.out.println("Response : " + jsonresult.toString());
				
				if(jsonresult.getBoolean("success")) {
					System.out.println("Invoice "+uid+" succesfully sent to OBR");
					Pointer.storePointer("OBR.INV."+uid, "");	
				}
				else {
					System.out.println("Invoice "+uid+" not sent to OBR");
					System.out.println(" --> "+jsonresult.getString("msg"));
					if(jsonresult.getString("msg").equalsIgnoreCase("Une facture avec le même numéro existe déjà.")) {
						Pointer.storePointer("OBR.INV."+uid, "");
						Pointer.storePointer("OBR.INV.ERROR."+uid, "");			
					}
				}
				if(!facture_simple) {
					MedwanQuery.getInstance().setConfigString("lastOBRSync", ""+rs.getTimestamp("OC_POINTER_UPDATETIME").getTime());
				}else {
					MedwanQuery.getInstance().setConfigString("lastOBRSync", ""+rs.getTimestamp("oc_patientinvoice_updatetime").getTime());	
				}
			}
			
			rs.close();
			ps.close();
		}
		catch(Exception e) {
			e.printStackTrace();;
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e1) {
				// TODO Auto-generated catch block
				e1.printStackTrace();
			}
		}
	}

}
