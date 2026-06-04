<%@include file="/includes/helper.jsp"%>
<%
	//*** SAVE ***
	if(request.getParameter("save")!=null){
		Enumeration ePars = request.getParameterNames();
		
		while(ePars.hasMoreElements()){
			String parameter = (String)ePars.nextElement();
			
			if(parameter.startsWith("par_")){
				// only save when value differs
				if(!MedwanQuery.getInstance().getConfigString(parameter.replace("par_","")).equals(request.getParameter(parameter))){
					if(parameter.equalsIgnoreCase("par_pharmaSyncServerURL")){
						MedwanQuery.getInstance().setConfigString("lastCentralPharmacyOperationId","0");
					}
					MedwanQuery.getInstance().setConfigString(parameter.replace("par_",""),request.getParameter(parameter));
				}
			}
		}
		MedwanQuery.getInstance(new java.util.Date().getTime()+"",true);
	}

	session.setAttribute("UserTheme","grey");
%>
<%=sCSSNORMAL %>
<title><%=SH.cs("diagnistixServerName","DIAGNOSTIX") %></title>
<form name='transactionForm'>
	<input type='hidden' name='Page' id='Page'/>
</form>
<center><img height='50px' src='<%=sCONTEXTPATH%>/_img/s5.png'/></center>
<table width='100%'>
	<tr class='adminblack'><td style='text-align: center'>Diagnostix S5 Middleware console</td></tr>
</table>
<%
	if(SH.p(request,"Page").length()==0){
%>
	<table width='100%'>
		<tr>
			<td style='text-align: center'><a href='javascript:showConfig()'>OpenClinic GA interface configuration</a></td>
		</tr>
		<tr>
			<td style='text-align: center'><a href='javascript:showIncomingHL7()'>Show incoming HL7 messages</a></td>
		</tr>
		<tr>
			<td style='text-align: center'><a href='javascript:showIncomingXML()'>Show incoming XML messages</a></td>
		</tr>
		<tr>
			<td style='text-align: center'><br/><br/><br/><br/><a href='javascript:logOff()'>Logoff</a></td>
		</tr>
	</table>
<%
	}
	else{
		SH.setIncludePage(SH.p(request,"Page"),pageContext);
	}
%>

<script>
	function showConfig(){
		document.getElementById('Page').value='/util/configparameters.jsp?group=s5';
		transactionForm.submit();
	}
	function showIncomingHL7(){
		document.getElementById('Page').value='/diagnostix/showIncomingHL7Messages.jsp';
		transactionForm.submit();
	}
	function showIncomingXML(){
		document.getElementById('Page').value='/diagnostix/showIncomingXMLMessages.jsp';
		transactionForm.submit();
	}
	function logOff(){
		window.location.href='<%=sCONTEXTPATH%>/diagnostix/index.jsp';
	}
	function goBack(){
		document.getElementById('Page').value='';
		transactionForm.submit();
	}
	<%-- HIDE SELECTS --%>
	function hideSelects(){
	  var selects = document.getElementsByTagName("SELECT");
	  for(var i=0; i<selects.length; i++){
	    selects[i].style.visibility = "hidden";
	  }
	}

	function uncheckRadio(radioitem){
		radioitem.checked=false;	
	}

	<%-- UNHIDE SELECTS --%>
	function unhideSelects(){
	  var selects = document.getElementsByTagName("SELECT");
	  for(var i=0; i<selects.length; i++){
	    selects[i].style.visibility = "visible";
	  }
	}
</script>

