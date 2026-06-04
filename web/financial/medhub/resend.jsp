<%@page import="be.openclinic.system.Screen"%>
<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.HTMLEntities,
                java.text.DecimalFormat,
                be.openclinic.finance.Insurance,
                java.util.Date,
                javax.json.JsonObject,
                be.mxs.common.util.io.OBR,
                be.mxs.common.util.io.MedHub,
                be.openclinic.medical.ReasonForEncounter,
                be.mxs.common.util.system.*"%>         
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
    
    String invoiceuid = checkString(request.getParameter("EditPatientInvoiceUID"));
    String module = checkString(request.getParameter("module")); 
    String resultat = "-----";
    
     //invoiceuid = "1147024"; 
     //module = "OBR";
    
    if(module.equalsIgnoreCase("OBR")){
    	//envoyer a l'obr
    JsonObject jsonresult = OBR.addPatientInvoiceGetJSONObject(invoiceuid, false);
    	
    resultat = jsonresult.toString();
    	
    if(jsonresult.getBoolean("success")) {
		//System.out.println("Facture "+invoiceuid+" ajoutée à l'OBR avec succès");
		Pointer.storePointer("OBR.INV."+invoiceuid, "");
		resultat = "Ok";
	}
	else {
		//System.out.println("Facture "+invoiceuid+" pas ajoutée à l'OBR");
		//System.out.println(" --> "+jsonresult.getString("msg"));
		if(jsonresult.getString("msg").equalsIgnoreCase("Une facture avec le même numéro"+
														" existe déjà.")) {
			Pointer.storePointer("OBR.INV."+invoiceuid, "");
			Pointer.storePointer("OBR.INV.ERROR."+invoiceuid, "");
			resultat = "DUPLICATION";
		}else if (jsonresult.getString("msg").equalsIgnoreCase("Le format de la chaine de caractère JSON est invalide")){
			resultat = "MAUVAIS FORMAT";
		}
	}	
    	
    	
    	
    	
    }else if(module.equalsIgnoreCase("MedHub")){
    	if(MedHub.CheckIfValidated(invoiceuid)){
    	JsonObject sent = null;
    	//envoyer a medhub
    	sent = MedHub.SendInvoice(invoiceuid.split("\\.")[1], MedHub.getToken(),false, true);
    	
    	resultat = sent.toString();
    	
    	if(sent.getJsonObject("msg_body").getString("status").equalsIgnoreCase("SUCCESS")) {
			
			//System.out.println("Status de la response apres envoie de la facture s/consolidee: "+invoiceuid+" envoye a med hub");
			Pointer.storePointer("MEDH.INV."+invoiceuid, invoiceuid);
			
			resultat = "Ok";
			
		}else {
			
			Pointer.storePointer("MEDH.ERROR."+invoiceuid, sent.getJsonObject("msg_body").getString("status"));
			
			//System.out.println("Status de la response apres envoie de la facture s/consolidee: "+invoiceuid+" La facture n'as pas ete envoyee!");
			//System.out.println("Erreur " + sent.getJsonObject("msg_hd").getString("msg_status").toString());
			
			if(sent.getJsonObject("msg_hd").getString("msg_status").toString().contains("-50")) {
				
				Pointer.storePointer("MEDH.ERROR.USER."+invoiceuid, invoiceuid);
				
				resultat = "MEDH.ERROR.USER.";
	
			}else {
				if(sent.getJsonObject("msg_hd").getString("msg_status").toString().contains("-41")) {
					//System.out.println("Facture dupliquee!");
					Pointer.storePointer("MEDH.INV."+invoiceuid, invoiceuid);
					Pointer.storePointer("MEDH.ERROR.DUP."+invoiceuid, invoiceuid);
					resultat = "MEDH.ERROR.DUP";
				}else {
				//System.out.println("Autre probleme!");
				Pointer.storePointer("MEDH.ERROR.OTHER."+invoiceuid, invoiceuid);
				resultat = "MEDH.ERROR.OTHER.";
				}
			}	
		}
    	
    	
    }else{
    	resultat = "Validation";
    	//Pointer.storePointer("MEDH.ERROR."+invoiceuid, invoiceuid);
    } 	
    }
   
    %>
	{"resultat":"<%=resultat%>"}
	<%
    
 %>
    
