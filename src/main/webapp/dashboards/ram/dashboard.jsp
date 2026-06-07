<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSGAUGE %>
<%
	String prefix="ram";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardGauge(prefix+"gauge",200,0,100,"% Mémoire RAM utilisé")%><br/>
			<a href='javascript:<%=prefix%>showDetails()'><%=getTran(request,"web","details",sWebLanguage) %></a>
		</td>
	</tr>
</table>

<script>
	var <%=prefix%>timer=window.setInterval('<%=prefix%>getValue()',1000);
	function <%=prefix%>getValue(){
  		//*****************************************
  		//Pass parameters here
  		//*****************************************
	    var params = "";
	    var url = '<c:url value="/dashboards/"/><%=prefix%>/getValue.jsp?ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      	method: "GET",
	      	parameters: params,
	      	onSuccess: function(resp){
	      		if(<%=prefix%>gauge){
		      		//*****************************************
		      		//Do something with the obtained value here
		      		//*****************************************
		            var result = eval('('+resp.responseText+')');
	    			gauge_setValue(<%=prefix%>gauge,result.usedram*100/result.maxram);
		      		//*****************************************
		      		//Update value after some time
		      		//*****************************************
	    			window.setTimeout('<%=prefix%>getValue()',5000);
		      		window.clearInterval(<%=prefix%>timer);
	      		}
	      	}
	    });
	}
	
	function <%=prefix%>showDetails(){
		openPopup('dashboards/<%=prefix%>/getDetails.jsp&language=<%=sWebLanguage%>',500,300,'Détails RAM');
	}
	
	gauge_setStaticZones(<%=prefix%>gauge,[{strokeStyle: "red", min: 80, max: 100},{strokeStyle: "yellow", min: 50, max: 80},{strokeStyle: "lightgreen", min: 10, max: 50},{strokeStyle: "black", min: 0, max: 10}]);
	<%=prefix%>gauge.animationSpeed=32;

</script>