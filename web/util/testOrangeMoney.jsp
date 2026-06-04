<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@page import="be.openclinic.system.*"%>
<%@include file="/includes/helper.jsp"%>
<%
	String callbackurl = SH.p(request,"callbacksuccess");
	Thread.sleep(5000);
	HttpClient client = new HttpClient();
	PostMethod method = new PostMethod(callbackurl);
	method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
	int statusCode = client.executeMethod(method);
	String sError=method.getResponseBodyAsString();
	SH.syslog("Sending callback to "+callbackurl);
	SH.syslog(statusCode+": "+sError.trim());
%>