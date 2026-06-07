<%@include file="/includes/validateUser.jsp"%>
<%
	double total=0, rfe=0;
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM oc_encounters WHERE oc_encounter_enddate BETWEEN ? and ? and oc_encounter_type='visit'");
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
	ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		total=rs.getDouble("total");
	}
	rs.close();
	ps.close();	
	ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM oc_encounters WHERE oc_encounter_enddate BETWEEN ? and ? AND oc_encounter_type='visit' and exists (select * from oc_rfe where replace(oc_rfe_encounteruid,'1.','')=oc_encounter_objectid)");
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
	ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
	rs = ps.executeQuery();
	if(rs.next()){
		rfe=rs.getDouble("total");
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	coverage: <%=rfe*100/total %>
}