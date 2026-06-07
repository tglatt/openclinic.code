<%@page import="net.admin.*"%>
<%
	AdminPerson patient = AdminPerson.get("2");
	patient.lastname="VERBEKE";
	patient.firstname="Frank";
	patient.dateOfBirth="23/08/1963";
	patient.store();
%>

