<%@include file="/includes/validateUser.jsp"%>
<%= sCSSNORMAL %>
<%= sJSPROTOTYPE %>
<%
	String sBegin = SH.p(request,"begin");
	String sEnd = SH.p(request,"end");
	if(sBegin.length()==0){
		sBegin=SH.getSQLDate(new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*7));
	}
	if(sEnd.length()==0){
		sEnd=SH.getSQLDate(new java.util.Date());
	}
	String sRenewalFrequency = SH.p(request,"renewalFrequency","-1");
%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='10'><%=getTran(request,"web.manage","manageOpenCarenetTraffic",sWebLanguage) %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","begindate",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDateField("begin", "transactionForm", sBegin, true, false, sWebLanguage, sCONTEXTPATH) %></td>
			<td class='admin'><%=getTran(request,"web","enddate",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDateField("end", "transactionForm", sEnd, true, false, sWebLanguage, sCONTEXTPATH) %></td>
			<td class='admin2'><input type='submit' name='submitButton' id='submitButton' class='button' value='<%=getTranNoLink("web","find",sWebLanguage)%>'/></td>
			<td class='admin' colspan='5'>
				<%=getTran(request,"web","renewalfrequency",sWebLanguage) %>:
				<select class='text' name='renewalFrequency' id='renewalFrequency' onchange='renew()'>
					<option <%=sRenewalFrequency.equals("5")?"selected":"" %> value='5'>5 sec</option>
					<option <%=sRenewalFrequency.equals("10")?"selected":"" %> value='10'>10 sec</option>
					<option <%=sRenewalFrequency.equals("30")?"selected":"" %> value='30'>30 sec</option>
					<option <%=sRenewalFrequency.equals("60")?"selected":"" %> value='60'>60 sec</option>
					<option <%=sRenewalFrequency.equals("300")?"selected":"" %> value='300'>5 min</option>
					<option <%=sRenewalFrequency.equals("-1")?"selected":"" %> value='-1'><%=getTranNoLink("web","never",sWebLanguage) %></option>
				</select>
			</td>
		</tr>
	</table>
	<div id='msgs'/>
</form>

<script>
	var to;
	
	function renew(){
		var freq = document.getElementById("renewalFrequency").value;
		if(freq*1>0){
			window.clearTimeout(to);
			to = window.setTimeout("loadMessages();",freq*1000);
		}
	}
	

	function loadMessages(){
    	var url = '<c:url value="/system/ajax/getOpenCarenetMessages.jsp"/>?ts='+new Date();
      	new Ajax.Request(url,{
	  		method: "GET",
        	parameters: "begin="+document.getElementById("begin").value+"&end="+document.getElementById("end").value,
        	onSuccess: function(resp){
        		document.getElementById('msgs').innerHTML=resp.responseText;
        		renew();
        	}
      	});
	}

	function deleteMessage(messageId){
		if(window.confirm('<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>')){
	    	var url = '<c:url value="/system/ajax/deleteOpenCarenetMessage.jsp"/>?ts='+new Date();
	      	new Ajax.Request(url,{
		  		method: "GET",
	        	parameters: "messageid="+messageId,
	        	onSuccess: function(resp){
	        		loadMessages();
	        	}
	      	});
		}
	}

	loadMessages();
</script>