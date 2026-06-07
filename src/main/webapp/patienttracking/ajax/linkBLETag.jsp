<%@page import="be.openclinic.system.Beacon"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String alias = SH.p(request,"alias");
	Beacon beacon = Beacon.getByAlias(alias);
	String msg = getTranNoLink("web","unknownalias",sWebLanguage);
	if(beacon!=null){
		if(SH.c(beacon.getResourceId()).length()>0){
			msg = getTranNoLink("web","alias",sWebLanguage)+" "+alias+" "+getTranNoLink("web","linkedto",sWebLanguage)+" "+beacon.getComment()+". "+getTranNoLink("web","unlinkitfirst",sWebLanguage);
		}
		else{
			Connection conn = SH.getOpenClinicConnection();
			PreparedStatement ps = conn.prepareStatement("select * from oc_beacon_recordings where oc_beacon_id=? order by oc_beacon_updatetime desc");
			ps.setString(1,beacon.getId());
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				if(rs.getInt("OC_BEACON_MOVEMENT")!=1){
					PreparedStatement ps3 = conn.prepareStatement("insert into OC_BEACON_RECORDINGS(OC_BEACON_ID,OC_BEACON_RESOURCETYPE,OC_BEACON_RESOURCEID,OC_BEACON_READERID,OC_BEACON_RSSI,OC_BEACON_EXITCOUNTER,OC_BEACON_MOVEMENT,OC_BEACON_UPDATETIME,OC_BEACON_OBJECTID,OC_BEACON_TS) values(?,?,?,?,?,?,?,?,?,?)");
					ps3.setString(1, rs.getString("OC_BEACON_ID"));
					ps3.setString(2, rs.getString("OC_BEACON_RESOURCETYPE"));
					ps3.setString(3, rs.getString("OC_BEACON_RESOURCEID"));
					ps3.setString(4, rs.getString("OC_BEACON_READERID"));
					ps3.setInt(5, rs.getInt("OC_BEACON_RSSI"));
					ps3.setInt(6, 0);
					ps3.setInt(7, 1); //OUT
					ps3.setTimestamp(8, SH.getSQLTime());
					ps3.setInt(9, MedwanQuery.getInstance().getOpenclinicCounter("OC_BEACON_OBJECTID"));
					ps3.setTimestamp(10, SH.getSQLTime());
					ps3.execute();
					ps3.close();
				}
			}
			rs.close();
			ps.close();
			conn.close();
			beacon.setResourceType("patient");
			beacon.setResourceId(activePatient.personid);
			beacon.setComment(activePatient.getFullName());
			beacon.store();
			msg = getTranNoLink("web","alias",sWebLanguage)+" "+alias+" "+getTranNoLink("web","linkedto",sWebLanguage)+" "+activePatient.getFullName();
		}
	}
%>
{
	"msg": "<%=msg %>"
}