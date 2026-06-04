<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/bloodgiftdistribution/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/bloodpocketscollected/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/rejectedgifts/dashboard.jsp"),pageContext);%></td>
	</tr>
	<tr>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/totalbloodproduced/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/frozenplasmaproduced/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/plateletsplasmaproduced/dashboard.jsp"),pageContext);%></td>
	</tr>
	<tr>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/redbloodcellsproduced/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/plateletsproduced/dashboard.jsp"),pageContext);%></td>
		<td width='33%'><%SH.setIncludePage(customerInclude("/dashboards/abo/dashboard.jsp"),pageContext);%></td>
	</tr>
</table>