<%@page import="net.admin.*"%>
<%
	User user = User.get(4);
%>
Administrateur système: 
<%=user.getParameter("sa").equalsIgnoreCase("on")?"oui":"non" %>