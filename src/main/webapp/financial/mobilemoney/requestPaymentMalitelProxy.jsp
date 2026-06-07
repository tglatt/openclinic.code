<%@page import="javax.json.JsonObject"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*,be.mxs.common.util.db.*"%>
<%@include file="/includes/helper.jsp"%>

<%
	String sTransactionId=SH.p(request,"transactionId");
	String sAmount=SH.p(request,"amount");
	String sMsisdn=SH.p(request,"msisdn");
	String sMessage=SH.p(request,"message");
	String sLogin=SH.p(request,"login");
	String sPassword=SH.p(request,"password");
	String sPatientUid=SH.p(request,"patientuid");
	String sUserId=SH.p(request,"userid");
	JsonObject jo = Malitel.requestPayment(sTransactionId, sMsisdn, Integer.parseInt(sAmount), sMessage, sPatientUid,sUserId, sLogin,sPassword);
	out.println(jo.toString());
%>