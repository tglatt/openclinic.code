<%@include file="/includes/validateUser.jsp"%>
<%
	double total=0, diagnosis=0;
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM oc_encounters WHERE oc_encounter_enddate BETWEEN ? and ? and oc_encounter_type='admission'");
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
	ps.setTimestamp(2,SH.toSQLTimestamp(new java.util.Date()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		total=rs.getDouble("total");
	}
	rs.close();
	ps.close();	
	ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM oc_encounters WHERE oc_encounter_enddate BETWEEN ? and ? AND oc_encounter_type='admission' and exists (select * from oc_diagnoses where replace(oc_diagnosis_encounteruid,'1.','')=oc_encounter_objectid)");
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
	ps.setTimestamp(2,SH.toSQLTimestamp(new java.util.Date()));
	rs = ps.executeQuery();
	if(rs.next()){
		diagnosis=rs.getDouble("total");
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	"coverage": <%=total==0?-1:diagnosis*100/total %>
}