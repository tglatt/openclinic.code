<%@page import="be.openclinic.erpnext.ERPNext"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
	ERPNext.exportTodaysFinancials();
%>