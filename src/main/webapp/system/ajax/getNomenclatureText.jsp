<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String code = SH.p(request,"code");
	String msg="";
	Connection conn = SH.getOpenClinicConnection();
	String sql="";
	if(SH.cs("prestationNomenclatureTable","nups").equalsIgnoreCase("nups")){
		sql="select * from nupsref where nups=?";
	}
	PreparedStatement ps = conn.prepareStatement(sql);
	ps.setString(1,code);
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		if(SH.cs("prestationNomenclatureTable","nups").equalsIgnoreCase("nups")){
			msg=SH.c(rs.getString(sWebLanguage).split(";")[0]).replaceAll("\n"," ").replaceAll("\r"," ");
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>
{
	"text":"<%=msg %>"
}