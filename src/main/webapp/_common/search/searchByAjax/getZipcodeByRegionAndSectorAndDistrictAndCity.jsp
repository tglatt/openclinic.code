<%@ page import="java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindDistrict = checkString(request.getParameter("FindDistrict"));
	String sFindCity = checkString(request.getParameter("FindCity"));
	String sFindRegion = checkString(request.getParameter("FindRegion"));
	String sFindSector = checkString(request.getParameter("FindSector"));
    String sZipcode = Zipcode.getZipcode2(sFindRegion,sFindSector,sFindDistrict,sFindCity,MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
	out.println(sZipcode);
%>
