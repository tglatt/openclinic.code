<%@include file="/dashboards/includes/dashboard.jsp"%>
<%
	String prefix="diskspace";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardText("diskspace","") %><br>
			Espace disque
		</td>
	</tr>
</table>

<script>
	var <%=prefix%>timer=window.setInterval('<%=prefix%>getValue()',1000);
	function <%=prefix%>getValue(){
		if(<%=prefix%>){
	  		//*****************************************
	  		//Pass parameters here
	  		//*****************************************
		    var params = "units=GB";
		    var url = '<c:url value="/dashboards/"/><%=prefix%>/getValue.jsp?ts='+new Date().getTime();
		    new Ajax.Request(url,{
		      	method: "GET",
		      	parameters: params,
		      	onSuccess: function(resp){
		      		//*****************************************
		      		//Do something with the obtained value here
		      		//*****************************************
		            var result = eval('('+resp.responseText+')');
		            <%=prefix%>.innerHTML=(result.diskspace).toFixed(2)+" GB";
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