package be.mxs.common.util.io;

import java.io.IOException;
//import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
//import java.util.Base64;
//import java.util.Vector;
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
//import org.hl7.fhir.utilities.json.JSONUtil;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.HTMLEntities;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
//import be.openclinic.finance.CsvInvoiceCCBRTA;
import be.openclinic.finance.Debet;
import be.openclinic.finance.Insurance;
import be.openclinic.finance.Insurar;
//import be.openclinic.finance.Insurar;
import be.openclinic.finance.PatientInvoice;
//import be.openclinic.finance.WicketCredit;
import be.openclinic.system.SH;
import net.admin.Service;
import be.openclinic.medical.Prescription;
import java.text.DecimalFormat;

public class MedHub {
	
	 public static String getToken() throws ClientProtocolException, IOException {
		
		 String sHubToken = "----";
		 HttpClient client = HttpClients.createDefault();
		 HttpPost	req = new HttpPost(SH.cs("MED_HUBauthentificate","http://10.241.10.25:8080/HMKInterface/authentificate"));
		    req.setHeader("Content-Type", "application/json");      
		 String aut = "{'username':'"+SH.cs("HUB_username","hmk")+"',"+
		           "'password':'"+SH.cs("HUB_password","1234567890")+"'"+
		                        "}";
		 StringEntity reqEntity = new StringEntity(aut.replaceAll("'","\""));
		 req.setEntity(reqEntity);  
		 HttpResponse resp = client.execute(req);
		 HttpEntity entity = resp.getEntity();
		 JsonReader jr = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
		 JsonObject jo = jr.readObject(); 
		 sHubToken = jo.getString("token");
	     return sHubToken;
	}
	
	public static JsonObject SendInvoice(String invoiceuid, String sHubToken, Boolean isutemporaire, Boolean facturesimple) {

		boolean bSuccess=false;
		JsonObject response_status = null;
		String invoi = ""; 
		JsonUtils jsonutil = new JsonUtils();
		//testing purp
		//testing purp
		
		//testing purp

		try {
		
		HttpClient	client = HttpClients.createDefault();
		HttpPost	req = new HttpPost(SH.cs("MED_HUBAddInvoice","http://10.241.10.25:8080/HMKInterface/addHospitalizationSheet"));
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+sHubToken);
	   	PatientInvoice invoice = PatientInvoice.get("1."+invoiceuid);
	   	
	   	String encounterin = "NaN";
	   	String status = "";
	   	String status_a_affich = "Lui-meme";
	   	
	   	String card_number = "0000";
	   	String assurance_number = "00000";
	   	
	   if(invoice!=null && invoice.getDebets().size() > 0){ 
	   	
	   	
	   	if(invoice.getDebets().size() >0) {
	   		Debet firstdebet = (Debet)invoice.getDebets().elementAt(0);
	   	    encounterin =  firstdebet.getEncounter().getEscortName();
	   	    Insurance ins = firstdebet.getInsurance();
	   	    status = ins.getStatus();
	   	    assurance_number = ins.getInsuranceNr();
	   	    card_number = ins.getMemberImmat(); 
	   	}
	   	
	   	
	   	switch(status) {
	   	case "affilate": 
	   		status_a_affich = "Lui-meme";
	   		break;
	   	case "child": 
	   		status_a_affich = "Enfant";
	   		break;	
	   	case "partner": 
	   		status_a_affich = "Conjoint";
	        break;	
	   	}
	   
	    
	   		if(invoice!=null){
	   			
	   		String isut = "";
	   		
	   		 if(isutemporaire){
	   		 isut = "HMK_" + invoice.getPatientUid() + "_0045";
		     }else {
		     isut =  getMatrPatient(invoice.getPatientUid());
		      }
	   	
	  
	        	  
        System.out.println("isu : "+ isut);  	
        System.out.println("-----------------------------------------------------------------");  
			         
        
        String original_sheet  = "";
         original_sheet = Pointer.getPointer("DERIVED."+invoice.getUid());
   		if(original_sheet!=null) {
   			String[] st = original_sheet.split("\\.");
   			original_sheet = st[1];
   		};
	   		   	 
	   		 
	   		MedHubMessageHeader msh = new MedHubMessageHeader();
	   		msh.setMsg_function("addHospitalizationSheet");
	   		msh.setMsg_date(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date().getTime()));
	   		msh.setMsg_sd(SH.cs("HUB_sender","HMK")); 
	   		msh.setMsg_rcv("MFP");
	   		msh.setMsgkey(new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(invoice.getDate())+"/"+SH.cs("HUB_sender","HMK")+"/MFP/"+ invoice.getPatientUid() +"/"+invoice.getUid());
	   		 
	   		
	   		MedHubAff affobject = new MedHubAff();
	   		affobject.setCrd_mut_id(card_number);
	   		affobject.setIsu(isut);
	   		affobject.setCrd_num(assurance_number);
	   		affobject.setSxe(invoice.getPatient().getBioGender());
	   		affobject.setSts(status_a_affich);
	   		
	   
	   		
		    invoi = "{";
		    invoi+="\"msg_hd\":";
		    invoi+= jsonutil.toJson(msh);
		    invoi+=",\"msg_body\":{";
		    invoi+="\"aff\":";
		    invoi+= jsonutil.toJson(affobject);
		    invoi+=",\"gen_info\":{";
		    invoi+="\"cod_sht\":\""+invoiceuid+"\",";
		    invoi+="\"origin_sheet\":\""+original_sheet+"\",";
		    invoi+="\"prs_cod\":\""+invoice.getCliniciansAsString() +"\",";
		    invoi+="\"code_hop\":\""+SH.cs("HUB_sender","HMK")+"\",";
		    invoi+="\"code_type_prest\":\""+ encounterin +"\",";
		    invoi+="\"prs_dat\":\""+ new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(invoice.getDate()) +"\",";
		    invoi+="\"code_service\":\""+ invoice.getServicesAsString("EN") +"\",";
		    
		    if(facturesimple) {
		    invoi+="\"code_agent\":\""+getPatientInvoiceSignature(invoice.getUid()) +"\"";
		    }else {
		    invoi+="\"code_agent\":\""+getPatientResumeSignature(invoice.getObjectId())+"\"";	
		    }
		    
		    invoi+="},\"items\":[";
		
		    boolean bHasDebets=false;
		    for(int n=0;n<invoice.getDebets().size();n++){
				Debet debet = (Debet)invoice.getDebets().elementAt(n);
				if(debet.getQuantity()!=0){
					if(bHasDebets){
						invoi+= ",";
					}
					else{
						bHasDebets=true;
					}
					
					invoi+="{";	
					invoi+="\"Code_act_M\":\""+ debet.getPrestation().getCode() +"\",";
					invoi+="\"des_act\":\""+ debet.getPrestation().getDescription() +"\",";
					invoi+="\"qtte\":"+ debet.getQuantity() +",";
					invoi+="\"prix_de_base\":"+ debet.getPrestation().getPrice() +",";
					invoi+="\"cout_patient\":"+ debet.getAmount() +",";
					invoi+="\"pty_ins_mod\":[";
					
					int haselement = 0;
					
					if(debet.getInsurance().getInsurar().getName()!=null  && 
							debet.getInsurarAmount() > 0) {
						
					invoi+="{";	
					invoi+="\"Id_assureur\":\""+ debet.getInsurance().getInsurar().getName() +"\",";
					invoi+="\"Cout\":"+debet.getInsurarAmount()+"";
					invoi+="}";
					haselement++;
					}
					
					if(debet.getExtraInsurar().getName()!=null && 
							debet.getExtraInsurarAmount() > 0) {
					if(haselement > 0) {
						invoi+=",";		
					}	
					invoi+="{";	
					invoi+="\"Id_assureur\":\""+debet.getExtraInsurar().getName()+"\",";
					invoi+="\"Cout\":"+debet.getExtraInsurarAmount()+"";
					invoi+="}";
					haselement++;
					}
					
					//Double extrainsamount2 = debet.getTotalAmount() - debet.getInsurarAmount() - debet.getExtraInsurarAmount() - debet.getAmount();
					
					if(debet.hasValidExtrainsurer2()) {
					Double extrainsamount2 = debet.getAmount();
					if(debet.getExtraInsurar2().getName()!=null && extrainsamount2 > 0) {
						if(haselement > 0) {
							invoi+=",";		
						}
					invoi+="{";	
					invoi+="\"Id_assureur\":\""+debet.getExtraInsurar2().getName()+"\",";
					invoi+="\"Cout\":"+ extrainsamount2 +"";
					invoi+="}";
					haselement++;
					  }
					}
					
				    invoi+="]";	
					invoi+="}";	
				}
		    };
		    
		   invoi+="]}}";  
		   StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(invoi));
		   req.setEntity(reqEntity);
		   System.out.println("Sent object: " + invoi);
		   
		    
		    }
	   	
	    HttpResponse resp = client.execute(req);
		HttpEntity entity = resp.getEntity();
	    
	    String s = EntityUtils.toString(entity);
	    JsonReader jraddinvioce = Json.createReader(new java.io.StringReader(s));
	    JsonObject joaddinvioce = jraddinvioce.readObject();
	    
	     response_status = joaddinvioce;
	    
	      }else {
	    	  
	    	String empty_message = "{";
	    	       empty_message+="\"msg_hd\": {";     
	    	       empty_message+="\"msg_function\": \"function\",";
	    	       empty_message+="\"msg_date\": \"date\",";
	    	       empty_message+="\"msg_snd\": \"EASYROUTER\",";
	    	       empty_message+="\"msg_rcv\": \"HMK\",";
	    	       empty_message+=" \"msg_key\": \"-\",";
	    	       empty_message+="\"msg_status\": \"-\"";
	    	       empty_message+= "},";
	    		   empty_message+= "\"msg_body\"";
	    		   empty_message+= ":{";
	    		   empty_message+= "\"status\": \"EMPTY : -1000\"";
	    		   empty_message+= ",";
	    		   empty_message+= "\"msg\":[ \"Prestation Empty\" ]";
	    		   empty_message+= "}";
	    		   empty_message+= "}";
	    		   
	    		   System.out.println("Test empty : " + empty_message);
	    		   
	      JsonReader jraddinvioce = Json.createReader(new java.io.StringReader(empty_message));
	      JsonObject joaddinvioce = jraddinvioce.readObject();	    
	      response_status = joaddinvioce;
	      
	      }
		
	      }catch(Exception e) {
			//return bSuccess;
	    	  System.out.println("Test exception : " + e.getMessage().toString());
			return response_status;
		}
	    //return bSuccess;
		return response_status;
	 
	}
	
	public static JsonObject SendPrescription(String prescriptionuid, String sHubToken, Boolean isutemporaire) {

		boolean bSuccess=false;
		String response_status = "";
		String pres = "";
		String isut = "";
		 String rep = "---";
		 
		 JsonReader jraddprescr = null;
		 JsonObject joaddprescr = null;
		 
		 JsonUtils jsonutil = new JsonUtils();
		
		try {
			
			if(prescriptionuid!=null){
		
		HttpClient	client = HttpClients.createDefault();
		HttpPost	req = new HttpPost(SH.cs("MED_HUBAddPrescription","http://10.241.10.25:8080/HMKInterface/addFurniture"));
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+sHubToken);
		Prescription prescr = Prescription.get("1."+prescriptionuid);
	    
		   if(isutemporaire){
		   		 isut = "HMK_" + prescr.getPatientUid() + "_0045";
			 }else {
			     isut =  getMatrPatient(prescr.getPatientUid());
		     }
		   
		   
		   
			MedHubMessageHeader msh = new MedHubMessageHeader();
	   		msh.setMsg_function("addFurniture");
	   		msh.setMsg_date(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date().getTime()));
	   		msh.setMsg_sd(SH.cs("HUB_sender","HMK")); 
	   		msh.setMsg_rcv("MFP");
	   		msh.setMsgkey(new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(prescr.getCreateDateTime())+"/"+SH.cs("HUB_sender","HMK")+"/MFP/"+ prescr.getPatientUid() +"/"+prescr.getUid());
	   		 
	   		
	   		MedHubAff affobject = new MedHubAff();
	   		affobject.setCrd_mut_id(isut);
	   		affobject.setIsu(isut);
	   		affobject.setCrd_num(isut);
	   		affobject.setSxe(prescr.getPatient().getBioGender());
	   		affobject.setSts("Lui-meme");
		   
		  
		   pres = "{";
		   pres+="\"msg_hd\":"; 
		   
		   pres+= jsonutil.toJson(msh);
		  
		   pres+=",\"msg_body\":{";
		   
		   pres+="\"aff\":";
		   pres+= jsonutil.toJson(affobject);
		   pres+=",\"gen_info\":{";
		   
		   pres+="\"cod_frn\":\""+prescr.getObjectId() +"\",";
		   pres+="\"prs_cod\":\""+prescr.getPrescriber().getFullName()+"\",";
		   pres+="\"code_hop\":\""+SH.cs("HUB_sender","HMK")+"\",";
		   pres+="\"code_type_prest\":\"MN\",";
		  
		   pres+="\"prs_dat\":\""+ new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(prescr.getCreateDateTime()) +"\"";
	
		   pres+="},\"items\":[";
		   

		   pres+="{";	
		   pres+="\"Code_act_M\":\""+ prescr.getProduct().getCode() +"\",";
		   pres+="\"des_act\":\""+ prescr.getProduct().getName() +"\",";
		   pres+="\"qtte\":"+ prescr.getRequiredPackages();
		   pres+="}";
		   
		   pres+="]}}";
		   
		   
	        System.out.println("-----OBJET A ENVOYER---------------------------------");  
	        System.out.println(pres);
	        System.out.println("-----OBJET A ENVOYER--------------------------------");
		   
	
		  StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(pres));	
		  req.setEntity(reqEntity);
		  	  
	   
	    HttpResponse resp = client.execute(req);
		HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	     jraddprescr = Json.createReader(new java.io.StringReader(s));
	     joaddprescr = jraddprescr.readObject();
	     
	   
		 }
	    
		}
		catch(Exception e) {
			//return bSuccess;
			rep = "Erreur "+e.getCause().getMessage();
		}
	    //return bSuccess;
	    //return response_status + "==="  + pres; 
		return joaddprescr;
	}
	
	
	public static String GetAffilie(String isu, String sHubToken) {

		String reponse = "No patient";
		String response_status = "";
		String requetteaffillie = "";
		 String isu_aff = "", nom_aff = "" , prenom_aff = "", empl_aff = ""; 
		 String sAssureur = "MFP";
		 String sISU = isu;
		
		try {
		
		HttpClient	client ;
		HttpPost	req ;
		  client = HttpClients.createDefault();
		    req = new HttpPost(SH.cs("MED_HUBfetchaffiliate","http://10.241.10.25:8080/HMKInterface/fetchAffiliated"));
		    req.setHeader("Content-Type", "application/json");  
		    req.setHeader("Authorization", "Bearer "+sHubToken);
		    requetteaffillie = "{\"msg_hd\":{"+
		                           "\"msg_function\":\"fetchAffilited\","+
		                           "\"msg_date\":\""+ new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())+"\","+
		                           "\"msg_snd\":\""+SH.cs("HUB_username","HMK")+"\","+
		                           "\"msg_rcv\":\""+SH.cs("HUB_rcv","EASYROUTER")+"\","+
		                           "\"msg_key\":\""+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new Date())+"/"+SH.cs("HUB_sender","HMK")+"/"+sAssureur+"/"+sISU+"\""+
		                           "},\"msg_body\":"+
		                           "{\"aff\":{"+
		                        	   "\"isu\":\""+isu+
		                        	   "\"}"+
		                           "}"+
		                        "}";
		    StringEntity reqEntity = new StringEntity(requetteaffillie.replaceAll("'","\""));
		     req.setEntity(reqEntity);
		    
		     HttpResponse resp = client.execute(req); 
		     HttpEntity entity = resp.getEntity();
		     
		     JsonReader jra = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
		     JsonObject joa = jra.readObject(); 
		     
		     if(joa.getJsonObject("msg_hd").getString("msg_status").equalsIgnoreCase("SUCCESS")){
		    	 
		    	 isu_aff = joa.getJsonObject("msg_body").getJsonObject("aff").getString("isu");
		    	 nom_aff = joa.getJsonObject("msg_body").getJsonObject("aff").getString("nam");
		    	 prenom_aff = joa.getJsonObject("msg_body").getJsonObject("aff").getString("srn");
		    	 empl_aff = joa.getJsonObject("msg_body").getJsonObject("aff").getString("emp_cod");
		    	 //resultataffilie = "Test response";
		    	 
		       
		         reponse = "<table width='100%'>";
		         reponse+= "<tr><td class='admin' >ISU:</td><td class='admin2' >"+isu_aff+"</td></tr>";
		         reponse+= "<tr><td class='admin' >Nom:</td><td class='admin2' >"+nom_aff+"</td></tr>";
		         reponse+= "<tr><td class='admin' >Prenom:</td><td class='admin2'>"+prenom_aff+"</td></tr>";
		         reponse+= "<tr><td class='admin' >Employeur:</td><td class='admin2'>"+empl_aff+"</td></tr></table>";
		        
		    	 
		    		 
		     }else{
		    	 
		    	 if(joa.getJsonObject("msg_hd").getString("msg_status").equalsIgnoreCase("NO FOUND")) {
		    
		    	
		    		 reponse = "<table width='100%' ><tr><td class='admin'>Erreur:</td><td class='admin2' >L'ISU: "+isu+" n'a pa ete retrouve</td></tr></table>";
		    	 
		    	 }else {
		    		 
		    		 reponse = "<table width='100%' ><tr><td class='admin'>Erreur:</td><td class='admin2' >Erreur inconu</td></tr></table>";
		    		 
		    	 }
		    	 
		    	 
		     }
		
		     reponse+= "<span>00000chek</span>";
		     
		}catch(Exception e) {
			return reponse + " : " + e.getMessage();
		}
	
	return reponse;	
	
   }	
	
	
	
	
	public static JsonObject SendPatientToMfpByPrescription(String prescription, String sHubToken) {
		
		int patient_case = 0;
		String nom_adherant = "";
		String nom_adherant_name = "";
		String nom_adherant_srname = "";
		String personidd = Prescription.get(prescription).getPatientUid();
		String requetteaffillie = "";
	    String isu_aff = "";
	    Prescription prescr = Prescription.get(prescription);
	    isu_aff = "HMK_" + personidd + "_0045";
		JsonObject add_response_status = null;
	   	String card_number = "0000";
	   	String assurance_number = "00000";
	   	String ass_status, status_a_afficher = "Lui-meme";

	   	String nam =  "";
	   	String srm = "";
	   	String isuprincipal = "";
	    String employer = "";
	   
	   	ass_status = "";
		Insurance ins = null;
	   	
	   	
	   	
	   	if(prescr.getPatient().getFullName().split(",").length > 0) {
	   		 nam =  prescr.getPatient().getFullName().split(",")[0];	
	   	}
	   
	   	if(prescr.getPatient().getFullName().split(",").length > 1) {
	   		 srm =  prescr.getPatient().getFullName().split(",")[1];
	   	}
	   	
	   
	 
	    Vector activeInsurances = Insurance.getCurrentInsurances(personidd);
	   	Insurance insurance = (Insurance)activeInsurances.elementAt(0);
	   	
	   	
	    for(int i = 0; i < activeInsurances.size(); i++ ) {
		   	 ins = (Insurance)activeInsurances.elementAt(i);
		   	
		    if(nom_adherant.toString().length() > 0) {break;}
	   	
	    ass_status = insurance.getStatus();
   	    assurance_number = insurance.getInsuranceNr();
   	    card_number = insurance.getMemberImmat(); 
   	    nom_adherant = insurance.getMember();
   	    
   	    if(nom_adherant.toString().length() > 0 ) {
   	    	   if(nom_adherant.trim().split("\\s+").length > 0) {
   	      nom_adherant_name =  nom_adherant.trim().split("\\s+")[0];	
		  nom_adherant_srname =  nom_adherant.trim().split("\\s+")[0];	
   	    	   };
   	    	if(nom_adherant.trim().split("\\s+").length > 1) {
   	      nom_adherant_name =  nom_adherant.trim().split("\\s+")[0];	
   		  nom_adherant_srname =  nom_adherant.trim().split("\\s+")[1];
   	    	   }
   	    }
   	    
   	    if(ins.getMemberEmployer().length() < 1) {
   	    	employer = ""	;
   	    }
   	    
	    }
	   	
   		
	   	
	   	switch(ass_status) {
	   	case "affilate": 
	   		status_a_afficher = "Lui-meme";
	   		isu_aff = "HMK_" + card_number + "_0045";
	   		patient_case = 0;
	   		isuprincipal = "";
	   		break;
	   	case "child": 
	   		status_a_afficher = "Enfant";
	   		patient_case = 1;
	   		isuprincipal = "HMK_" + card_number + "_0045";
	   		break;	
	   	case "partner": 
	   		status_a_afficher = "Conjoint";
	   		patient_case = 2;
	   		isuprincipal = "HMK_" + card_number + "_0045";
	        break;	
	   	}
		
		try {
		
		HttpClient	client ;
		HttpPost	req ;
		
		 req = new HttpPost(SH.cs("MED_HUBaddaffiliate","http://10.241.10.25:8080/HMKInterface/addAffiliated"));
		 req.setHeader("Content-Type", "application/json");  
		 req.setHeader("Authorization", "Bearer "+sHubToken);
		
		  client = HttpClients.createDefault();
		  
		  if(patient_case==1|| patient_case==2) {
			  
			  String isu_pri_changed = "";
			  String status_pri_changed = "Lui-meme";
			   
			    requetteaffillie = "{\"msg_hd\":{"+
			                           "\"msg_function\":\"addAffiliated\","+
			                           "\"msg_date\":\""+ new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())+"\","+
			                           "\"msg_snd\":\""+SH.cs("HUB_username","HMK")+"\","+
			                           "\"msg_rcv\":\""+SH.cs("HUB_rcv","EASYROUTER")+"\","+
			                           "\"msg_key\":\""+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new Date())+"/"+SH.cs("HUB_sender","HMK")+"/EASYROUTER/"+isu_aff+"\""+
			                           "},\"msg_body\":"+
			                           "{\"aff\":{"+
			                           
			                        	   "\"isu\":\""+isuprincipal+ "\"," +
			                        	   "\"crd_mut_id\":\""+card_number+ "\"," +
			                        	   "\"crd_num\":\""+card_number+ "\"," +
			                        	   "\"nam\":\""+ nom_adherant_name.trim() + "\"," +
			                        	   "\"srn\":\""+ nom_adherant_srname.trim() + "\"," +
			                        	   "\"sxe\":\""+prescr.getPatient().getBioGender() + "\"," +
			                        	   
			                        	   "\"crd_nbr\":\""+card_number+ "\"," +
			                        	   "\"ins_nbr\":\""+assurance_number+ "\"," +
			                        	   
			                        	   "\"emp_cod\":\""+ employer + "\"," +  
			                        	   
			                        	   "\"sts\":\""+status_pri_changed+ "\"," +
			                        	   "\"ins_nbr\":\""+assurance_number+ "\"," +
			                        	   "\"isu_pri\":\""+isu_pri_changed+ "\"," +
			                        	   "\"sts_reg\":\"OK\"" + "," +
			                        	   "\"rat_part\":\"80%\"" +
			                        	  
			                        	  "}"+
			                           "}"+
			                        "}";
			     System.out.println("Sent object creation de l'adherent : " + requetteaffillie);
			     StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(requetteaffillie));
			     req.setEntity(reqEntity);
			     HttpResponse resp = client.execute(req); 
			     HttpEntity entity = resp.getEntity();
			     
			     System.out.println("Resultat creation de l'adherent : " + entity.toString());
			  
			  
		  }else {
			 // isuprincipal = ""; 
		  }
		  
		    requetteaffillie = "{\"msg_hd\":{"+
		                           "\"msg_function\":\"addAffiliated\","+
		                           "\"msg_date\":\""+ new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())+"\","+
		                           "\"msg_snd\":\""+SH.cs("HUB_username","HMK")+"\","+
		                           "\"msg_rcv\":\""+SH.cs("HUB_rcv","EASYROUTER")+"\","+
		                           "\"msg_key\":\""+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new Date())+"/"+SH.cs("HUB_sender","HMK")+"/EASYROUTER/"+isu_aff+"\""+
		                           "},\"msg_body\":"+
		                           "{\"aff\":{"+
		                           
		                        	   "\"isu\":\""+isu_aff+ "\"," +
		                        	   "\"crd_mut_id\":\""+card_number+ "\"," +
		                        	   "\"crd_num\":\""+card_number+ "\"," +
		                        	   "\"nam\":\""+ nam.trim() + "\"," +
		                        	   "\"srn\":\""+ srm.trim() + "\"," +
		                        	   "\"sxe\":\""+prescr.getPatient().getBioGender() + "\"," +
		                        	   
		                        	   "\"crd_nbr\":\""+card_number+ "\"," +
		                        	   "\"ins_nbr\":\""+assurance_number+ "\"," +
		                        	   
		                        	   "\"emp_cod\":\""+ employer + "\"," +  
		                        	   
		                        	   "\"sts\":\""+status_a_afficher+ "\"," +
		                        	   "\"ins_nbr\":\""+assurance_number+ "\"," +
		                        	   "\"isu_pri\":\""+isuprincipal+ "\"," +
		                        	   "\"sts_reg\":\"OK\"" + "," +
		                        	   "\"rat_part\":\"80%\"" +
		                        	  
		                        	  "}"+
		                           "}"+
		                        "}";
		     System.out.println("Sent object patient creation: " + requetteaffillie);
		     StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(requetteaffillie));
		     req.setEntity(reqEntity);
		     HttpResponse resp = client.execute(req); 
		     
		     
		     
		     
		     HttpEntity entity = resp.getEntity();
		     JsonReader jra = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
		     JsonObject joa = jra.readObject(); 
		     add_response_status = joa;
		     
		 
		}catch(Exception e) {
			//return add_response_status;
		}
		return  add_response_status;	
	}
	
	
	
	
	public static JsonObject SendPatientToMfp(String invoice, String sHubToken) {
		
		int patient_case = 0;
		String nom_adherant = "";
		String nom_adherant_name =  "";	
		String nom_adherant_srname =  "";
		String personid = PatientInvoice.get(invoice).getPatientUid();
		String requetteaffillie = "";
	    String isu_aff = "";
	    PatientInvoice inv = PatientInvoice.get(invoice);
	    isu_aff = "HMK_" + personid + "_0045";
		JsonObject add_response_status = null;
	   	String card_number = "0000";
	   	String assurance_number = "00000";
	   	String ass_status, status_a_afficher = "Lui-meme";
	   	String nam =  "";
	   	String srm = "";
	   	String isuprincipal = "";
	    String employer = "";
	   	ass_status = "";
	   	Insurance ins = null;
	   	
	   	
	   	
	   	if(inv.getPatient().getFullName().split(",").length > 0) {
	   		 nam =  inv.getPatient().getFullName().split(",")[0];	
	   	}
	   
	   	if(inv.getPatient().getFullName().split(",").length > 1) {
	   		 srm =  inv.getPatient().getFullName().split(",")[1];
	   	}
	   	
	   
	   	
	      //if(inv.getDebets().size() >0) {
	   		//Debet firstdebet = (Debet)inv.getDebets().elementAt(0);
	   	     //ins = firstdebet.getInsurance();
	   	    //ass_status = ins.getStatus();
	   	    //assurance_number = ins.getInsuranceNr();
	   	   // card_number = ins.getMemberImmat(); 
	   	    //recuperer l'adherant 
	   	    //nom_adherant = ins.getMember(); 
	   	    //}
	   	
	   	
	    Vector activeInsurances = Insurance.getCurrentInsurances(personid);
	    
	    for(int i = 0; i < activeInsurances.size(); i++ ) {
	   	 ins = (Insurance)activeInsurances.elementAt(i);
	   	
	    if(nom_adherant.toString().length() > 0) {break;}
	   	
	   	
	    ass_status = ins.getStatus();
   	    assurance_number = ins.getInsuranceNr();
   	    card_number = ins.getMemberImmat(); 
   	    nom_adherant = ins.getMember();
   	    
   	    
   	    if(nom_adherant.toString().length() > 0 ) {
	    	   if(nom_adherant.trim().split("\\s+").length > 0) {
	      nom_adherant_name =  nom_adherant.trim().split("\\s+")[0];	
		  nom_adherant_srname =  nom_adherant.trim().split("\\s+")[0];	
	    	   };
	    	if(nom_adherant.split(" ").length > 1) {
	      nom_adherant_name = nom_adherant.trim().split("\\s+")[0];	
		  nom_adherant_srname = nom_adherant.trim().split("\\s+")[1];
	    	   }
	    }
   	    
   	   if(ins.getMemberEmployer().length() < 1) {
  	    	employer = ""	;
  	    }
   	  
	  }
	   	
		
 
	   	
	   	switch(ass_status) {
	   	case "affilate": 
	   		status_a_afficher = "Lui-meme";
	   		isu_aff = "HMK_" + card_number + "_0045";
	   		patient_case = 0;
	   		isuprincipal = "";
	   		break;
	   	case "child": 
	   		status_a_afficher = "Enfant";
	   		patient_case = 1;
	   		isuprincipal = "HMK_" + card_number + "_0045";
	   		break;	
	   	case "partner": 
	   		status_a_afficher = "Conjoint";
	   		patient_case = 2;
	   		isuprincipal = "HMK_" + card_number + "_0045";
	        break;	
	   	}
		
		try {
		
		HttpClient	client ;
		HttpPost	req ;
		
		 req = new HttpPost(SH.cs("MED_HUBaddaffiliate","http://10.241.10.25:8080/HMKInterface/addAffiliated"));
		 req.setHeader("Content-Type", "application/json");  
		 req.setHeader("Authorization", "Bearer "+sHubToken);
		
		  client = HttpClients.createDefault();
		  
		  if(patient_case==1|| patient_case==2) {
			  
			  
			  String isu_pri_changed = "";
			  String status_pri_changed = "Lui-meme";
			  
			   
			    requetteaffillie = "{\"msg_hd\":{"+
			                           "\"msg_function\":\"addAffiliated\","+
			                           "\"msg_date\":\""+ new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())+"\","+
			                           "\"msg_snd\":\""+SH.cs("HUB_username","HMK")+"\","+
			                           "\"msg_rcv\":\""+SH.cs("HUB_rcv","EASYROUTER")+"\","+
			                           "\"msg_key\":\""+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new Date())+"/"+SH.cs("HUB_sender","HMK")+"/EASYROUTER/"+isu_aff+"\""+
			                           "},\"msg_body\":"+
			                           "{\"aff\":{"+
			                           
			                        	   "\"isu\":\""+isuprincipal+ "\"," +
			                        	   "\"crd_mut_id\":\""+card_number+ "\"," +
			                        	   "\"crd_num\":\""+card_number+ "\"," +
			                        	   "\"nam\":\""+ nom_adherant_name.trim() + "\"," +
			                        	   "\"srn\":\""+ nom_adherant_srname.trim() + "\"," +
			                        	   "\"sxe\":\""+inv.getPatient().getBioGender() + "\"," +
			                        	   
			                        	   "\"crd_nbr\":\""+card_number+ "\"," +
			                        	   "\"ins_nbr\":\""+assurance_number+ "\"," +
			                        	   
			                        	   "\"emp_cod\":\""+ employer + "\"," +  
			                        	   
			                        	   "\"sts\":\""+status_pri_changed+ "\"," +
			                        	   "\"ins_nbr\":\""+assurance_number+ "\"," +
			                        	   "\"isu_pri\":\""+isu_pri_changed+ "\"," +
			                        	   "\"sts_reg\":\"OK\"" + "," +
			                        	   "\"rat_part\":\"80%\"" +
			                        	  
			                        	  "}"+
			                           "}"+
			                        "}";
		
			     System.out.println("Sent object creation de l'adherent : " + requetteaffillie);
			     StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(requetteaffillie));
			     req.setEntity(reqEntity);
			     HttpResponse resp = client.execute(req); 
			     HttpEntity entity = resp.getEntity();
			     
			     
			     JsonReader jra = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
			     JsonObject joa = jra.readObject(); 
			     add_response_status = joa;
			     
			     System.out.println("Resultat creation de l'adherent : " + joa.toString());
			  
			  
		  }else {
			  //isuprincipal = ""; 
		  }
		  
		    requetteaffillie = "{\"msg_hd\":{"+
		                           "\"msg_function\":\"addAffiliated\","+
		                           "\"msg_date\":\""+ new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())+"\","+
		                           "\"msg_snd\":\""+SH.cs("HUB_username","HMK")+"\","+
		                           "\"msg_rcv\":\""+SH.cs("HUB_rcv","EASYROUTER")+"\","+
		                           "\"msg_key\":\""+new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(new Date())+"/"+SH.cs("HUB_sender","HMK")+"/EASYROUTER/"+isu_aff+"\""+
		                           "},\"msg_body\":"+
		                           "{\"aff\":{"+
		                           
		                        	   "\"isu\":\""+isu_aff+ "\"," +
		                        	   "\"crd_mut_id\":\""+card_number+ "\"," +
		                        	   "\"crd_num\":\""+card_number+ "\"," +
		                        	   "\"nam\":\""+ nam.trim() + "\"," +
		                        	   "\"srn\":\""+ srm.trim() + "\"," +
		                        	   "\"sxe\":\""+inv.getPatient().getBioGender() + "\"," +
		                        	   
		                        	   "\"crd_nbr\":\""+card_number+ "\"," +
		                        	   "\"ins_nbr\":\""+assurance_number+ "\"," +
		                        	   
		                        	   "\"emp_cod\":\""+ employer + "\"," +  
		                        	   
		                        	   "\"sts\":\""+status_a_afficher+ "\"," +
		                        	   "\"ins_nbr\":\""+assurance_number+ "\"," +
		                        	   "\"isu_pri\":\""+isuprincipal+ "\"," +
		                        	   "\"sts_reg\":\"OK\"" + "," +
		                        	   "\"rat_part\":\"80%\"" +
		                        	  
		                        	  "}"+
		                           "}"+
		                        "}";
		     System.out.println("Sent object patient creation: " + requetteaffillie);
		     StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(requetteaffillie));
		     req.setEntity(reqEntity);
		     HttpResponse resp = client.execute(req); 
		     
		     
		     
		     
		     HttpEntity entity = resp.getEntity();
		     JsonReader jra = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
		     JsonObject joa = jra.readObject(); 
		     add_response_status = joa;
		     
		 
		}catch(Exception e) {
			//return add_response_status;
		}
		return  add_response_status;	
	}
	
	public static Boolean CheckTempUsiSaved(String object, int typeobject) throws SQLException{
		
        Boolean response = false;
        String  isu_aff = "";
        int count  = 0;
        
        if(typeobject==0) {

	      isu_aff = "HMK_" + PatientInvoice.get(object).getPatientUid() + "_0045";
        }
        
        if(typeobject==1) {
             
    	      isu_aff = "HMK_" + Prescription.get(object).getPatientUid() + "_0045";
            }
	    
        System.out.println("USI hub: " + isu_aff);
		
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		
		PreparedStatement ps = conn.prepareStatement("SELECT count(*) FROM  oc_pointers WHERE oc_pointer_key = ? and oc_pointer_value = ?");
		ps.setString(1, "MEDHUBID."+isu_aff);
		ps.setString(2, isu_aff);
		ResultSet rs = ps.executeQuery();
	
		try {
	     rs.next();
	      count = rs.getInt(1);   
	      
	     if(count > 0) {
	    	   response = true;
	       }
	       
		conn.close();
		ps.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		 System.out.println("USI hub lines : " + count);
		
		return response;	
	}
	
	public static void SaveTempisu(String object, int type_object) {
		
		String isu_tempo = "";
		if(type_object==0) {
	     isu_tempo = "HMK_" + PatientInvoice.get(object).getPatientUid() + "_0045";
		}
		
		if(type_object==1) {
		     isu_tempo = "HMK_" + Prescription.get(object).getPatientUid() + "_0045";
			}
	    
	    Pointer.storePointer("MEDHUBID."+isu_tempo, isu_tempo);
	    
	}
	
	
	
	private static String getMatrPatient(String patientuid) throws SQLException {
		String patientmatr = null;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement("SELECT immatnew FROM  adminview WHERE personid = ?");
		ps.setString(1, patientuid);
		ResultSet rs = ps.executeQuery();
		///comment for test 
		
		try {
	
		while(rs.next()) {	
			patientmatr = rs.getString("immatnew");		
		}
		conn.close();
		ps.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return patientmatr;		
	  }
	
	
	public static String getPatientInvoiceSignature(String patientinvoiceuid) throws SQLException {
		String mfpsignature = null;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement(
	    " select AdminView.lastname, AdminView.firstname from  AdminView , UsersView, OC_PATIENTINVOICES oc_pa " +   
		" where UsersView.personid = AdminView.personid "+ 
		" and oc_pa.OC_PATIENTINVOICE_ACCEPTATIONUID = UsersView.userid "+ 
		" and concat( oc_pa.OC_PATIENTINVOICE_SERVERID,'.', oc_pa.OC_PATIENTINVOICE_OBJECTID ) = ? "
         );
		ps.setString(1, patientinvoiceuid);
		ResultSet rs = ps.executeQuery();
		
		try {
	
		while(rs.next()) {	
			mfpsignature = rs.getString("lastname") + " " + rs.getString("firstname") ;		
		}
		conn.close();
		ps.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return mfpsignature;		
	  }
	
	
	public static  Vector<PatientInvoice> ListClosedInvoices(String begin, String end, String status, String module, String insurance, String service, String begin_select, String max, String end_select, String orderby, String context) throws SQLException {
	
		
	     Vector<PatientInvoice> invoices = new Vector<PatientInvoice>();
	   
	     String result = "";
	     PreparedStatement ps = null;
	     ResultSet rs = null;
	
		service  = Service.getChildIdsAsString(service);
		
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String requet = "";
		
		requet+="SELECT ";
		
		if(SH.cs("setup.database","").equalsIgnoreCase("sqlserver")) {	
			requet+=" distinct TOP " + max + " inv.OC_PATIENTINVOICE_OBJECTID, inv.OC_PATIENTINVOICE_SERVERID ";
		 }
		
		if(SH.cs("setup.database","").equalsIgnoreCase("mysql")) {
		requet+=" distinct inv.OC_PATIENTINVOICE_OBJECTID, inv.OC_PATIENTINVOICE_SERVERID ";
	     };
	     
	requet+=" FROM oc_debets deb, oc_patientinvoices inv  ";  
		
		if(insurance.length() > 0 ) {
			requet+= ", oc_insurances ins ";
		}
		
		requet+=" WHERE inv.oc_patientinvoice_date >= ? ";
		requet+=" AND inv.oc_patientinvoice_date <= ? ";
		requet+=" AND deb.OC_DEBET_PATIENTINVOICEUID = CONCAT(inv.OC_PATIENTINVOICE_SERVERID , '.' , inv.OC_PATIENTINVOICE_OBJECTID) ";
		
		if(insurance.length() > 0 ) {
		requet+=" AND deb.OC_DEBET_INSURANCEUID = CONCAT(ins.OC_INSURANCE_SERVERID , '.' , ins.OC_INSURANCE_OBJECTID) ";
		}
		
		if(service.length() > 0) {
		requet+=" AND deb.OC_DEBET_SERVICEUID IN ("+service+") ";
		Pointer.storePointer("TEST.", service);
		}
		
		if(insurance.length() > 0 ) {
		requet+=" AND ( ins.OC_INSURANCE_INSURARUID = ? ";
		requet+=" OR deb.OC_DEBET_EXTRAINSURARUID  = ? ";
		requet+=" OR deb.OC_DEBET_EXTRAINSURARUID2 = ? )";
		}
		

		if(status.equalsIgnoreCase("all")) {
			requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled' ) ";
			}
		
		if(status.equalsIgnoreCase("open")) {
		requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' ) ";
		}
		if(status.equalsIgnoreCase("closed")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
		}
		
		if(status.equalsIgnoreCase("canceled")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'canceled' ";
		}
		
		
		if(status.equalsIgnoreCase("validated")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			requet+=" AND ( inv.oc_patientinvoice_acceptationuid != '' OR  inv.oc_patientinvoice_acceptationuid != 'NULL' )";
			}
		
		if(status.equalsIgnoreCase("novalidated")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			requet+=" AND ( inv.oc_patientinvoice_acceptationuid = '' OR  inv.oc_patientinvoice_acceptationuid = 'NULL' )";
			}
		
		if(status.equalsIgnoreCase("sent")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			if(module.equalsIgnoreCase("OBR")) {
			requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
			}
			if(module.equalsIgnoreCase("MedHub")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
			}
		
		if(status.equalsIgnoreCase("errors")) {
			requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled') ";
			if(module.equalsIgnoreCase("OBR")) {
			requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.ERROR.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
			}
			if(module.equalsIgnoreCase("MedHub")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.ERROR.USER.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
			}
		
		if(orderby.equalsIgnoreCase("ASC")) {
		requet+=" AND inv.OC_PATIENTINVOICE_OBJECTID > ? ";
		}
		
		if(orderby.equalsIgnoreCase("DESC")) {
			requet+=" AND inv.OC_PATIENTINVOICE_OBJECTID < ? ";
			}
		
		
		if(orderby.equalsIgnoreCase("DESC")) {
			 requet+=" ORDER BY inv.OC_PATIENTINVOICE_OBJECTID DESC ";
  	     }
		
		if(SH.cs("setup.database","").equalsIgnoreCase("mysql")) {	
		requet+=" LIMIT " + max;
		}
		
	
		 ps = conn.prepareStatement(requet);
	
		  
		 ps.setDate(1,ScreenHelper.getSQLDate(begin));
		 ps.setDate(2,ScreenHelper.getSQLDate(end));
		 
		  int param_index = 2;
		  
		  if(service.length() > 0) {
			  //param_index ++;  
       	      //ps.setString(param_index, service);
			  
			  //ps.setString(param_index, Service.getChildIdsAsString(service));
       	           
		  }
		  
		  
           if(insurance.length() > 0 ) {
        	   param_index ++;  
        	   ps.setString(param_index,insurance);
        	   param_index ++;  
        	   ps.setString(param_index,insurance);
        	   param_index ++;  
        	   ps.setString(param_index,insurance);
           }
          
           param_index ++;  
           
           if(orderby.equalsIgnoreCase("ASC")) {
    	   ps.setString(param_index, end_select);
	        }
           
           if(orderby.equalsIgnoreCase("DESC")) {
        	   ps.setString(param_index, begin_select);
    	        }
           
	
		 rs = ps.executeQuery();
		
		try {
	
		while(rs.next()) {	
			invoices.add(PatientInvoice.get(rs.getInt("OC_PATIENTINVOICE_SERVERID")+"."+rs.getInt("OC_PATIENTINVOICE_OBJECTID")));
		}
		conn.close();
		ps.close();
		rs.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
		
		Integer invoiceCount = 0;
		
		DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));
	
	     if(orderby.equalsIgnoreCase("DESC")) {
	    	 if(invoices!=null && invoices.size() > 0) {
		 invoices = reverse(invoices); 
	    	 }
	     }
		
		if(invoices.size() > 0) {
		PatientInvoice inv = (PatientInvoice)invoices.elementAt(0);
		begin_select = ""+inv.getObjectId();
		  }
		
		result +="<table width='100%'>";
		
			for(int n=0; n<invoices.size(); n++){
				
	        	PatientInvoice invoice = (PatientInvoice)invoices.elementAt(n);
	        	
	        	invoiceCount++;
	       
	        	result += "<tr class='admin'>";
	        	result += "<td colspan='1' class='admin2'>" +invoice.getUid()+"</td>";
	        	result +="<td colspan='1' class='admin2'>"+ScreenHelper.formatDate(invoice.getDate())+"</td>";

	        	result +="<td colspan='1' class='admin2'>"+invoice.getPatientUid()+"</td>";
	    		
	        	result +="<td colspan='1' class='admin2'>"+deci.format(invoice.getBalance())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td>";
	    	
	    		   if(invoice.getStatus().equalsIgnoreCase("open")){
	    		 result +="<td colspan='1' class='admin2' style='color:red;'>"+HTMLEntities.htmlentities(invoice.getStatus())+"</td>";
	                }else{
	             result +="<td colspan='1' class='admin2' >"+HTMLEntities.htmlentities(invoice.getStatus())+"</td>";  
	                }
	    		   
	    		   
	    		   String info  = ""; 
	    		 
	    		    //OBR obr = new OBR();
	    	        //String signature_obr = "";
	    			//signature_obr = obr.getSignature(invoice.getUid()); 
	    			//if(signature_obr.length() > 0){
	    			//signature_obr = signature_obr.substring(0,10); 
	    			//}
	    			//String signature1 = ""; 
	    			 //signature1 = MedHub.getPatientResumeSignature(invoice.getObjectId()) ;
	    			 //String signature2 = ""; 
	    			  //signature2 = MedHub.getPatientInvoiceSignature(invoice.getUid());
	    			
	    		   //info = info + signature1 +","
	    				      //  + signature2 ;
	    		   
	    		   info = info + "<br>"; 
	    		   
	    		   
	     		  // info = info + Pointer.getPointer("MEDH.ERROR.USER."+invoice.getUid());
	     		   //info = info + ","+Pointer.getPointer("MEDH.ERROR."+invoice.getUid());
	     		   
	    		   info = info + "M "+"&nbsp;"  + MedHub.getSendingStatus(invoice.getUid(),context);
	    		   info = info + "&nbsp;";
	    		   info = info + "O " + "&nbsp;" +  OBR.getSendingStatus(invoice.getUid(),context);
	    		   info = info + "&nbsp;";
	    		   info = info + Medhubmessage.countInvoiceMessages(invoice.getUid(),context);
	    		   info = info + "&nbsp;";
	    		   
	     		   //info = info + "<br>"; 
	    		   //info = info + "<a href='#' onclick='OpenDiscussion("+ invoice.getObjectId() +")'>message(0)</a>";
	    		  //info = info + "<br>"; 
	    		   
	    		   //info = info + "Medhub:" + Pointer.getPointer("MEDH.INV."+invoice.getUid());
	    		   //info = info + "<br>"; 
	               //info = info + "OBR:" + Pointer.getPointer("OBR.INV."+invoice.getUid());
	    		   
	    		   //info = info + "<br>";
	    		   //info = info + "<span ><a  href='#' onclick='OpenDiscussion("+ invoice.getObjectId() +")' >";
	    		   //info = info + signature_obr;
	    		  //info = info + "</a></span>";
	    		   //info = info + "<br>";
	    		   //info = info + Pointer.getPointer("FOLLOW."+invoice.getServerId()+ "." +invoice.getObjectId());   	
	    		      		  
	    		   
	     		  result +="<td class='admin2'>"+info+"</td>";  		 
	     		  result +="</tr>";
	     		  
	     		 end_select = ""+invoice.getObjectId();
	     		  
	        }
			
			 result +="</table>";
			
			 result +="<div id='begindiv' name='begindiv' hidden='hidden' >"+begin_select+"</div>";
			 result +="<div id='maxdiv' name='maxdiv' hidden='hidden'>"+max+"</div>";
			 result +="<div id='statusdiv' name='maxdiv' hidden='hidden'>"+status+"</div>";
			 result = result + "&nbsp;";
			 result +="<div id='enddiv' name='enddiv' hidden='hidden' >"+end_select+"</div>";
			 
			 result +="<img height='16px' style='float:left;' onclick='changeList(\"DESC\")' style='vertical-align: middle' src='/openclinic/_img/icons/mobile/arrow-left.png'>";
			 result +="&nbsp;"+status;
			 result +="<img height='16px' style='float:left;' onclick='changeList(\"ASC\")' style='vertical-align: middle' src='/openclinic/_img/icons/mobile/arrow-right.png'>";
		
		
		return invoices;		
	}
	
	
	public static Integer countClosedInvoices(String begin, String end, String status, String module, String insurance, String service) throws SQLException {
		
		Integer ninvoice = 0;
		
		service  = Service.getChildIdsAsString(service);
		
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String requet = "";
		
		requet+="SELECT COUNT(distinct inv.OC_PATIENTINVOICE_OBJECTID) as countinvoice  FROM oc_debets deb, oc_patientinvoices inv  ";  
		
		if(insurance.length() > 0 ) {
			requet+= ", oc_insurances ins ";
		}
		
		requet+=" WHERE inv.oc_patientinvoice_date >= ? ";
		requet+=" AND inv.oc_patientinvoice_date <= ? ";
		requet+=" AND deb.OC_DEBET_PATIENTINVOICEUID = CONCAT(inv.OC_PATIENTINVOICE_SERVERID , '.' , inv.OC_PATIENTINVOICE_OBJECTID) ";
		
		if(insurance.length() > 0 ) {
		requet+=" AND deb.OC_DEBET_INSURANCEUID = CONCAT(ins.OC_INSURANCE_SERVERID , '.' , ins.OC_INSURANCE_OBJECTID) ";
		}
		
		if(service.length() > 0) {
		requet+=" AND deb.OC_DEBET_SERVICEUID IN ("+service+") ";
		Pointer.storePointer("TEST.", service);
		}
		
		if(insurance.length() > 0 ) {
		requet+=" AND ( ins.OC_INSURANCE_INSURARUID = ? ";
		requet+=" OR deb.OC_DEBET_EXTRAINSURARUID  = ? ";
		requet+=" OR deb.OC_DEBET_EXTRAINSURARUID2 = ? )";
		}
		

		if(status.equalsIgnoreCase("all")) {
			requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled'  ) ";
			}
		
		if(status.equalsIgnoreCase("open")) {
		requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open'  ) ";
		}
		
		
		if(status.equalsIgnoreCase("closed")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			}
		
		
		if(status.equalsIgnoreCase("canceled")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'canceled' ";
			}
		
		if(status.equalsIgnoreCase("validated")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			requet+=" AND ( inv.oc_patientinvoice_acceptationuid != '' OR  inv.oc_patientinvoice_acceptationuid != 'NULL' )";
			}
		
		if(status.equalsIgnoreCase("novalidated")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			requet+=" AND ( inv.oc_patientinvoice_acceptationuid = '' OR  inv.oc_patientinvoice_acceptationuid = 'NULL' )";
			}
		
		if(status.equalsIgnoreCase("sent")) {
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			if(module.equalsIgnoreCase("OBR")) {
			requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
			}
			if(module.equalsIgnoreCase("MedHub")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
			}
		
		if(status.equalsIgnoreCase("errors")) {
			requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled') ";
			if(module.equalsIgnoreCase("MedHub")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.ERROR.USER.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
			
			if(module.equalsIgnoreCase("OBR")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.ERROR.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
	     }
		
		if(status.equalsIgnoreCase("noservsignature")) {
			
		requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled') ";
		requet+=" AND not exists (select * from oc_pointers where oc_pointer_key  = concat('INVSERVSIGN.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				
	     }
		
		
		PreparedStatement ps = conn.prepareStatement(requet);
	
		  
		  ps.setDate(1,ScreenHelper.getSQLDate(begin));
		  ps.setDate(2,ScreenHelper.getSQLDate(end));
		  int param_index = 2;
		  
		  if(service.length() > 0) {
			  
			  //param_index ++;  
       	      //ps.setString(param_index, service);
			  //ps.setString(param_index, Service.getChildIdsAsString(service));
       	           
		  }
		  
		  
           if(insurance.length() > 0 ) {
        	   param_index ++;  
        	   ps.setString(param_index,insurance);
        	   param_index ++;  
        	   ps.setString(param_index,insurance);
        	   param_index ++;  
        	   ps.setString(param_index,insurance);
           }
	
		ResultSet rs = ps.executeQuery();
		
		try {
	
		while(rs.next()) {	
			ninvoice = rs.getInt(1);
		}
		conn.close();
		ps.close();
		rs.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return ninvoice;		
	  }
	
	
	public static Integer countSummaryInvoices(String begin, String end, String status, String module, String insurance, String service) throws SQLException {
		Integer ninvoice = 0;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String requet = "";
		
		service  = Service.getChildIdsAsString(service);
	
		requet+=" SELECT count(oc_pa.oc_patientinvoice_objectid) FROM oc_patientinvoices oc_pa, OC_SUMMARYINVOICES cons, OC_SUMMARYINVOICEITEMS lien, oc_debets deb  ";
		if(insurance.length() > 0 ) {
			requet+=", oc_insurances ins ";
			}
		requet+=" WHERE oc_pa.oc_patientinvoice_date >= ? ";
		requet+=" AND oc_pa.oc_patientinvoice_date <= ? ";
		
		requet+=" and lien.OC_ITEM_PATIENTINVOICEUID = CONCAT( oc_pa.OC_PATIENTINVOICE_SERVERID ,'.', oc_pa.OC_PATIENTINVOICE_OBJECTID ) ";
		requet+=" and lien.OC_ITEM_SUMMARYINVOICEUID = CONCAT( cons.OC_SUMMARYINVOICE_SERVERID ,'.', cons.OC_SUMMARYINVOICE_OBJECTID ) ";
		requet+=" and deb.OC_DEBET_PATIENTINVOICEUID = CONCAT(oc_pa.OC_PATIENTINVOICE_SERVERID , '.' , oc_pa.OC_PATIENTINVOICE_OBJECTID) ";
		
		if(insurance.length() > 0 ) {
		requet+=" AND deb.OC_DEBET_INSURANCEUID = CONCAT(ins.OC_INSURANCE_SERVERID , '.' , ins.OC_INSURANCE_OBJECTID) ";
		}
		
		if(service.length() > 0) {
		requet+=" AND deb.OC_DEBET_SERVICEUID IN ("+service+") ";
		}
		
		  if(insurance.length() > 0 ) {
		requet+=" AND ( ins.oc_insurance_insuraruid = ? ";
		requet+=" OR deb.OC_DEBET_EXTRAINSURARUID  = ? ";
		requet+=" OR deb.OC_DEBET_EXTRAINSURARUID2 = ? ) " ;
		  }
		
		

		    if(status.equalsIgnoreCase("all")) {
			requet+=" AND (  cons.OC_SUMMARYINVOICE_STATUS ='open'  OR cons.OC_SUMMARYINVOICE_STATUS ='closed' OR cons.OC_SUMMARYINVOICE_STATUS ='canceled'  ) ";
			}

		    if(status.equalsIgnoreCase("open")) {
			requet+=" AND (  cons.OC_SUMMARYINVOICE_STATUS ='open' ) ";
			}
			if(status.equalsIgnoreCase("closed")) {
				requet+="  AND cons.OC_SUMMARYINVOICE_STATUS ='closed' ";
		    }
			
			if(status.equalsIgnoreCase("canceled")) {
				requet+="  AND cons.OC_SUMMARYINVOICE_STATUS ='canceled' ";
		    }
			
			
			if(status.equalsIgnoreCase("validated")) {
				requet+=" AND cons.OC_SUMMARYINVOICE_STATUS ='closed' ";
				requet+=" AND ( cons.OC_SUMMARYINVOICE_VALIDATED !=''  OR  cons.OC_SUMMARYINVOICE_VALIDATED != 'NULL' )";
				}
			
			if(status.equalsIgnoreCase("novalidated")) {
				requet+=" AND cons.OC_SUMMARYINVOICE_STATUS ='closed' ";
				requet+=" AND ( cons.OC_SUMMARYINVOICE_VALIDATED =''  OR  cons.OC_SUMMARYINVOICE_VALIDATED = 'NULL' )";
				}
			
			if(status.equalsIgnoreCase("sent")) {
				requet+=" AND cons.OC_SUMMARYINVOICE_STATUS ='closed' ";
				if(module.equalsIgnoreCase("OBR")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
				if(module.equalsIgnoreCase("MedHub")) {
					requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					}
		     }
			
			
			
		
		PreparedStatement ps = conn.prepareStatement(requet);
	
		  
		  ps.setDate(1,ScreenHelper.getSQLDate(begin));
		  ps.setDate(2,ScreenHelper.getSQLDate(end));
		  int param_index = 2;
		  
		  if(service.length() > 0) {
			 // param_index ++;  
       	     // ps.setString(param_index,service);
       	   //Pointer.storePointer("TEST.", service);
		  }
		  
		   if(insurance.length() > 0 ) {
	        	   param_index ++;  
	        	   ps.setString(param_index,insurance);
	        	   param_index ++;  
	        	   ps.setString(param_index,insurance);
	        	   param_index ++;  
	        	   ps.setString(param_index,insurance);
	          }
		  
      
		ResultSet rs = ps.executeQuery();
		
		try {
	
		while(rs.next()) {	
			ninvoice = rs.getInt("countinvoice");		
		}
		conn.close();
		ps.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return ninvoice;		
	  }
	
	
	
	public static Double AmountInvoices(String begin, String end, String status, String module, String insurance, String service, int type_assurance) throws SQLException {
		
		service  = Service.getChildIdsAsString(service);
		Double theamount = 0.0;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String requet = "SELECT ";
		if(insurance.length() > 0) {
		        if(type_assurance==0) {
				requet+= " COALESCE(sum(deb.oc_debet_insuraramount),0) AS theamount ";
		        }
		        if(type_assurance==1) {
					requet+= " COALESCE(sum(deb.oc_debet_extrainsuraramount),0) AS theamount ";
			    }
		        if(type_assurance==2) {
					requet+= " COALESCE(sum(deb.oc_debet_amount),0) AS theamount ";
			    }
		        
		     }else {
		   
		    	 requet+= " COALESCE(sum(deb.oc_debet_insuraramount),0) + ";
		    	 requet+= " COALESCE(sum(deb.oc_debet_extrainsuraramount),0) + ";
		    	 requet+= " COALESCE(sum(deb.oc_debet_amount),0) AS theamount ";
		     }
		        
				requet+= " FROM oc_patientinvoices inv, oc_debets deb ";
				
				if(insurance.length() > 0) {
				if(type_assurance==0) {
				requet+= ", oc_insurances ins ";
				}
				}
				
				
				requet+= " WHERE inv.oc_patientinvoice_date >= ? ";
				requet+= " AND inv.oc_patientinvoice_date <= ? ";
				requet+= " AND deb.OC_DEBET_PATIENTINVOICEUID = CONCAT(inv.OC_PATIENTINVOICE_SERVERID , '.' , inv.OC_PATIENTINVOICE_OBJECTID) ";
				
				if(insurance.length() > 0) {
				if(type_assurance==0) {
				requet+= " AND deb.OC_DEBET_INSURANCEUID = CONCAT(ins.OC_INSURANCE_SERVERID , '.' , ins.OC_INSURANCE_OBJECTID) ";
				}
				}
				
				if(service.length() > 0) {
			 	requet+= " AND deb.OC_DEBET_SERVICEUID IN ( "+service+ ") ";
			 	Pointer.storePointer("TEST.", service);
				}
				
				
				if(insurance.length() > 0) {
			      if(type_assurance==0) {
			    	  requet+= " AND ins.oc_insurance_insuraruid = ? ";
				      }
				        if(type_assurance==1) {
							requet+= " AND deb.OC_DEBET_EXTRAINSURARUID  = ? ";
				      }
				        if(type_assurance==2) {
							requet+= "  AND deb.OC_DEBET_EXTRAINSURARUID2 = ? ";
					  }
				        
				}
			
		  if(status.equalsIgnoreCase("all")) {
			requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled') ";
		   }

		   if(status.equalsIgnoreCase("open")) {
			requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' ) ";
			}
		   
		   
			if(status.equalsIgnoreCase("closed")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			  }
			
			if(status.equalsIgnoreCase("canceled")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'canceled' ";
			  }
			
			if(status.equalsIgnoreCase("validated")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
				requet+=" AND ( inv.oc_patientinvoice_acceptationuid != '' OR  inv.oc_patientinvoice_acceptationuid != 'NULL'  )";
				}
			
			if(status.equalsIgnoreCase("novalidated")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
				requet+=" AND ( inv.oc_patientinvoice_acceptationuid = '' OR  inv.oc_patientinvoice_acceptationuid = 'NULL'  )";
				}
			
			if(status.equalsIgnoreCase("sent")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
				if(module.equalsIgnoreCase("OBR")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
				if(module.equalsIgnoreCase("MedHub")) {
					requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					}
		     }
			
			if(status.equalsIgnoreCase("errors")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
				if(module.equalsIgnoreCase("MedHub")) {
					requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.ERROR.USER.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					}
				
				if(module.equalsIgnoreCase("OBR")) {
					requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.ERROR.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					}
		     }
			
			if(status.equalsIgnoreCase("noservsignature")) {
				
			requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			requet+=" AND not exists (select * from oc_pointers where oc_pointer_key  = concat('INVSERVSIGN.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					
		     }
			

		PreparedStatement ps = conn.prepareStatement(requet);
	
		  
		  ps.setDate(1,ScreenHelper.getSQLDate(begin));
		  ps.setDate(2,ScreenHelper.getSQLDate(end));
		  int param_index = 2;
		  
		  if(service.length() > 0) {
			  //param_index ++;  
       	      //ps.setString(param_index,service);
		  }
		  
		   if(insurance.length() > 0 ) {
	        	   param_index ++;  
	        	   ps.setString(param_index,insurance);
	          }
		  
		ResultSet rs = ps.executeQuery();
		
		try {
	
		while(rs.next()) {	
			theamount = rs.getDouble("theamount");		
		}
		conn.close();
		ps.close();
		rs.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
		
		return  theamount;		
	  }
	
	
	public static Double AmmountSummaryInvoices(String begin, String end, String status, String module, String insurance, String service, int type_assurance) throws SQLException {
        
		service  = Service.getChildIdsAsString(service);
		Double  ninvoice = 0.0;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	
		String requet = "SELECT ";
		if(insurance.length() > 0) {
		        if(type_assurance==0) {
				requet+= " COALESCE(sum(deb.oc_debet_insuraramount),0) AS theamount ";
		        }
		        if(type_assurance==1) {
					requet+= " COALESCE(sum(deb.oc_debet_extrainsuraramount),0) AS theamount ";
			        }
		        if(type_assurance==2) {
					requet+= " COALESCE(sum(deb.oc_debet_amount),0) AS theamount ";
			        }
		        
		     }else {
		   
		    	 requet+= " COALESCE(sum(deb.oc_debet_insuraramount),0) + ";
		    	 requet+= " COALESCE(sum(deb.oc_debet_extrainsuraramount),0) + ";
		    	 requet+= " COALESCE(sum(deb.oc_debet_amount),0) AS theamount ";
		     }

		requet+= " FROM oc_patientinvoices oc_pa, OC_SUMMARYINVOICES cons, OC_SUMMARYINVOICEITEMS lien, oc_debets deb ";
		if(insurance.length() > 0 ) {
		requet+=", oc_insurances ins ";
			}
		requet+=" WHERE oc_pa.oc_patientinvoice_date >= ? ";
		requet+=" AND oc_pa.oc_patientinvoice_date <= ? ";
		
		requet+=" AND lien.OC_ITEM_PATIENTINVOICEUID = CONCAT( oc_pa.OC_PATIENTINVOICE_SERVERID ,'.', oc_pa.OC_PATIENTINVOICE_OBJECTID ) ";
		requet+=" AND lien.OC_ITEM_SUMMARYINVOICEUID = CONCAT( cons.OC_SUMMARYINVOICE_SERVERID ,'.', cons.OC_SUMMARYINVOICE_OBJECTID ) ";
		requet+=" AND  deb.OC_DEBET_PATIENTINVOICEUID = CONCAT(oc_pa.OC_PATIENTINVOICE_SERVERID , '.' , oc_pa.OC_PATIENTINVOICE_OBJECTID) ";
	
		if(insurance.length() > 0 ) {
		requet+=" AND deb.OC_DEBET_INSURANCEUID = CONCAT(ins.OC_INSURANCE_SERVERID , '.' , ins.OC_INSURANCE_OBJECTID) ";
		}
		
		if(service.length() > 0) {
		requet+=" AND deb.OC_DEBET_SERVICEUID IN ( "+ service+ " ) ";
		Pointer.storePointer("TEST.", service);
		}
		
		if(insurance.length() > 0) {
		      if(type_assurance==0) {
		    	  requet+= " AND ins.oc_insurance_insuraruid = ? ";
			        }
			        if(type_assurance==1) {
						requet+= " AND deb.OC_DEBET_EXTRAINSURARUID  = ? ";
				        }
			        if(type_assurance==2) {
						requet+= "  AND deb.OC_DEBET_EXTRAINSURARUID2 = ? ";
				        }
			        
			}
	
		if(status.equalsIgnoreCase("open")) {
			requet+=" AND (  cons.OC_SUMMARYINVOICE_STATUS ='open'  OR cons.OC_SUMMARYINVOICE_STATUS ='closed'  ) ";
			}
			if(status.equalsIgnoreCase("closed")) {
				requet+="  AND cons.OC_SUMMARYINVOICE_STATUS ='closed' ";
				}
			
			
			if(status.equalsIgnoreCase("validated")) {
				requet+=" AND cons.OC_SUMMARYINVOICE_STATUS ='closed' ";
				requet+=" AND ( cons.OC_SUMMARYINVOICE_VALIDATED =''  OR  cons.OC_SUMMARYINVOICE_VALIDATED != 'NULL' )";
				}
			
			if(status.equalsIgnoreCase("sent")) {
				requet+=" AND cons.OC_SUMMARYINVOICE_STATUS ='closed' ";
				if(module.equalsIgnoreCase("OBR")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
				if(module.equalsIgnoreCase("MedHub")) {
					requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					}
		     }
			

		
		
		
		
		PreparedStatement ps = conn.prepareStatement(requet);
	
		  
		  ps.setDate(1,ScreenHelper.getSQLDate(begin));
		  ps.setDate(2,ScreenHelper.getSQLDate(end));
		  int param_index = 2;
		  
		  if(service.length() > 0) {
			  //param_index ++;  
       	      //ps.setString(param_index,service);
		  }
		  
		   if(insurance.length() > 0 ) {
			   
			   if(type_assurance==0) {
	        	   param_index ++;  
	        	   ps.setString(param_index,insurance);
			     }
			   if(type_assurance==1) {
	        	   param_index ++;  
	        	   ps.setString(param_index,insurance);
			   }
	        	   
			   if(type_assurance==2) {
	        	   param_index ++;  
	        	   ps.setString(param_index,insurance);
			    }
	          }
		  
      
		ResultSet rs = ps.executeQuery();
		
		try {
	
		while(rs.next()) {	
			ninvoice = rs.getDouble("theamount");		
		}
		conn.close();
		ps.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return ninvoice;		
	  }
	
	
	public static Double ListAmountInvoices(String begin, String end, String status, String module, String insurance, String service, int type_assurance) throws SQLException {
		
		//service  = Service.getChildIdsAsString(service);
		Double theamount = 0.0;

		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String requet = "SELECT ";
		if(insurance.length() > 0) {
		        if(type_assurance==0) {
				requet+= " COALESCE(sum(deb.oc_debet_insuraramount),0) AS theamount ";
		        }
		        if(type_assurance==1) {
					requet+= " COALESCE(sum(deb.oc_debet_extrainsuraramount),0) AS theamount ";
			        }
		        if(type_assurance==2) {
					requet+= " COALESCE(sum(deb.oc_debet_amount),0) AS theamount ";
			        }
		        
		     }else {
		   
		    	 requet+= " COALESCE(sum(deb.oc_debet_insuraramount),0) + ";
		    	 requet+= " COALESCE(sum(deb.oc_debet_extrainsuraramount),0) + ";
		    	 requet+= " COALESCE(sum(deb.oc_debet_amount),0) AS theamount ";
		     }
		        
		        //requet+= ", deb.OC_DEBET_SERVICEUID AS serv ";
				requet+= " FROM oc_patientinvoices inv, oc_debets deb ";
				
				if(insurance.length() > 0) {
				if(type_assurance==0) {
				requet+= ", oc_insurances ins ";
				}
				}
				
				
				requet+= " WHERE inv.oc_patientinvoice_date >= ? ";
				requet+= " AND inv.oc_patientinvoice_date <= ? ";
				requet+= " AND deb.OC_DEBET_PATIENTINVOICEUID = CONCAT(inv.OC_PATIENTINVOICE_SERVERID , '.' , inv.OC_PATIENTINVOICE_OBJECTID) ";
				
				if(insurance.length() > 0) {
				if(type_assurance==0) {
				requet+= " AND deb.OC_DEBET_INSURANCEUID = CONCAT(ins.OC_INSURANCE_SERVERID , '.' , ins.OC_INSURANCE_OBJECTID) ";
				}
				}
				
				if(service.length() > 0) {
			 	requet+= " AND deb.OC_DEBET_SERVICEUID IN ( "+service+ ") ";
			 	Pointer.storePointer("TEST.", service);
				}
				
				
				if(insurance.length() > 0) {
			      if(type_assurance==0) {
			    	  requet+= " AND ins.oc_insurance_insuraruid = ? ";
				        }
				        if(type_assurance==1) {
							requet+= " AND deb.OC_DEBET_EXTRAINSURARUID  = ? ";
					        }
				        if(type_assurance==2) {
							requet+= "  AND deb.OC_DEBET_EXTRAINSURARUID2 = ? ";
					        }
				        
				}
			
		  if(status.equalsIgnoreCase("all")) {
			requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled') ";
		   }

		   if(status.equalsIgnoreCase("open")) {
			requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' ) ";
			}
		   
		   
			if(status.equalsIgnoreCase("closed")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
			  }
			
			if(status.equalsIgnoreCase("canceled")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'canceled' ";
			  }
			
			if(status.equalsIgnoreCase("validated")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
				requet+=" AND ( inv.oc_patientinvoice_acceptationuid != '' OR  inv.oc_patientinvoice_acceptationuid != 'NULL'  )";
				}
			
			if(status.equalsIgnoreCase("novalidated")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
				requet+=" AND ( inv.oc_patientinvoice_acceptationuid = '' OR  inv.oc_patientinvoice_acceptationuid = 'NULL'  )";
				}
			
			if(status.equalsIgnoreCase("sent")) {
				requet+=" AND inv.OC_PATIENTINVOICE_STATUS = 'closed' ";
				if(module.equalsIgnoreCase("OBR")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
				if(module.equalsIgnoreCase("MedHub")) {
					requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.INV.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					}
		     }
			
			if(status.equalsIgnoreCase("errors")) {
				requet+=" AND (  inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled') ";
				if(module.equalsIgnoreCase("OBR")) {
				requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('OBR.INV.ERROR.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
				}
				if(module.equalsIgnoreCase("MedHub")) {
					requet+=" AND exists (select * from oc_pointers where oc_pointer_key  = concat('MEDH.ERROR.USER.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					}
		     }
			
			if(status.equalsIgnoreCase("noservsignature")) {
				
			requet+=" AND ( inv.OC_PATIENTINVOICE_STATUS = 'open' OR inv.OC_PATIENTINVOICE_STATUS = 'closed' OR inv.OC_PATIENTINVOICE_STATUS = 'canceled') ";
			requet+=" AND not exists (select * from oc_pointers where oc_pointer_key  = concat('INVSERVSIGN.', oc_patientinvoice_serverid ,'.', oc_patientinvoice_objectid)) ";
					
		     }
			
			//requet+=" GROUP BY serv ";
		PreparedStatement ps = conn.prepareStatement(requet);
	
		  
		  ps.setDate(1,ScreenHelper.getSQLDate(begin));
		  ps.setDate(2,ScreenHelper.getSQLDate(end));
		  int param_index = 2;
		  
		  if(service.length() > 0) {
			  //param_index ++;  
       	      //ps.setString(param_index,service);
		  }
		  
		   if(insurance.length() > 0 ) {
	        	   param_index ++;  
	        	   ps.setString(param_index,insurance);
	          }
		  
		ResultSet rs = ps.executeQuery();
		
		try {
	
		while(rs.next()) {	
			theamount = rs.getDouble("theamount");	
		}
		conn.close();
		ps.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return  theamount;		
	  }
	
	
	public static String getPatientResumeSignature(int patientientobjectid) throws SQLException {
		String mfpsignature = null;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = conn.prepareStatement(
				" select AdminView.lastname, AdminView.firstname from  AdminView , UsersView, OC_PATIENTINVOICES oc_pa , OC_SUMMARYINVOICEITEMS lien ," +
			    " OC_SUMMARYINVOICES cons where UsersView.personid = AdminView.personid " + 
				" and cons.OC_SUMMARYINVOICE_VALIDATED = UsersView.userid "+ 
				" and lien.OC_ITEM_PATIENTINVOICEUID = concat( oc_pa.OC_PATIENTINVOICE_SERVERID ,'.', oc_pa.OC_PATIENTINVOICE_OBJECTID )  " +
				" and lien.OC_ITEM_SUMMARYINVOICEUID = concat( cons.OC_SUMMARYINVOICE_SERVERID, '.', cons.OC_SUMMARYINVOICE_OBJECTID )   "+ 
				" and oc_pa.OC_PATIENTINVOICE_OBJECTID = ? "
         );
		ps.setInt(1, patientientobjectid);
		ResultSet rs = ps.executeQuery();
		
		try {
	
		while(rs.next()) {	
			mfpsignature = rs.getString("lastname") + " " + rs.getString("firstname") ;		
		}
		conn.close();
		ps.close();
		rs.close();
		
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return mfpsignature;		
	  }
	
	
	
	public static String SendMessage(String invoiceuid, String messeagecontent, String currentuser , String sHubToken, String reciever) {
		
		String response_status = null;
		String invoi = "";
		JsonUtils jsonutil = new JsonUtils();
		String reciev = reciever;
		
		try {
		
		HttpClient	client = HttpClients.createDefault();
		HttpPost	req = new HttpPost(SH.cs("MED_HUBsendMessage","http://10.241.10.25:8080/HMKInterface/addValidationMessage"));
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+sHubToken);
		
	   	PatientInvoice invoice = PatientInvoice.get("1."+invoiceuid);
	    
	   		 
	   		MedHubMessageHeader msh = new MedHubMessageHeader();
	   		msh.setMsg_function("addValidationMessage");
	   		msh.setMsg_date(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date().getTime()));
	   		msh.setMsg_sd(SH.cs("HUB_sender","HMK")); 
	   		msh.setMsg_rcv(reciev);
	   		msh.setMsgkey(new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(invoice.getDate())+"/"+SH.cs("HUB_sender","HMK")+"/MFP/"+ invoice.getPatientUid() +"/"+invoice.getUid());
	   		 
	   		
		    invoi = "{";
		    invoi+="\"msg_hd\":";
		    invoi+= jsonutil.toJson(msh);
		    invoi+=",\"msg_body\":{";
		    invoi+="\"invoice_ref\":\""+invoiceuid+"\",";
		    invoi+="\"message\":\""+messeagecontent+"\",";
		    invoi+="\"message_date\":\""+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date())+"\",";
		    invoi+="\"autor\":\""+currentuser+"\"";
		    
		    invoi+="}}";  
		    
		    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(invoi));
		    req.setEntity(reqEntity);
		     
		    //System.out.println("Sent object: " + invoi);
		   
	         HttpResponse resp = client.execute(req);
		     HttpEntity entity = resp.getEntity();
	    
	         String s = EntityUtils.toString(entity);
	         JsonReader jraddinvioce = Json.createReader(new java.io.StringReader(s));
	         JsonObject joaddinvioce = jraddinvioce.readObject();
	    	 
	         response_status = joaddinvioce.toString();
	         
	        // System.out.println("La reponse au message : " + response_status);
	    
	      }catch(Exception e) {

	        // System.out.println("Test exception : " + e.getMessage().toString());	
	          response_status = "reponse: " + e.getMessage().toString();

		}
	    //return bSuccess;
		return response_status;
	 
	}
	
	
	public static JsonObject FetchMessage(String invoiceuid,  String sHubToken) {
		
		JsonObject response_status = null;
		String invoi = "";
		JsonUtils jsonutil = new JsonUtils();
		String status_to_send = "0";
		
		try {
		
		HttpClient	client = HttpClients.createDefault();
		HttpPost	req = new HttpPost(SH.cs("MED_HUBfetchValidationMessage","http://10.241.10.25:8080/HMKInterface/fetchValidationMessage"));
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+sHubToken);
		
	   	PatientInvoice invoice = PatientInvoice.get("1."+invoiceuid);
	    
	   		 
	   		MedHubMessageHeader msh = new MedHubMessageHeader();
	   		msh.setMsg_function("fetchValidationMessage");
	   		msh.setMsg_date(new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date().getTime()));
	   		msh.setMsg_sd(SH.cs("HUB_sender","HMK")); 
	   		msh.setMsg_rcv("MFP");
	   		msh.setMsgkey(new java.text.SimpleDateFormat("yyyyMMddHHmmss").format(invoice.getDate())+"/"+SH.cs("HUB_sender","HMK")+"/MFP/"+ invoice.getPatientUid() +"/"+invoice.getUid());
	   		 
	   
		    invoi = "{";
		    invoi+="\"msg_hd\":";
		    invoi+= jsonutil.toJson(msh);
		    invoi+=",\"msg_body\":{";

		    invoi+="\"status\":\""+status_to_send+"\"";
		    
		    invoi+="}"; 
		    invoi+="}";
		    
		    StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(invoi));
		    req.setEntity(reqEntity);
		     
		    //System.out.println("Sent object: " + invoi);
		   

	         HttpResponse resp = client.execute(req);
		     HttpEntity entity = resp.getEntity();
	    
	         String s = EntityUtils.toString(entity);
	         JsonReader jraddinvioce = Json.createReader(new java.io.StringReader(s));
	         JsonObject joaddinvioce = jraddinvioce.readObject();
	    	 
	         response_status = joaddinvioce;
	         
	        // System.out.println("La reponse au message : " + response_status);
	    
	      }catch(Exception e) {

	        // System.out.println("Test exception : " + e.getMessage().toString());	
	         // response_status = "reponse: " + e.getMessage().toString();

		}
	    //return bSuccess;
		return response_status;
	 
	}
	
	
	public static String getErrorOnIsu(String invoiceuid, String context ) {
		String err = "";
		if(invoiceuid!=null) {
		if(Pointer.getPointer("MEDH.ERROR.USER."+invoiceuid)!="") {
		err = "<img style='vertical-align: middle' src='"+context+"/_img/icons/icon_error.jpg' />";
		err = err +	" ISU non reconnu";	
		//err = Pointer.getPointer("MEDH.ERROR.USER."+invoiceuid);
		}
		}else {
			err = "";		
		}
		return  err;
	}
	
	public static String getSendingStatus(String invoiceuid,String context) {
		String err = "";
		if(invoiceuid!=null) {
		if(Pointer.getPointer("MEDH.INV."+invoiceuid)!="") {
		err = "<img style='vertical-align: middle' src='"+context+"/_img/icons/icon_check.png' />";
		}else {
		err = "<img style='vertical-align: middle' src='"+context+"/_img/icons/icon_warning.gif' />";	
		}
		}else {
		err = "";	
		}
		return  err;
	}
	
	
    

   private static Vector<PatientInvoice> reverse(Vector<PatientInvoice> inv) {
	   int vector_size = inv.size();
	   Vector<PatientInvoice> invnew = new Vector<PatientInvoice>();
	   for(int i = 0; i < vector_size; i++ ) {
		    
		   invnew.add(i, inv.get(vector_size-1-i));
		   
	   }
	   
   return invnew;
   }
   
   public static Boolean CheckIfValidated(String patieninvoiceuid) throws SQLException {
    Boolean sent = false;

	Integer ninvoice = 0;
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String request = "";
	
	request+=" SELECT COUNT(inv.OC_PATIENTINVOICE_OBJECTID) as countinvoice ";
	request+=" FROM oc_patientinvoices inv ";
	request+=" WHERE concat( inv.OC_PATIENTINVOICE_SERVERID,'.', inv.OC_PATIENTINVOICE_OBJECTID ) = ? ";
	request+=" AND inv.oc_patientinvoice_status='closed' ";
	request+=" AND inv.oc_patientinvoice_acceptationuid !='' ";
	request+=" AND inv.oc_patientinvoice_acceptationuid !='NULL' ";
	
	 try {
	
	PreparedStatement ps = conn.prepareStatement(request);
	ps.setString(1,patieninvoiceuid);
	ResultSet rs = ps.executeQuery();
	
	rs.next();	
	ninvoice = rs.getInt(1);
	
	if(ninvoice > 0) {
		sent = true;
	}
	conn.close();
	ps.close();
	rs.close();
	
	} catch (SQLException e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	   
	return sent;   
   }
   
   public static String getParticipant(String invoiceuid) {
	  String participants = ""; //"<option>"+invoiceuid+"</option>";
	  Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String request = "";
		
		String first = "-1";
		String second = "-1";
		String third = "-1";
		
		request+=" SELECT oc_debet_patientinvoiceuid, oc_debet_insuranceuid, "; 
		request+=" oc_debet_extrainsuraruid, oc_debet_extrainsuraruid2 ";
		request+=" from oc_debets WHERE oc_debet_patientinvoiceuid = ? ;";
	
		 try {
		
		PreparedStatement ps = conn.prepareStatement(request);
		ps.setString(1,invoiceuid);
		ResultSet rs = ps.executeQuery();
		
		while(rs.next()) {	
			
			first = rs.getString("oc_debet_insuranceuid");
			second = rs.getString("oc_debet_extrainsuraruid");
			third = rs.getString("oc_debet_extrainsuraruid2");
			
		}
		String part1 = Insurar.get(getInsurarUID(first)).getName();
		String part2 = Insurar.get(second).getName();
		String part3 = Insurar.get(third).getName();
		
		if(part1!=null) {
		participants+="<option>"+ part1 +"</option>";
		}
		if(part2!=null) {
		participants+="<option>"+ part2 +"</option>";
		}
		if(part3!=null) {
		participants+="<option>"+ part3 +"</option>";
		}
		
		conn.close();
		ps.close();
		rs.close();
		
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		   
		return participants;   
	
   }
   
   public static String getInsurarUID(String ins) {
		  String res = ""; 
		  Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String request = "";
			request+=" SELECT oc_insurance_insuraruid  "; 
			request+=" FROM oc_insurances WHERE oc_insurance_objectid = ?;";
			 try {
			PreparedStatement ps = conn.prepareStatement(request);
			ps.setString(1,ins);
			ResultSet rs = ps.executeQuery();	
			while(rs.next()) {		
				res = rs.getString("oc_insurance_insuraruid");		
			}
			conn.close();
			ps.close();
			rs.close();
			
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			   
			return res;   
		
	   }
   
   //public static void main(String[] args) throws ClientProtocolException, IOException {
	   //String tok = getToken();
	   //System.out.println(">>>>>>>>>>>>>>>>>>> : "+tok);
	   //SendMessage("1.102", "Hello", "Horanimana H" ,getToken());
	//}
   
   
   
   
   
}
		
	
