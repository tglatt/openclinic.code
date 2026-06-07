<%@page import="javax.json.JsonObject"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*"%>
<%@page import="be.openclinic.mobilemoney.*,be.openclinic.system.*,be.mxs.common.util.db.*"%>
<%@include file="/includes/helper.jsp"%>

<%

	String sRequestId=SH.p(request,"requestId");
	String sMsisdn=SH.p(request,"msisdn");
	String sLogin=SH.p(request,"login");
	String sPassword=SH.p(request,"password");
	JsonObject jo = Malitel.getSubscriberInfo(sMsisdn, sRequestId,sLogin,sPassword);
	out.println(jo.toString());
%>
