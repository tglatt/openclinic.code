<%@page import="javax.json.JsonObject"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*,be.mxs.common.util.db.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sStatus="error";
	String sTransactionId=SH.p(request,"transactionId");
	String sRequestId=SH.p(request,"requestId");
	String sAmount=SH.p(request,"amount");
	String sPhone=SH.p(request,"phone");
	String sMessage=SH.p(request,"message");
	String sCurrency=SH.p(request,"currency");
	String sPatientUid=SH.p(request,"patientuid");
	JsonObject jo = Malitel.requestPayment(sTransactionId, sPhone, new Double(sAmount).intValue(), sMessage, sPatientUid, activeUser.userid);
	SH.syslog(jo.toString());
	if(!jo.isNull("status") && (jo.getString("status").equalsIgnoreCase("0"))){
		sStatus="ok";
	}
%>
{
	"status":"<%=sStatus %>",
	"transactionId":"<%=sTransactionId %>"
}
