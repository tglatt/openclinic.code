<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='4'><%=getTran(request,"web","prematuredeliveries",sWebLanguage) %></td>
		</tr>
		<tr class='admin'>
			<td><%=getTran(request,"web","date",sWebLanguage) %></td>
			<td>ID</td>
			<td><%=getTran(request,"web","patient",sWebLanguage) %></td>
		</tr>
		<%
			String sTimeUnit = SH.p(request,"timeunit");
			Connection conn = SH.getOpenClinicConnection();
			String sSql = 	"select * from transactions t,items i where t.updatetime>=? and t.updatetime<=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ATTERM' and i.value ='medwan.common.false') order by updatetime desc";
			PreparedStatement ps = conn.prepareStatement(sSql);
			if(sTimeUnit.equalsIgnoreCase("month")){
				ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
			}
			else if(sTimeUnit.equalsIgnoreCase("year")){
				ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
			}
			ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				int personid = MedwanQuery.getInstance().getPersonIdFromHealthrecordId(rs.getInt("healthrecordid"));
				out.println("<tr><td class='admin'>"+SH.formatDate(rs.getDate("updatetime"))+"</td><td class='admin2'>"+personid+"</td><td class='admin2'>"+AdminPerson.getFullName(personid+"")+"</td></tr>");
			}
		%>
	</table>
</form>

