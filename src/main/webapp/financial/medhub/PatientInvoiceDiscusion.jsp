<%@page import="be.openclinic.system.Screen"%>
<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.HTMLEntities,
                java.text.DecimalFormat,
                javax.json.JsonObject,
                be.openclinic.finance.Insurance,
                java.util.Date,
                be.mxs.common.util.io.OBR,
                be.mxs.common.util.io.MedHub,
                be.mxs.common.util.io.Medhubmessage,
                be.openclinic.medical.ReasonForEncounter,
                be.mxs.common.util.system.*"%>         
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSDATE%> 

<%
String invoiceuid = checkString(request.getParameter("invoiceuid"));
//for test 
//invoiceuid = "4311410";
		
String signature_obr = "";
OBR obr = new OBR();
signature_obr = obr.getSignature(invoiceuid);	

		
%>
<style>
.tit_message{
  border-radius:5px;
  border: 1px solid #336699;
  padding: 5px;
  background: #8cb3d9;
  color:#fff;
}

.txt_message{
  border-radius:5px;
  border: 1px solid #336699;
  padding: 5px;
}

</style>
 <table class="admin" width="100%"  >
<tr>
<td class="admin">
<div id='result' ><span>La facture:</span><%=invoiceuid%>(0 messages)</div>
<td>
</tr></table>
 <table class="admin" width="100%"  >
<tr>
<td width='34%' style='vertical-align: top; overflow: hidden;'>

<textarea style='border:1px solid red; margin-bottom:10px; width:100%;' name='newMessage' id='newMessage' onkeypress="onTestChange();" cols="120" rows="6" ></textarea>
<select id="message_rec" name="message_rec"><%=MedHub.getParticipant(invoiceuid)%></select>
<input type='button' class='button' name='sendButton' value='<%=getTran(null,"web","send",sWebLanguage) %>' onclick="sendMessage()"/>
<input type='button' class='button' name='clearButton' value='<%=getTran(null,"web","clear",sWebLanguage) %>' onclick="clearText()"/>   
<br>
<span id='statusresult' ></span>

<%=Medhubmessage.ListeMessage(invoiceuid)%>
</td>
<td width='66%' style='vertical-align: top; overflow: hidden;' >
<table style='table-layout: fixed; width: 100%;' ><tr><td  style='vertical-align: top; overflow: hidden;' >
<span>Signature:</span><%=signature_obr%>
<div id='signature_data'></div>
</td></tr></table>
</td>
</tr>
</table>
<script>

LoadDetails();
fetchMessages();
function LoadDetails(){
	//alert("Goo!");
    var params = '';
    var today = new Date();
    var url= '<c:url value="/financial/medhub/getInvoice.jsp"/>?invoiceuid=<%=invoiceuid%>&ts='+today;
    //alert(url);
    document.getElementById('signature_data').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/><br/>Loading";
    new Ajax.Request(url,{
	  method: "GET",
      parameters: params,
      onSuccess: function(resp){
    	document.getElementById('signature_data').innerHTML=resp.responseText;
      }
    });	
    
}

function sendMessage(){
	var MessageText = document.getElementById("newMessage").value;
	 //alert("Ok...");
	//sendMessageToserver();
	
	if(MessageText.length > 0){
	saveMessage(MessageText);
	sendMessageToserver();
	}else{
		//alert("No txt");
	}
}

function saveMessage(MessageT){
	
	var savem = "savemessage";
	var sel = document.getElementById("message_rec");
	var message_rec = sel.options[sel.selectedIndex].text;
	var MessageText = MessageT;
    var today = new Date();
    var url= '<c:url value="/financial/medhub/doSendDiscusion.jsp"/>?ts='+today;
    
    document.getElementById('statusresult').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/> Loading";
    
    new Ajax.Request(url,{
          method: "GET",
          parameters: 'messagecontent=' + MessageText +
            '&savemessage='+savem + 
            '&message_rec='+message_rec +
			'&currentuser='+'<%=activeUser.getFullName()%>'+
			'&current_house='+'<%=Medhubmessage.getCurrentHouse(activeUser.getParameter("insuranceagent"))%>'+
			'&invoiceuid='+'<%=invoiceuid%>',
          onSuccess: function(data){	  
        	  var json = eval('(' + data.responseText + ')');  
        	  var status = json.message;
        	  //alert(status);
        	  switch(status){
        	  case "1":
        		  document.getElementById("statusresult").innerHTML = "Message envoyee";
        		  break;
        	  case "-2": 
        		  document.getElementById("statusresult").innerHTML = "La facture n'existe pas";
        		  break;
        	  case "-1000":
        		  document.getElementById("statusresult").innerHTML = "Fournir une facture pour cette discussion";  
        		  break;
        	  default:
        		  document.getElementById("statusresult").innerHTML = "Une erreur s'est produite";  
        		  break;
        	  }
        	  //clearText();//fetchMessages();
        	  location.reload();
          },
          dataType: "json",
          onFailure: function(){
             alert("Error!");
          }
      }
    );
    
}

function sendMessageToserver(){
	
	var MessageText = document.getElementById("newMessage").value;
    var today = new Date();
    var toserver = 1;
    
    var sel = document.getElementById("message_rec");
	var message_rec = sel.options[sel.selectedIndex].text;
    
    var url= '<c:url value="/financial/medhub/doSendDiscusion.jsp"/>?ts='+today;
    
    document.getElementById('statusresult').innerHTML = "<img src='<c:url value="/_img/themes/default/ajax-loader.gif"/>'/> Loading";
    
    new Ajax.Request(url,{
          method: "GET",
          parameters: 'messagecontent=' + MessageText +
            '&toserver='+toserver +
            '&message_rec='+message_rec +
			'&message_sender='+ '<%=activeUser.getFullName()%>'+
			'&invoiceuid='+ '<%=invoiceuid%>',
          onSuccess: function(data){	  
        	  var json = eval('(' + data.responseText + ')');  
        	  var status = json.message;
        	  alert(status);
        	  switch(status){
        	  case "1":
        		  document.getElementById("statusresult").innerHTML = "Message envoyee";
        		  break;
        	  case "-2": 
        		  document.getElementById("statusresult").innerHTML = "La facture n'existe pas";
        		  break;
        	  case "-1000":
        		  document.getElementById("statusresult").innerHTML = "Fournir une facture pour cette discussion";  
        		  break;
        	  default:
        		  document.getElementById("statusresult").innerHTML = "Une erreur s'est produite";  
        		  break;
        	  }
        	  clearText();fetchMessages();
          },
          dataType: "json",
          onFailure: function(){
             alert("Error!");
          }
      }
    );
	
}

function fetchMessages(){

    var today = new Date();
    var fetch = "1";
    var url= '<c:url value="/financial/medhub/doSendDiscusion.jsp"/>?ts='+today;
    
    new Ajax.Request(url,{
          method: "GET",
          parameters: 'fetch=' + fetch +
			'&invoiceuid='+ '<%=invoiceuid%>',
          onSuccess: function(data){	  
        	  var json = eval('(' + data.responseText + ')');  
        	  var status = json.message;
        	  //alert(status);

          },
          dataType: "json",
          onFailure: function(){
             alert("Error!");
          }
      }
    );
}

function clearText(){
	 document.getElementById("newMessage").innerHTML = "";  	
}


function onTestChange() {
    var key = window.event.keyCode;

    // If the user has pressed enter
    if (key === 13) {
        //alert(document.getElementById("newMessage").value);
        sendMessage();
        return false;
    }
    else {
        return true;
    }
}

</script>