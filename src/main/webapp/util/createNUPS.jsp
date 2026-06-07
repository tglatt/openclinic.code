<%@page import="be.mayele.MayeleAPI"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from nups where nups is null or nups=''");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		int muid = rs.getInt("muid");
		String nups = MayeleAPI.convertToNUPSUUID(muid);
		PreparedStatement ps2 = conn.prepareStatement("update nups set nups=? where muid=?");
		ps2.setString(1,nups);
		ps2.setInt(2,muid);
		ps2.execute();
		ps2.close();
	}
	rs.close();
	ps.close();
	conn.close();
%>