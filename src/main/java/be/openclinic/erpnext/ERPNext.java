package be.openclinic.erpnext;

import java.sql.*;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Pointer;
import be.openclinic.finance.PatientInvoice;
import be.openclinic.system.SH;

public class ERPNext {
	public static String exportTodaysFinancials() {
		return exportFinancials(SH.beginOfDay(SH.getToday()), SH.beginOfDay(SH.getTomorrow()));
	}
	
	public static String exportYesterdaysFinancials() {
		return exportFinancials(SH.beginOfDay(SH.getYesterday()), SH.beginOfDay(SH.getToday()));
	}
	
	public static String exportLastMonthsFinancials() {
		return exportFinancials(SH.getPreviousMonthBegin(), SH.getBeginOfMonth());
	}
	
	public static String exportFinancials(Date begin, Date end) {
		String error="";
		boolean bOk=true;
		double totalAmount = 0;
		Hashtable<String,String> invoicePointers = new Hashtable<String,String>();
		Connection conn = SH.getOpenClinicConnection();
		try {
			//First calculate total amount received in the period
			String sql = "SELECT * from oc_patientinvoices"+
						 " WHERE"+
						 " oc_patientinvoice_updatetime>=? AND"+
						 " oc_patientinvoice_updatetime<? AND"+
						 " oc_patientinvoice_status='closed'";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setTimestamp(1, SH.getSQLTimestamp(begin));
			ps.setTimestamp(2, SH.getSQLTimestamp(end));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				String uid = rs.getInt("oc_patientinvoice_serverid")+"."+rs.getInt("oc_patientinvoice_objectid");
				String exportedAmount = Pointer.getPointer("erpnext.invoice."+uid);
				PatientInvoice invoice = PatientInvoice.get(uid);
				double invoiceAmount = invoice.getAmountPaid();
				double previousAmount=0;
				if(exportedAmount.length()>0) {
					previousAmount = Double.parseDouble(exportedAmount);
				}
				if(invoiceAmount-previousAmount!=0) {
					totalAmount+=invoiceAmount-previousAmount;
					invoicePointers.put("erpnext.invoice."+uid,SH.formatDouble(invoiceAmount));
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
			bOk=false;
		}
		if(!bOk) {
			error="100: Error calculating amount";
		}
		else {
			SH.syslog("Total amount: "+SH.formatDouble(totalAmount));
			if(totalAmount!=0) {
			   	JsonNodeFactory factory = JsonNodeFactory.instance;
			   	ObjectNode journalEntry = factory.objectNode();
			   	journalEntry.put("doctype", "Journal Entry");
			   	journalEntry.put("voucher_type", "Journal Entry");
			   	journalEntry.put("posting_date", SH.formatDate(new java.util.Date(),"yyyy-MM-dd"));
			   	journalEntry.put("company", SH.cs("ERPNext_api_company", "HGR BONDEKO"));
			   	journalEntry.put("naming_series", "ACC-JV-.YYYY.-");
			   	journalEntry.put("user_remark", "Relevé des encaissements OpenClinic pour la période "+SH.formatDate(begin,"dd/MM/yyyy HH:mm:ss")+" - "+SH.formatDate(end,"dd/MM/yyyy HH:mm:ss"));
			   	ObjectMapper mapper = new ObjectMapper();
			   	ArrayNode accounts = mapper.createArrayNode();
			   	ObjectNode account1 = factory.objectNode();
			   	account1.put("account", SH.cs("ERPNext_api_clientaccount", "411 - Adhérents - HGR BNDK"));
			   	account1.put("debit_in_account_currency", SH.formatDouble(totalAmount));
			   	account1.put("credit_in_account_currency", 0);
			   	accounts.add(account1);
			   	ObjectNode account2 = factory.objectNode();
			   	account2.put("account", SH.cs("ERPNext_api_cashaccount", "571 - Caisse en monnaie nationale - HGR BNDK"));
			   	account2.put("debit_in_account_currency", 0);
			   	account2.put("credit_in_account_currency", SH.formatDouble(totalAmount));
			   	accounts.add(account2);
			   	journalEntry.put("accounts", accounts);
			   	SH.syslog(journalEntry.toPrettyString());
			   	try {
					PreparedStatement ps = conn.prepareStatement("insert into oc_messages(oc_message_messageid,oc_message_type,oc_message_language,oc_message_transport,oc_message_data,oc_message_createdatetime,oc_message_sendafter) value(?,?,?,?,?,?,?)");
					ps.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("OC_MESSAGES"));
					ps.setString(2,"erpnext");
					ps.setString(3,"en");
					ps.setString(4,"http");
					ps.setString(5, journalEntry.toPrettyString());
					ps.setTimestamp(6,SH.getSQLTimestamp(new java.util.Date()));
					ps.setTimestamp(7,SH.getSQLTimestamp(new java.util.Date()));
					ps.execute();
					ps.close();
				} catch (SQLException e) {
					bOk=false;
					e.printStackTrace();
				}
			}
		}
		try {
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
			bOk=false;
		}
		//If message was correctly sent to API, update the list of already sent invoices and ther amounts
		if(bOk) {
			Enumeration<String> p = invoicePointers.keys();
			while(p.hasMoreElements()) {
				String uid = p.nextElement();
				Pointer.deletePointers(uid);
				Pointer.storePointer(uid, invoicePointers.get(uid));
			}
		}
		return error;
	}
	
	public static boolean sendMessage(int id, String data) {
		boolean bOk=true;
		//Now send the amount to the ERPNext instance
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(SH.cs("ERPNext_api_url", ""));
		   	req.setHeader("Authorization", "token "+SH.cs("ERPNext_api_key", "")+":"+SH.cs("ERPNext_api_secret", ""));
		   	req.setHeader("Content-Type", "application/json");
		   	StringEntity reqEntity = new StringEntity(data,"utf-8");
		   	req.setEntity(reqEntity);
		   	HttpResponse resp = client.execute(req);
		   	HttpEntity entity = resp.getEntity();
		   	String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    JsonObject jo = jr.readObject();
		    SH.syslog(jo.toString());
		}
		catch(Exception e) {
			bOk=false;
			e.printStackTrace();
			Debug.println("Error sending ERPNext message #"+id);
		}
		return bOk;
	}
}
