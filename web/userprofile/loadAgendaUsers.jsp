<%@include file="/includes/validateUser.jsp"%>
<%
	User refUser = activeUser;
	if(SH.p(request,"refuser").length()>0){
		refUser=User.get(Integer.parseInt(SH.p(request,"refuser")));
	}
%>
<td>
	<table width='100%'>
		<tr class='admin'>
			<td/>
			<td><%=getTran(request,"web","user",sWebLanguage) %></td>
			<td><%=getTran(request,"agenda","edit",sWebLanguage) %></td>
			<td><%=getTran(request,"agenda","add",sWebLanguage) %></td>
		</tr>
	<%
		String[] users = refUser.getParameter("agenda_users").split(";");
		for(int n=0;n<users.length;n++){
			if(users[n].split("=").length>1){
				String userid = users[n].split("=")[0];
				String rights = users[n].split("=")[1].toLowerCase();
				out.println("<tr>");
				out.println("<td width='1%'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' onclick='deleteUser("+userid+")'/></td>");
				out.println("<td>"+User.getFullUserName(userid)+"</td>");
				out.println("<td>"+(rights.contains("u")?getTran(request,"web","yes",sWebLanguage):getTran(request,"web","no",sWebLanguage))+"</td>");
				out.println("<td>"+(rights.contains("c")?getTran(request,"web","yes",sWebLanguage):getTran(request,"web","no",sWebLanguage))+"</td>");
			}
		}
	%>
	</table>
</td>