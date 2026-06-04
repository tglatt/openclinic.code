<%@page import="be.openclinic.finance.Wicket"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='2'><%=getTran(request,"web","todaysincome",sWebLanguage) %></td>
	</tr>
	<%
		Connection conn = SH.getOpenClinicConnection();
		String sSql = 	"select sum(oc_wicket_credit_amount) amount,oc_wicket_credit_wicketuid from oc_wicket_credits,oc_patientinvoices where "+
						" oc_wicket_credit_type='patient.payment' and oc_patientinvoice_objectid=replace(oc_wicket_credit_invoiceuid,'1.','') and "+
						" oc_wicket_credit_operationdate>=? and oc_wicket_credit_operationdate<now() group by oc_wicket_credit_wicketuid"+
						" order by sum(oc_wicket_credit_amount) desc";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			out.println("<tr>");
			out.println("<td class='admin'>"+Wicket.getWicketName(rs.getString("oc_wicket_credit_wicketuid"), sWebLanguage)+"</td>");
			out.println("<td class='admin2'>"+SH.formatPrice(rs.getDouble("amount"))+"</td>");
			out.println("</tr>");
		}
		rs.close();
		ps.close();
		conn.close();
	%>
</table>
