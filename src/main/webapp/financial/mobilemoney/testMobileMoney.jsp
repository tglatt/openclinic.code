<%@include file="/includes/helper.jsp"%>
<head>
  <%=sJSPROTOTYPE%>

</head>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr>
			<td>URI to call MobileMoney API:</td>
			<td><input onkeyup="composeURL();" type='text' size='100' name='url' id='url' value='https://openclinic.hnrw.org/openclinic/mobileMoneyAPI.jsp'/></td>
		</tr>
		<tr>
			<td colspan='2'><hr/><b>PARAMETERS</b></td>
		</tr>
		<tr>
			<td>Amount to be paid:</td>
			<td><input onkeyup="composeURL();" type='text' size='20' name='amount' id='amount' value='1000'/></td>
		</tr>
		<tr>
			<td>Currency:</td>
			<td><input onkeyup="composeURL();" type='text' size='5' name='currency' id='currency' value='XOF'/></td>
		</tr>
		<tr>
			<td>Payer phone number:</td>
			<td><input onkeyup="composeURL();" type='text' size='20' name='phone' id='phone' value='0022399568136'/></td>
		</tr>
		<tr>
			<td>OpenClinic invoice ref:</td>
			<td><input onkeyup="composeURL();" type='text' size='20' name='invoice' id='invoice' value='1.234567'/></td>
		</tr>
		<tr>
			<td>Mobile money API login:</td>
			<td><input onkeyup="composeURL();" type='text' size='20' name='login' id='login' value='hop12345'/></td>
		</tr>
		<tr>
			<td>Mobile money API password:</td>
			<td><input onkeyup="composeURL();" type='text' size='20' name='password' id='password' value='ABCDEFGH0987654'/></td>
		</tr>
		<tr>
			<td colspan='2'><b>Full URL to be called:</b></td>
		</tr>
		<tr>
			<td colspan='2'><span id='fullurl'/></td>
		</tr>
	</table>
	<input type='button' onclick='sendPaymentRequest()' value='Call Mobile money API'/>
	<hr/>
	<table width='100%'>
		<tr>
			<td>URI to check payment status:</td>
			<td><input type='text' size='100' name='statusurl' id='statusurl' value='https://openclinic.hnrw.org/openclinic/mobileMoneyAPIStatus.jsp'/></td>
		</tr>
		<tr>
			<td colspan='2'><b>Full check status URL to be called:</b></td>
		</tr>
		<tr>
			<td colspan='2'><span id='fullstatusurl'/></td>
		</tr>
	</table>
</form>
<script>
	function composeURL(){
		var url = 	document.getElementById('url').value+"?"+
					"amount="+document.getElementById('amount').value+"&amp;"+
					"currency="+document.getElementById('currency').value+"&amp;"+
					"phone="+document.getElementById('phone').value+"&amp;"+
					"invoice="+document.getElementById('invoice').value+"&amp;"+
					"login="+document.getElementById('login').value+"&amp;"+
					"password="+document.getElementById('password').value;
		document.getElementById('fullurl').innerHTML=url;
		document.getElementById('fullstatusurl').innerHTML=document.getElementById('statusurl').value+"?"+
					"invoice="+document.getElementById('invoice').value+"&amp;"+
					"login="+document.getElementById('login').value+"&amp;"+
					"password="+document.getElementById('password').value;
	}
	
	function sendPaymentRequest(){
		var url = 	document.getElementById('url').value+"?"+
			"amount="+document.getElementById('amount').value+"&"+
			"currency="+document.getElementById('currency').value+"&"+
			"phone="+document.getElementById('phone').value+"&"+
			"invoice="+document.getElementById('invoice').value+"&"+
			"login="+document.getElementById('login').value+"&"+
			"password="+document.getElementById('password').value;
		window.open(url);
		window.setTimeout("checkPaymentStatus()",2000);
	}
	
	function checkPaymentStatus(){
		var url = "<%=sCONTEXTPATH%>/mobileMoneyCheckStatus.jsp";
		var params="invoice="+document.getElementById('invoice').value+"&"+
		"url="+document.getElementById('url').value+"&"+
		"login="+document.getElementById('login').value+"&"+
		"password="+document.getElementById('password').value;
		new Ajax.Request(url,{
		  	method: "POST",
		  	parameters: params,
		  	onSuccess: function(resp){
			    var s=eval('('+resp.responseText+')');
			    if(s.status=="Payment status not yet available"){
			    	window.setTimeout("checkPaymentStatus()",2000);
			    }
			    else{
			    	alert(s.status);
			    }
		  	}
		})
	}
	
	composeURL();
</script>