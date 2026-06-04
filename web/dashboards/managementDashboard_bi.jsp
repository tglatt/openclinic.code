<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
	<tr height='150'>
		<td>
			<center><%SH.setIncludePage(customerInclude("/dashboards/freeram/dashboard.jsp"),pageContext); %></center>
		</td>
		<td><center><%SH.setIncludePage(customerInclude("/dashboards/maxram/dashboard.jsp"),pageContext); %></center></td>
		<td><center><%SH.setIncludePage(customerInclude("/dashboards/reservedram/dashboard.jsp"),pageContext); %></center></td>
	</tr>
	<tr height='150'>
		<td><center><%SH.setIncludePage(customerInclude("/dashboards/availableram/dashboard.jsp"),pageContext); %></center></td>
		<td><center><%SH.setIncludePage(customerInclude("/dashboards/time/dashboard.jsp"),pageContext); %></center></td>
		<td><center><%SH.setIncludePage(customerInclude("/dashboards/income/dashboard.jsp"),pageContext); %></center></td>
	</tr>
</table>
