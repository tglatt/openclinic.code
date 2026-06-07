
<%@page import="be.openclinic.adt.Encounter"%>
<%@page import="net.admin.User"%>
<h1>
	La date d'aujourd'hui est:
	<%
		out.println(new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()));
	%>
</h1>



