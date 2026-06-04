<%@include file="/includes/validateUser.jsp"%>
<%
	String sTimeUnit = SH.p(request,"timeunit");
	String title = getTranNoLink("web","openinvoices",sWebLanguage);
	String title2 = getTranNoLink("web","allinvoices",sWebLanguage);
	String period="";

	String dates="",values="",values2="";
	Connection conn = SH.getOpenClinicConnection();
	if(sTimeUnit.equalsIgnoreCase("day")){
		String sSql = 	"select sum(open) open, sum(allinvoices) allinvoices, day from ("+
						" select count(*) open,0 allinvoices, date_format(oc_patientinvoice_date,'%Y-%m-%d') day FROM oc_patientinvoices"+
						" WHERE oc_patientinvoice_status='open' and oc_patientinvoice_date>=? and oc_patientinvoice_date<? GROUP BY date_format(oc_patientinvoice_date,'%Y-%m-%d')"+
						" union "+
						" select 0 open,count(*) allinvoices, date_format(oc_patientinvoice_date,'%Y-%m-%d') day FROM oc_patientinvoices"+
						" WHERE oc_patientinvoice_date>=? and oc_patientinvoice_date<? GROUP BY date_format(oc_patientinvoice_date,'%Y-%m-%d')) a"+
						" group by day order by day DESC";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
		ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
		ps.setDate(3,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
		ps.setDate(4,new java.sql.Date(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+rs.getString("day")+"'";
			values+= rs.getDouble("open")+"";
			values2+= rs.getDouble("allinvoices")+"";
		}
		rs.close();
		ps.close();
		period =" 30 "+getTranNoLink("web","days",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("month")){
		String sSql = 	"select sum(open) open, sum(allinvoices) allinvoices, day from ("+
				" select count(*) open,0 allinvoices, date_format(oc_patientinvoice_date,'%Y-%m-01') day FROM oc_patientinvoices"+
				" WHERE oc_patientinvoice_status='open' and oc_patientinvoice_date>=? and oc_patientinvoice_date<? GROUP BY date_format(oc_patientinvoice_date,'%Y-%m-01')"+
				" union "+
				" select 0 open,count(*) allinvoices, date_format(oc_patientinvoice_date,'%Y-%m-01') day FROM oc_patientinvoices"+
				" WHERE oc_patientinvoice_date>=? and oc_patientinvoice_date<? GROUP BY date_format(oc_patientinvoice_date,'%Y-%m-01')) a"+
				" group by day order by day DESC";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
		ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
		ps.setDate(3,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
		ps.setDate(4,new java.sql.Date(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+rs.getString("day")+"'";
			values+= rs.getDouble("open")+"";
			values2+= rs.getDouble("allinvoices")+"";
		}
		rs.close();
		ps.close();
		period =" 12 "+getTranNoLink("web","months",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("year")){
		String sSql = 	"select sum(open) open, sum(allinvoices) allinvoices, day from ("+
				" select count(*) open,0 allinvoices, date_format(oc_patientinvoice_date,'%Y-01-01') day FROM oc_patientinvoices"+
				" WHERE oc_patientinvoice_status='open' and oc_patientinvoice_date>=? and oc_patientinvoice_date<? GROUP BY date_format(oc_patientinvoice_date,'%Y-01-01')"+
				" union "+
				" select 0 open,count(*) allinvoices, date_format(oc_patientinvoice_date,'%Y-01-01') day FROM oc_patientinvoices"+
				" WHERE oc_patientinvoice_date>=? and oc_patientinvoice_date<? GROUP BY date_format(oc_patientinvoice_date,'%Y-01-01')) a"+
				" group by day order by day DESC";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
		ps.setDate(2,new java.sql.Date(new java.util.Date().getTime()));
		ps.setDate(3,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
		ps.setDate(4,new java.sql.Date(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+rs.getString("day")+"'";
			values+= rs.getDouble("open")+"";
			values2+= rs.getDouble("allinvoices")+"";
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