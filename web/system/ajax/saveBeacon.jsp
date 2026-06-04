<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.system.Beacon"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sMessage = "";
	String sId = checkString(request.getParameter("id"));
	String sAlias = checkString(request.getParameter("alias"));
	String sResourceType = checkString(request.getParameter("resourcetype"));
	String sResourceId = checkString(request.getParameter("resourceid"));
	String sComment = checkString(request.getParameter("comment"));
       
	Beacon beacon = Beacon.get(sId);
	if(beacon==null){
		beacon = new Beacon();
	}
	beacon.setId(sId);
	beacon.setAlias(sAlias);
	beacon.setResourceType(sResourceType);
	beacon.setResourceId(sResourceId);
	beacon.setComment(sComment);
	boolean errorOccurred=!beacon.store();
	
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTranNoLink("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = "<font color='red'>"+getTranNoLink("web","error",sWebLanguage)+"</font>";
    }
	
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}