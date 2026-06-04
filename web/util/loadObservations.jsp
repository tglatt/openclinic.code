<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<table width='100%'>
	<tr>
		<td class='adminblack'>Device ID</td>
		<td class='adminblack'>Timestamp</td>
		<td class='adminblack'>LOINC Code</td>
		<td class='adminblack'>Label</td>
		<td class='adminblack'>Value</td>
	</tr>
<%
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_observations order by ts desc,id,code limit 100");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		out.println("<tr>");
		out.println("<td class='admin2'>"+rs.getString("id")+"</td>");
		out.println("<td class='admin2'>"+SH.formatDate(rs.getTimestamp("ts"),"dd/MM/yyyy HH:mm:ss.SSS")+"</td>");
		out.println("<td class='admin2'><b>"+rs.getString("code")+"</b></td>");
		out.println("<td class='admin2'><i>"+getTranNoLink("observation",rs.getString("code"),"en")+"</i></td>");
		out.println("<td class='admin2'><b>"+rs.getFloat("value")+"</b></td>");
		out.println("</tr>");
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>