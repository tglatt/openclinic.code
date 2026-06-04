<%@page import="be.openclinic.finance.Prestation"%>
<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="com.fasterxml.jackson.databind.ObjectMapper"%>
<%@page import="javax.json.*"%>
<%@page import="be.openclinic.openimis.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'><td><%=getTran(request,"web","sumissionOfOpenIMISClaim",sWebLanguage) %> #<%=SH.p(request,"invoiceuid") %></td></tr>
	<%
		JsonObject claimResponse= FHIRClaim.submit(SH.p(request,"invoiceuid"), SH.p(request,"status"));
		ObjectMapper mapper = new ObjectMapper();
		String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(claimResponse);
		System.out.println(json);
		boolean bOperationError=false,bError=false;
		//Analyze response
		String resourceType = claimResponse.getString("resourceType");
		if(resourceType.equalsIgnoreCase("OperationOutcome")){
			bOperationError=true;
			out.println("<tr><td style='color: red'>"+getTran(request,"web","errorsdetected",sWebLanguage).toUpperCase()+"</td></tr>");
			JsonArray issues = claimResponse.getJsonArray("issue");
			for(int n=0;n<issues.size();n++){
				JsonObject issue = issues.getJsonObject(n);
				JsonObject details = issue.getJsonObject("details");
				if(details!=null){
					out.println("<tr><td style='color: red'><li>"+details.getString("text")+"</td></tr>");
				}
			}
		}
		else if(resourceType.equalsIgnoreCase("ClaimResponse")){
			String itemDescription = "?", itemStatus="?", itemReason="?";
			JsonArray items = claimResponse.getJsonArray("item");
			for(int n=0;n<items.size();n++){
				JsonObject item = items.getJsonObject(n);
				JsonArray extensions = item.getJsonArray("extension");
				if(extensions.size()>0){
					JsonObject extension = extensions.getJsonObject(0);
					JsonObject valueReference = extension.getJsonObject("valueReference");
					Prestation prestation = Prestation.getByCode(valueReference.getString("display"));
					itemDescription = "["+valueReference.getString("display")+"] "+(prestation==null?"":prestation.getDescription());
				}
				JsonArray adjudications = item.getJsonArray("adjudication");
				if(adjudications!=null && adjudications.size()>0){
					JsonObject adjudication = adjudications.getJsonObject(0);
					JsonObject category = adjudication.getJsonObject("category");
					if(category!=null){
						JsonArray codings = category.getJsonArray("coding");
						if(codings!=null && codings.size()>0){
							JsonObject coding = codings.getJsonObject(0);
							if(coding!=null){
								itemStatus=coding.getString("display");
							}
						}
					}
					JsonObject reason = adjudication.getJsonObject("reason");
					if(category!=null){
						JsonArray codings = reason.getJsonArray("coding");
						if(codings!=null && codings.size()>0){
							JsonObject coding = codings.getJsonObject(0);
							if(coding!=null){
								itemReason=coding.getString("code")+": "+getTran(request,"openimis.rejection",coding.getString("code"),sWebLanguage);
							}
						}
					}
				}
				if(!itemReason.startsWith("0")){
					out.println("<tr><td style='color: red'><li><img height='14px' src='"+sCONTEXTPATH+"/_img/icons/icon_warning.gif'/> <b>"+itemDescription+"</b>: "+itemStatus+" - "+itemReason+"</td></tr>");
					bError=true;
				}
				else{
					out.println("<tr><td ><li><img height='14px' src='"+sCONTEXTPATH+"/_img/icons/icon_check.png'/> "+itemDescription+": "+itemStatus+" - "+itemReason+"</td></tr>");
				}
			}
			Pointer.storePointer("sentToOpenIMIS."+SH.getServerId()+"."+SH.p(request,"invoiceuid"), SH.formatDate(new java.util.Date(),"dd/MM/yyyy HH:mm:sss"));
			if(!bOperationError && bError){
				Pointer.storePointer("sentToOpenIMISWithErrors."+SH.getServerId()+"."+SH.p(request,"invoiceuid"), SH.formatDate(new java.util.Date(),"dd/MM/yyyy HH:mm:sss"));
				out.println("<script>if(window.opener.document.getElementById('openIMISMsg')){window.opener.document.getElementById('openIMISMsg').innerHTML='"+getTran(request,"web","sent",sWebLanguage)+": "+SH.formatDate(new java.util.Date(),"dd/MM/yyyy HH:mm:sss")+" <img src=\""+sCONTEXTPATH+"/_img/icons/icon_warning.gif\" height=\"14px\"/> <b>"+getTran(request,"web","invoicesentwitherrors",sWebLanguage)+"</b>';};</script>");
			}
			else{
				out.println("<script>if(window.opener.document.getElementById('openIMISMsg')){window.opener.document.getElementById('openIMISMsg').innerHTML='"+getTran(request,"web","sent",sWebLanguage)+": "+SH.formatDate(new java.util.Date(),"dd/MM/yyyy HH:mm:sss")+"';};</script>");
			}
		}
	%>
	</table>
</form>