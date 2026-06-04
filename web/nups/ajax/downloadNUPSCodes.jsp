<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	StringBuffer result = new StringBuffer();
	result.append("MUID;CSU;UNHS;ORIGINALCODE;DOMAIN;FR;EN;ES;PT;SECTIONCODE;SECTION;PARENT\n");
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
	Connection conn = SH.getOpenClinicConnection();
	String sql="select r.*,(select count(*) from nupsref where parent=r.nups) children from nupsref r where 1=1";
	if(sectioncode.length()>0){
		sql+=" and sectioncode='"+sectioncode+"'";
	}
	if(keywords.length()>0){
		for(int n=0;n<keywords.split(" ").length;n++){
			if(keywords.split(" ")[n].trim().length()>0){
				sql+=" and "+sWebLanguage+" like '%"+keywords.split(" ")[n].trim()+"%'";
			}
		}
	}
	if(code.length()>0){
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
	sql+=" order by nups limit "+limit;
	PreparedStatement ps = conn.prepareStatement(sql);
	ResultSet rs = ps.executeQuery();
	int n=0;
	while(rs.next()){
		n++;
		result.append(SH.c(rs.getString("muid"))+";");
		result.append(SH.c(rs.getString("csu"))+";");
		result.append(SH.c(rs.getString("nups"))+";");
		result.append(SH.c(rs.getString("originalcode"))+";");
		result.append(SH.c(rs.getString("domain"))+";");
		result.append(SH.c(rs.getString("fr")).toUpperCase().split(";")[0].replaceAll(";",",").replaceAll("\n",", ").replaceAll("\r","")+";");
		result.append(SH.c(rs.getString("en")).toUpperCase().split(";")[0].replaceAll(";",",").replaceAll("\n",", ").replaceAll("\r","")+";");
		result.append(SH.c(rs.getString("es")).toUpperCase().split(";")[0].replaceAll(";",",").replaceAll("\n",", ").replaceAll("\r","")+";");
		result.append(SH.c(rs.getString("pt")).toUpperCase().split(";")[0].replaceAll(";",",").replaceAll("\n",", ").replaceAll("\r","")+";");
		result.append(SH.c(rs.getString("sectioncode"))+";");
		result.append(SH.c(rs.getString("section"))+";");
		result.append(SH.c(rs.getString("parent"))+";\n");
	}
	rs.close();
	ps.close();
	conn.close();

    response.setContentType("application/octet-stream; charset=windows-1252");
    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicStatistic"+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".csv\"");
   
    ServletOutputStream os = response.getOutputStream();
    byte[] b = result.toString().getBytes("ISO-8859-1");
    for(int u=0; u<b.length; u++){
        os.write(b[u]);
    }
    os.flush();
    os.close();
%>