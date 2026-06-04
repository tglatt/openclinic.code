<%@page import="be.openclinic.finance.PatientCredit"%>
<%@page import="be.openclinic.finance.Debet"%>
<%@page import="be.openclinic.finance.PatientInvoice"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	int maxversion=Integer.parseInt(SH.p(request,"maxversion","0"));
	String uid = SH.p(request,"uid");
	String version = SH.p(request,"version");
	PatientInvoice invoice = PatientInvoice.get(uid,Integer.parseInt(version));
	if(invoice!=null){
%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='4'><span style='font-size: 14px'><%=getTran(request,"web","invoice",sWebLanguage) %> #<%=invoice.getInvoiceNumber()+" "+getTran(request,"web","version",sWebLanguage)+" "+invoice.getVersion() %>&nbsp;&nbsp;&nbsp;<%=getTran(request,"web","patient",sWebLanguage) %>: <%=invoice.getPatient().getFullName() %> [<%=invoice.getPatient().personid %>]</span></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"web","invoicedate",sWebLanguage) %></td>
		<td class='admin2'><%=new SimpleDateFormat("dd/MM/yyyy HH:mm").format(invoice.getDate()) %></td>
		<td class='admin'><%=getTran(request,"web","user",sWebLanguage) %></td>
		<td class='admin2'><b><%=User.getFullUserName(invoice.getUpdateUser())%></b></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"web","updatetime",sWebLanguage) %></td>
		<td class='admin2'><b><%=new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(invoice.getUpdateDateTime()) %></b></td>
		<td class='admin'><%=getTran(request,"web.finance","patientinvoice.status",sWebLanguage) %></td>
		<td class='admin2'><%=getTran(request,"finance.patientinvoice.status",invoice.getStatus(),sWebLanguage)%></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"web","totalinvoiced",sWebLanguage) %></td>
		<td class='admin2'><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(invoice.getTotalAmount())%> <%=MedwanQuery.getInstance().getConfigString("currency","EUR") %></td>
		<td class='admin'><%=getTran(request,"web.finance","insurarreference",sWebLanguage)%></td>
		<td class='admin2'><%=SH.c(invoice.getInsurarreference())%></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"web","paid",sWebLanguage) %></td>
		<td class='admin2'><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(invoice.getAmountPaid())%> <%=MedwanQuery.getInstance().getConfigString("currency","EUR") %></td>
		<td class='admin'><%=getTran(request,"web.finance","dateinsurarreference",sWebLanguage)%></td>
		<td class='admin2'><%=SH.c(invoice.getInsurarreferenceDate())%></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"web.finance","balance",sWebLanguage) %></td>
		<td class='admin2'><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(invoice.getBalanceField())%> <%=MedwanQuery.getInstance().getConfigString("currency","EUR") %></td>
		<td class='admin'><%=getTran(request,"web","services",sWebLanguage)%></td>
		<td class='admin2'><%=SH.c(invoice.getServicesAsString(sWebLanguage))%></td>
	</tr>
	<tr class='admin'>
		<td colspan='4'><%=getTran(request,"web","debets",sWebLanguage) %></td>
	</tr>
</table>
<table width='100%'>
	<tr>
		<td class='admin'><%=getTran(request,"web","date",sWebLanguage) %></td>
		<td class='admin'><%=getTran(request,"web","insurar",sWebLanguage) %></td>
		<td class='admin'><%=getTran(request,"web","encounter",sWebLanguage) %></td>
		<td class='admin'><%=getTran(request,"web","prestation",sWebLanguage) %></td>
		<td class='admin'><%=getTran(request,"web","amount",sWebLanguage) %></td>
		<td class='admin'><%=getTran(request,"web","linked.service",sWebLanguage) %></td>
	</tr>
	<%
		if(invoice.getDebets()==null || invoice.getDebets().size()==0){
			%>
				<tr>
					<td colspan='6'><%=getTran(request,"web","nohistoricaldata",sWebLanguage) %></td>
				</tr>
			<%
		}
		else{
			for(int n=0;n<invoice.getDebets().size();n++){
				Debet debet = (Debet)invoice.getDebets().elementAt(n);
				String insurer="?";
				try{
					insurer=debet.getInsurance().getInsurar().getName();
				}
				catch(Exception e){}
				%>
				<tr>
					<td class='admin2'><%=SH.formatDate(debet.getDate()) %></td>
					<td class='admin2'><%=insurer %></td>
					<td class='admin2'><%=debet.getEncounterUid()+" - "+getTranNoLink("service",debet.getEncounter().getServiceUID(debet.getDate()),sWebLanguage) %></td>
					<td class='admin2'><%=debet.getPrestation().getDescription() %></td>
					<td class='admin2'><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(debet.getAmount())+" "+MedwanQuery.getInstance().getConfigParam("currency","EUR")  %></td>
					<td class='admin2'><%=getTranNoLink("service",debet.getServiceUid(),sWebLanguage) %></td>
				</tr>
				<%
			}
		}
	%>
</table>
<table width='100%'>
	<tr class='admin'>
		<td colspan='4'><%=getTran(request,"web.finance","credits",sWebLanguage) %></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"web","date",sWebLanguage) %></td>
		<td class='admin'><%=getTran(request,"web","type",sWebLanguage) %></td>
		<td class='admin'><%=getTran(request,"web","amount",sWebLanguage) %></td>
		<td class='admin'><%=getTran(request,"web","cashier",sWebLanguage) %></td>
	</tr>
	<%
		if(invoice.getCredits()==null || invoice.getCredits().size()==0){
			%>
				<tr>
					<td colspan='6'><%=getTran(request,"web","nohistoricaldata",sWebLanguage) %></td>
				</tr>
			<%
		}
		else{
			for(int n=0;n<invoice.getCredits().size();n++){
				PatientCredit credit = PatientCredit.get((String)invoice.getCredits().elementAt(n));
				if(credit!=null){
				%>
				<tr>
					<td class='admin2'><%=SH.formatDate(credit.getDate()) %></td>
					<td class='admin2'><%=getTran(null,"credit.type",checkString(credit.getType()),sWebLanguage)+" "+(checkString(credit.getComment()).length()>0?"[<i>"+checkString(credit.getComment())+"</i>]":"") %></td>
					<td class='admin2'><%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(credit.getAmount())+" "+MedwanQuery.getInstance().getConfigParam("currency","EUR") %></td>
					<td class='admin2'><%=User.getFullUserName(credit.getUpdateUser()) %></td>
				</tr>
				<%
				}
			}
		}
	%>
</table>
<p/>
<table width='100%'>
	<tr>
		<td width='33%' style='text-align: left'>
		<% 	
			if(invoice.getVersion()>1){
				out.println("<input class='button' type='button' value='"+getTranNoLink("web","previous",sWebLanguage)+"' onclick='prev()'>");
			}
		%>
		</td>
		<td width='33%' style='text-align: center'>
		<%
			out.println("<input class='button' type='button' value='"+getTranNoLink("web","close",sWebLanguage)+"' onclick='window.close()'>");
		%>
		</td>
		<td style='text-align: right'>
		<%
			if(invoice.getVersion()<maxversion){
				out.println("<input class='button' type='button' value='"+getTranNoLink("web","next",sWebLanguage)+"' onclick='nxt()'>");
			}
		%>
		</td>
	<tr>
</table>
<script>
	function prev(){
		window.location.href="<%=sCONTEXTPATH%>/popup.jsp?Page=/healthrecord/showPatientInvoiceFromHistory.jsp&ts=<%=getTs()%>&maxversion=<%=maxversion%>&uid=<%=invoice.getUid()%>&version=<%=invoice.getVersion()-1%>&PopupWidth=1024&PopupHeight=600";
	}
	function nxt(){
		window.location.href="<%=sCONTEXTPATH%>/popup.jsp?Page=/healthrecord/showPatientInvoiceFromHistory.jsp&ts=<%=getTs()%>&maxversion=<%=maxversion%>&uid=<%=invoice.getUid()%>&version=<%=invoice.getVersion()+1%>&PopupWidth=1024&PopupHeight=600";
	}
</script>

<%
	}
%>