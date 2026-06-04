<%@include file="/includes/validateUser.jsp"%>
<%
	String dates="",values="";
	for(int n=11;n>0;n--){
		if(dates.length()>0){
			dates+=",";
			values+=",";
		}
		dates+= "'"+new SimpleDateFormat("yyyy-MM-dd HH-mm-ss").format(new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*30*n))+"'";
		values+= 100*Math.random()+"";
	}
	String title = "data";
%>
{
	data: {
		labels: [<%=dates %>],
		datasets: [{
			data: [<%=values %>],
			label: '<%=title %>'
		}]
	}
}