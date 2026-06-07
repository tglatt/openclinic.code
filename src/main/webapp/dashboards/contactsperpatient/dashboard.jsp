<%@include file="/dashboards/includes/dashboard.jsp"%>

<%
	String prefix="contactsperpatient";
%>
<table width='100%'>
	<tr>
		<td style='text-align: center'>
			<%=writeDashboardText(prefix,"<img height='14px' src='"+sCONTEXTPATH+"/_img/themes/default/ajax-loader.gif'/>") %><br>
		</td>
	</tr>
	<tr>
		<td style='text-align: center'>
			<a style="font-size: 12px" href="javascript:<%=prefix%>showDetails();"><%=getTran(request,"web","details",sWebLanguage) %></a><br>
		</td>
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
	            <%=prefix%>.innerHTML="contacts/patient: "+(result.consultations*1).toFixed(2);
	      		//*****************************************
	      		//Update value after some time
	      		//*****************************************
	      		window.clearInterval(<%=prefix%>timer);
	      	}
	    });
	}
	function <%=prefix%>showDetails(){
		openPopup('dashboards/<%=prefix%>/getDetails.jsp&language=<%=sWebLanguage%>',
				700,300,"Détails encounters per patient");
	}
	
	<%=prefix%>getValue();
</script>