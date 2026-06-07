<%@page import="be.openclinic.finance.PatientInvoice"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	double prematures = 0,total=0;
	Vector los = new Vector();;
	Connection conn = SH.getOpenClinicConnection();
	String sSql = "select * from oc_encounters where oc_encounter_enddate>=? and oc_encounter_enddate<=? and oc_encounter_type='admission'";
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
	ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		los.add(new Double((rs.getTimestamp("oc_encounter_enddate").getTime()-rs.getTimestamp("oc_encounter_begindate").getTime()))/new Double(SH.getTimeDay()));
	}
	rs.close();
	ps.close();
	double totalvalue=0;
	for(int n=0;n<los.size();n++){
		totalvalue+=(Double)los.elementAt(n);
	}
%>
{
	los: "<%=los.size()==0?"?":new DecimalFormat("#0.00").format(totalvalue/los.size()) %>"
}