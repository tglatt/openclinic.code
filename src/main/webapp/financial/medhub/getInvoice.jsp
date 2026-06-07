<%@page import="be.mxs.common.util.io.OBR,javax.json.*,
                java.nio.charset.*"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%" cellspacing="1" cellpadding="0">
    <%-- HEADER --%>
    <tr class="gray">
        <td><%=getTranNoLink("web","designation",sWebLanguage) %></td>
        <td><%=getTranNoLink("web","price",sWebLanguage) %></td>
        <td><%=getTranNoLink("web","quantity",sWebLanguage) %></td>
        <td><%=getTranNoLink("web","total",sWebLanguage) %></td>
    </tr>

<%
try{
	String  invoiceuid  = "" ;
	
	invoiceuid = request.getParameter("invoiceuid");
	//invoiceuid  = "14";
	String signature_obr = "";
	String token = "";
	Double total_amount = 0.0;
	
	if(invoiceuid!=null){
		
		JsonObject jo = null;
		signature_obr = OBR.getSignature(invoiceuid);
		token = OBR.getToken();
		
		if(!token.equals("-1")){
			 jo = OBR.getInvoice(invoiceuid, false);
			 JsonArray inv =  jo.getJsonObject("result").getJsonArray("invoices");
			 if(inv.size() > 0){
				 for(int i = 0; i < inv.size(); i++){
					
				        JsonArray items =  inv.getJsonObject(i).getJsonArray("invoice_items");
				        String sClass = "";
				        for(int j = 0; j < items.size(); j++){
				        	 
					        if(sClass.equals("")) sClass = "1";
					        else                  sClass = "";
					    
					      	String item_designation = new String(items.getJsonObject(j).getString("item_designation").getBytes(),StandardCharsets.ISO_8859_1);
					
					     	String item_quantity = items.getJsonObject(j).getString("item_quantity");
					     	String item_total_amount = items.getJsonObject(j).getString("item_total_amount");
					      
					      
					        out.println( "<tr class='list"+sClass+"'>");
					        out.println("<td>"+item_designation+"</td>");
					        out.println("<td>"+items.getJsonObject(j).getString("item_price")+"</td>");
					        out.println("<td>"+item_quantity+"</td>");
					        out.println("<td>"+item_total_amount+"</td>");  
					        out.println("</tr>");
					         
					        total_amount = total_amount + Double.parseDouble(item_total_amount);
				         
				        }
			  	   }
			  }
		 }
	}
	%>
	  <tr>
	        <td></td>
	        <td></td>
	        <td></td>
	        <td><%=total_amount%></td>
	    </tr>
	
	</table>
	<%
}
catch(Exception e){
}
%>