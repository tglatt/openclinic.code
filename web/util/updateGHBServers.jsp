<%@page import="be.openclinic.sync.GHBNetwork"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
	out.println(GHBNetwork.syncGHBServers(checkString(request.getParameter("domain"))));
%>