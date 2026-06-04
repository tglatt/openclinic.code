<%@include file="/includes/validateUser.jsp"%>
<%
	String sTimeUnit = SH.p(request,"timeunit");
	String title = getTranNoLink("web","totaldeliveries",sWebLanguage);
	String title2 = getTranNoLink("web","prematuredeliveries",sWebLanguage);
	String period="";

	String dates="",values="",values2="";
	Connection conn = SH.getOpenClinicConnection();
	if(sTimeUnit.equalsIgnoreCase("month")){
		SortedMap deliveries = new TreeMap(), prematuredeliveries = new TreeMap();
		String sSql = "select * from transactions t,items i where t.updatetime>=? and t.updatetime<=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ATTERM' and i.value in ('medwan.common.true','medwan.common.false'))";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
		ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String date = new SimpleDateFormat("yyyy-MM-01").format(rs.getDate("updatetime"));
			if(deliveries.get(date)==null){
				deliveries.put(date,1);
			}
			else{
				deliveries.put(date,(Integer)deliveries.get(date)+1);
			}
			if(rs.getString("value").equalsIgnoreCase("medwan.common.false")){
				if(prematuredeliveries.get(date)==null){
					prematuredeliveries.put(date,1);
				}
				else{
					prematuredeliveries.put(date,(Integer)prematuredeliveries.get(date)+1);
				}
			}
		}
		Iterator iDeliveries = deliveries.keySet().iterator();
		while(iDeliveries.hasNext()){
			String date = (String)iDeliveries.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+date+"'";
			values+= deliveries.get(date)+"";
			values2+= prematuredeliveries.get(date)==null?"0":prematuredeliveries.get(date)+"";
		}
		rs.close();
		ps.close();
		period =" 12 "+getTranNoLink("web","months",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("year")){
		SortedMap deliveries = new TreeMap(), prematuredeliveries = new TreeMap();
		String sSql = "select * from transactions t,items i where t.updatetime>=? and t.updatetime<=? and t.transactionid=i.transactionid and (i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_ATTERM' and i.value in ('medwan.common.true','medwan.common.false'))";
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
		ps.setTimestamp(2,new java.sql.Timestamp(new java.util.Date().getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String date = new SimpleDateFormat("yyyy-01-01").format(rs.getDate("updatetime"));
			if(deliveries.get(date)==null){
				deliveries.put(date,1);
			}
			else{
				deliveries.put(date,(Integer)deliveries.get(date)+1);
			}
			if(rs.getString("value").equalsIgnoreCase("medwan.common.false")){
				if(prematuredeliveries.get(date)==null){
					prematuredeliveries.put(date,1);
				}
				else{
					prematuredeliveries.put(date,(Integer)prematuredeliveries.get(date)+1);
				}
			}
		}
		Iterator iDeliveries = deliveries.keySet().iterator();
		while(iDeliveries.hasNext()){
			String date = (String)iDeliveries.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+date+"'";
			values+= deliveries.get(date)+"";
			values2+= prematuredeliveries.get(date)==null?"0":prematuredeliveries.get(date)+"";
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