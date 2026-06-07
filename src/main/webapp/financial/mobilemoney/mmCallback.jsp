<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@include file="/includes/helper.jsp"%>
<%
	String sOCTransactionId=SH.p(request,"uid"); //<ip target server>;<invoiceuid>;<amount>;<payer phone number>
	String sPaymentStatus=SH.p(request,"status");
	
	//Process payment callback data
	SH.syslog("Received callback for OpenClinic transaction "+sOCTransactionId+" with status "+sPaymentStatus);
	String sDecodedUid = new String(Base64.getDecoder().decode(sOCTransactionId));
	String sTargetServer = sDecodedUid.split(";")[0];
	String sTargetUid = sDecodedUid.split(";")[1];
	//Transfer callback data to the server that originated the payment request
	HttpClient client = new HttpClient();
	String url = "http://"+sTargetServer+"/openclinic/financial/mobilemoney/setPaymentStatus.jsp";
	PostMethod method = new PostMethod(url);
	method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
	NameValuePair nvp1= new NameValuePair("uid",sOCTransactionId);
	NameValuePair nvp2= new NameValuePair("status",sPaymentStatus);
	method.setQueryString(new NameValuePair[]{nvp1,nvp2});
	int statusCode = client.executeMethod(method);
	String sError=method.getResponseBodyAsString();
	SH.syslog(statusCode+": "+sError.trim());
%>