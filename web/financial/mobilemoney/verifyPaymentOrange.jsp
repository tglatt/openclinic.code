<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*,be.mxs.common.util.db.*"%>
<%@include file="/includes/helper.jsp"%>

<%
	String sStatus="cancel";
	String sAmount = SH.p(request,"amount");
	String sPaymentCode = SH.p(request,"paymentcode");
	String sMerchantCode = SH.cs("orangeMoneyMerchantCode","");
	HttpClient client = new HttpClient();
	String url = SH.cs("orangeMoneyEasyURL","");
	PostMethod method = new PostMethod(url);
	method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
	//*******************************************************
	//Todo: choose parameters to send to OrangeMoney API here
	//*******************************************************
	NameValuePair nvp1= new NameValuePair("amount",sAmount);
	NameValuePair nvp2= new NameValuePair("paymentcode",sPaymentCode);
	NameValuePair nvp3= new NameValuePair("merchantcode",SH.cs("orangeMoneyMerchantCode",""));
	method.setQueryString(new NameValuePair[]{nvp1,nvp2,nvp3});
	int statusCode = client.executeMethod(method);
	//Capture response????
	if(statusCode==200){
		sStatus="ok";
	}
	String sError=method.getResponseBodyAsString();
	SH.syslog("OrangeMoney API call result: "+statusCode+" => "+sError.trim());
%>
{
	"status":"<%=sStatus %>"
}
