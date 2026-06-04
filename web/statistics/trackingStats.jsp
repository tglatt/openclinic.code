<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSCHARTJS %>
<%=sJSSORTTABLE%>
<%
	String sBegin = SH.formatDate(SH.getPreviousMonthBegin());
	String sEnd = SH.formatDate(SH.getPreviousMonthEnd());
%>

<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'><td colspan='2'><%=getTran(request,"web","trackingStats",sWebLanguage) %></td></tr>
		<tr>
		    <td class="admin">ICD-10</td>
		    <td class="admin2">
		    	<input type='text' class='text' name='icd10' id='icd10' size='100'/>
		    </td>                        
		</tr>
		<tr>
		    <td class="admin"><%=getTran(request,"web","period",sWebLanguage)%></td>
		    <td class='admin2'>
		    	<%= SH.writeDateField("dashboardBegin", "transactionForm", sBegin, true, false, sWebLanguage, sCONTEXTPATH)%>
		    	<%= SH.writeDateField("dashboardEnd", "transactionForm", sEnd, true, false, sWebLanguage, sCONTEXTPATH)%>
		    	<input type='button' onclick='doAnalyze()' name='submitButton' class='button' value='<%=getTranNoLink("web","analyze",sWebLanguage) %>'/>
		    </td>
		</tr>
	</table>
	<div id='divDashboard'></div>
</form>
<script>
	function doAnalyze(){
	    document.getElementById('divDashboard').innerHTML = "<img height='14px' src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/>";
	    var params = "icd10="+document.getElementById("icd10").value+"&begin="+document.getElementById("dashboardBegin").value+"&end="+document.getElementById("dashboardEnd").value;
	    var url = "<%=sCONTEXTPATH%>/statistics/ajax/generateTrackingStats.jsp";
		new Ajax.Request(url,{
		method: "POST",
		parameters: params,
		onSuccess: function(resp){
			document.getElementById('divDashboard').innerHTML=resp.responseText;
			sortables_init();
		}
		});
	}
	</script>
