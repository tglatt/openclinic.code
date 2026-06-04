<%@page import="be.openclinic.finance.PatientInvoice"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	int occupancy=0;
	Vector los = new Vector();;
	Connection conn = SH.getOpenClinicConnection();
	String sSql = "select count(distinct oc_encounter_patientuid) total from oc_encounters where (oc_encounter_enddate is null or oc_encounter_enddate>=?) and oc_encounter_begindate<? and oc_encounter_type='admission'";
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()));
	ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		occupancy=rs.getInt("total");
	}
	rs.close();
	ps.close();
%>
{
	occupancy: "<%=occupancy %>"
}