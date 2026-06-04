<%@include file="/includes/validateUser.jsp"%>
<%
	double consultations=0, patients=0;

	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM oc_encounters WHERE oc_encounter_begindate BETWEEN ? and ? and oc_encounter_type='visit'");
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeYear()));
	ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		consultations=rs.getInt("total");
	}
	rs.close();
	ps.close();	
	ps = conn.prepareStatement("SELECT COUNT(distinct oc_encounter_patientuid) AS total FROM oc_encounters WHERE oc_encounter_begindate BETWEEN ? and ? and oc_encounter_type='visit'");
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeYear()));
	ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
	rs = ps.executeQuery();
	if(rs.next()){
		patients=rs.getInt("total");
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	consultations : <%=consultations/patients %>
}