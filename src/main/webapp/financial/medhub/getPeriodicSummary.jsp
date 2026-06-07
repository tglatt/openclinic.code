<%@page import="be.openclinic.system.Screen"%>
<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.HTMLEntities,
                java.text.DecimalFormat,
                be.openclinic.finance.Insurance,
                java.util.Date,
                be.mxs.common.util.io.OBR,
                be.mxs.common.util.io.MedHub,
                be.openclinic.medical.ReasonForEncounter,
                be.mxs.common.util.system.*"%>         
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSDATE%>


<%
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin"));
    String sFindDateEnd = checkString(request.getParameter("FindDateEnd"));   
    String smodule = checkString(request.getParameter("module"));
    String sPeriodicSummaService = checkString(request.getParameter("EditEncounterService"));
    String sinsurarUid = checkString(request.getParameter("insurarUid"));
    String selectstatus = checkString(request.getParameter("selectstatus"));
    String selectstatus_to_send = "";
    String selectstatus_to_show = "";
    
    
      //sFindDateBegin = "04/01/2023";
      //sFindDateEnd = "06/03/2023"; 
      //smodule = "MedHub";
      //sPeriodicSummaService = "";
      //sinsurarUid = "";
     //selectstatus = "all";
    
    
     switch(selectstatus){
     case "1":
    	 selectstatus_to_send = "all";
    	 selectstatus_to_show = "Total";
    	 break;
     case "2":
    	 selectstatus_to_send = "canceled";
    	 selectstatus_to_show = "Annulees";
    	 break;
     case "3":
    	 selectstatus_to_send = "open";
    	 selectstatus_to_show = "Ouvertes";
    	 break;
     case "4":
    	 selectstatus_to_send = "closed";
    	 selectstatus_to_show = "Fermees";
    	 
    	 break;
     case "5":
    	 selectstatus_to_send = "validated";
    	 selectstatus_to_show = "Validees";
    	 break;
     case "6":
    	 selectstatus_to_send = "novalidated";
    	 selectstatus_to_show = "Non Validees";
    	 break;
     case "7":
    	 selectstatus_to_send = "sent";
    	 selectstatus_to_show = "Envoyees";
    	 break;
     case "8":
    	 selectstatus_to_send = "errors";
    	 selectstatus_to_show = "Erreurs";
    	 break;
     case "9":
    	 selectstatus_to_send = "noservsignature";
    	 selectstatus_to_show = "Sans signature du responable de service";
    	 break;
     }
    
 
    
    Vector vInvoices = null;

    	
   
    if(smodule.equalsIgnoreCase("MedHub")||smodule.equalsIgnoreCase("OBR")){
    	
    	Integer ninvoices = MedHub.countClosedInvoices(sFindDateBegin,sFindDateEnd,selectstatus_to_send,smodule,sinsurarUid, sPeriodicSummaService);
    	if(selectstatus_to_send.equalsIgnoreCase("validated")){
    		ninvoices = ninvoices + MedHub.countSummaryInvoices(sFindDateBegin,sFindDateEnd,"validated",smodule,sinsurarUid, sPeriodicSummaService); 
    	}
        /////
        Double invoices_amount = 0.0;
        String sinvoices_amount = "";
        
        if(selectstatus_to_send.equalsIgnoreCase("validated")){
        Double nvalidated_amount_assurance = MedHub.AmountInvoices(sFindDateBegin,sFindDateEnd,"validated", smodule,sinsurarUid, sPeriodicSummaService,0)+
        		MedHub.AmmountSummaryInvoices(sFindDateBegin,sFindDateEnd,"validated", smodule,sinsurarUid, sPeriodicSummaService,0);
        Double nvalidated_amount_assurance1 = MedHub.AmountInvoices(sFindDateBegin,sFindDateEnd,"validated", smodule,sinsurarUid, sPeriodicSummaService,1)+
        		MedHub.AmmountSummaryInvoices(sFindDateBegin,sFindDateEnd,"validated", smodule,sinsurarUid, sPeriodicSummaService,1);
        Double nvalidated_amount_assurance2 = MedHub.AmountInvoices(sFindDateBegin,sFindDateEnd,"validated", smodule,sinsurarUid, sPeriodicSummaService,2)+
        		MedHub.AmmountSummaryInvoices(sFindDateBegin,sFindDateEnd,"validated", smodule,sinsurarUid, sPeriodicSummaService,2);
         invoices_amount = nvalidated_amount_assurance + nvalidated_amount_assurance1 + nvalidated_amount_assurance2;
         sinvoices_amount = String.format("%,.0f", invoices_amount); 
         
        }else{
        	if(sinsurarUid!=""){
            Double nclosed_amount_assurance = MedHub.AmountInvoices(sFindDateBegin,sFindDateEnd,selectstatus_to_send,smodule, sinsurarUid, sPeriodicSummaService,0);
            Double nclosed_amount_assurance1 = MedHub.AmountInvoices(sFindDateBegin,sFindDateEnd,selectstatus_to_send,smodule, sinsurarUid, sPeriodicSummaService,1);
            Double nclosed_amount_assurance2 = MedHub.AmountInvoices(sFindDateBegin,sFindDateEnd,selectstatus_to_send,smodule, sinsurarUid, sPeriodicSummaService,2);
            
            invoices_amount =  nclosed_amount_assurance + nclosed_amount_assurance1 + nclosed_amount_assurance2;
            sinvoices_amount = String.format("%,.0f", invoices_amount);
        	
        	}else{
        		
             invoices_amount = MedHub.AmountInvoices(sFindDateBegin,sFindDateEnd,selectstatus_to_send,smodule, sinsurarUid, sPeriodicSummaService,-1);	 
             sinvoices_amount = String.format("%,.0f", invoices_amount);
        		
        	}
        }
        

        
        %>
    	

       <table width="100%" class="list" cellspacing="0" border="1">
         <tr class="admin2">
          <td class="admin"  width="20%" style="text-align: left;"><div style="font-weight: bolder" id=""><%=selectstatus_to_show %></div></td>
          <td width="20%" style="text-align: left;"><div style="font-weight: bolder" id=""><%=ninvoices %></div></td>
          <td width="20%" style="text-align: left;"><div style="font-weight: bolder" id=""><%=sinvoices_amount %></div></td>
          <td  width="20%" style="text-align: left;"><div style="font-weight: bolder" id=""><a href="#" onclick='MedhubInvoicesDetails("sent");'><%=HTMLEntities.htmlentities(getTran(request,"web","download",sWebLanguage))%> CSV</a></div></td>
          <td  width="20%" style="text-align: left;"><div style="font-weight: bolder" id=""><a href="#"  onclick='printSummary();'><%=HTMLEntities.htmlentities(getTran(request,"web","download",sWebLanguage))%> PDF</a></div></td>
         </tr>  
       </table>
    
      <%  
       }
    %>
    

           
            
      
       