<%@include file="/includes/helper.jsp"%>
<%@page import="be.mxs.common.util.system.Pointer"%>
<%
	Pointer.deletePointers("paymentstatus."+request.getParameter("invoice"));
%>
<br/><br/><br/><br/><br/><br/><br/><br/><br/>
<center>
	This is the Mobile money API window where communication with the payment provider happens<br/>
	<input type='button' value='Respond with successful payment' onclick='setresult(1)'/>
	<input type='button' value='Respond with unsuccessful payment' onclick='setresult(0)'/>
</center>

<script>
	alert("Payment request filed");
	
	function setresult(r){
		window.location.href="<%=sCONTEXTPATH%>/mobileMoneySetResult.jsp?invoice=<%=request.getParameter("invoice")%>&result="+r;
	}
</script>
