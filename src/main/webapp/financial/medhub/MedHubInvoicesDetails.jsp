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



<%
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin"));
    String sFindDateEnd = checkString(request.getParameter("FindDateEnd"));   
    String smodule = checkString(request.getParameter("module"));
    String sPeriodicSummaService = checkString(request.getParameter("EditEncounterService"));
    String sinsurarUid = checkString(request.getParameter("insurarUid"));
    String invoicestatus = checkString(request.getParameter("invoicestatus"));
    
    String max_selection = checkString(request.getParameter("max_selection"));
    String begin_select = checkString(request.getParameter("begin_select"));
    String end_select = checkString(request.getParameter("end_select"));
    
    
    DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));
    
    // sFindDateBegin = "04/01/2005";
    // sFindDateEnd = "06/03/2023"; 
    // smodule = "MedHub";
      //sPeriodicSummaService = "COV";
      //sinsurarUid = "";
    
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
        
        
        switch(invoicestatus){
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
        }
       
     
        
        String serviceLabel = "";
        
        if(sPeriodicSummaService.length() > 0){
    		serviceLabel = Service.getService(sPeriodicSummaService).getLabel("FR");
    	}
    	
    	String insurarLabel = "";
    	if(sinsurarUid.length() > 0){
    		insurarLabel = Insurar.get(sinsurarUid).getName();
    	}
        
        
    	out.print("<table width='100%' >");
    	out.print("<tr class='admin'>");
    	out.print("<td  colspan='6' >"+ serviceLabel +"  "+getTran(request,"web","Periode",sWebLanguage)+"  "+sFindDateBegin+" - "+sFindDateEnd+ " - "+ insurarLabel + "</td>");
    	out.print("</tr>");
    	out.print("</table>");
	    	
    	out.print("<table width='100%' >");
		out.print("<tr class='admin' >");
	    	
		//out.print(" >");
			 
		out.print("<td colspan='1' class='admin2'>"+getTran(request,"web","invoice","FR")+"</td>");
		out.print("<td colspan='1'  class='admin2'>"+getTran(request,"web","date",sWebLanguage)+"</td>");
		out.print("<td colspan='1'  class='admin2'>"+getTran(request,"web","patient",sWebLanguage)+"</td>");
			
		out.print( "<td colspan='1'  class='admin2'>"+getTran(request,"web","balance",sWebLanguage)+"</td>");
		out.print( "<td colspan='1'  class='admin2'>"+getTran(request,"web","finance.patientinvoice.status",sWebLanguage)+"</td>");
		out.print( "<td colspan='1'  class='admin2'>"+getTran(request,"web","information",sWebLanguage)+"</td>");
		out.print("</tr>");
		out.print("</table>");

		out.print("<div id='listt' name='listt'>");
		out.print(MedHub.ListClosedInvoices(sFindDateBegin,sFindDateEnd,selectstatus_to_send,smodule,sinsurarUid, sPeriodicSummaService, begin_select , max_selection, end_select, "ASC",sCONTEXTPATH ));
		out.print("</div>");
       
       }
    %>
    
<script>
   function OpenDiscussion(invoice){
	   
     //alert(invoice);	
     var url  = "/financial/medhub/PatientInvoiceDiscusion.jsp&invoiceuid="+invoice+"&ts=<%=getTs()%>"
     //alert(url);
   openPopup(url ,700,350);
   
    }
   
   function changeList(direction){
 	   
	
	   var begin_date = '<%=sFindDateBegin%>';
	   var end_date = '<%=sFindDateEnd%>';
	   var ssmodule = '<%=smodule%>';
	   var ssPeriodicSummaService = '<%=sPeriodicSummaService%>';
	   var ssinsurarUid = '<%=sinsurarUid%>';
	   var sinvoicestatus = '<%=invoicestatus%>';
	   
	   sinvoicestatus = $('statusdiv').innerHTML;
	   
	   var maxdiv = $('maxdiv').innerHTML;
	   var begindiv = $('begindiv').innerHTML;
	   var enddiv = $('enddiv').innerHTML; 
	  
	   //alert(sinvoicestatus);
	   
	   $("listt").innerHTML = "<br><br><br><div id='ajaxLoader' style='display:block;text-align:center;'>"+
       "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..</div>";
      var params ="";                          
      params = "FindDateBegin="+begin_date+
      "&FindDateEnd="+end_date+
      "&EditEncounterService="+ssPeriodicSummaService+
      "&module="+ssmodule+
      "&selectstatus="+sinvoicestatus+
      
      "&maxdiv="+maxdiv+
      "&begindiv="+begindiv+
      "&enddiv="+enddiv+
      "&direction="+direction+
      "&insurarUid="+ssinsurarUid;

      //alert(direction);
   
        	 //alert("Send!");
        	 
      var url= "<c:url value='/financial/medhub/getMedHubDetails.jsp'/>?ts="+new Date();
      new Ajax.Request(url,{
      method: "GET",
      parameters: params,
      onSuccess: function(resp){
     $("listt").innerHTML = resp.responseText; 
        }
      });
          
       
   	    }
    
</script>