<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSGAUGE %>
<%
	String prefix="ramtext";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardText("free_ram","") %><br>
			<a href='javascript:<%=prefix%>showDetails()'><%=getTran(request,"web","details",sWebLanguage) %></a><br/><br/>
			<select id="units" class='text' onchange='<%=prefix%>getValue()'>
				<option>KB</option>
				<option selected>MB</option>
				<option>GB</option>
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
	    var params = "units="+document.getElementById("units").value;
	    var url = '<c:url value="/dashboards/"/><%=prefix%>/getValue.jsp?ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      	method: "GET",
	      	parameters: params,
	      	onSuccess: function(resp){
	      		//*****************************************
	      		//Do something with the obtained value here
	      		//*****************************************
	            var result = eval('('+resp.responseText+')');
    			free_ram.innerHTML="Disponible<br/>"+(result.maxram-result.usedram).toFixed(2)+" "+document.getElementById("units").value;
	      		//*****************************************
	      		//Update value after some time
	      		//*****************************************
    			window.setTimeout('<%=prefix%>getValue()',5000);
	      		window.clearInterval(<%=prefix%>timer);
	      	}
	    });
	}
	
	function <%=prefix%>showDetails(){
		openPopup('dashboards/<%=prefix%>/getDetails.jsp&language=<%=sWebLanguage%>',500,300,'Détails RAM');
	}
	
	<%=prefix%>getValue();
	
</script>