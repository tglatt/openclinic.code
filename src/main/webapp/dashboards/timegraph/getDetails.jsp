<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='2'>Détails mémoire RAM</td>
	</tr>
	<tr>
		<td class='admin'>Mémoire RAM réservée en MB</td>
		<td class='admin2'><%=Runtime.getRuntime().totalMemory()/(1024*1024) %></td>
	</tr>
	<tr>
		<td class='admin'>Mémoire RAM maximale en MB</td>
		<td class='admin2'><%=Runtime.getRuntime().maxMemory()/(1024*1024) %></td>
	</tr>
	<tr>
		<td class='admin'>Mémoire RAM utilisée en MB</td>
		<td class='admin2'><%=(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory())/(1024*1024) %></td>
	</tr>
	<tr>
		<td class='admin'>Mémoire RAM libre en MB</td>
		<td class='admin2'><%=Runtime.getRuntime().freeMemory()/(1024*1024) %></td>
	</tr>
</table>