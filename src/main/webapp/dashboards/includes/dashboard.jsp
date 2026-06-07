<%@include file="/includes/validateUser.jsp"%>
<%!
	public String writeDashboardMoneyTimeGraph(String id,int width,int height,String timeunit){
		StringBuffer sb = new StringBuffer();
		sb.append("<table width='100%'>");
		sb.append("	<tr>");
		sb.append("		<td>");
		sb.append("			<center><canvas width='"+width+"' height='"+height+"' id='timegraph_"+id+"'></canvas></center>");
		sb.append("		</td>");
		sb.append("	</tr>");
		sb.append("</table>");
		sb.append("<script>");
		sb.append(" var "+id+" = new Chart(document.getElementById('timegraph_"+id+"'),{");
		sb.append(" 	type: 'line',");
		sb.append(" 	options: {scales: {xAxes: [{type: 'time',time:{unit: '"+timeunit+"',displayFormats: { hour: 'HH',day: 'DD',week: 'WW',month: 'MM',year: 'YY'}}}],yAxes: [{ticks: {beginAtZero: true, callback: function(value, index, values) {return Intl.NumberFormat().format((value/1000)) + 'K';}}}]},responsive: false}");
		sb.append(" });");
		sb.append("</script>");
		return sb.toString();
	}
	
	public String writeDashboardTimeGraph(String id,int width,int height,String timeunit){
		StringBuffer sb = new StringBuffer();
		sb.append("<table width='100%'>");
		sb.append("	<tr>");
		sb.append("		<td>");
		sb.append("			<center><canvas width='"+width+"' height='"+height+"' id='timegraph_"+id+"'></canvas></center>");
		sb.append("		</td>");
		sb.append("	</tr>");
		sb.append("</table>");
		sb.append("<script>");
		sb.append(" Chart.defaults.global.defaultFontSize=9; var "+id+" = new Chart(document.getElementById('timegraph_"+id+"'),{");
		sb.append(" 	type: 'line',");
		sb.append(" 	options: {scales: {yAxes: [{ticks: {fontSize: 10}}], xAxes: [{ticks: {fontSize: 10}, type: 'time',time:{unit: '"+timeunit+"',displayFormats: { hour: 'HH',day: 'DD',week: 'WW',month: 'MM',year: 'YY'}}}]},responsive: false}");
		sb.append(" });");
		sb.append("</script>");
		return sb.toString();
	}
	
	public String writeDonutGraph(String id,int width,int height){
		StringBuffer sb = new StringBuffer();
		sb.append("<table width='100%'>");
		sb.append("	<tr>");
		sb.append("		<td>");
		sb.append("			<center><canvas width='"+width+"' height='"+height+"' id='donutgraph_"+id+"'></canvas></center>");
		sb.append("		</td>");
		sb.append("	</tr>");
		sb.append("</table>");
		sb.append("<script>");
		sb.append(" Chart.defaults.global.defaultFontSize=9; var "+id+" = new Chart(document.getElementById('donutgraph_"+id+"'),{");
		sb.append(" 	type: 'doughnut',");
		sb.append(" 	options: {responsive: false}");
		sb.append(" });");
		sb.append("</script>");
		return sb.toString();
	}
	
	public String writeDashboardGauge(String id,int width, double minval, double maxval,String footer){
		StringBuffer sb = new StringBuffer();
		sb.append("<table width='100%'>");
		sb.append("	<tr>");
		sb.append("		<td>");
		sb.append("			<center><div style='font-size: 24px;font-weight: bolder' id='previewtext_"+id+"'></div></center>");
		sb.append("		</td>");
		sb.append("	</tr>");
		sb.append("	<tr>");
		sb.append("		<td>");
		sb.append("			<center><canvas id='canvas_"+id+"' width='"+width+"' height='"+width/2+"'></canvas></center>");
		sb.append("		</td>");
		sb.append("	</tr>");
		sb.append("	<tr>");
		sb.append("		<td>");
		sb.append("			<center><div style='font-size: 14px;font-weight: bolder' id='previewfooter_"+id+"'>"+footer+"</div></center>");
		sb.append("		</td>");
		sb.append("	</tr>");
		sb.append("</table>");
		sb.append("<script>");
		sb.append("	window."+id+" = new Gauge(document.getElementById('canvas_"+id+"')).setOptions({radiusScale: 1, limitMin: true, limitMax: true, angle: 0,lineWidth: 0.4});");
		sb.append(  id+".setTextField(document.getElementById('previewtext_"+id+"'));");
		sb.append(  id+".setMinValue("+minval+");");
		sb.append(  id+".maxValue="+maxval+";");
		sb.append(  id+".animationSpeed=5;");
		sb.append("	</script>");
		return sb.toString();
	}

	public String writeDashboardText(String id,String text){
		StringBuffer sb = new StringBuffer();
		sb.append("<table width='100%'>");
		sb.append("	<tr>");
		sb.append("		<td>");
		sb.append("			<center><span style='font-size: 24px;font-weight: bolder' id='text_"+id+"'>"+text+"</span></center>");
		sb.append("		</td>");
		sb.append("	</tr>");
		sb.append("</table>");
		sb.append("<script>");
		sb.append(" var "+id+"=document.getElementById('text_"+id+"');");
		sb.append("	</script>");
		return sb.toString();
	}

	public String writeDashboardText(String id,String text,int size){
		StringBuffer sb = new StringBuffer();
		sb.append("<table width='100%'>");
		sb.append("	<tr>");
		sb.append("		<td>");
		sb.append("			<center><span style='font-size: "+size+"px;font-weight: bolder' id='text_"+id+"'>"+text+"</span></center>");
		sb.append("		</td>");
		sb.append("	</tr>");
		sb.append("</table>");
		sb.append("<script>");
		sb.append(" var "+id+"=document.getElementById('text_"+id+"');");
		sb.append("	</script>");
		return sb.toString();
	}

%>
<script>
	function gauge_setValue(gauge,value){
		gauge.set(value);
		return value;
	}
	function gauge_setMinimum(gauge,value){
		gauge.setMinValue(value);
		gauge.render();
		return value;
	}
	function gauge_setMaximum(gauge,value){
		gauge.maxValue=value;
		gauge.render();
		return value;
	}
	function gauge_setStaticZones(gauge,zones){
		gauge.options.staticZones=zones;
	}
	function gauge_setRadiusScale(gauge,scale){
		gauge.options.radiusScale=scale;
	}
	function gauge_setLineWidth(gauge,lineWidth){
		gauge.options.lineWidth=lineWidth;
	}
	function gauge_redraw(gauge){
		var value = gauge.value;
		gauge.render();
		gauge.set(gauge.value+gauge.value*(gauge.maxValue-gauge.MinValue)/1000);
		gauge.set(value);
		return true;
	}
	
</script>
