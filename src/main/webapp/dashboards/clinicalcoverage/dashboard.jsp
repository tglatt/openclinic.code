<%@include file="/dashboards/includes/dashboard.jsp"%>
<%=sJSGAUGE %>

<%
	String prefix="clinicalcoverage";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardGauge(prefix+"gauge",200,0,100,"% Couverture clinique")%><br/>
			<select name='<%=prefix%>period' id='<%=prefix%>period' class='text' onchange='<%=prefix%>getValue()'>
				<%
					int month = Integer.parseInt(new SimpleDateFormat("MM").format(new java.util.Date()));
					int year = Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()));
					for(int n =0;n<12;n++){
						int theMonth = month-n;
						if(theMonth>0){
							out.println("<option value='"+theMonth+"/"+year+"'>"+theMonth+"/"+year+"</option>");
						}
						else{
							out.println("<option value='"+(12+theMonth)+"/"+(year-1)+"'>"+(12+theMonth)+"/"+(year-1)+"</option>");
						}
					}
				%>
			</select>&nbsp;&nbsp;
			<a href='javascript:<%=prefix%>showDetails()'><%=getTran(request,"web","details",sWebLanguage) %></a>
		</td>
	</tr>
</table>

<script>
	var <%=prefix%>timer=window.setInterval('<%=prefix%>getValue()',1000);

	function <%=prefix%>getValue(){
	    var params = "";
	    var url = '<c:url value="/dashboards/"/><%=prefix%>/getValue.jsp?period='+document.getElementById('<%=prefix%>period').value+'&ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      	method: "GET",
	      	parameters: params,
	      	onSuccess: function(resp){
	      		if(<%=prefix%>gauge){
		      		//*****************************************
		      		//Do something with the obtained value here
		      		//*****************************************
		            var result = eval('('+resp.responseText+')');
	    			gauge_setValue(<%=prefix%>gauge,result.coverage);
		      		//*****************************************
		      		//Update value after some time
		      		//*****************************************
		      		window.clearInterval(<%=prefix%>timer);
	      		}
	      	}
	    });
	}
	
	function <%=prefix%>showDetails(){
		openPopup('dashboards/<%=prefix%>/getDetails.jsp&language=<%=sWebLanguage%>&period='+document.getElementById('<%=prefix%>period').value,800,400,'Détails couverture clinique');
	}
	
	gauge_setStaticZones(<%=prefix%>gauge,[{strokeStyle: "red", min: 0, max: 50},{strokeStyle: "yellow", min: 50, max: 85},{strokeStyle: "lightgreen", min: 85, max: 100}]);
	<%=prefix%>gauge.animationSpeed=10;

</script>