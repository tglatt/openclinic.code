<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSCHARTJS %>
<%
	String prefix="timegraph";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center' onclick='alert(1);'><%=writeDashboardTimeGraph("mytimegraph", 200, 150,"month") %></td>
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
	            mytimegraph.data=result.data;
	            mytimegraph.update();
	      		window.clearInterval(<%=prefix%>timer);
	      	}
	    });
	}
	
	<%=prefix%>getValue();
	
</script>