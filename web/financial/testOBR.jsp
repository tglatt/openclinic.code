<%@include file="/includes/validateUser.jsp"%>
<%=sJSPROTOTYPE %>

<form name="transactionForm" method="post">
	N° facture: <input type='text' class='text' name='invoiceuid' id='invoiceuid'/>
	<input type="button" class="button" name="testButton" value="Sauvegarder chez OBR" 
			onclick="doTest()"/>
	<div id="log"></div>
</form>

<script>
	function doTest(){
		putInvoice();
	}
	
	function putInvoice(){
	    var params = "";
	    var url = '<c:url value="/api/obr/putInvoice.jsp"/>?invoiceuid='+document.getElementById("invoiceuid").value+'&ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      	method: "POST",
	      	parameters: params,
	      	onSuccess: function(resp){
	            var result = eval('('+resp.responseText+')');
	            document.getElementById("log").innerHTML+="<br/><b>Success ["+document.getElementById("invoiceuid").value+"]</b>: "+result.success;
	      	}
	    });
	}
</script>