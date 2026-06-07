<%@page import="be.openclinic.assets.Util"%>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%ScreenHelper.setIncludePage(customerInclude("statistics/ajax/generateMalariaDashboardEncounters.jsp"),pageContext);%>
<%ScreenHelper.setIncludePage(customerInclude("statistics/ajax/generateMalariaDashboardFever.jsp"),pageContext);%>
<%ScreenHelper.setIncludePage(customerInclude("statistics/ajax/generateMalariaDashboardTests.jsp"),pageContext);%>
<%ScreenHelper.setIncludePage(customerInclude("statistics/ajax/generateMalariaDashboardClinical.jsp"),pageContext);%>
<%ScreenHelper.setIncludePage(customerInclude("statistics/ajax/generateMalariaDashboardTreatment.jsp"),pageContext);%>
