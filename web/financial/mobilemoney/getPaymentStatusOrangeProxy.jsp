<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*"%>
<%
	String sTransactionId=SH.p(request,"transactionId");
	String sLogin=SH.p(request,"login");
	String sPassword=SH.p(request,"password");
	OrangeMali om = new OrangeMali();
	JsonObject jo = om.getPaymentStatus(sTransactionId,sLogin,sPassword);
	out.println(jo.toString());
%>
