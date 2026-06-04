<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran(request,"web","service",sWebLanguage) %></td>
		<td><%=getTran(request,"web","score",sWebLanguage)%></td>
		<td><%=getTran(request,"web","consultations",sWebLanguage) %></td>
		<td><%=getTran(request,"web","patients",sWebLanguage) %></td>
	</tr>
	<%
		double consultations=0, patients=0, maxfont=3, maxfontsize=16;
	
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) AS total,COUNT(distinct oc_encounter_patientuid) AS patients,oc_encounter_serviceuid"+
													 " FROM oc_encounters_view"+ 
													 " WHERE oc_encounter_begindate BETWEEN ? AND ? AND"+
													 " oc_encounter_type='visit'"+
													 " GROUP BY oc_encounter_serviceuid order by COUNT(*)/COUNT(distinct oc_encounter_patientuid) desc;");
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeYear()));
		ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			consultations =rs.getInt("total");
			patients =rs.getInt("patients");
			%>
			<tr>
				<td class='admin'><%=getTran(request,"service",rs.getString("oc_encounter_serviceuid"),sWebLanguage) %></td>
				<td class='admin2'><b><center style='font-size: <%=consultations/patients>maxfont?maxfontsize:10+(maxfontsize-10)*(consultations/patients-1)/(maxfont-1)%>px'><%=new DecimalFormat("0.0#").format(consultations/patients) %></center></b></td>
				<td class='admin2'><center><%=new Double(consultations).intValue() %></center></td>
				<td class='admin2'><center><%=new Double(patients).intValue() %></center></td>
			</tr>
			<%
		}
		rs.close();
		ps.close();	
		conn.close();
	%>

</table>