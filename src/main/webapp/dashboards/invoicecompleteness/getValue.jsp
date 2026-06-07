<%@include file="/includes/validateUser.jsp"%>
<%
	double total=0, paid=0;
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM oc_encounters WHERE oc_encounter_enddate BETWEEN ? and ?");
	ps.setDate(1,new java.sql.Date(SH.getPreviousMonthBegin().getTime()));
	ps.setDate(2,new java.sql.Date(SH.getBeginOfMonth().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		total=rs.getDouble("total");
	}
	rs.close();
	ps.close();	
	ps = conn.prepareStatement("SELECT COUNT(*) AS total FROM oc_encounters WHERE oc_encounter_enddate BETWEEN ? and ? AND EXISTS (SELECT * FROM oc_patientinvoices WHERE oc_patientinvoice_patientuid=oc_encounter_patientuid AND oc_patientinvoice_date>=date(oc_encounter_begindate))");
	ps.setDate(1,new java.sql.Date(SH.getPreviousMonthBegin().getTime()));
	ps.setDate(2,new java.sql.Date(SH.getBeginOfMonth().getTime()));
	rs = ps.executeQuery();
	if(rs.next()){
		paid=rs.getDouble("total");
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	coverage: <%=paid*100/total %>
}