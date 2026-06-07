<%@page import="be.openclinic.system.Screen"%>
<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.HTMLEntities,
                java.text.DecimalFormat,
                be.openclinic.finance.Insurance,
                java.util.Date,
                be.mxs.common.util.io.OBR,
                be.mxs.common.util.io.MedHub,
                be.openclinic.medical.ReasonForEncounter,
                be.mxs.common.util.system.*"%>         
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>


<%
String invoiceuid = checkString(request.getParameter("invoiceuid"));
String signature_obr = "";
OBR obr = new OBR();
signature_obr = obr.getSignature(invoiceuid);
//JsonObject jo = obr.getInvoice(invoiceuid, false);

%>
 <table class="admin" width="100%"  >
<tr>
<td>
<td>
</tr></table>
 <table class="admin" width="100%"  >
<tr>
<td width='66%' style='vertical-align: top;'>
<span>Signature :<%=signature_obr%></span>
<br>
<span id='statusresult'></span>
</td>
<td width='34%' style='vertical-align: top;' >
<table><tr><td>
Test again!
</td></tr></table>
</td>
</tr>
</table>
<script>
LoadDetails();
function LoadDetails(){
	
    var params = '';
    var today = new Date();
    var url= '<c:url value="/financial/medhub/getInvoice.jsp"/>?invoiceuid=<%=invoiceuid%>&ts='+today;
    //alert(url);
    document.getElementById('statusresult').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/><br/>Loading";
    new Ajax.Request(url,{
	  method: "GET",
      parameters: params,
      onSuccess: function(resp){
    document.getElementById('statusresult').innerHTML=resp.responseText;
      }
    });	
    
}

</script>