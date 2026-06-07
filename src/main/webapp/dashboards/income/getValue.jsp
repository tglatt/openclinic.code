<%@include file="/includes/validateUser.jsp"%>
<%
	String dates="",values="";

	SortedMap<String,Double> income = new TreeMap();
	java.sql.Timestamp begin=null,end=null;
	long day = 24*60*60000;
	java.util.Date today = new java.util.Date();
	java.util.Date yesterday = new java.util.Date(today.getTime()-day);
	if(SH.p(request,"period").length()==0 || SH.p(request,"period").equalsIgnoreCase("day")){
		begin = new java.sql.Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(SH.formatDate(yesterday)).getTime()-30*day);
		end = new java.sql.Timestamp(yesterday.getTime()+day);
	}
	Connection conn = SH.getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_debets where oc_debet_date>=? and oc_debet_date<? and length(oc_debet_patientinvoiceuid)>1");
	ps.setTimestamp(1, begin);
	ps.setTimestamp(2, end);
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		String d = new SimpleDateFormat("yyyy-MM-dd HH-mm-ss").format(rs.getDate("oc_debet_date"));
		if(income.get(d)==null){
			income.put(d,new Double(0));
		}
		income.put(d,(Double)income.get(d)+rs.getDouble("oc_debet_amount") + rs.getDouble("oc_debet_insuraramount")+ rs.getDouble("oc_debet_extrainsuraramount"));
	}
	rs.close();
	ps.close();
	conn.close();
	Iterator i = income.keySet().iterator();
	while(i.hasNext()){
		String date = (String)i.next();
		if(dates.length()>0){
			dates+=",";
			values+=",";
		}
		dates+= "'"+date+"'";
		values+= income.get(date)+"";
	}
	
%>
{
	data: {
		labels: [<%=dates %>],
		datasets: [{
			data: [<%=values %>],
			label: 'Recettes',
			borderWidth: 1,
			pointRadius: 1
		}]
	}
}