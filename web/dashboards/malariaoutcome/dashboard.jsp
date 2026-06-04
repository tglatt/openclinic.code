<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSCHARTJS %>
<%
	String prefix="malariaoutcome";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'><%=writeDonutGraph(prefix+"graph", 200, 150) %></td>
	</tr>
	<tr>
		<td style='text-align: center;font-size: 12px'>
			<%=getTran(request,"web","malariaoutcome",sWebLanguage) %><BR/>
			<a href='javascript:<%=prefix %>showDetails()'><%=getTran(request,"web","details",sWebLanguage) %></a>
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
	            <%=prefix%>graph.data=result.data;
	            <%=prefix%>graph.update();
	      		window.clearInterval(<%=prefix%>timer);
	      	}
	    });
	}
	
	function <%=prefix%>showDetails(){
		openPopup('dashboards/<%=prefix%>/getDetails.jsp&language=<%=sWebLanguage%>',500,300,'<%=getTranNoLink("web","malariaoutcome",sWebLanguage)%>');
	}
	
</script>