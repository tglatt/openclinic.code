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

public class SendStockMovementsToOBR {
	
	
	public static void main(String[] args) throws SQLException {
		
		//Préparation des paramètres pour se connecter aux bases de données
		String processid=ManagementFactory.getRuntimeMXBean().getName();
		System.out.println(processid+" - Loading primrose configuration "+args[0]);
		try {
			PrimroseLoader.load(args[0], true);
			System.out.println(processid+" - Primrose loaded");
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
		
		java.util.Date begin = new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*5);
		java.util.Date lastSync = new java.util.Date(Long.parseLong(SH.cs("lastOBRStockSync", "0")));
		if(lastSync.after(begin)) {
			begin=lastSync;
		}
		
		//execute facture simple///
		ExecuteOperation( begin);
		
		
	}
	
	
	public static void ExecuteOperation(java.util.Date begin) throws SQLException {
		
		System.out.println("Begin : " + begin.toString());

		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = null;
		String selectionstring = "";
		
		if(SH.cs("setup.database","").equalsIgnoreCase("sqlserver")){
			
			selectionstring = " SELECT oc_operation_serverid, oc_operation_objectid, oc_operation_updatetime FROM oc_productstockoperations "
					+ " WHERE oc_operation_updatetime > ? "
					+ " and not exists (select * from oc_pointers where oc_pointer_key=  "
					+ " CONCAT('OBR.STOCKOP.',oc_operation_serverid,'.',oc_operation_objectid))  "
					+ " order by oc_operation_updatetime;";
		}
		else if(SH.cs("setup.database","").equalsIgnoreCase("mysql")) {
			
			selectionstring = " SELECT oc_operation_serverid, oc_operation_objectid, oc_operation_updatetime FROM oc_productstockoperations "
					+ " WHERE oc_operation_updatetime > ? "
					+ " and not exists (select * from oc_pointers where oc_pointer_key=  "
					+ " CONCAT('OBR.STOCKOP.',oc_operation_serverid,'.',oc_operation_objectid))  "
					+ " order by oc_operation_updatetime;";
		
		}
		
		ps = conn.prepareStatement(selectionstring);
		ps.setDate(1, new java.sql.Date(begin.getTime()));
		
		ResultSet rs = ps.executeQuery();
		
		System.out.println("Result : " + rs.getFetchSize());
		
		while(rs.next()) {
			String uid = rs.getString("oc_operation_serverid")+"."+
						 rs.getString("oc_operation_objectid");
			JsonObject jsonresult = OBR.addStockMovement(uid, false);
			
			System.out.println("Response : " + jsonresult.toString());
			
			if(jsonresult.getBoolean("success")) {
				System.out.println("Invoice "+uid+" succesfully sent to OBR");
				Pointer.storePointer("OBR.STOCKOP."+uid, "");	
			}
			else {
				System.out.println("Operation "+uid+" not sent to OBR");
				System.out.println(" --> "+jsonresult.getString("msg"));
				if(jsonresult.getString("msg").equalsIgnoreCase("Une facture avec le même numéro existe déjà.")) {
					Pointer.storePointer("OBR.STOCKOP."+uid, "");
					Pointer.storePointer("OBR.STOCKOP.ERROR."+uid, "");			
				}
			}
			MedwanQuery.getInstance().setConfigString("lastOBRStockSync", ""+rs.getTimestamp("oc_patientinvoice_updatetime").getTime());
		}
		
		rs.close();
		ps.close();
		conn.close();
		System.exit(0);
	}

}
