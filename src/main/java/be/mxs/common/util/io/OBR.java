package be.mxs.common.util.io;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Base64; 
import java.util.Date;
import java.util.Vector;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.finance.Debet;
import be.openclinic.finance.Insurance;
import be.openclinic.finance.PatientInvoice;
import be.openclinic.finance.WicketCredit;
import be.openclinic.system.SH;
import net.admin.AdminPerson;
import net.admin.AdminPrivateContact;

public class OBR {
	public static String getProxyToken() throws ClientProtocolException, IOException {
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost("http://10.0.0.1/openclinic/api/obr/getToken.jsp");
		String aut = Base64.getEncoder().encodeToString((SH.cs("OBR_proxyuser","4")+":"+SH.cs("OBR_proxypassword","")).getBytes("utf-8"));
		req.setHeader("Authorization", "Basic "+aut);
		HttpResponse resp = client.execute(req);
		HttpEntity entity = resp.getEntity();
		String s = EntityUtils.toString(entity);
		JsonReader jr = Json.createReader(new java.io.StringReader(s));
		return jr.readObject().getString("token");
	}
	
	public static String getToken() throws ClientProtocolException, IOException {
		String response ="";
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OBR_logincommand","https://ebms.obr.gov.bi:9443/ebms_api/login/"));
	    req.setHeader("Content-Type", "application/json");
	    String aut = "{'username':'"+SH.cs("OBR_username","")+"','password':'"+SH.cs("OBR_password","")+"'}";
	    StringEntity reqEntity = new StringEntity(aut.replaceAll("'","\""));
	    req.setEntity(reqEntity);
	    
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    JsonReader jr = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
	    JsonObject jo = jr.readObject();
	    if(jo.getBoolean("success")) {
	    	response = jo.getJsonObject("result").getString("token");
	    }else {
	    	response = "-1";	
	    }
	    return response;
	}
	
	public static boolean addPatientInvoice(String uid, boolean useproxy) {
		boolean bSuccess=false;
		String prefixx="";
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(SH.cs("OBR_addinvoicecommand", "https://ebms.obr.gov.bi:9443/ebms_api/addInvoice/"));
		   	req.setHeader("Content-Type", "application/json");
		   	req.setHeader("Authorization", "Bearer "+(useproxy?getProxyToken():getToken()));
		   	PatientInvoice invoice = PatientInvoice.get(uid);
		   	
		   String signature_obr = be.openclinic.system.SH.cs("OBR_TIN","")+"/"+be.openclinic.system.SH.cs("OBR_username","")+"/"+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(invoice.getDate())+"/"+invoice.getObjectId();
		   	
		   	 invoice.getExtraInsurarAmount2();
		   	
		   	if(invoice!=null && invoice.getStatus().equalsIgnoreCase("closed") && invoice.getDebets().size() > 0){
			    String inv = "{";
				inv+="'invoice_number':'"+prefixx+invoice.getObjectId() +"',";
				inv+="'invoice_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getCreateDateTime())+"',";
				inv+="'invoice_type':'FN',";
				inv+="'tp_type':'2',";
				inv+="'tp_name':'"+be.openclinic.system.SH.cs("OBR_taxpayer","")+"',";
				inv+="'tp_TIN':'"+be.openclinic.system.SH.cs("OBR_TIN","")+"',";
				inv+="'tp_trade_number':'"+be.openclinic.system.SH.cs("OBR_tradenumber","3333")+"',";
				inv+="'tp_postal_number':'"+be.openclinic.system.SH.cs("OBR_postalcode","1234")+"',";
				inv+="'tp_phone_number':'"+be.openclinic.system.SH.cs("OBR_phonenumber","68350265")+"',";
				inv+="'tp_address_commune':'"+be.openclinic.system.SH.cs("OBR_town","Commune")+"',";
				inv+="'tp_address_quartier':'"+be.openclinic.system.SH.cs("OBR_quarter","Quartier")+"',";
				inv+="'tp_address_avenue':'"+be.openclinic.system.SH.cs("OBR_street","Rue")+"',"; //Pas d'accents!!!
				inv+="'tp_address_number':'"+be.openclinic.system.SH.cs("OBR_streetnumber","No")+"',";
				inv+="'vat_taxpayer':'"+be.openclinic.system.SH.cs("OBR_vattaxpayer","0")+"',";
				inv+="'ct_taxpayer':'0',";
				inv+="'tl_taxpayer':'0',";
				inv+="'tp_fiscal_center':'"+be.openclinic.system.SH.cs("OBR_fiscal_center","DMC")+"',"; //fiscal center
				inv+="'tp_activity_sector':'"+be.openclinic.system.SH.cs("OBR_activitysector","Services de soins")+"',";
				inv+="'tp_legal_form':'"+be.openclinic.system.SH.cs("OBR_legalform","hospitals")+"',";
		   		String paymenttype="4";
		   		Vector<WicketCredit> credits = WicketCredit.getByInvoiceUid(invoice.getUid());
		   		if(credits.size()>0){
		   			WicketCredit credit = credits.elementAt(0);
		   			if(credit.getWicket()!=null && be.openclinic.system.SH.c(credit.getWicket().getType()).length()>0 && !credit.getWicket().getType().equalsIgnoreCase("cash")){
		   				paymenttype="1";
		   			}
		   		}
				inv+="'payment_type':'"+paymenttype+"',";  
				inv+="'customer_name':'"+invoice.getPatient().getFullName()+"',";
				inv+="'customer_TIN':'',";
				inv+="'customer_address':'"+(invoice.getPatient().privateContacts.size()>0?((AdminPrivateContact)(invoice.getPatient().privateContacts.elementAt(0))).address:"")+"',";
				inv+="'vat_customer_payer':'0',";
				inv+="'invoice_type':'FN',";
				inv+="'cancelled_invoice_ref':'"+ Pointer.getPointer("DERIVED." + invoice.getUid()) +"',";
				inv+="'invoice_signature':'"+signature_obr+"',"; //Identifiant du système?
				inv+="'invoice_identifier':'"+signature_obr+"',";
				inv+="'invoice_signature_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getDate())+"',";
				inv+="'invoice_items':[";
				boolean bHasDebets=false;
				for(int n=0;n<invoice.getDebets().size();n++){
					Debet debet = (Debet)invoice.getDebets().elementAt(n);					
					if(debet.getQuantity()!=0){
						if(bHasDebets){
							inv+= ",";
						}
						else{
							bHasDebets=true;
						}
						inv+=	"{";
						inv+=		"'item_designation':'"+debet.getPrestation().getDescription().replaceAll("'","\'")+"',"; //pas d'accents
						inv+=		"'item_quantity':'"+debet.getQuantity()+"',";
						inv+=		"'item_price':'"+(debet.getTotalAmount()/debet.getQuantity())+"',";
						inv+=		"'item_ct':'0',";
						inv+=		"'item_tl':'0',";
						inv+=		"'item_price_nvat':'"+(debet.getTotalAmount())+"',";
						inv+=		"'vat':'0',";
						inv+=		"'item_price_wvat':'"+(debet.getTotalAmount())+"',";
						inv+=		"'item_total_amount':'"+(debet.getTotalAmount())+"'";
						
						inv+=	"}";
					}
				}
				inv+="]";
				inv+="}";
			    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(inv.replaceAll("'","\"")));
			    req.setEntity(reqEntity);
		   	}
		    
		   	HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    JsonObject jo = jr.readObject();
		    bSuccess=jo.getBoolean("success");
		        
		    Pointer.storePointer("OBR.SIG."+invoice.getObjectId(),signature_obr);
		    
		}
		catch(Exception e) {
			return false;
		}
	    return bSuccess;
	}
	
	public static JsonObject addPatientInvoiceGetJSONObject(String uid, boolean useproxy) {
		Boolean unsenderbleinvoice = false;
		JsonObject joResult=null;
		String prefixx="";
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(SH.cs("OBR_addinvoicecommand", "https://ebms.obr.gov.bi:9443/ebms_api/addInvoice_confirm/"));
		   	req.setHeader("Content-Type", "application/json");
		   	req.setHeader("Authorization", "Bearer "+(useproxy?getProxyToken():getToken()));
		   	PatientInvoice invoice = PatientInvoice.get(uid);
		   	
		   	String signature_obr = be.openclinic.system.SH.cs("OBR_TIN","")+"/"+be.openclinic.system.SH.cs("OBR_username","")+"/"+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(invoice.getCreateDateTime())+"/"+invoice.getObjectId();
		   	
		   	if(invoice!=null && invoice.getStatus().equalsIgnoreCase("closed") && invoice.getDebets().size() > 0){
			    String inv = "{";
			    inv+="'invoice_number':'"+prefixx+invoice.getObjectId()+"',";
				inv+="'invoice_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getCreateDateTime())+"',";
				inv+="'invoice_type':'FN',";
				inv+="'tp_type':'2',";
				inv+="'tp_name':'"+be.openclinic.system.SH.cs("OBR_taxpayer","")+"',";
				inv+="'tp_TIN':'"+be.openclinic.system.SH.cs("OBR_TIN","")+"',";
				inv+="'tp_trade_number':'"+be.openclinic.system.SH.cs("OBR_tradenumber","N/a")+"',";
				inv+="'tp_postal_number':'"+be.openclinic.system.SH.cs("OBR_postalcode","N")+"',";
				inv+="'tp_phone_number':'"+be.openclinic.system.SH.cs("OBR_phonenumber","")+"',";
				inv+="'tp_address_commune':'"+be.openclinic.system.SH.cs("OBR_town","")+"',";
				inv+="'tp_address_quartier':'"+be.openclinic.system.SH.cs("OBR_quarter","")+"',";
				inv+="'tp_address_avenue':'"+be.openclinic.system.SH.cs("OBR_street","")+"',"; //Pas d'accents!!!
				inv+="'tp_address_number':'"+be.openclinic.system.SH.cs("OBR_streetnumber","No")+"',";
				inv+="'vat_taxpayer':'"+be.openclinic.system.SH.cs("OBR_vattaxpayer","0")+"',";
				inv+="'ct_taxpayer':'0',";
				inv+="'tl_taxpayer':'0',";
				inv+="'tp_fiscal_center':'"+be.openclinic.system.SH.cs("OBR_fiscalcenter","")+"',";
				inv+="'tp_activity_sector':'"+be.openclinic.system.SH.cs("OBR_activitysector","Services de soins")+"',";
				inv+="'tp_legal_form':'"+be.openclinic.system.SH.cs("OBR_legalform","hospitals")+"',";
		   		String paymenttype="4";
		   		Vector<WicketCredit> credits = WicketCredit.getByInvoiceUid(invoice.getUid());
		   		if(credits.size()>0){
		   			WicketCredit credit = credits.elementAt(0);
		   			if(credit.getWicket()!=null && be.openclinic.system.SH.c(credit.getWicket().getType()).length()>0 && !credit.getWicket().getType().equalsIgnoreCase("cash")){
		   				paymenttype="1";
		   			}
		   		}
				inv+="'payment_type':'"+paymenttype+"',";  
				inv+="'customer_name':'"+ AdminPerson.getAdminPerson(invoice.getPatientUid()).getFullName() +"',";
				inv+="'customer_TIN':'',";
				inv+="'customer_address':'"+(invoice.getPatient().privateContacts.size()>0?((AdminPrivateContact)(invoice.getPatient().privateContacts.elementAt(0))).address:"")+"',";
				inv+="'vat_customer_payer':'0',";
				inv+="'invoice_type':'FN',";
				inv+="'cancelled_invoice_ref':'',";
				inv+="'invoice_signature':'"+signature_obr+"',"; //Identifiant du système
				inv+="'invoice_identifier':'"+signature_obr+"',"; //Identifiant du système
				inv+="'invoice_signature_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getDate())+"',";
				inv+="'invoice_items':[";
				boolean bHasDebets=false;
				for(int n=0;n<invoice.getDebets().size();n++){
					Debet debet = (Debet)invoice.getDebets().elementAt(n);
					if(debet.getQuantity()!=0){
						if(bHasDebets){
							inv+= ",";
						}
						else{
							bHasDebets=true;
						}
						inv+=	"{";
						inv+=		"'item_designation':'"+debet.getPrestation().getDescription().replaceAll("'","\'")+"',"; //pas d'accents
						inv+=		"'item_quantity':'"+debet.getQuantity()+"',";
						inv+=		"'item_price':'"+(debet.getTotalAmount()/debet.getQuantity())+"',";
						inv+=		"'item_ct':'0',";
						inv+=		"'item_tl':'0',";
						inv+=		"'item_price_nvat':'"+(debet.getTotalAmount())+"',";
						inv+=		"'vat':'0',";
						inv+=		"'item_price_wvat':'"+(debet.getTotalAmount())+"',";
						inv+=		"'item_total_amount':'"+(debet.getTotalAmount())+"'";
						inv+=	"}";
					}
				}
				inv+="]";
				inv+="}";
			    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(inv.replaceAll("'","\"")));
			    
			 	System.out.println("Request:  "+inv.replaceAll("'","\""));
			    
			    req.setEntity(reqEntity);
		   	}
		  
		    
		   	HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    
		    String s = EntityUtils.toString(entity);
		    System.out.println("Add invoice response :  "+s);
		    
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    joResult = jr.readObject();
		    
		    //Pointer.storePointer("OBR.SIG."+invoice.getUid(),signature_obr);
		    
		}
		catch(Exception e) {
			System.out.println("Error : " + e.getMessage().toString());
			return null;
		}
		
		
	    return joResult;
	}
	
	public static String validateTIN(String tin) throws ClientProtocolException, IOException {
		String taxpayer ="Unknown";
		//1. Construire un client HTTP
		HttpClient client = HttpClients.createDefault();
		
		//2. Construire une requête POST et l'exécuter sur le client HTTP
		HttpPost req = new HttpPost(SH.cs("OBR_checkTINcommand","https://ebms.obr.gov.bi:9443/ebms_api/checkTIN/"));
	    req.setHeader("Content-Type", "application/json");
	   	req.setHeader("Authorization", "Bearer "+getProxyToken());
		String body = "{'tp_TIN':'"+tin+"'}";
	    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(body.replaceAll("'","\"")));
	    req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    
		//3. Récupérer la réponse HTTP
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
		
		//4. Mettre le body de la réponse dans un objet JSON
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    JsonObject jo = jr.readObject();
		
		//5. Extraire le nom du contribuable de l'objet JSON
	    if(jo.getBoolean("success")) {
	    	taxpayer = jo.getJsonObject("result").getJsonArray("taxpayer").getJsonObject(0).getString("tp_name");
	    }
	    
		return taxpayer;
	}
	
	public static Vector getList(
			String sFindDateBegin, 
			String sFindDateEnd,
			String serv, 
			String contacttype,
			String invoiceStatus) {
		
		Vector rez = new Vector();
        PreparedStatement ps = null;
        ResultSet rs = null;
       
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String  sSql = "";
            sSql = " SELECT DISTINCT "
            		+ " inv.OC_PATIENTINVOICE_SERVERID, "
            		+ " inv.OC_PATIENTINVOICE_OBJECTID, "
            		+ " inv.OC_PATIENTINVOICE_DATE, "
            		+ " inv.OC_PATIENTINVOICE_BALANCE, "
            		+ " inv.OC_PATIENTINVOICE_STATUS "
            		+ " FROM oc_debets deb, ";
                    if(contacttype!="") {
            		sSql += " oc_encounters enc,  ";
                     }
            		sSql += " oc_patientinvoices inv ";
            		sSql += " WHERE inv.oc_patientinvoice_updatetime >= ? "
            		+ " AND inv.oc_patientinvoice_updatetime <= ? "
            		+ " AND inv.OC_PATIENTINVOICE_OBJECTID = REPLACE(deb.OC_DEBET_PATIENTINVOICEUID,'1.','') ";
            		
            		if(serv!="") {
            		sSql +=" AND deb.OC_DEBET_SERVICEUID = ? ";
            		}
            		
            		if(contacttype!="") {
            		sSql +=" AND enc.OC_ENCOUNTER_OBJECTID = REPLACE(deb.OC_DEBET_ENCOUNTERUID,'1.','') ";
            		sSql +=" AND enc.OC_ENCOUNTER_TYPE = ? ";	
            		}
            		
            	
        
            		System.out.println("Request: " +sSql);
            
             ps = oc_conn.prepareStatement(sSql);
             int param = 0;
             
             param++;
             ps.setDate(param, ScreenHelper.getSQLDate(sFindDateBegin));
             param++;
             ps.setDate(param, ScreenHelper.getSQLDate(sFindDateEnd));
             
             if(serv!=""){
            	 param++;
            	 ps.setString(param, serv);
             }
             
             if(contacttype!=""){
            	 param++;
            	 ps.setString(param, contacttype);
             }
             
           
             
             rs = ps.executeQuery();

             String[] item  = new String[6];
             
            while(rs.next()){
            	
                 item  = new String[6]; 
                item[0] = rs.getString("inv.OC_PATIENTINVOICE_SERVERID");
                item[1] = rs.getString("inv.OC_PATIENTINVOICE_OBJECTID");
                item[2] = new java.text.SimpleDateFormat("dd/MM/yyyy").
                format(rs.getDate("inv.OC_PATIENTINVOICE_DATE"));
                
                item[3] = rs.getString("inv.OC_PATIENTINVOICE_BALANCE");
                item[4] = rs.getString("inv.OC_PATIENTINVOICE_STATUS");
               

                rez.add(item);
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

		return rez;
	}
	
	public static Vector searchInvoices(
			String sInvoiceBeginDate,
			String sInvoiceEndDate, 
             String sInvoiceService,
             String sInvoiceAssuseur){
		
            Vector invoices = new Vector();
            PreparedStatement ps = null;
            ResultSet rs = null;
           
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                // compose query
                String  sSql = "";
                sSql = " select * from oc_patientinvoices "+
        				" where oc_patientinvoice_updatetime > ? and "+
        				" oc_patientinvoice_updatetime <= ? "; 	
                
                 ps = oc_conn.prepareStatement(sSql);
                 ps.setDate(1,ScreenHelper.getSQLDate(sInvoiceBeginDate));
                 ps.setDate(2,ScreenHelper.getSQLDate(sInvoiceEndDate));
                 
                 rs = ps.executeQuery();

                PatientInvoice patientInvoice;
                while(rs.next()){
                    patientInvoice = new PatientInvoice();

                    patientInvoice.setUid(rs.getInt("OC_PATIENTINVOICE_SERVERID")+"."+rs.getInt("OC_PATIENTINVOICE_OBJECTID"));
                    patientInvoice.setDate(rs.getDate("OC_PATIENTINVOICE_DATE"));
                    patientInvoice.setInvoiceUid(rs.getInt("OC_PATIENTINVOICE_ID")+"");
                    patientInvoice.setPatientUid(rs.getString("OC_PATIENTINVOICE_PATIENTUID"));
                    patientInvoice.setCreateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_CREATETIME"));
                    patientInvoice.setUpdateDateTime(rs.getTimestamp("OC_PATIENTINVOICE_UPDATETIME"));
                    patientInvoice.setUpdateUser(rs.getString("OC_PATIENTINVOICE_UPDATEUID"));
                    patientInvoice.setVersion(rs.getInt("OC_PATIENTINVOICE_VERSION"));
                    patientInvoice.setBalance(rs.getDouble("OC_PATIENTINVOICE_BALANCE"));
                    patientInvoice.setStatus(rs.getString("OC_PATIENTINVOICE_STATUS"));
                    patientInvoice.setNumber(rs.getString("OC_PATIENTINVOICE_NUMBER"));
                    patientInvoice.setInsurarreference(rs.getString("OC_PATIENTINVOICE_INSURARREFERENCE"));
                    patientInvoice.setInsurarreferenceDate(rs.getString("OC_PATIENTINVOICE_INSURARREFERENCEDATE"));
                    patientInvoice.setAcceptationUid(rs.getString("OC_PATIENTINVOICE_ACCEPTATIONUID"));
                    patientInvoice.setVerifier(rs.getString("OC_PATIENTINVOICE_VERIFIER"));
                    patientInvoice.setComment(rs.getString("OC_PATIENTINVOICE_COMMENT"));   
                    patientInvoice.setModifiers(rs.getString("OC_PATIENTINVOICE_MODIFIERS"));

                    invoices.add(patientInvoice);
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            finally{
                try{
                    if(rs!=null) rs.close();
                    if(ps!=null) ps.close();
                    oc_conn.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }

            return invoices;
	}
	
	private static java.util.Date getInvoicedate(String uid) {
		   
		   java.util.Date date = null;
	       PreparedStatement ps = null;
           ResultSet rs = null;
           String sSelect = "SELECT * FROM OC_PATIENTINVOICES WHERE OC_PATIENTINVOICE_SERVERID = ? AND OC_PATIENTINVOICE_OBJECTID = ?";
           Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
           try{
               ps = oc_conn.prepareStatement(sSelect);
               ps.setInt(1,Integer.parseInt(uid.split("\\.")[0]));
               ps.setInt(2,Integer.parseInt(uid.split("\\.")[1]));
               rs = ps.executeQuery();

               if(rs.next()){
            	   date=rs.getTimestamp("OC_PATIENTINVOICE_CREATETIME"); 
               }
               
               rs.close();
               ps.close();
               oc_conn.close();
               
               }catch(Exception e){
                   Debug.println("OpenClinic => PatientInvoice.java => getViaInvoiceUID => "+e.getMessage());
                   e.printStackTrace();
               }
		return date;
	}
	
	public static String getSignature(String uid) {
		
		String signature_obr  = "";
		String suffix = uid;
		
		try {
		
		if(uid!=null&&uid!="") {
			
		if(uid.split("\\.").length >1) {
			suffix = uid.split("\\.")[1];
		}
		if(getInvoicedate(uid)!=null) {
	   signature_obr = be.openclinic.system.SH.cs("OBR_TIN","")+"/"+be.openclinic.system.SH.cs("OBR_username","")+"/"+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(getInvoicedate(uid))+"/"+suffix;
		}
		else {
			signature_obr = "-";
			}
		}
		
		}catch(Exception ex) {
			signature_obr = null;
		}
		//return Pointer.getPointer("OBR.SIG."+uid);
		return signature_obr;
	}
	
	public static Date getCancel(String uid) {
		//PatientInvoice invoice = PatientInvoice.get(uid);
		return Pointer.getPointerDate ("OBR.CANC."+uid);
	}
	
	public static JsonObject getInvoice(String invoceuid, boolean useproxy) {
		
		JsonObject joResult=null;
		String prefixx="";
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(SH.cs("OBR_getinvoicecommand", "https://ebms.obr.gov.bi:9443/ebms_api/getInvoice/"));
		   	req.setHeader("Content-Type", "application/json");
		   	req.setHeader("Authorization", "Bearer "+(useproxy?getProxyToken():getToken()));
		   	
		   	String signature_obr = getSignature(invoceuid);
		   	
		   	if(signature_obr.length() < 1 ) {
		   		signature_obr = "sign";
		   	}
			    String inv = "{";
				inv+="'invoice_signature':'"+signature_obr+"'";
				inv+="}";
				
			    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(inv.replaceAll("'","\"")));
			    req.setEntity(reqEntity);
		   	
		    
		   	HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    JsonObject jo = jr.readObject();
		    joResult=jo;
		    
		}
		catch(Exception e) {
			return null;
		}
	    return joResult;
	}
	
public static JsonObject cancelInvoice(String invoceuid, String motif , boolean useproxy) {
		
		JsonObject joResult=null;
	
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(SH.cs("OBR_cancelinvoicecommand", "https://ebms.obr.gov.bi:9443/ebms_api/cancelInvoice/")); 
		   	req.setHeader("Content-Type", "application/json");
		   	req.setHeader("Authorization", "Bearer "+(useproxy?getProxyToken():getToken()));
		   	
		   	String signature_obr = getSignature(invoceuid);
		   	
		   	if(signature_obr.length() < 1 ) {
		   		signature_obr = "sign";
		   	}
			    String inv = "{";
				inv+="'invoice_signature':'"+signature_obr+"',";
				inv+="'cn_motif':'"+motif+"'";
				inv+="}";
				
			    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(inv.replaceAll("'","\"")));
			    req.setEntity(reqEntity);
		   	
		    
		   	HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    JsonObject jo = jr.readObject();
		    joResult=jo;
		    
		}
		catch(Exception e) {
			return null;
		}
	    return joResult;
	}	

public static String getErrorOfDuplication(String invoiceuid, String context) {
	String err = "";
	if(invoiceuid!=null) {
		if(Pointer.getPointer("OBR.INV.ERROR."+invoiceuid)!="") {
				
			err = "<img style='vertical-align: middle' src='"+context+"/_img/icons/icon_error.jpg' />";	
			err =  err + "DUPLICATION";	
			
		}else {
			err = "Pas d'erreur";
		}
		//facture annulle au niveau de l'obr 
		//OBR.CANC.
		if(Pointer.getPointer("OBR.CANC."+invoiceuid)!="") {
			
			err = "<img style='vertical-align: middle' src='"+context+"/_img/icons/icon_error.jpg' />";	
			err =  err + "FACTURE ANNULEE";	
			
		}
		
	}else {
		err = "";	
	}
	return err;
}

public static String getSendingStatus(String invoiceuid, String context) {
	String err = "";
	if(invoiceuid!=null) {
	if(Pointer.getPointer("OBR.INV."+invoiceuid)!="") {
	err = "<img style='vertical-align: middle' src='"+context+"/_img/icons/icon_check.png' />";
	}else {
	err = "<img style='vertical-align: middle' src='"+context+"/_img/icons/icon_warning.gif' />";		
	}
	}else {
    err = "";	
	}
	return  err;
}

public static JsonObject addStockMovement(String uid, boolean useproxy) {
	Boolean unsenderbleinvoice = false;
	JsonObject joResult=null;
	String prefixx="";
	try {
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OBR_addinvoicecommand", "https://ebms.obr.gov.bi:9443/ebms_api/addInvoice_confirm/"));
	   	req.setHeader("Content-Type", "application/json");
	   	req.setHeader("Authorization", "Bearer "+(useproxy?getProxyToken():getToken()));
	   	PatientInvoice invoice = PatientInvoice.get(uid);
	   	
	   	String signature_obr = be.openclinic.system.SH.cs("OBR_TIN","")+"/"+be.openclinic.system.SH.cs("OBR_username","")+"/"+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(invoice.getCreateDateTime())+"/"+invoice.getObjectId();
	   	
	   	if(invoice!=null && invoice.getStatus().equalsIgnoreCase("closed") && invoice.getDebets().size() > 0){
		    String inv = "{";
		    inv+="'invoice_number':'"+prefixx+invoice.getObjectId()+"',";
			inv+="'invoice_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getCreateDateTime())+"',";
			inv+="'invoice_type':'FN',";
			inv+="'tp_type':'2',";
			inv+="'tp_name':'"+be.openclinic.system.SH.cs("OBR_taxpayer","")+"',";
			inv+="'tp_TIN':'"+be.openclinic.system.SH.cs("OBR_TIN","")+"',";
			inv+="'tp_trade_number':'"+be.openclinic.system.SH.cs("OBR_tradenumber","N/a")+"',";
			inv+="'tp_postal_number':'"+be.openclinic.system.SH.cs("OBR_postalcode","N")+"',";
			inv+="'tp_phone_number':'"+be.openclinic.system.SH.cs("OBR_phonenumber","")+"',";
			inv+="'tp_address_commune':'"+be.openclinic.system.SH.cs("OBR_town","")+"',";
			inv+="'tp_address_quartier':'"+be.openclinic.system.SH.cs("OBR_quarter","")+"',";
			inv+="'tp_address_avenue':'"+be.openclinic.system.SH.cs("OBR_street","")+"',"; //Pas d'accents!!!
			inv+="'tp_address_number':'"+be.openclinic.system.SH.cs("OBR_streetnumber","No")+"',";
			inv+="'vat_taxpayer':'"+be.openclinic.system.SH.cs("OBR_vattaxpayer","0")+"',";
			inv+="'ct_taxpayer':'0',";
			inv+="'tl_taxpayer':'0',";
			inv+="'tp_fiscal_center':'"+be.openclinic.system.SH.cs("OBR_fiscalcenter","")+"',";
			inv+="'tp_activity_sector':'"+be.openclinic.system.SH.cs("OBR_activitysector","Services de soins")+"',";
			inv+="'tp_legal_form':'"+be.openclinic.system.SH.cs("OBR_legalform","hospitals")+"',";
	   		String paymenttype="4";
	   		Vector<WicketCredit> credits = WicketCredit.getByInvoiceUid(invoice.getUid());
	   		if(credits.size()>0){
	   			WicketCredit credit = credits.elementAt(0);
	   			if(credit.getWicket()!=null && be.openclinic.system.SH.c(credit.getWicket().getType()).length()>0 && !credit.getWicket().getType().equalsIgnoreCase("cash")){
	   				paymenttype="1";
	   			}
	   		}
			inv+="'payment_type':'"+paymenttype+"',";  
			inv+="'customer_name':'"+ AdminPerson.getAdminPerson(invoice.getPatientUid()).getFullName() +"',";
			inv+="'customer_TIN':'',";
			inv+="'customer_address':'"+(invoice.getPatient().privateContacts.size()>0?((AdminPrivateContact)(invoice.getPatient().privateContacts.elementAt(0))).address:"")+"',";
			inv+="'vat_customer_payer':'0',";
			inv+="'invoice_type':'FN',";
			inv+="'cancelled_invoice_ref':'',";
			inv+="'invoice_signature':'"+signature_obr+"',"; //Identifiant du système
			inv+="'invoice_identifier':'"+signature_obr+"',"; //Identifiant du système
			inv+="'invoice_signature_date':'"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getDate())+"',";
			inv+="'invoice_items':[";
			boolean bHasDebets=false;
			for(int n=0;n<invoice.getDebets().size();n++){
				Debet debet = (Debet)invoice.getDebets().elementAt(n);
				if(debet.getQuantity()!=0){
					if(bHasDebets){
						inv+= ",";
					}
					else{
						bHasDebets=true;
					}
					inv+=	"{";
					inv+=		"'item_designation':'"+debet.getPrestation().getDescription().replaceAll("'","\'")+"',"; //pas d'accents
					inv+=		"'item_quantity':'"+debet.getQuantity()+"',";
					inv+=		"'item_price':'"+(debet.getTotalAmount()/debet.getQuantity())+"',";
					inv+=		"'item_ct':'0',";
					inv+=		"'item_tl':'0',";
					inv+=		"'item_price_nvat':'"+(debet.getTotalAmount())+"',";
					inv+=		"'vat':'0',";
					inv+=		"'item_price_wvat':'"+(debet.getTotalAmount())+"',";
					inv+=		"'item_total_amount':'"+(debet.getTotalAmount())+"'";
					inv+=	"}";
				}
			}
			inv+="]";
			inv+="}";
		    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(inv.replaceAll("'","\"")));
		    
		 	System.out.println("Request:  "+inv.replaceAll("'","\""));
		    
		    req.setEntity(reqEntity);
	   	}
	  
	    
	   	HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    
	    String s = EntityUtils.toString(entity);
	    System.out.println("Add invoice response :  "+s);
	    
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    joResult = jr.readObject();
	    }catch(Exception e) {
			System.out.println("Error : " + e.getMessage().toString());
			return null;
		}
		
		
	    return joResult;
	    }
}
