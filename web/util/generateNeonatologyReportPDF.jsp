<%@page import="be.openclinic.util.NeonatalMonitoringData"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="java.io.*,
                com.itextpdf.text.DocumentException,
                java.io.PrintWriter, be.mxs.common.util.pdf.general.*" %>
<%
	NeonatalMonitoringData.store(activeUser, 6656, SH.getYesterday());
%>
