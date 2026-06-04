<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='4'><%=getTran(request,"web","mortality",sWebLanguage) %></td>
		</tr>
		<tr class='admin'>
			<td><%=getTran(request,"web","date",sWebLanguage) %></td>
			<td>ID</td>
			<td><%=getTran(request,"web","patient",sWebLanguage) %></td>
			<td><%=getTran(request,"web","maternalmortality",sWebLanguage) %></td>
		</tr>
		<%
			String sTimeUnit = SH.p(request,"timeunit");
			Connection conn = SH.getOpenClinicConnection();
			String sSql = 	"select * from oc_encounters where oc_encounter_outcome like 'dead%' and oc_encounter_enddate>=? and oc_encounter_enddate<? order by oc_encounter_enddate desc";
			PreparedStatement ps = conn.prepareStatement(sSql);
			if(sTimeUnit.equalsIgnoreCase("day")){
				ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
			}
			else if(sTimeUnit.equalsIgnoreCase("month")){
				ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
			}
			else if(sTimeUnit.equalsIgnoreCase("year")){
				ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
			}
			ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				out.println("<tr><td class='admin'>"+SH.formatDate(rs.getDate("oc_encounter_enddate"))+"</td><td class='admin2'>"+rs.getString("oc_encounter_patientuid")+"</td><td class='admin2'>"+AdminPerson.getFullName(rs.getString("oc_encounter_patientuid"))+"</td><td class='admin2'>");
				//Check if this is intrahospital maternal death
				PreparedStatement ps2 = conn.prepareStatement("select * from transactions t,items i where t.healthrecordid=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MATERNALDEATH' and i.value='1')");
				ps2.setInt(1,MedwanQuery.getInstance().getHealthRecordIdFromPersonId(rs.getInt("oc_encounter_patientuid")));
				ResultSet rs2 = ps2.executeQuery();
				if(rs2.next()){
					out.println("<font style='color: red;font-weight: bolder;font-size: 12px'>"+getTranNoLink("web","yes",sWebLanguage)+"</font></td></tr>");
				}
				else {
					out.println(getTranNoLink("web","no",sWebLanguage)+"</td></tr>");
				}
				rs2.close();
				ps2.close();
			}
		%>
	</table>
</form>

