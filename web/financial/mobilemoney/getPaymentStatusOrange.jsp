<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*"%>
<%
	String transactionId = SH.p(request,"transactionId");
	SH.syslog("transactionId="+transactionId);
	OrangeMali om = new OrangeMali();
	JsonObject jo = om.getPaymentStatus(transactionId);
	String sStatus = SH.c(jo.getJsonObject("data").getString("state")).toLowerCase();
	if(!jo.isNull("code") && jo.getInt("code")!=200){
		sStatus="error";
	}
	String txn_id =jo.getJsonObject("data").isNull("txn_id")?"":SH.c(jo.getJsonObject("data").getString("txn_id"));
   	if(SH.ci("mali.orangemoney.simulate",0)==1) {
   		sStatus="ok";
   		txn_id="SIM_"+new java.util.Date().getTime();
   	}
   	
   	if(sStatus.equalsIgnoreCase("ok")){
   		//Update payment request status
   		MobileMoney.updatePaymentStatus(transactionId, "OK", txn_id);
   	}

%>
{
	"status":"<%=sStatus %>",
	"financialTransactionId":"<%=txn_id%>",
	"ref":"<%=transactionId %>"
}