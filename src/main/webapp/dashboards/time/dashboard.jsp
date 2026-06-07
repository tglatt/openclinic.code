<%@include file="/dashboards/includes/dashboard.jsp"%>
<%
	String prefix="time";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardText("time", "") %>
		</td>
	</tr>
</table>

<script>
	var <%=prefix%>timer=window.setInterval('<%=prefix%>getValue()',1000);
	
	function <%=prefix%>getValue(){
  		//*****************************************
  		//Pass parameters here
  		//*****************************************
	    var params = '';
	    var url = '<c:url value="/dashboards/"/><%=prefix%>/getValue.jsp?ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      	method: "GET",
	      	parameters: params,
	      	onSuccess: function(resp){
	      		//*****************************************
	      		//Do something with the obtained value here
	      		//*****************************************
	            var result = eval('('+resp.responseText+')');
	            time.innerHTML=result.time;
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