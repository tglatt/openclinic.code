<%@page errorPage="/includes/error.jsp"%>
<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.io.OBR,
                be.mxs.common.util.io.MedHub"%> 
<%@include file="/includes/validateUser.jsp"%>
<%
DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
String sFindDateBegin = checkString(request.getParameter("FindDateBegin"));
String sFindDateEnd = checkString(request.getParameter("FindDateEnd"));   
String smodule = checkString(request.getParameter("module"));
String sPeriodicSummaService = checkString(request.getParameter("EditEncounterService"));
String sinsurarUid = checkString(request.getParameter("insurarUid"));
String selectstatus = checkString(request.getParameter("invoicestatus"));

String begin_select = checkString(request.getParameter("begindiv"));
String max_selection = checkString(request.getParameter("maxdiv"));
String end_select = checkString(request.getParameter("enddiv"));
String sdirection = checkString(request.getParameter("direction"));


Vector vInvoices = null;



if(smodule.equalsIgnoreCase("MedHub")||smodule.equalsIgnoreCase("OBR")){


	Integer nopen = MedHub.countClosedInvoices(sFindDateBegin,sFindDateEnd,"open",smodule,sinsurarUid, sPeriodicSummaService);
	Integer nclosed = MedHub.countClosedInvoices(sFindDateBegin,sFindDateEnd,"closed",smodule,sinsurarUid, sPeriodicSummaService);
	Integer nvalidated = MedHub.countClosedInvoices(sFindDateBegin,sFindDateEnd,"validated",smodule,sinsurarUid, sPeriodicSummaService);
           
	nvalidated = nvalidated + MedHub.countSummaryInvoices(sFindDateBegin,sFindDateEnd,"validated",smodule,sinsurarUid, sPeriodicSummaService);
    Integer nsent = MedHub.countClosedInvoices(sFindDateBegin,sFindDateEnd,"sent",smodule,sinsurarUid, sPeriodicSummaService);
    

	String activeuser = "";
    int dossierCount = 0, invoiceCount = 0;
    String selectstatus_to_send = "all";
    
    
    switch(selectstatus){
    case "1":
   	 selectstatus_to_send = "all";
   	 break;
    case "2":
   	 selectstatus_to_send = "canceled";
   	 break;
    case "3":
   	 selectstatus_to_send = "open";
   	 break;
    case "4":
   	 selectstatus_to_send = "closed";
   	 break;
    case "5":
   	 selectstatus_to_send = "validated";
   	 break;
    case "6":
   	 selectstatus_to_send = "novalidated";
   	 break;
    case "7":
   	 selectstatus_to_send = "sent";
   	 break;
    case "8":
   	 selectstatus_to_send = "errors";
   	 break;
    case "9":
     selectstatus_to_send = "noservsignature";
    break;
    }
   
    
    //selectstatus_to_send = "all";
 
    
    String serviceLabel = "";
    
    if(sPeriodicSummaService.length() > 0){
		serviceLabel = Service.getService(sPeriodicSummaService).getLabel("FR");
	}
	
	String insurarLabel = "";
	if(sinsurarUid.length() > 0){
		insurarLabel = Insurar.get(sinsurarUid).getName();
	}
    

    	//Construire le contenu du rapport
StringBuffer sResult = new StringBuffer();
sResult.append("FACTURE;DATE;PATIENTID;STATUS;SIGNATURE\r\n");
//sResult.append("FACTURE;"+selectstatus+";PATIENTID;STATUS;SIGNATURE\r\n");
		//ajouter le contenu du rapport
//Connection conn = SH.getOpenClinicConnection();

    		//sResult.append(sFindDateBegin+";");
    		//sResult.append(sFindDateEnd+";");
    		//sResult.append(selectstatus_to_send+";");
    		//sResult.append(smodule+";");
    		//sResult.append(sinsurarUid+";");  
    		
    		//sResult.append(sPeriodicSummaService+";"); 
    
    		
    		//sResult.append(0+";");
    		//sResult.append(10+";");
    		//sResult.append(100);
    	
    		
    		//sResult.append("\r\n");
    		
    		
          Vector<PatientInvoice> invoices = MedHub.ListClosedInvoices(sFindDateBegin,sFindDateEnd,selectstatus_to_send,smodule,sinsurarUid, sPeriodicSummaService, "0" , "999999999", "0", "ASC",sCONTEXTPATH );
    		
         for(int n=0; n<invoices.size(); n++){
				
	       PatientInvoice invoice = (PatientInvoice)invoices.elementAt(n);
	       
	       
	   	sResult.append(invoice.getUid()+";");
   		sResult.append(ScreenHelper.formatDate(invoice.getDate())+";");
   		sResult.append(invoice.getPatientUid()+";");
	   	sResult.append(invoice.getStatus()+";");
   		sResult.append(OBR.getSignature(invoice.getInsuranceUid()));
   		sResult.append("\r\n");
	       
	       
          }
    	
    	//rs.close();
    	//ps.close();
    	//conn.close();
    	//Produire une réponse http
    	//Mettre à jour l'en-tête de la réponse http
        response.setContentType("application/octet-stream; charset=windows-1252");
	    response.setHeader("Content-Disposition", "Attachment;Filename=\"resumedhubobr.csv\"");
	    //Mettre le body dans la réponse
	    // Convertir le body en array de bytes (octets)
	    byte[] aBytes = sResult.toString().getBytes("ISO-8859-1");
	    for(int n=0;n<aBytes.length;n++){
	    	// Ecrire chaque byte dans le body de la réponse http
	    	response.getOutputStream().write(aBytes[n]);
	    }
	    // Etre sûr que tous les bytes ont été envoyés vers le navigateur
	    response.getOutputStream().flush();
	    // Clôturer la réponse: indique à l'indicateur que c'est terminé
	    response.getOutputStream().close();
	    
}
	 
 %>