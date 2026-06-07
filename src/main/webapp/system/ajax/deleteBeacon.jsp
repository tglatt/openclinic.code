<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.system.Beacon"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sId = checkString(request.getParameter("beaconId"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** system/ajax/deleteBeacon.jsp **************");
        Debug.println("sId : "+sId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = Beacon.delete(sId);
    String sMessage = "";
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTranNoLink("web","dataIsDeleted",sWebLanguage)+"</font>";
    }
    else{
        sMessage = "<font color='red'>"+getTranNoLink("web","error",sWebLanguage)+"</font>";
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}