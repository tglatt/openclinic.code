<%@page import="be.openclinic.mobilemoney.OrangeMali"%>
<%
	OrangeMali om = new OrangeMali();
	String ts=new java.util.Date().getTime()+"";
	System.out.println(om.requestPayment("12345678"+ts, "71328116", 500, "Labo").toString());
	System.out.println(om.getPaymentStatus("12345678"+ts).toString());
%>
