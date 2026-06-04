<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSGAUGE %>
<%
	String prefix="availableram";
	long maxram=Runtime.getRuntime().maxMemory()/(1024*1024);
%>
<table width='100%'>
	<tr>
		<td style='text-align: center' onclick='<%=prefix%>showDetails();'>
			<%=writeDashboardGauge("available_ram",200,0,maxram,"Mémoire disponible en MB") %><br>
		</td>
	</tr>
</table>

<script>
	var <%=prefix%>timer=window.setInterval('<%=prefix%>getValue()',1000);
	
	function <%=prefix%>getValue(){
  		//*****************************************
  		//Pass parameters here
  		//*****************************************
	    var params = "units=MB";
	    var url = '<c:url value="/dashboards/"/><%=prefix%>/getValue.jsp?ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      	method: "GET",
	      	parameters: params,
	      	onSuccess: function(resp){
	      		//*****************************************
	      		//Do something with the obtained value here
	      		//*****************************************
	            var result = eval('('+resp.responseText+')');
	      		if(available_ram){
	      			available_ram.set(result.freeram+result.maxram-result.reservedram);
	      		}
	      		//*****************************************
	      		//Update value after some time
	      		//*****************************************
    			window.setTimeout('<%=prefix%>getValue()',1000);
	      		window.clearInterval(<%=prefix%>timer);
	      	}
	    });
	}
	function <%=prefix%>showDetails(){
		openPopup('dashboards/<%=prefix%>/getDetails.jsp&language=<%=sWebLanguage%>',
				500,300,"Détails RAM");
	}
	gauge_setStaticZones(available_ram,[
			{strokeStyle: "red", min: 0, max: <%=0.2*maxram%>},
			{strokeStyle: "yellow", min: <%=0.2*maxram%>, max: <%=0.5*maxram%>},
			{strokeStyle: "lightgreen", min: <%=0.5*maxram%>, max: <%=0.95*maxram%>},
			{strokeStyle: "black", min: <%=0.95*maxram%>, max: <%=maxram%>}
	]);

	<%=prefix%>getValue();
	
</script>