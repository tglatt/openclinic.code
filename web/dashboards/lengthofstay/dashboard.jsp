<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSCHARTJS %>
<%
	String prefix="lengthofstay";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'><%=writeDashboardTimeGraph(prefix+"graph", 200, 150,"month") %></td>
	</tr>
	<tr>
		<td style='text-align: center'>
			<select name='<%=prefix%>timeunit' id='<%=prefix%>timeunit' class='text' onchange='<%=prefix%>getValue()'>
				<option value='month'><%=getTranNoLink("web","month",sWebLanguage) %></option>
				<option value='year'><%=getTranNoLink("web","year",sWebLanguage) %></option>
			</select>
		</td>
	</tr>
</table>

<script>
	var <%=prefix%>timer=window.setInterval('<%=prefix%>getValue()',1000);
	function <%=prefix%>getValue(){
  		//*****************************************
  		//Pass parameters here
  		//*****************************************
	    var params = 'timeunit='+document.getElementById('<%=prefix%>timeunit').value;
	    var url = '<c:url value="/dashboards/"/><%=prefix%>/getValue.jsp?ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      	method: "GET",
	      	parameters: params,
	      	onSuccess: function(resp){
	      		//*****************************************
	      		//Do something with the obtained value here
	      		//*****************************************
	            var result = eval('('+resp.responseText+')');
	            <%=prefix%>graph.options.scales.xAxes[0].time.unit=document.getElementById('<%=prefix%>timeunit').value;
	            <%=prefix%>graph.data=result.data;
	            <%=prefix%>graph.update();
	      		window.clearInterval(<%=prefix%>timer);
	      	}
	    });
	}
	
	function <%=prefix%>showDetails(){
		openPopup('dashboards/<%=prefix%>/getDetails.jsp&language=<%=sWebLanguage%>&timeunit='+document.getElementById('<%=prefix%>timeunit').value,500,300,'<%=getTranNoLink("web","lengthofstay",sWebLanguage)%>');
	}
	
</script>