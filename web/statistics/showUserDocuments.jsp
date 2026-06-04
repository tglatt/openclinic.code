<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran(request,"web","date",sWebLanguage) %></td>
		<td><%=getTran(request,"web","personid",sWebLanguage) %></td>
		<td><%=getTran(request,"web","patient",sWebLanguage) %></td>
		<td><%=getTran(request,"web","documenttype",sWebLanguage) %></td>
		<td><%=getTran(request,"web","accesstype",sWebLanguage) %></td>
	</tr>
<%
	String userid=SH.p(request,"userid");
	String begin=SH.p(request,"begin");
	String end=SH.p(request,"end");
	
	SortedSet hTransactions = new TreeSet();
	
	String sQuery = "select *"+
			" from accesslogs"+
			"  where accesstime between ? and ?"+
			"   and accesscode like 'T.%'"+
			"   and "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(accesscode)>2"+
			"   and userid=?"+
			"  order by accesstime";						
	Connection conn = SH.getAdminConnection();
	Connection conn2 = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ps.setDate(1,new java.sql.Date(SH.parseDate(begin).getTime()));
	ps.setDate(2,new java.sql.Date(SH.parseDate(end).getTime()));
	ps.setString(3,userid);
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		try{
			hTransactions.add(new SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs.getTimestamp("accesstime"))+";"+SH.getServerId()+"."+Integer.parseInt(rs.getString("accesscode").split("\\.")[2]));
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	rs.close();
	ps.close();
	
	HashSet hCreates = new HashSet();
	
	Iterator<String> iTransactions = hTransactions.iterator();
	while(iTransactions.hasNext()){
		String key = iTransactions.next();
		String uid = key.split(";")[1];
		String accesstime=key.split(";")[0];
		ps = conn2.prepareStatement("select * from transactions where serverid=? and transactionid=?");
		ps.setInt(1,Integer.parseInt(uid.split("\\.")[0]));
		ps.setInt(2,Integer.parseInt(uid.split("\\.")[1]));
		rs = ps.executeQuery();
		if(rs.next()){
			int personid=MedwanQuery.getInstance().getPersonIdFromHealthrecordId(rs.getInt("healthrecordid"));
			String sType="visualisation";
			String sClass="admin2";
			if(!hCreates.contains(uid) &&  rs.getString("userid").equalsIgnoreCase(userid) && rs.getTimestamp("creationDate").after(SH.parseDate(begin))){
				sType="creation";
				sClass="admin";
				hCreates.add(uid);
			}
			String patientname=AdminPerson.getFullName(personid+"");
			out.println("<tr style='height: 20px'>");
			out.println("<td class='"+sClass+"'>"+accesstime+"</td>");
			out.println("<td class='"+sClass+"'><a style='font-weight: bold' href='javascript:showPatient("+personid+",\""+patientname+"\")'>"+personid+"</a></td>");
			out.println("<td class='"+sClass+"'>"+patientname+"</td>");
			out.println("<td class='"+sClass+"'>["+uid+"] "+getTran(request,"web.occup",rs.getString("transactionType"),sWebLanguage)+"</td>");
			out.println("<td class='"+sClass+"'>"+getTran(request,"web.occup",sType,sWebLanguage)+"</td>");
			out.println("</tr>");
		}
		rs.close();
		ps.close();
	}
	conn.close();
	conn2.close();
%>
</table>
<script>
	function showPatient(personid,patientname){
		window.open('<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&PersonID='+personid+'&language=<%=sWebLanguage%>','Contact sans contenu clinique','toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1024,height=768,menubar=no').moveTo((this.screen.width-1024)/2,(this.screen.height-768)/2);
	}
</script>