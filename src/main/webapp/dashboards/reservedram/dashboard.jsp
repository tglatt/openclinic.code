<%@include file="/dashboards/includes/dashboard.jsp"%>
<%
	String prefix="reservedram";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardText("reserved_ram","") %><br>
			Mémoire RAM réservée
		</td>
	</tr>
</table>

<script>
	var <%=prefix%>timer=window.setInterval('<%=prefix%>getValue()',1000);
	function <%=prefix%>getValue(){
		if(reserved_ram){
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
	      			reserved_ram.innerHTML=(result.reservedram).toFixed(2)+" MB";
		      		//*****************************************
		      		//Update value after some time
		      		//*****************************************
	    			window.setTimeout('<%=prefix%>getValue()',5000);
		      		window.clearInterval(<%=prefix%>timer);
		      	}
		    });
		}else{
    		window.setTimeout('<%=prefix%>getValue()',5000);
		}
	}
	
	<%=prefix%>getValue();
	
</script>