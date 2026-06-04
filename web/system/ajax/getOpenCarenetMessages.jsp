<%@include file="/includes/validateUser.jsp"%>
<%
	String sBegin = SH.p(request,"begin");
	String sEnd = SH.p(request,"end");
%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='11'><%=getTran(request,"web.manage","waitingmessages",sWebLanguage) %></td>
	</tr>
	<tr class='admin'>
		<td><%=getTran(request,"web","id",sWebLanguage) %></td>
		<td><%=getTran(request,"web","datereceived",sWebLanguage) %></td>
		<td><%=getTran(request,"web","datesent",sWebLanguage) %></td>
		<td><%=getTran(request,"web","delay",sWebLanguage) %></td>
		<td><%=getTran(request,"web","fromserver",sWebLanguage) %></td>
		<td><%=getTran(request,"web","fromip",sWebLanguage) %></td>
		<td><%=getTran(request,"web","toserver",sWebLanguage) %></td>
		<td><%=getTran(request,"web","toip",sWebLanguage) %></td>
		<td colspan='3'><%=getTran(request,"web","error",sWebLanguage) %></td>
	</tr>
	<%
		Hashtable<Integer,String> servers = new Hashtable<Integer,String>();
		Connection conn = SH.getStatsConnection();
		PreparedStatement ps = conn.prepareStatement("select * from ghb_servers");
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			servers.put(rs.getInt("ghb_server_id"),rs.getString("ghb_server_name"));
		}
		rs.close();
		ps.close();
		ps = conn.prepareStatement("select * from ghb_messages where ghb_message_receiveddatetime>=? and ghb_message_receiveddatetime<? and ghb_message_delivereddatetime is null order by ghb_message_receiveddatetime desc");
		ps.setDate(1,SH.toSQLDate(sBegin));
		ps.setDate(2,SH.toSQLDate(SH.parseDate(sEnd).getTime()+SH.getTimeDay()));
		rs = ps.executeQuery();
		while(rs.next()){
			out.println("<tr>");
			out.println("<td class='admin'>"+rs.getString("ghb_message_id")+"</td>");
			out.println("<td class='admin2'>"+SH.formatDate(rs.getTimestamp("ghb_message_receiveddatetime"),SH.fullDateFormatSS)+"</td>");
			if(activeUser.getAccessRightNoSA("mpi.serveradmin.delete")){
				out.println("<td class='admin2'><center><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' onclick='deleteMessage("+rs.getString("ghb_message_id")+")'/></center></td>");
			}
			else{
				out.println("<td class='admin2'></td>");
			}
			out.println("<td class='admin2'><b>"+SH.getTimeBetween(rs.getTimestamp("ghb_message_receiveddatetime"),new java.util.Date(),sWebLanguage)+"</b></td>");
			out.println("<td class='admin2'><b>"+SH.c(servers.get(rs.getInt("ghb_message_sourceserverid")))+"</b></td>");
			out.println("<td class='admin2'>"+SH.c(rs.getString("ghb_message_sourceip"))+"</td>");
			out.println("<td class='admin2'><b>"+SH.c(servers.get(rs.getInt("ghb_message_targetserverid")))+"</b></td>");
			out.println("<td class='admin2'>"+SH.c(rs.getString("ghb_message_targetip"))+"</td>");
			out.println("<td class='admin2'>"+SH.c(rs.getString("ghb_message_error"))+"</td>");
			out.println("</tr>");
		}
		rs.close();
		ps.close();
	%>
	<tr><td colspan='11'><hr/></td></tr>
	<tr class='admin'>
		<td colspan='11'><%=getTran(request,"web.manage","processedmessages",sWebLanguage) %></td>
	</tr>
	<tr class='admin'>
		<td><%=getTran(request,"web","id",sWebLanguage) %></td>
		<td><%=getTran(request,"web","datereceived",sWebLanguage) %></td>
		<td><%=getTran(request,"web","datesent",sWebLanguage) %></td>
		<td><%=getTran(request,"web","delay",sWebLanguage) %></td>
		<td><%=getTran(request,"web","fromserver",sWebLanguage) %></td>
		<td><%=getTran(request,"web","fromip",sWebLanguage) %></td>
		<td><%=getTran(request,"web","toserver",sWebLanguage) %></td>
		<td><%=getTran(request,"web","toip",sWebLanguage) %></td>
		<td colspan='3'><%=getTran(request,"web","error",sWebLanguage) %></td>
	</tr>
	<%
		ps = conn.prepareStatement("select * from ghb_servers");
		rs = ps.executeQuery();
		while(rs.next()){
			servers.put(rs.getInt("ghb_server_id"),rs.getString("ghb_server_name"));
		}
		rs.close();
		ps.close();
		ps = conn.prepareStatement("select * from ghb_messages where ghb_message_receiveddatetime>=? and ghb_message_receiveddatetime<? and ghb_message_delivereddatetime is not null order by ghb_message_receiveddatetime desc");
		ps.setDate(1,SH.toSQLDate(sBegin));
		ps.setDate(2,SH.toSQLDate(SH.parseDate(sEnd).getTime()+SH.getTimeDay()));
		rs = ps.executeQuery();
		while(rs.next()){
			out.println("<tr>");
			out.println("<td class='admin'>"+rs.getString("ghb_message_id")+"</td>");
			out.println("<td style='background-color: #EEF3FF'>"+SH.formatDate(rs.getTimestamp("ghb_message_receiveddatetime"),SH.fullDateFormatSS)+"</td>");
			out.println("<td style='background-color: #EEF3FF'>"+SH.formatDate(rs.getTimestamp("ghb_message_delivereddatetime"),SH.fullDateFormatSS)+"</td>");
			out.println("<td style='background-color: #EEF3FF'>"+SH.getTimeBetween(rs.getTimestamp("ghb_message_receiveddatetime"),rs.getTimestamp("ghb_message_delivereddatetime"),sWebLanguage)+"</td>");
			out.println("<td style='background-color: #EEF3FF'>"+SH.c(servers.get(rs.getInt("ghb_message_sourceserverid")))+"</td>");
			out.println("<td style='background-color: #EEF3FF'>"+rs.getString("ghb_message_sourceip")+"</td>");
			out.println("<td style='background-color: #EEF3FF'>"+SH.c(servers.get(rs.getInt("ghb_message_targetserverid")))+"</td>");
			out.println("<td style='background-color: #EEF3FF'>"+rs.getString("ghb_message_targetip")+"</td>");
			out.println("<td style='background-color: #EEF3FF'>"+SH.c(rs.getString("ghb_message_error"),"<center><img height='14px' src='"+sCONTEXTPATH+"/_img/icons/mobile/check.png'/></center>")+"</td>");
			out.println("</tr>");
		}
		rs.close();
		ps.close();
		conn.close();
	%>
</table>