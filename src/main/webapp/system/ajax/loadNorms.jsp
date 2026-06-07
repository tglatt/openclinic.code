<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
	<%
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("select * from oc_standards where structure = ? order by structure,nomenclature");
		ps.setString(1,SH.p(request,"structure"));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String snm="";
			String nm[] = rs.getString("nomenclature").split(";");
			for(int n=0;n<nm.length;n++){
				if(n>0){
					snm+=", ";
				}
				snm+=nm[n].toUpperCase()+" - "+getTran(request,"admin.nomenclature.asset",nm[n],sWebLanguage);
			}
			out.println("<tr><td class='admin2'>"+rs.getString("structure").toUpperCase()+"</td><td class='admin2'>"+rs.getString("quantity")+(rs.getString("nomenclature").toUpperCase().startsWith("I")?" m2":"")+"</td><td class='admin2'><a href='javascript:editstandard(\""+rs.getString("structure")+"\",\""+rs.getString("nomenclature")+"\",\""+rs.getString("quantity")+"\")'>"+snm+"</a></td></tr>");
		}
		rs.close();
		ps.close();
		conn.close();
	%>
