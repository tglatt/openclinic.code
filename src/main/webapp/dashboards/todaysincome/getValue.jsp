<%@include file="/includes/validateUser.jsp"%>
<%
	double amount=0;
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT sum(oc_wicket_credit_amount) amount FROM oc_wicket_credits WHERE oc_wicket_credit_operationdate>= ? and oc_wicket_credit_operationdate<now() and oc_wicket_credit_type='patient.payment'");
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		amount=rs.getDouble("amount");
	}
	rs.close();
	ps.close();	
	conn.close();
%>
{
	"amount": "<%=SH.formatPrice(amount) %>"
}