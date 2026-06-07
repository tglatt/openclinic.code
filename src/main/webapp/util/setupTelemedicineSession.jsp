<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String key1 = SH.p(request,"sessionkey1");
	String key2 = SH.p(request,"sessionkey2");
	if(request.getParameter("submitButton")!=null && key1.length()>0 || key2.length()>0){
		if(activePatient!=null && activePatient.isNotEmpty()){
			application.setAttribute("wizzeyeRoomId."+key1, activePatient.personid+"");
			application.setAttribute("wizzeyeRoomId."+key2, activePatient.personid+"");
		}
		out.println("<script>window.opener.startWizzeyeSession('"+key1+"','"+key2+"');window.close();</script>");
		out.flush();
	}
%>


<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'><%=getTran(request,"web","telemedicinesessionconfig",sWebLanguage) %></td>
		</tr>
		<%if(!SH.p(request,"noglasses").equalsIgnoreCase("1")){%>
		<tr>
			<td class='admin'><%=getTran(request,"web","telemedicinesessionkey1",sWebLanguage) %> <img style='vertical-align: middle' height='32px' src='<%=sCONTEXTPATH%>/_img/themes/default/smartglasses.png'/></td>
			<td class='admin2'><input name='sessionkey1' type='text' class='text' value='<%=key1 %>' size='10'/></td>
		</tr>
		<%}else{ %>
			<input type='hidden' name='sessionkey1'/>
		<%} %>		
		<tr>
			<td class='admin'><%=getTran(request,"web","telemedicinesessionkey2",sWebLanguage) %> <img style='vertical-align: middle' height='32px' src='<%=sCONTEXTPATH%>/_img/themes/default/webcam.png'/></td>
			<td class='admin2'><input name='sessionkey2' type='text' class='text'  value='<%=key2 %>'size='10'/></td>
		</tr>
	</table>
	<p><center><input type='submit' name='submitButton' value='<%=getTranNoLink("wizzeye","startsession",sWebLanguage) %>'/></center></p>
</form>