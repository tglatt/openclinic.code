<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	double er=-1;
	java.util.Date date = SH.parseDate(request.getParameter("date"));
	if(date==null){
		date = new java.util.Date();
	}
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select OC_EXCHANGERATE_RATE from OC_EXCHANGERATES where OC_EXCHANGERATE_DATE<=? and OC_EXCHANGERATE_CURRENCY=? order by OC_EXCHANGERATE_DATE DESC");
	ps.setDate(1, SH.toSQLDate(date));
	ps.setString(2, request.getParameter("currency"));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		er=rs.getDouble("OC_EXCHANGERATE_RATE");
	}
	rs.close();
	ps.close();
	conn.close();

	out.println(er==-1?"":new java.text.DecimalFormat("#0.0000000000000000").format(er));
%>