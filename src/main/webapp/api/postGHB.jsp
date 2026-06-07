<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,java.io.*,be.openclinic.medical.*"%>
<%@include file="/includes/helper.jsp"%>
<%
	String xml = SH.c(request.getParameter("xml"));
	if(xml.length()==0){
		//Missing xml parameter
	}
	else{
		//Load xml parameter in GHBMessage object
	}
%>