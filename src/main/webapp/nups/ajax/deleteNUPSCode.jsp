<%@page import="be.mayele.MayeleAPI"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String msg="";
	String code = SH.p(request,"code");
	String extension = SH.p(request,"extension");
	Connection conn = SH.getOpenClinicConnection();
	if(code.length()>0){
		if(extension.length()>0){
			code=code+"."+extension;
		}
		String sql="delete from nupsref where nups=?";
		PreparedStatement ps = conn.prepareStatement(sql);
		ps.setString(1,code);
		ps.execute();
		ps.close();
		msg="NUPS code "+code+" has been deleted";
	}
	else {
		msg="Cannot delete empty NUPS code";
	}
	conn.close();
%>
<h1>
<%=msg%>
</h1>