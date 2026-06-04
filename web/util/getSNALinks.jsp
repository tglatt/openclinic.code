<%@page import="java.io.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	response.setContentType("application/octet-stream; charset=windows-1252");
	response.setHeader("Content-Disposition", "Attachment;Filename=\"snalinks.csv\"");
	ServletOutputStream os = response.getOutputStream();
	byte[] b = ((StringBuffer)session.getAttribute("snalinks")).toString().getBytes();
	for(int n=0; n<b.length; n++){
	    os.write(b[n]);
	}
	os.flush();
	os.close();
%>