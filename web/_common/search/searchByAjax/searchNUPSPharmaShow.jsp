<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran(request,"web","code",sWebLanguage) %></td>
		<td><%=getTran(request,"web","section",sWebLanguage) %></td>
		<td><%=getTran(request,"web","label",sWebLanguage) %></td>
	</tr>
<%
	String section=SH.p(request,"section");
	String keyword=SH.p(request,"keyword");
	Connection conn = SH.getOpenClinicConnection();
	String sql="select * from nupsref where domain in ('MED','CONS','PROT')";
	if(section.length()>0){
		sql+=" and sectioncode='"+section+"'";
	}
	if(keyword.length()>0){
		for(int n=0;n<keyword.split(" ").length;n++){
			if(keyword.split(" ")[n].trim().length()>0){
				sql+=" and "+sWebLanguage+" like '%"+keyword.split(" ")[n].trim()+"%'";
			}
		}
	}
	sql+=" limit 1000";
	PreparedStatement ps = conn.prepareStatement(sql);
	ResultSet rs = ps.executeQuery();
	int n=0;
	while(rs.next()){
		n++;
		out.println("<tr><td class='admin'><a style='font-weight: bolder;color: darkblue' href='javascript:selectNUPS(\""+rs.getString("nups")+"\")'>"+rs.getString("nups")+"</a>&nbsp;</td><td class='admin' nowrap>"+getTranNoLink("nups.section",rs.getString("sectioncode"),sWebLanguage)+"&nbsp;</td><td class='admin2'>"+rs.getString(sWebLanguage).toUpperCase().split(";")[0]+"</td></tr>");
	}
	if(n>999){
		out.println("<tr><td colspan='2'>"+getTran(request,"web","toomanyrows",sWebLanguage)+"</td></tr>");
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>