<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	SH.syslog("newextended");
	String sectioncode=SH.p(request,"sectioncode");
	SH.syslog("section="+sectioncode);
	if(sectioncode.length()>0 && Double.parseDouble(sectioncode)==3){
		%>
		<table width='100%'>
			<tr><td colspan='4'><table width='100%' id='dcitable'>
			<tr>
				<td class='admin' width='10%'><%=getTran(request,"nups","icd",sWebLanguage)%> 1</td>
				<td class='admin2' width='40%'>
					<input type='text' class='text' size="50" name="dci1" id="dci1" value=""/>
				</td>
				<td class='admin' width='10%'><%=getTran(request,"nups","dose",sWebLanguage)%> 1</td>
				<td class='admin2' width='40%'>
					<input type='text' class='text' size="10" name="dose1" id="dose1" value=""/>
				</td>
			</tr>
		</table>
		<table width='100%'>
			<tr><td colspan='4'><center><img style='vertical-align: middle' height='14px' src='<%=sCONTEXTPATH %>/_img/icons/mobile/plus.png' onclick='addDCI()'/></center></td></tr>
			<tr>
				<td class='admin' width='10%'><%=getTran(request,"nups","presentation",sWebLanguage)%></td>
				<td class='admin2' width='40%'>
					<select style='max-width: 250px' name='presentation' id='presentation' class='text'>
						<option/>
						<%= ScreenHelper.writeSelect(request, "nups.presentation", "", sWebLanguage) %>
					</select>
				</td>
				<td class='admin' width='10%'><%=getTran(request,"nups","comment",sWebLanguage)%></td>
				<td class='admin2' width='40%'>
					<textarea class='text' cols="60" rows="1" name="comment" id="comment"></textarea>
					<input type='hidden' name="e-fr" id="e-fr" value=''/>
					<input type='hidden' name="e-en" id="e-en" value=''/>
					<input type='hidden' name="e-es" id="e-es" value=''/>
					<input type='hidden' name="e-pt" id="e-pt" value=''/>
					<input type='hidden' id='dosetlabels' value='1'/>
				</td>
			</tr>
		</table>
		<%
	}
	else{
		%>
		<table width='100%'>
			<tr>
				<td class='admin'>Français</td>
				<td class='admin2' colspan='3'>
					<textarea class='text' cols="120" rows="2" name="e-fr" id="e-fr"></textarea>
					<% if(!sWebLanguage.equalsIgnoreCase("fr")){ %>
						<input class="button" type="button" value="<%=getTranNoLink("Web","translate",sWebLanguage)%>" onclick="dotranslate('fr',document.getElementById('e-<%=sWebLanguage.toLowerCase() %>').value,'e-fr');">
					<% } %>
				</td>
			</tr>
			<tr>
				<td class='admin'>English</td>
				<td class='admin2' colspan='3'>
					<textarea class='text' cols="120" rows="2" name="e-en" id="e-en"></textarea>
					<% if(!sWebLanguage.equalsIgnoreCase("en")){ %>
						<input class="button" type="button" value="<%=getTranNoLink("Web","translate",sWebLanguage)%>" onclick="dotranslate('en',document.getElementById('e-<%=sWebLanguage.toLowerCase() %>').value,'e-en');">
					<% } %>
				</td>
			</tr>
			<tr>
				<td class='admin'>Español</td>
				<td class='admin2' colspan='3'>
					<textarea class='text' cols="120" rows="2" name="e-es" id="e-es"></textarea>
					<% if(!sWebLanguage.equalsIgnoreCase("es")){ %>
						<input class="button" type="button" value="<%=getTranNoLink("Web","translate",sWebLanguage)%>" onclick="dotranslate('es',document.getElementById('e-<%=sWebLanguage.toLowerCase() %>').value,'e-es');">
					<% } %>
				</td>
			</tr>
			<tr>
				<td class='admin'>Portugues</td>
				<td class='admin2' colspan='3'>
					<textarea class='text' cols="120" rows="2" name="e-pt" id="e-pt"></textarea>
					<% if(!sWebLanguage.equalsIgnoreCase("pt")){ %>
						<input class="button" type="button" value="<%=getTranNoLink("Web","translate",sWebLanguage)%>" onclick="dotranslate('pt',document.getElementById('e-<%=sWebLanguage.toLowerCase() %>').value,'e-pt');">
					<% } %>
				</td>
			</tr>
		</table>
	<%
	}
	%>