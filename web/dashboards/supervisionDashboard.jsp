<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/activelogins/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/invoicecompleteness/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/invoicerecovery/dashboard.jsp"),pageContext);%></td>
	</tr>
	<tr>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/rfecompleteness/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/admissiondiagnosis/dashboard.jsp"),pageContext);%></td>
	</tr>
</table>