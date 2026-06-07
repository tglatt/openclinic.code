<%@page import="be.openclinic.finance.PatientInvoice"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	double prematures = 0,total=0;
	Connection conn = SH.getOpenClinicConnection();
	String sSql = "select count(*) number from transactions t,items i where t.updatetime>=? and t.updatetime<=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ATTERM' and i.value ='medwan.common.false')";
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
	ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		prematures=rs.getDouble("number");
	}
	rs.close();
	ps.close();
	sSql = "select count(*) number from transactions t,items i where t.updatetime>=? and t.updatetime<=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ATTERM' and i.value in('medwan.common.true','medwan.common.false'))";
	ps = conn.prepareStatement(sSql);
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
	ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
	rs = ps.executeQuery();
	if(rs.next()){
		total=rs.getDouble("number");
	}
	rs.close();
	ps.close();
%>
{
	number: "<%=new Double(prematures).intValue() %>",
	numberpct: "<%=new DecimalFormat("#0.00").format(prematures*100/total)%>"
}