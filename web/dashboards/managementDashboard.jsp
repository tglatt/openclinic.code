<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/clinicalcoverage/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/clinicalcompleteness/dashboard.jsp"),pageContext);%></td>
	</tr>
</table>