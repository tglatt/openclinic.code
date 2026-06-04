<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSCHARTJS %>
<%
	String prefix="totalbloodproduced";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=getTran(request,"cnts","totalbloodproduced",sWebLanguage) %>
			<%=writeDashboardTimeGraph(prefix+"graph", 200, 150,"day") %>
		</td>
	</tr>
	<tr>
		<td style='text-align: center'>
			<select name='<%=prefix%>timeunit' id='<%=prefix%>timeunit' class='text' onchange='<%=prefix%>getValue()'>
				<option value='day'><%=getTranNoLink("web","day",sWebLanguage) %></option>
				<option value='month'><%=getTranNoLink("web","month",sWebLanguage) %></option>
				<option value='year'><%=getTranNoLink("web","year",sWebLanguage) %></option>
			</select>
			<select name='<%=prefix%>center' id='<%=prefix%>center' class='text' onchange='<%=prefix%>getValue()'>
				<option/>
				<option value='cnts'>CNTS</option>
				<option value='bururi'>CRTS Bururi</option>
				<option value='ngozi'>CRTS Ngozi</option>
				<option value='gitega'>CRTS Gitega</option>
				<option value='cibitoke'>CRTS Cibitoke</option>
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
	    var params = 'timeunit='+document.getElementById('<%=prefix%>timeunit').value+'&center='+document.getElementById('<%=prefix%>center').value;
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
	
</script>