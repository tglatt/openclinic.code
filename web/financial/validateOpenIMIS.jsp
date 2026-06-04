<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="be.openclinic.finance.Prestation"%>
<%@page import="be.openclinic.finance.PatientInvoice"%>
<%@page import="be.openclinic.openimis.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'><td><%=getTran(request,"web","validateinvoice",sWebLanguage)+" "+SH.p(request,"invoiceuid") %></td></tr>
<%
	try{
		GraphQLDraftClaim.ClaimValidationResult messages = GraphQLDraftClaim.validateDraftClaim(SH.p(request,"invoiceuid"));
		String className="admin";
		if(messages.status==2){
			className="admingreen";
		}
		else if(messages.status==1){
			className="adminred";
		}
		out.println("<tr><td class='"+className+"' height='30px'><b>"+getTran(request,"openimis.invoicestatus",messages.status+"",sWebLanguage)+"</b></td></tr>");
		if(messages.errors!=null){
			for(int n=0;n<messages.errors.size();n++){
				String message = messages.errors.elementAt(n);
				for(int i=0;i<message.split("/").length;i++){
					String messagePart=message.split("/")[i].trim();
					if(messagePart.split("-").length>=3){
						String id = messagePart.split("-")[1];
						if(messagePart.split("-")[0].equalsIgnoreCase("item") || messagePart.split("-")[0].equalsIgnoreCase("svc")){
							Prestation prestation = Prestation.getByNomenclatureCode(id);
							id="["+id+"] "+prestation.getDescription();
						}
						else{
							id="["+id+"]";
						}
						out.println("<tr><td class='admin2'>"+getTran(request,"openimischecktype",messagePart.split("-")[0],sWebLanguage)+
									" <b>"+id+"</b> "+getTran(request,"openimischeckerror",messagePart.split("-")[2],sWebLanguage)+"</td></tr>");
					}
					else if (messagePart.split("-").length>=2 && messagePart.split("-")[0].equalsIgnoreCase("claim")){
						out.println("<tr><td class='admin2'>"+getTran(request,"openimisclaimerror",messagePart.split("-")[1],sWebLanguage)+"</td></tr>");
					}
					else{
						out.println("<tr><td class='admin2'>"+messagePart+"</td></tr>");
					}
				}
			}
		}
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
</table>
<br/>
<center>
	<input type='button' class='button' value='<%=getTranNoLink("web","close",sWebLanguage) %>' onclick='window.close();'/>
	<%
		if(Pointer.getPointer("sentToOpenIMIS."+SH.getServerId()+"."+SH.p(request,"invoiceuid")).length()==0){
			out.println("&nbsp;<input type='button' class='button' name='sendToOpenIMISButton' onclick='window.opener.sendToOpenIMIS();window.close();' value='"+getTranNoLink("web","sendToOpenIMIS",sWebLanguage)+"'/></td></tr>");
		}
	%>
</center>