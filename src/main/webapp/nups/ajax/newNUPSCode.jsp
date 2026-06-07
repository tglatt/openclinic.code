<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<input type='hidden' name='e-code' id='e-code'/>
	<input type='hidden' name='e-muid' id='e-muid'/>
	<input type='hidden' name='e-extension' id='e-extension'/>
	<tr class='admin'><td colspan='2'><%=getTran(request,"nups","code",sWebLanguage) %></td></tr>
	<tr>
		<td class='admin'><%=getTran(request,"nups","uhc",sWebLanguage)%></td>
		<td class='admin2'>
			<input class='text' type='checkbox' name="e-csu" id="e-csu" value="1"/>
		</td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"nups","code",sWebLanguage) %></td>
		<td class='admin2'>
			<input class='text' type='text' size="10" name="e-parent" id="e-parent" value="" onkeyup="getNomenclatureLabel();"/>
			<input type='button' class='button' name='nomenclatureButton' value='<%=getTranNoLink("web","search",sWebLanguage) %>' onclick='searchParentCode()'/>
	                 &nbsp;&nbsp;&nbsp;<span style='color: darkblue;font-style: italic;font-size: 11px' id='nomenclatureText'/>
		</td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"nups","originalcode",sWebLanguage) %></td>
		<td class='admin2'>
			<input class='text' type='text' size="10" name="e-originalcode" id="e-originalcode" value=""/>
		</td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"nups","domain",sWebLanguage)%></td>
		<td class='admin2'>
			<select class='text' name='e-domain' id='e-domain'>
				<%= SH.getNUPSDomainOptions(activeUser, "") %>
			</select>
		</td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"nups","section",sWebLanguage)%></td>
		<td class='admin2'>
			<select class='text' name='e-sectioncode' id='e-sectioncode' onchange='if(this.value*1==3){document.getElementById("e-domain").value="MED";};newNUPSExtended()'>
				<%= SH.getNUPSSectionOptions(activeUser, SH.p(request,"sectioncode"),sWebLanguage) %>
			</select>
		</td>
	</tr>
	<tr><td colspan='2'><div id='nupsdataextended'/></td></tr>
	<tr>
		<td colspan='2'>
			<input type='button' class='button' name='saveButton' value='<%=getTranNoLink("web","save",sWebLanguage) %>' onclick='checkSaveNUPS();'/>
			<input type='button' class='button' name='cancelButton' value='<%=getTranNoLink("web","cancel",sWebLanguage) %>' onclick='document.getElementById("nupsdata").innerHTML="";'/>
			<span id='nupsmessage'/>
		</td>
	</tr>
</table>