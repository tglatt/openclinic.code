<%@page import="net.admin.Service"%>
<%
	Service service = Service.getService("CLI.PED");
%>
Nom du service COV:<br/>
<b><%= service.getLabel("fr")%></b>