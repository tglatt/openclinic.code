<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='2'><%=getTran(request,"web","code",sWebLanguage) %></td>
		<td><%=getTran(request,"web","section",sWebLanguage) %></td>
		<td colspan='2'><%=getTran(request,"web","label",sWebLanguage) %></td>
	</tr>
<%
	String code=SH.p(request,"code");
	String level=SH.p(request,"level");
	String group=SH.p(request,"group");
	String extension=SH.p(request,"extension");
	String originalcode=SH.p(request,"originalcode");
	String sectioncode=SH.p(request,"sectioncode");
	String keywords=SH.p(request,"keywords");
	String parent=SH.p(request,"parent");
	String limit=SH.p(request,"limit");
	String csu=SH.p(request,"csu");
	String sort=SH.p(request,"sort");
	Connection conn = SH.getOpenClinicConnection();
	String sql="select r.*,(select count(*) from nupsref where parent=r.nups) children from nupsref r where 1=1";
	if(sectioncode.length()>0){
		sql+=" and sectioncode='"+sectioncode+"'";
	}
	else{
		//Only show codes from authorized list
		sql+=" and sectioncode in ("+SH.getAvailableNUPSSections(activeUser)+")";
	}
	if(keywords.length()>0 && !sort.equalsIgnoreCase("4")){
		for(int n=0;n<keywords.split(" ").length;n++){
			if(keywords.split(" ")[n].trim().length()>0){
				sql+=" and "+sWebLanguage+" like '%"+keywords.split(" ")[n].trim()+"%'";
			}
		}
	}
	if(code.length()>0 && !sort.equalsIgnoreCase("3")){
		if(extension.length()>0){
			sql+=" and nups='"+code+"."+extension+"'";
		}
		else{
			sql+=" and (nups='"+code+"' or nups like '"+code+".%')";
		}
	}
	if(originalcode.length()>0){
		sql+=" and originalcode='"+originalcode+"'";
	}
	if(parent.length()>0){
		sql+=" and parent='"+parent+"'";
	}
	if(csu.equalsIgnoreCase("true")){
		sql+=" and csu='true'";
	}
	if(level.length()>0){
		sql+=" and exists (select * from nupsapplications ap where ap.nups=r.nups and application='levels' and data='"+level+"')";
	}
	if(group.length()>0){
		sql+=" and exists (select * from nupsapplications ap where ap.nups=r.nups and application='groups' and data='"+group+"')";
	}
	if(sort.equalsIgnoreCase("1")){
		sql+=" order by nups";
	}
	if(sort.equalsIgnoreCase("2")){
		sql+=" order by "+sWebLanguage;
	}
	if(sort.equalsIgnoreCase("3")){
		sql+=" and nups>='"+code+"' order by nups";
	}
	if(sort.equalsIgnoreCase("4")){
		sql+=" and "+sWebLanguage+">='"+keywords+"' order by "+sWebLanguage;
	}
	sql+=" limit "+limit;
	PreparedStatement ps = conn.prepareStatement(sql);
	ResultSet rs = ps.executeQuery();
	int n=0;
	while(rs.next()){
		n++;
		String nups=rs.getString("nups");
		String imgedit="&nbsp;<img title='"+getTranNoLink("nups","edit",sWebLanguage)+"' style='vertical-align: middle' height='14px' src='"+sCONTEXTPATH+"/_img/icons/mobile/edit.png' onclick='editNUPS(\""+nups+"\");'/>";
		if(nups.split("\\.").length<2){
			imgedit+="&nbsp;<img title='"+getTranNoLink("nups","showextensions",sWebLanguage)+"' style='vertical-align: middle' height='14px' src='"+sCONTEXTPATH+"/_img/icons/mobile/copy.png' onclick='showNUPSCode(\""+nups+"\");'/>";
		}
		String imgdown="";
		if(rs.getInt("children")>0){
			imgdown="&nbsp;<img title='"+getTranNoLink("nups","children",sWebLanguage)+"' style='vertical-align: middle' height='14px' src='"+sCONTEXTPATH+"/_img/icons/mobile/down.png' onclick='showNUPSChildren(\""+nups+"\");'/>";
		}
		String imgup="";
		if(SH.c(rs.getString("parent")).length()>0){
			imgup="&nbsp;<img title='"+getTranNoLink("nups","parent",sWebLanguage)+": "+rs.getString("parent")+"' style='vertical-align: middle' height='14px' src='"+sCONTEXTPATH+"/_img/icons/mobile/increase.png' onclick='showNUPSCode(\""+rs.getString("parent")+"\");'/>";
		}
		out.println("<tr><td class='admin'><a title='"+getTranNoLink("nups","edit",sWebLanguage)+"' style='font-weight: bolder;color: darkblue' href='javascript:editNUPS(\""+nups+"\")'>"+nups+"</a></td><td class='admin'>"+imgedit+imgdown+imgup+"&nbsp;</td><td class='admin' nowrap>"+getTran(request,"nups.section",rs.getDouble("sectioncode")+"",sWebLanguage)+"&nbsp;</td><td class='admin2'>"+(nups.contains(".")||!activeUser.getAccessRight("nups.manage.select")?"":"<input type='button' class='button' value='"+getTranNoLink("nups","subcode",sWebLanguage)+"' onclick='extendNUPS(\""+nups+"\");'/>")+"</td><td class='admin2'>"+SH.c(rs.getString(sWebLanguage)).toUpperCase().split(";")[0]+"</td></tr>");
	}
	if(n>Long.parseLong(limit)-1){
		out.println("<tr><td colspan='5'>"+getTran(request,"web","toomanyrows",sWebLanguage)+" >"+limit+"</td></tr>");
	}
	else{
		out.println("<tr><td colspan='5'>"+getTran(request,"web","totalrows",sWebLanguage)+" = "+n+"</td></tr>");
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>