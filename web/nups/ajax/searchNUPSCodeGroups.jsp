<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<link href="https://unpkg.com/bootstrap@3.3.2/dist/css/bootstrap.min.css" rel="stylesheet"/>
<script src="https://unpkg.com/jquery@3.3.1/dist/jquery.min.js"></script>
<script src="https://unpkg.com/bootstrap@3.3.2/dist/js/bootstrap.min.js"></script>
<script src="https://unpkg.com/bootstrap-multiselect@0.9.13/dist/js/bootstrap-multiselect.js"></script>
<link href="https://unpkg.com/bootstrap-multiselect@0.9.13/dist/css/bootstrap-multiselect.css" rel="stylesheet"/>

<table width='100%'>
	<tr class='admin'>
		<td><%=getTran(request,"web","code",sWebLanguage) %></td>
		<td><%=getTran(request,"web","section",sWebLanguage) %></td>
		<td><%=getTran(request,"web","groups",sWebLanguage) %></td>
		<td><%=getTran(request,"web","label",sWebLanguage) %></td>
	</tr>
<%
	String code=SH.p(request,"code");
	String extension=SH.p(request,"extension");
	String originalcode=SH.p(request,"originalcode");
	String sectioncode=SH.p(request,"sectioncode");
	String keywords=SH.p(request,"keywords");
	String parent=SH.p(request,"parent");
	String limit=SH.p(request,"limit");
	String csu=SH.p(request,"csu");
	String sort=SH.p(request,"sort");
	Hashtable<String,HashSet<String>> hGroups = new Hashtable<String,HashSet<String>>();
	Connection conn = SH.getOpenClinicConnection();
	String sql = "select * from nupsapplications where application='groups'";
	PreparedStatement ps = conn.prepareStatement(sql);
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		if(hGroups.get(rs.getString("nups"))==null){
			hGroups.put(rs.getString("nups"),new HashSet<String>());
		}
		hGroups.get(rs.getString("nups")).add(rs.getString("data"));
	}
	rs.close();
	ps.close();
	sql="select r.*,(select count(*) from nupsref where parent=r.nups) children from nupsref r where 1=1";
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
	ps = conn.prepareStatement(sql);
	rs = ps.executeQuery();
	int n=0;
	while(rs.next()){
		n++;
		String nups=rs.getString("nups");
		out.println("<tr>");
		out.println("<td class='admin'>"+nups+"</td>");
		out.println("<td class='admin' nowrap>"+getTran(request,"nups.section",rs.getDouble("sectioncode")+"",sWebLanguage)+"</td>");
		out.println("<td class='admin' nowrap>");
		String[] groups=SH.cs("nups.groups","").split(";");
		String[] nupsGroups = {};
		if(hGroups.get(nups)!=null){
			nupsGroups = new String[hGroups.get(nups).size()];
			Iterator<String> iGroups = hGroups.get(nups).iterator();
			int nc = 0;
			while(iGroups.hasNext()){
				nupsGroups[nc++]=iGroups.next();
			}
		}
		for(int nCounter=0;nCounter<3;nCounter++){
			String group = "";
			if(nupsGroups.length>nCounter){
				group = nupsGroups[nCounter];
			}
			out.println("<select class='text' id='selgroup;"+nCounter+";"+nups+"' onchange='registerGroup(this.id)'><option/>");
			for(int q=0;q<groups.length;q++){
				out.println("<option value='"+groups[q]+"' "+(group.equalsIgnoreCase(groups[q])?"selected":"")+">"+groups[q]+"</option>");
			}
			out.println("</select>");
		}
		out.println("</td>");
		out.println("<td class='admin2'>"+SH.c(rs.getString(sWebLanguage)).toUpperCase().split(";")[0]+"</td>");
		out.println("</tr>");
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