<%@page import="net.admin.Service"%>
<%
	Service service = Service.getService("CLI.PED");
	Service parent = Service.getService(service.getParentcode());
	out.println("Nom du parent: "+parent.getFullyQualifiedName("fr"));
%>