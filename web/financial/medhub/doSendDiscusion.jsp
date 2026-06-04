<%@page import="be.openclinic.system.Screen"%>
<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.HTMLEntities,
                java.text.DecimalFormat,
                be.openclinic.finance.Insurance,
                java.util.Date,
                be.mxs.common.util.io.OBR,
                be.mxs.common.util.io.MedHub,
                 be.mxs.common.util.io.Medhubmessage,
                be.openclinic.medical.ReasonForEncounter,
                javax.json.Json,
                javax.json.JsonObject,
                javax.json.JsonArray,
                be.mxs.common.util.system.*"%>         
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%

String invoiceuid  = "",
messageconnent = "", 
currentuser = "",
fetch = "",
savemessage="";
String toserver = "";
String current_house = "";

 invoiceuid = checkString(request.getParameter("invoiceuid"));
 messageconnent = checkString(request.getParameter("messagecontent"));
 currentuser = checkString(request.getParameter("currentuser"));
 current_house = checkString(request.getParameter("current_house"));
 fetch = checkString(request.getParameter("fetch"));
 toserver = checkString(request.getParameter("toserver"));
 
 savemessage = checkString(request.getParameter("savemessage"));
 String message_sender = checkString(request.getParameter("message_sender"));
 String message_rec = checkString(request.getParameter("message_rec"));

 
 
 String jsonrespons = null;
 String resp = "";
 String token = "";
 
    String[] st = invoiceuid.split("\\.");
    String sinvoiceuid = st[1];
 
   //String sinvoiceuid = "103";
 
   //fetch = "1";
  //toserver = "1";
  //invoiceuid  = "103"; 
  //messageconnent = "hello world!";
  //message_sender = "Horanimana,Henri";
  //current_house = "HMK";
  //message_rec = "MFP";
  //savemessage = "savemessage"; 
 
    try {
		 	
		 
         if(toserver.toString().length() > 0){
        	 
        	  token = MedHub.getToken();
        jsonrespons =  MedHub.SendMessage(sinvoiceuid, messageconnent, message_sender ,token, message_rec);
        resp = jsonrespons;
        
         }else{
        	 resp="-1000"; 
        if(fetch.toString().length() > 0 && sinvoiceuid.toString().length() > 0){
        	token = MedHub.getToken();	
        	//resp = MedHub.FetchMessage(sinvoiceuid, token).getJsonObject("msg_body").getJsonArray("messages").toString();
        	JsonArray mess = MedHub.FetchMessage(sinvoiceuid, token).getJsonObject("msg_body").getJsonArray("messages");	
        		for(int j = 0; j < mess.size(); j++){
        			
        			String rec = mess.getJsonObject(j).getString("receiver");
        			String sender = mess.getJsonObject(j).getString("sender");
        			String messagedate = mess.getJsonObject(j).getString("messadeDate");
        			String message = mess.getJsonObject(j).getString("content");
        			String inv = "1." + mess.getJsonObject(j).getString("inv_ref");
        			String autor = mess.getJsonObject(j).getString("autor");
        			
        		 	Medhubmessage.insertInvoiceMessages( inv
                		, autor, sender , "",  message );	
        			
        		}
        		
        		resp = "Ok";
        		
        				//resp = MedHub.FetchMessage(sinvoiceuid, token).toString();
        		 	//Medhubmessage.insertInvoiceMessages( invoiceuid
                		//	, currentuser, current_house , "",  messageconnent );	 	
              }
        	 
        	 
        if(savemessage.toString().length() > 0 && invoiceuid.toString().length() > 0){
        	resp = Medhubmessage.insertInvoiceMessages( invoiceuid
        			, currentuser, current_house , "",  messageconnent );
           }	 
        		 
         }
 
    	%>
    	{"message":"<%=resp%>"}
    	<%
    	
    }
    catch (Exception ex) {

    	out.println("Erreur : " + ex.toString());
    }
    finally {
     
    }
%>