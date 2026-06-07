<%@page import="be.openclinic.system.SH"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Vector"%>
<%@page import="be.openclinic.adt.Encounter"%>

Liste des contacts:<br/>
<table border="1">
<%
	Vector<Encounter> encounters = 
	Encounter.selectEncounters("", "", "", "", "", "", "", "", "0", "");
	for(int n=0;n<encounters.size();n++){
		out.println("<tr>");
		Encounter encounter = encounters.elementAt(n);
		out.println("<td>"+new SimpleDateFormat("dd/MM/yyyy").format(encounter.getBegin())+"</td>");
		out.println("<td>"+SH.getTranNoLink("web", encounter.getType(), "fr")+"</td>");
		out.println("</tr>");
	}
%>
</table>
