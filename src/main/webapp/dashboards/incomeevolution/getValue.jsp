<%@include file="/includes/validateUser.jsp"%>
<%
	String sTimeUnit = SH.p(request,"timeunit");
	String title = getTranNoLink("web","patientincome",sWebLanguage);
	String title2 = getTranNoLink("web","insurerincome",sWebLanguage);
	String period="";

	String dates="",values="",values2="";
	Connection conn = SH.getOpenClinicConnection();
	if(sTimeUnit.equalsIgnoreCase("day")){
		String sSql = 	"select sum(oc_debet_amount) patient,sum(oc_debet_insuraramount+oc_debet_extrainsuraramount) insurer,date_format(oc_debet_date,'%Y-%m-%d') day FROM oc_debets,oc_patientinvoices"+
						" WHERE oc_patientinvoice_objectid=replace(oc_debet_patientinvoiceuid,'1.','') and oc_patientinvoice_status='closed' and oc_debet_date>=? and oc_debet_date<=now() GROUP BY date_format(oc_debet_date,'%Y-%m-%d') order by date_format(oc_debet_date,'%Y-%m-%d')";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+rs.getString("day")+"'";
			values+= rs.getDouble("patient")+"";
			values2+= rs.getDouble("insurer")+"";
		}
		rs.close();
		ps.close();
		period =" 30 "+getTranNoLink("web","days",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("month")){
		String sSql = 	"select sum(oc_debet_amount) patient,sum(oc_debet_insuraramount+oc_debet_extrainsuraramount) insurer,date_format(oc_debet_date,'%Y-%m-01') month FROM oc_debets,oc_patientinvoices"+
						" WHERE oc_patientinvoice_objectid=replace(oc_debet_patientinvoiceuid,'1.','') and oc_patientinvoice_status='closed' and oc_debet_date>=? and oc_debet_date<=now() GROUP BY date_format(oc_debet_date,'%Y-%m-01') order by date_format(oc_debet_date,'%Y-%m-01')";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+rs.getString("month")+"'";
			values+= rs.getDouble("patient")+"";
			values2+= rs.getDouble("insurer")+"";
		}
		rs.close();
		ps.close();
		period =" 12 "+getTranNoLink("web","months",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("year")){
		String sSql = 	"select sum(oc_debet_amount) patient,sum(oc_debet_insuraramount+oc_debet_extrainsuraramount) insurer,date_format(oc_debet_date,'%Y-01-01') year FROM oc_debets,oc_patientinvoices"+
						" WHERE oc_patientinvoice_objectid=replace(oc_debet_patientinvoiceuid,'1.','') and oc_patientinvoice_status='closed' and oc_debet_date>=? and oc_debet_date<=now() GROUP BY date_format(oc_debet_date,'%Y-01-01') order by date_format(oc_debet_date,'%Y-01-01')";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+rs.getString("year")+"'";
			values+= rs.getDouble("patient")+"";
			values2+= rs.getDouble("insurer")+"";
		}
		rs.close();
		ps.close();
		period =" 10 "+getTranNoLink("web","years",sWebLanguage);
	}
	conn.close();
%>
{
	data: {
		labels: [<%=dates %>],
		datasets: [{
			data: [<%=values %>],
			borderColor: 'red',
			label: '<%=title+period %>',
			borderWidth: 1,
			pointRadius: 1
		},
		{
			data: [<%=values2 %>],
			borderColor: 'blue',
			label: '<%=title2+period %>',
			borderWidth: 1,
			pointRadius: 1
		}]
	}
}