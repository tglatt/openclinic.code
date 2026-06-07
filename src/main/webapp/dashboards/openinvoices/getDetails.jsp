<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='4'><%=getTran(request,"web","openinvoiceslastmonth",sWebLanguage) %></td>
		</tr>
		<tr class='admin'>
			<td><%=getTran(request,"web","date",sWebLanguage) %></td>
			<td>ID</td>
			<td><%=getTran(request,"web","patient",sWebLanguage) %></td>
			<td><%=getTran(request,"web","balance",sWebLanguage) %></td>
		</tr>
		<%
			Vector openinvoices = PatientInvoice.searchInvoicesByStatusAndBalance(SH.formatDate(new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*30)), SH.formatDate(new java.util.Date()), "open", "");
			for(int n=0;n<openinvoices.size();n++){
				PatientInvoice invoice = (PatientInvoice)openinvoices.elementAt(n);
				out.println("<td class='admin'>"+SH.formatDate(invoice.getDate())+"</td><td><a href='javascript:openinvoice(\""+invoice.getUid()+"\")'>"+invoice.getUid()+"</a></td><td>"+invoice.getPatient().getFullName()+"</td><td><b>"+SH.formatPrice(invoice.getBalance())+"</b></td></tr>");
			}
		%>
	</table>
</form>

<script>
	function openinvoice(uid){
		openPopup('/financial/patientInvoiceEdit.jsp&showpatientname=1&FindPatientInvoiceUID='+uid);
	}
</script>