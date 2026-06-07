<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="javax.json.JsonObject"%>
<%@page import="javax.json.Json"%>
<%@page import="javax.json.JsonReader"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*"%>
<%
	String requestId=SH.p(request,"requestId");
	String sLogin=SH.p(request,"login");
	String sPassword=SH.p(request,"password");
	JsonObject jo = Malitel.getPaymentStatus(requestId,sLogin,sPassword);
	out.println(jo.toString());
%>
