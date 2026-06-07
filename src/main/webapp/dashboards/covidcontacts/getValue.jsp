<%@include file="/includes/validateUser.jsp"%>
<%
	String sTimeUnit = SH.p(request,"timeunit");
	String title = getTranNoLink("web","covid.contacts",sWebLanguage);
	String period="";

	String dates="",values="";
	Connection conn = SH.getOpenClinicConnection();
	if(sTimeUnit.equalsIgnoreCase("day")){
		for(int n=0;n<30;n++){
			String sSql = "select count(distinct healthrecordid) total from transactions where transactiontype in ('be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_COVID19_TRIAGE','be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_COVID19_TRIAGEWITHPULSOXIMETRY') and updatetime >=? and updatetime <?";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*(n+1)));
			ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()-SH.getTimeDay()*n));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				String date = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*n));
				if(dates.length()>0){
					dates+=",";
					values+=",";
				}
				dates+= "'"+date+"'";
				values+= rs.getInt("total")+"";
			}
			rs.close();
			ps.close();
		}
		period =" 30 "+getTranNoLink("web","days",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("month")){
		java.util.Date activeDate=SH.getEndOfMonth(new java.util.Date());
		for(int n=0;n<12;n++){
			String sSql = "select count(distinct healthrecordid) total from transactions where transactiontype in ('be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_COVID19_TRIAGE','be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_COVID19_TRIAGEWITHPULSOXIMETRY') and updatetime >=? and updatetime <?";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1,new java.sql.Date(SH.getBeginOfMonth(activeDate).getTime()));
			ps.setTimestamp(2,new java.sql.Timestamp(activeDate.getTime()));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				String date = new SimpleDateFormat("yyyy-MM-01").format(activeDate);
				if(dates.length()>0){
					dates+=",";
					values+=",";
				}
				dates+= "'"+date+"'";
				values+= rs.getInt("total")+"";
			}
			rs.close();
			ps.close();
			activeDate = SH.getPreviousMonthEnd(activeDate);
		}
		period =" 12 "+getTranNoLink("web","months",sWebLanguage);
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
		}]
	}
}