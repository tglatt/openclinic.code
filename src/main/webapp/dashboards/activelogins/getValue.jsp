<%@include file="/includes/validateUser.jsp"%>
<%
	String activelogins="0";
	Connection conn = SH.getAdminConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) logins FROM (SELECT COUNT(*) logins,userid FROM (SELECT distinct userid,DATE_FORMAT(accesstime, '%d/%m/%Y') FROM accesslogs WHERE accesstime between ? and ?) a GROUP BY userid) b WHERE logins>4");
	ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
	ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		activelogins=rs.getString("logins");
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	activelogins: <%=activelogins %>
}