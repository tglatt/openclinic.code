<%@include file="/includes/validateUser.jsp"%>
<%
	int consultations=0, admissions=0;
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT COUNT(distinct DATE_FORMAT(oc_encounter_begindate, '%Y-%m-%d'),oc_encounter_patientuid) AS total FROM oc_encounters WHERE oc_encounter_begindate BETWEEN ? and ? and oc_encounter_type='visit'");
	ps.setDate(1,new java.sql.Date(SH.getPreviousMonthBegin().getTime()));
	ps.setDate(2,new java.sql.Date(SH.getBeginOfMonth().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		consultations=rs.getInt("total");
	}
	rs.close();
	ps.close();	
	ps = conn.prepareStatement("SELECT COUNT(distinct DATE_FORMAT(oc_encounter_begindate, '%Y-%m-%d'),oc_encounter_patientuid) AS total FROM oc_encounters WHERE oc_encounter_begindate BETWEEN ? and ? and oc_encounter_type='admission'");
	ps.setDate(1,new java.sql.Date(SH.getPreviousMonthBegin().getTime()));
	ps.setDate(2,new java.sql.Date(SH.getBeginOfMonth().getTime()));
	rs = ps.executeQuery();
	if(rs.next()){
		admissions=rs.getInt("total");
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	consultations : <%=consultations %>,
	admissions : <%=admissions %>
}