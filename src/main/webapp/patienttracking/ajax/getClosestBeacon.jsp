<%@page import="be.openclinic.system.Beacon"%>
<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Beacon beacon = new Beacon();
	String readerId=SH.p(request,"readerid");
	int rssi=0;
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_beacon_recordings where oc_beacon_readerid=? order by oc_beacon_updatetime desc,oc_beacon_rssi desc limit 1");
	ps.setString(1,readerId);
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		if(rs.getTimestamp("oc_beacon_updatetime").after(new java.util.Date(new java.util.Date().getTime()-SH.getTimeMinute()))){
			rssi=rs.getInt("oc_beacon_rssi");
			beacon = Beacon.get(rs.getString("oc_beacon_id"));
			if(beacon==null){
				beacon = new Beacon();
				beacon.setId(rs.getString("oc_beacon_id"));
			}
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	"id":"<%=SH.c(beacon.getId()) %>",
	"alias":"<%=SH.c(beacon.getAlias()) %>",
	"resourcetype":"<%=SH.c(beacon.getResourceType()) %>",
	"resourceid":"<%=SH.c(beacon.getResourceId()) %>",
	"rssi":"<%=rssi %>",
	"comment":"<%=SH.c(beacon.getComment()) %>"
}