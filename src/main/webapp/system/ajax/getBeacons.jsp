<%@page import="be.openclinic.system.Beacon"%>
<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    // search-criteria
    String sId           = checkString(request.getParameter("id")),
           sAlias           = checkString(request.getParameter("alias")),
           sType      = checkString(request.getParameter("type"));


    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** system/ajax/getBeacons.jsp ****************");
        Debug.println("sId           : "+sId);
        Debug.println("sAlias           : "+sAlias);
        Debug.println("sType      : "+sType);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    // compose object to pass search criteria with
    Vector<Beacon> beacons = Beacon.getList(sId,sAlias,sType);
    String sReturn = "";
    
    if(beacons.size() > 0){
        Hashtable<String,String> hSort = new Hashtable<String,String>();
        Beacon beacon;
        // sort on supplier.code
        for(int i=0; i<beacons.size(); i++){
            beacon = beacons.get(i);

            hSort.put(SH.c(beacon.getAlias())+"="+beacon.getId(),
                      " onclick=\"displayBeacon('"+beacon.getId()+"');\">"+
                      "<td class='hand' style='padding-left:5px'>"+beacon.getId()+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+beacon.getAlias()+
                      (beacon.getResourceType().equalsIgnoreCase("patient")?"<a style='font-weight: bolder' href='"+sCONTEXTPATH+"/main.do?Page=curative/index.jsp&PersonID="+beacon.getResourceId()+"'>"+
                      (SH.c(beacon.getComment()).length()>0?" ["+beacon.getComment()+"]":"")+"</a>"
                      :(SH.c(beacon.getComment()).length()>0?" ["+beacon.getComment()+"]":""))+
                      "</td>"+
                      "<td class='hand' style='padding-left:5px'>"+beacon.getResourceType()+"</td>"+
                      "<td class='hand' style='padding-left:5px'>"+beacon.getResourceId()+"</td>"+
                     "</tr>");
        }
    
        Vector<String> keys = new Vector(hSort.keySet());
        Collections.sort(keys);
        Iterator<String> iter = keys.iterator();
        String sClass = "1";
        
        while(iter.hasNext()){
            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            sReturn+= "<tr class='list"+sClass+"' "+hSort.get(iter.next());
        }
    }
    else{
        sReturn = "<td colspan='4'>"+getTran(request,"web","noRecordsFound",sWebLanguage)+"</td>";
    }
%>

<%
    if(beacons.size() > 0){
        %>
<table width="100%" class="sortable" id="searchresults" cellspacing="1" style="border:none;">
    <%-- header --%>
    <tr class="admin" style="padding-left:1px;">    
        <td width="10%" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web","id",sWebLanguage))%></td>
        <td width="25%" nowrap><asc><%=HTMLEntities.htmlentities(getTran(request,"web","alias",sWebLanguage))%></asc></td>
        <td width="15%" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web","type",sWebLanguage))%></td>
        <td width="*" nowrap><%=HTMLEntities.htmlentities(getTran(request,"web","id",sWebLanguage))%></td>
    </tr>
    
    <tbody class="hand"><%=sReturn%></tbody>
</table> 

&nbsp;<i><%=beacons.size()+" "+getTran(request,"web","recordsFound",sWebLanguage)%></i>
        <%
    }
    else{
        %><%=sReturn%><%
    }
%>