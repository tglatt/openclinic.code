<%@page import="java.util.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindRegion = checkString(request.getParameter("FindRegion"));

    Vector vSectors = Zipcode.getSectors(sFindRegion,MedwanQuery.getInstance().getConfigString("zipcodetable","RwandaZipcodes"));
    Collections.sort(vSectors);

    String sTmpSector, sSectors = "";
    for(int i=0; i<vSectors.size(); i++){
        sTmpSector = (String)vSectors.elementAt(i);
        sSectors+= "$"+checkString(sTmpSector);
    }
    
    out.print(sSectors);
%>
