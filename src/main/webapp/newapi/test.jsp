<%@include file="/includes/validateUser.jsp"%>

<%
String contenu = "";
if(request.getParameter("contenu")!=null){
	contenu=request.getParameter("contenu");
}
%>


<table width='100%'>
	<tr class='admin'><td colspan='5'>Bonjour!</td></tr>
	<%
		
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		PreparedStatement ps = conn.prepareStatement(" select personid,lastname,firstname,dateofbirth,gender,telephone "+
				                                     " from admin,adminprivate"+
				                                     " where"+
				                                     " admin.personid=adminprivate.personid;");
		ps.setString(1,"%"+contenu+"%");
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String personid = rs.getString("personid");
			String lastname = rs.getString("lastname");
			String firstname = rs.getString("firstname");
			String telephone = rs.getString("telephone");
			String gender = rs.getString("gender");
			String dateofbirth = rs.getString("dateofbirth");
			out.println("<tr><td class='admin'>"+personid+"</td><td class='admin2'>"+
			lastname.toUpperCase()+", "+firstname+"</td><td class='admin2'>"+telephone+"</td><td class='admin2'>"+gender+", "+dateofbirth+"</td></tr>");
			out.println("Nombre total de patients retrouvés<%=");
		}
		rs.close();
		ps.close();
		conn.close();
	%>
</table>