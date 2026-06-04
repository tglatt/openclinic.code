<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<html id='html'>
<head>
  <%=sCSSNORMAL%>
  <%=sCSSMODALBOX%>
  <%=sJSTOGGLE%>
  <%=sJSFORM%>
  <%=sJSPOPUPMENU%>
  <%=sJSPROTOTYPE%>
  <%=sJSSCRPTACULOUS%>
  <%=sJSMODALBOX%>
  <%=sIcon%>
  <%=sJSSCRIPTS%>
  <%=sJSSTRINGFUNCTIONS%>
</head>

<table width='100%'>
	<tr>
		<td class='adminblack'>Monitoring of 100 most recently posted observations at <span id='time'/></td>
	</tr>
</table>
<div id='observations'/>

<script>
	function loadObservations(){
	    var url = '<c:url value="/util/loadObservations.jsp"/>';
		new Ajax.Request(url,{
		parameters: "",
		onSuccess: function(resp){
		  document.getElementById('observations').innerHTML = resp.responseText;
		  document.getElementById('time').innerHTML = (new Date()).toLocaleTimeString();
		  window.setTimeout("loadObservations();",5000)
		}
		});
	}
	
	window.setTimeout("loadObservations();",500)
</script>