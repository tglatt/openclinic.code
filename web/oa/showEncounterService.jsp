<%@page import="be.openclinic.adt.*"%>
<%
	Encounter encounter = Encounter.get("1.2");
%>
Nom du service pour le contact 1.2:<br/> 
<b><%= encounter.getService().getFullyQualifiedName("fr")%></b>