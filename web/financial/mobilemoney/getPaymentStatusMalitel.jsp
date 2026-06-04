<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*"%>
<%
	String requestId = SH.p(request,"requestId");
	SH.syslog("requestId="+requestId);
	JsonObject jo = Malitel.getPaymentStatus(requestId);
	SH.syslog(jo);
	String sStatus = "ok";
	if(!jo.isNull("status") && !jo.getString("status").equalsIgnoreCase("0")){
		sStatus="error";
	}
	String txn_id =SH.c(jo.getString("trans-id"));
   	if(SH.ci("mali.malitel.simulate",0)==1) {
   		sStatus="ok";
   		txn_id="SIM_"+new java.util.Date().getTime();
   	}
   	
   	if(sStatus.equalsIgnoreCase("ok")){
   		//Update payment request status
   		MobileMoney.updatePaymentStatus(requestId, "OK", txn_id);
   	}

%>
{
	"status":"<%=sStatus %>",
	"financialTransactionId":"<%=txn_id%>",
	"ref":"<%=requestId %>"
}