<%@page import="be.openclinic.system.Beacon,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sId = checkString(request.getParameter("beaconId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** system/ajax/getBeacon.jsp *****************");
        Debug.println("sId : "+sId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Beacon beacon = Beacon.get(sId);
    
    if(beacon!=null){
        %>    
{    
  "id":"<%=beacon.getId()%>",
  "alias":"<%=HTMLEntities.htmlentities(SH.c(beacon.getAlias()))%>",
  "resourcetype":"<%=HTMLEntities.htmlentities(SH.c(beacon.getResourceType()))%>",
  "resourceid":"<%=HTMLEntities.htmlentities(SH.c(beacon.getResourceId()))%>",
  "comment":"<%=SH.c(beacon.getComment())%>",
  "updatetime":"<%=HTMLEntities.htmlentities(SH.formatDate(beacon.getUpdatetime(),"yyyyMMddHHmmss"))%>",
}
        <%
    }
    else{
        %>    
{
  "id":"",
  "alias":"",
  "resourcetype":"",
  "resourceid":"",
  "comment":"",
  "updatetime":"",
}
        <%
    }
%>