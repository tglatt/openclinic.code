<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSCHARTJS %>
<%
	String prefix="income";
%>
<table width='100%'>
	<tr>
	<tr>
		<td style='text-align: center'><%=writeDashboardMoneyTimeGraph(prefix+"graph", 200, 150,"day") %></td>
	</tr>
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
	      		//*****************************************
	      		//Do something with the obtained value here
	      		//*****************************************
	            var result = eval('('+resp.responseText+')');
	            <%=prefix%>graph.data=result.data;
	            <%=prefix%>graph.update();
	      		//*****************************************
	      		//Update value after some time
	      		//*****************************************
	      		window.clearInterval(<%=prefix%>timer);
	      	}
	    });
	}
	
	function <%=prefix%>showDetails(){
		openPopup('dashboards/<%=prefix%>/getDetails.jsp&language=<%=sWebLanguage%>',500,300,'<%=getTranNoLink("web","income",sWebLanguage)%>');
	}
	
</script>