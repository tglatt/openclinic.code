<%@page import="javax.json.JsonObject"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*,be.mxs.common.util.db.*"%>
<%@include file="/includes/helper.jsp"%>

<%
	String sTransactionId=SH.p(request,"transactionId");
	String sAmount=SH.p(request,"amount");
	String sPhone=SH.p(request,"phone");
	String sMessage=SH.p(request,"message");
	String sLogin=SH.p(request,"login");
	String sPassword=SH.p(request,"password");
	String sPatientUid=SH.p(request,"patientuid");
	String sUserid=SH.p(request,"userid");
	OrangeMali om = new OrangeMali();
	JsonObject jo = om.requestPayment(sTransactionId, sPhone, new Double(Double.parseDouble(sAmount)).intValue(), sMessage, sLogin, sPassword, sPatientUid, sUserid);
	out.println(jo.toString());
%>