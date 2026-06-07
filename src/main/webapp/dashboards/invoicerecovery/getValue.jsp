<%@page import="be.openclinic.finance.PatientInvoice"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	double amount=0,paid=0;
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT SUM(oc_debet_amount) amount FROM oc_patientinvoices, oc_debets WHERE replace(oc_debet_patientinvoiceuid,'1.','')=oc_patientinvoice_objectid AND oc_patientinvoice_date BETWEEN ? AND ? AND oc_patientinvoice_status='closed'");
	ps.setDate(1,new java.sql.Date(SH.getPreviousMonthBegin().getTime()));
	ps.setDate(2,new java.sql.Date(SH.getBeginOfMonth().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		amount=rs.getDouble("amount");
	}
	rs.close();
	ps.close();	
	System.out.println(1);
	ps = conn.prepareStatement("SELECT SUM(oc_patientcredit_amount) amount FROM oc_patientinvoices, oc_patientcredits WHERE replace(oc_patientcredit_invoiceuid,'1.','')=oc_patientinvoice_objectid AND oc_patientinvoice_date BETWEEN ? AND ? AND oc_patientinvoice_status='closed'");
	ps.setDate(1,new java.sql.Date(SH.getPreviousMonthBegin().getTime()));
	ps.setDate(2,new java.sql.Date(SH.getBeginOfMonth().getTime()));
	rs = ps.executeQuery();
	if(rs.next()){
		paid=rs.getDouble("amount");
	}
	rs.close();
	ps.close();
	conn.close();

%>
{
	coverage: <%=paid*100/amount %>
}