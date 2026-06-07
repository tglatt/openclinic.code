<%@include file="/includes/validateUser.jsp"%>
<%
	String sTimeUnit = SH.p(request,"timeunit");
	String sCenter = SH.p(request,"center");
	String title = getTranNoLink("cnts","fixed",sWebLanguage);
	String title2 = getTranNoLink("cnts","mobile",sWebLanguage);
	String period="";

	String dates="",values="",values2="";
	SortedMap<String,Integer> hFixed=new TreeMap<String,Integer>(),hMobile=new TreeMap<String,Integer>();
	SortedSet<String> alldates=new TreeSet<String>();
	
	Connection conn = SH.getOpenClinicConnection();
	if(sTimeUnit.equalsIgnoreCase("day")){
		String sSql = 	"select count(*) total,date_format(t.updatetime,'%Y-%m-%d') day,i.value from transactions t,items i where"+
						" t.serverid=i.serverid and"+
						" t.transactionid=i.transactionid and"+
						" t.transactiontype='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNTS_BLOODGIFT' and"+
						" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNTSBLOODGIFT_COLLECTIONUNIT' and"+
						" t.updatetime>? and"+
						" i.value in (--ivalues--)"+
						" GROUP BY date_format(t.updatetime,'%Y-%m-%d'),i.value order by date_format(t.updatetime,'%Y-%m-%d'),i.value";
		if(sCenter.length()==0){
			sSql=sSql.replaceAll("--ivalues--","'1','2','3','4','5','6','7','8','9','10'");
		}
		else if(sCenter.equalsIgnoreCase("cnts")){
			sSql=sSql.replaceAll("--ivalues--","'1','6'");
		}
		else if(sCenter.equalsIgnoreCase("bururi")){
			sSql=sSql.replaceAll("--ivalues--","'3','7'");
		}
		else if(sCenter.equalsIgnoreCase("ngozi")){
			sSql=sSql.replaceAll("--ivalues--","'5','10'");
		}
		else if(sCenter.equalsIgnoreCase("gitega")){
			sSql=sSql.replaceAll("--ivalues--","'2','9'");
		}
		else if(sCenter.equalsIgnoreCase("cibitoke")){
			sSql=sSql.replaceAll("--ivalues--","'4','8'");
		}
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*30));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String sd=rs.getString("day");
			if("1,2,3,4,5,".contains(rs.getString("value"))){
				if(hFixed.get(sd)==null){
					hFixed.put(sd,0);
				}
				hFixed.put(sd,rs.getInt("total")+hFixed.get(sd));
			}
			else if("6,7,8,9,10,".contains(rs.getString("value"))){
				if(hMobile.get(sd)==null){
					hMobile.put(sd,0);
				}
				hMobile.put(sd,rs.getInt("total")+hMobile.get(sd));
			}
			alldates.add(sd);
		}
		rs.close();
		ps.close();
		Iterator<String> iDates = alldates.iterator();
		while(iDates.hasNext()){
			String sd = iDates.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+sd+"'";
			values+= (hFixed.get(sd)==null?"0":hFixed.get(sd))+"";
			values2+= (hMobile.get(sd)==null?"0":hMobile.get(sd))+"";
		}
		period =" 30 "+getTranNoLink("web","days",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("month")){
		String sSql = 	"select count(*) total,date_format(t.updatetime,'%Y-%m-01') month,i.value from transactions t,items i where"+
						" t.serverid=i.serverid and"+
						" t.transactionid=i.transactionid and"+
						" t.transactiontype='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNTS_BLOODGIFT' and"+
						" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNTSBLOODGIFT_COLLECTIONUNIT' and"+
						" t.updatetime>? and"+
						" i.value in (--ivalues--)"+
						" GROUP BY date_format(t.updatetime,'%Y-%m-01'),value order by date_format(t.updatetime,'%Y-%m-01'),value";
		if(sCenter.length()==0){
			sSql=sSql.replaceAll("--ivalues--","'1','2','3','4','5','6','7','8','9','10'");
		}
		else if(sCenter.equalsIgnoreCase("cnts")){
			sSql=sSql.replaceAll("--ivalues--","'1','6'");
		}
		else if(sCenter.equalsIgnoreCase("bururi")){
			sSql=sSql.replaceAll("--ivalues--","'3','7'");
		}
		else if(sCenter.equalsIgnoreCase("ngozi")){
			sSql=sSql.replaceAll("--ivalues--","'5','10'");
		}
		else if(sCenter.equalsIgnoreCase("gitega")){
			sSql=sSql.replaceAll("--ivalues--","'2','9'");
		}
		else if(sCenter.equalsIgnoreCase("cibitoke")){
			sSql=sSql.replaceAll("--ivalues--","'4','8'");
		}
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*365));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String sd=rs.getString("month");
			if("1,2,3,4,5,".contains(rs.getString("value"))){
				if(hFixed.get(sd)==null){
					hFixed.put(sd,0);
				}
				hFixed.put(sd,rs.getInt("total")+hFixed.get(sd));
			}
			else if("6,7,8,9,10,".contains(rs.getString("value"))){
				if(hMobile.get(sd)==null){
					hMobile.put(sd,0);
				}
				hMobile.put(sd,rs.getInt("total")+hMobile.get(sd));
			}
			alldates.add(sd);
		}
		rs.close();
		ps.close();
		Iterator<String> iDates = alldates.iterator();
		while(iDates.hasNext()){
			String sd = iDates.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+sd+"'";
			values+= (hFixed.get(sd)==null?"0":hFixed.get(sd))+"";
			values2+= (hMobile.get(sd)==null?"0":hMobile.get(sd))+"";
		}
		period =" 12 "+getTranNoLink("web","months",sWebLanguage);
	}
	else if(sTimeUnit.equalsIgnoreCase("year")){
		String sSql = 	"select count(*) total,date_format(t.updatetime,'%Y-01-01') year,i.value from transactions t,items i where"+
						" t.serverid=i.serverid and"+
						" t.transactionid=i.transactionid and"+
						" t.transactiontype='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNTS_BLOODGIFT' and"+
						" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNTSBLOODGIFT_COLLECTIONUNIT' and"+
						" t.updatetime>? and"+
						" i.value in (--ivalues--)"+
						" GROUP BY date_format(t.updatetime,'%Y-01-01'),value order by date_format(t.updatetime,'%Y-01-01'),value";
		if(sCenter.length()==0){
			sSql=sSql.replaceAll("--ivalues--","'1','2','3','4','5','6','7','8','9','10'");
		}
		else if(sCenter.equalsIgnoreCase("cnts")){
			sSql=sSql.replaceAll("--ivalues--","'1','6'");
		}
		else if(sCenter.equalsIgnoreCase("bururi")){
			sSql=sSql.replaceAll("--ivalues--","'3','7'");
		}
		else if(sCenter.equalsIgnoreCase("ngozi")){
			sSql=sSql.replaceAll("--ivalues--","'5','10'");
		}
		else if(sCenter.equalsIgnoreCase("gitega")){
			sSql=sSql.replaceAll("--ivalues--","'2','9'");
		}
		else if(sCenter.equalsIgnoreCase("cibitoke")){
			sSql=sSql.replaceAll("--ivalues--","'4','8'");
		}
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-SH.getTimeDay()*3650));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String sd=rs.getString("year");
			if("1,2,3,4,5,".contains(rs.getString("value"))){
				if(hFixed.get(sd)==null){
					hFixed.put(sd,0);
				}
				hFixed.put(sd,rs.getInt("total")+hFixed.get(sd));
			}
			else if("6,7,8,9,10,".contains(rs.getString("value"))){
				if(hMobile.get(sd)==null){
					hMobile.put(sd,0);
				}
				hMobile.put(sd,rs.getInt("total")+hMobile.get(sd));
			}
			alldates.add(sd);
		}
		rs.close();
		ps.close();
		Iterator<String> iDates = alldates.iterator();
		while(iDates.hasNext()){
			String sd = iDates.next();
			if(dates.length()>0){
				dates+=",";
				values+=",";
				values2+=",";
			}
			dates+= "'"+sd+"'";
			values+= (hFixed.get(sd)==null?"0":hFixed.get(sd))+"";
			values2+= (hMobile.get(sd)==null?"0":hMobile.get(sd))+"";
		}
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