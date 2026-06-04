<%@page import="be.openclinic.mobilemoney.*"%>
<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	//Malitel.importCertificate();
	//SH.syslog(Malitel.getBasicAuthentication());
	//out.println(Malitel.requestPayment("1.12345679", "22366515429", 1000, "Test payment request", "Moussa COULIBALY"));
	out.println("<br/>");
	out.println(Malitel.getPaymentStatus("22366515429", "1.12345679"));

%>