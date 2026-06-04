<%@page import="be.openclinic.finance.Wicket"%>
<%@include file="/includes/validateUser.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'><%=getTran(request,"web","incomeevolutiondetails",sWebLanguage) %></td>
		</tr>
		<tr>
			<td colspan='2'>
				<select name='uid' id='uid' onchange='transactionForm.submit()' class='text'>
					<option value='%'/>
				<%
					String sTimeUnit=SH.p(request,"timeunit");
					String uid=SH.p(request,"uid","%");
					Connection conn = SH.getOpenClinicConnection();
					PreparedStatement ps = conn.prepareStatement("select distinct oc_wicket_credit_wicketuid from oc_wicket_credits where oc_wicket_credit_operationdate>=? and oc_wicket_credit_operationdate<now()");
					if(sTimeUnit.equalsIgnoreCase("day")){
						ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
					}
					else if(sTimeUnit.equalsIgnoreCase("month")){
						ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
					}
					else if(sTimeUnit.equalsIgnoreCase("year")){
						ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
					}
					ResultSet rs = ps.executeQuery();
					while(rs.next()){
						out.println("<option "+(uid.equalsIgnoreCase(rs.getString("oc_wicket_credit_wicketuid"))?"selected":"")+" value='"+rs.getString("oc_wicket_credit_wicketuid")+"'>"+Wicket.getWicketName(rs.getString("oc_wicket_credit_wicketuid"),sWebLanguage)+"</option>");
					}
					rs.close();
					ps.close();
				%>
				</select>
			</td>
		</tr>
		<%
			if(sTimeUnit.equalsIgnoreCase("day")){
				String sSql = 	"select sum(oc_wicket_credit_amount) amount,date_format(oc_wicket_credit_operationdate,'%Y-%m-%d') date from oc_wicket_credits,oc_patientinvoices,oc_patientcredits where "+
								" oc_wicket_credit_type='patient.payment' and oc_patientcredit_objectid=replace(oc_wicket_credit_referenceuid,'1.','') and "+
								" oc_patientinvoice_objectid=replace(oc_patientcredit_invoiceuid,'1.','') and "+
								" oc_wicket_credit_operationdate>=? and oc_wicket_credit_operationdate<now() and oc_wicket_credit_wicketuid like ? group by date_format(oc_wicket_credit_operationdate,'%Y-%m-%d')"+
								" order by date_format(oc_wicket_credit_operationdate,'%Y-%m-%d') DESC";
				ps = conn.prepareStatement(sSql);
				ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
				ps.setString(2,uid);
				rs = ps.executeQuery();
				while(rs.next()){
					out.println("<tr>");
					out.println("<td class='admin'>"+SH.formatDate(new SimpleDateFormat("yyyy-MM-dd").parse(rs.getString("date")))+"</td>");
					out.println("<td class='admin2'>"+SH.formatPrice(rs.getDouble("amount"))+"</td>");
					out.println("</tr>");
				}
				rs.close();
				ps.close();
			}
			else if(sTimeUnit.equalsIgnoreCase("month")){
				String sSql = 	"select sum(oc_wicket_credit_amount) amount,date_format(oc_wicket_credit_operationdate,'%Y-%m-01') date from oc_wicket_credits,oc_patientinvoices,oc_patientcredits where "+
						" oc_wicket_credit_type='patient.payment' and oc_patientcredit_objectid=replace(oc_wicket_credit_referenceuid,'1.','') and "+
						" oc_patientinvoice_objectid=replace(oc_patientcredit_invoiceuid,'1.','') and "+
								" oc_wicket_credit_operationdate>=? and oc_wicket_credit_operationdate<now() and oc_wicket_credit_wicketuid like ? group by date_format(oc_wicket_credit_operationdate,'%Y-%m-01')"+
								" order by date_format(oc_wicket_credit_operationdate,'%Y-%m-01') DESC";
				ps = conn.prepareStatement(sSql);
				ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
				ps.setString(2,uid);
				rs = ps.executeQuery();
				while(rs.next()){
					out.println("<tr>");
					out.println("<td class='admin'>"+new SimpleDateFormat("MM-yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(rs.getString("date")))+"</td>");
					out.println("<td class='admin2'>"+SH.formatPrice(rs.getDouble("amount"))+"</td>");
					out.println("</tr>");
				}
				rs.close();
				ps.close();
			}
			else if(sTimeUnit.equalsIgnoreCase("year")){
				String sSql = 	"select sum(oc_wicket_credit_amount) amount,date_format(oc_wicket_credit_operationdate,'%Y-01-01') date from oc_wicket_credits,oc_patientinvoices,oc_patientcredits where "+
								" oc_wicket_credit_type='patient.payment' and oc_patientcredit_objectid=replace(oc_wicket_credit_referenceuid,'1.','') and "+
								" oc_patientinvoice_objectid=replace(oc_patientcredit_invoiceuid,'1.','') and "+
								" oc_wicket_credit_operationdate>=? and oc_wicket_credit_operationdate<now() and oc_wicket_credit_wicketuid like ? group by date_format(oc_wicket_credit_operationdate,'%Y-01-01')"+
								" order by date_format(oc_wicket_credit_operationdate,'%Y-01-01') DESC";
				ps = conn.prepareStatement(sSql);
				ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
				ps.setString(2,uid);
				rs = ps.executeQuery();
				while(rs.next()){
					out.println("<tr>");
					out.println("<td class='admin'>"+new SimpleDateFormat("yyyy").format(new SimpleDateFormat("yyyy-MM-dd").parse(rs.getString("date")))+"</td>");
					out.println("<td class='admin2'>"+SH.formatPrice(rs.getDouble("amount"))+"</td>");
					out.println("</tr>");
				}
				rs.close();
				ps.close();
			}
			conn.close();
		%>
	</table>
</form>