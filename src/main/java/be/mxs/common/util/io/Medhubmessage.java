package be.mxs.common.util.io;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.Date;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class Medhubmessage {
	
	public static String countInvoiceMessages(String invoiceuid, String context) {
		Integer countMessages = 0;
	    PreparedStatement ps = null;
	    String response = "<a href='#' onclick='OpenDiscussion("+ invoiceuid +")'><img style='vertical-align: middle' src='"+context+"/_img/icons/icon_incoming.gif' /></a>";
        ResultSet rs = null;
        try {
        	
        String sSelect = "SELECT COUNT(*) FROM oc_medhubmessages WHERE oc_medhubmessage_invoice = ? ;";
        
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        ps = oc_conn.prepareStatement(sSelect);
		ps.setString(1, invoiceuid);
	
	    rs = ps.executeQuery();
	
	    rs.next();
	    countMessages = rs.getInt(1); 
	    
	    oc_conn.close();
	    ps.close();
		rs.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        response = response + " " + countMessages;
		return response;
	}
	
	
	public static String ListeMessage(String invoiceuid) throws SQLException {
	
		Integer countMessages = 0;
	    PreparedStatement ps = null;
	    String response = "";
        ResultSet rs = null;
        try {
        	
        String sSelect = "SELECT * FROM oc_medhubmessages WHERE oc_medhubmessage_invoice = ? ";
              sSelect += " ORDER BY oc_medhubmessageid DESC ;";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        ps = oc_conn.prepareStatement(sSelect);
		ps.setString(1, invoiceuid);
	
	    rs = ps.executeQuery();
	
	    response +="<table width='100%'>";
	     
		while(rs.next()) {	
			response += "<tr><td><div class='tit_message'>" + rs.getString("oc_medhubmessage_sender") + " - " + rs.getString("oc_medhubmessage_sender2");	
			response += " - "+rs.getString("oc_medhubmessage_date") +"</div></td></tr>";
			response += "<tr><td><div class='txt_message'>" + rs.getString("oc_medhubmessage_text") + "</div></td></tr>";
		  }
		response +="</table>";
	     
	    oc_conn.close();
		ps.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
        response = response + " " + countMessages;
		return response;
		
	}
	
	public static String insertInvoiceMessages(String invoiceuid
			,String message_sender, String message_sender2 ,String message_to, String oc_medhubmessage_text) throws SQLException{
	String rez_back = ""; 
	rez_back = "1";
	PreparedStatement ps = null;
 
      try {
      	
      String insert_message_request = "INSERT INTO oc_medhubmessages ";
      insert_message_request += " (oc_medhubmessageid,oc_medhubmessage_invoice, oc_medhubmessage_sender, oc_medhubmessage_sender2, oc_medhubmessage_to, oc_medhubmessage_date, oc_medhubmessage_text) ";
      insert_message_request += " VALUES ";
      insert_message_request += " (?,?,?,?,?,?,?) ;";
      
      Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
      ps = oc_conn.prepareStatement(insert_message_request);
      
      ps.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("oc_medhubmessageid"));
      ps.setString(2, invoiceuid);
      ps.setString(3, message_sender);
      ps.setString(4, message_sender2);
      ps.setString(5, message_to);
      ps.setTimestamp(6,new Timestamp(new java.util.Date().getTime()));
      ps.setString(7,oc_medhubmessage_text);
    
      ps.execute();
      ps.close();
      oc_conn.close();
      
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			rez_back = e.toString();
		}
		
		return rez_back;
	}
	
	public static String getCurrentHouse(String insuranceagent) {
		String  house = null;
		if(insuranceagent!=null&&insuranceagent!="") {
			house = insuranceagent;
		}else {
			house = "HMK";
		}
		return house;
	}
	
}
