<%@page import="be.mxs.common.util.system.Pointer"%>
<%@include file="/includes/helper.jsp"%>
<%
	String sEncounterUid = SH.p(request,"encounterUid");
	if(sEncounterUid.split("\\.").length==3){
		//Store encounter in pointers
		Pointer.storeUniquePointer("malariyapi", sEncounterUid, SH.now());
		out.println("{\"result\":\"200\",\"encounterUid\":\""+sEncounterUid+"\"}");
	}
%>