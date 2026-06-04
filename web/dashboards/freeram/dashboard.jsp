<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSGAUGE %>
<%
	String prefix="freeram";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardGauge("free_ram",200,0,Runtime.getRuntime().maxMemory()/(1024*1024),"Mémoire libre en MB") %><br>
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
      			free_ram.set(result.activeusers);
	      		//*****************************************
	      		//Update value after some time
	      		//*****************************************
    			window.setTimeout('<%=prefix%>getValue()',1000);
	      		window.clearInterval(<%=prefix%>timer);
	      	}
	    });
	}
	
	<%=prefix%>getValue();
	
</script>