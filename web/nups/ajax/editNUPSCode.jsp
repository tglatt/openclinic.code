<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
<%
	SH.syslog("editing");
	String code=SH.p(request,"code");
	Connection conn = SH.getOpenClinicConnection();
	String sql="select r.*,(select "+sWebLanguage+" from nupsref where nups=?) baselabel from nupsref r where nups=?";
	PreparedStatement ps = conn.prepareStatement(sql);
	ps.setString(1,code.split("\\.")[0]);
	ps.setString(2,code);
	ResultSet rs = ps.executeQuery();
	String disabled="";
	if(code.split("\\.").length>1){
		disabled=" disabled ";		
	}
	if(rs.next()){
		%>
			<tr class='admin'><td colspan='2'><%=getTran(request,"nups","code",sWebLanguage) %></td></tr>
			<tr>
				<td class='admin'>MUID</td>
				<td class='admin2'>
					<b><%=rs.getInt("muid") %></b>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","uhc",sWebLanguage)%></td>
				<td class='admin2'>
					<input class='text' type='checkbox' name="e-csu" id="e-csu" value="true" <%=SH.c(rs.getString("csu")).equalsIgnoreCase("true")?"checked":"" %>/>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","code",sWebLanguage) %></td>
				<td class='admin2'>
					<input class='greytext' style='font-weight: bolder' type='text' size="10" readonly name="e-code" id="e-code" value="<%=SH.c(rs.getString("nups")).split("\\.")[0]%>"/>
					<%=SH.c(rs.getString("nups")).length()>0?"&nbsp;"+SH.c(rs.getString("baselabel")).split(";")[0]:"" %>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","suffix",sWebLanguage) %></td>
				<td class='admin2'>
					<input class='greytext' style='font-weight: bolder' type='text' size="10" readonly name="e-extension" id="e-extension" value="<%=SH.c(rs.getString("nups")).split("\\.").length<2?"":SH.c(rs.getString("nups")).split("\\.")[1]%>"/>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","parentcode",sWebLanguage)%></td>
				<td class='admin2'>
					<input class='text' <%=disabled.length()>0?"readonly":"" %> type='text' size="10" name="e-parent" id="e-parent" value="<%=SH.c(rs.getString("parent"))%>" onkeyup="getNomenclatureLabel();"/>
					<%if(disabled.length()==0){ %>
						<input type='button' class='button' name='nomenclatureButton' value='<%=getTranNoLink("web","search",sWebLanguage) %>' onclick='searchParentCode()'/>
					<%} %>
                    &nbsp;&nbsp;&nbsp;<span style='color: darkblue;font-style: italic;font-size: 11px' id='nomenclatureText'/>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","originalcode",sWebLanguage)%></td>
				<td class='admin2'>
					<input class='text' type='text' <%=disabled.length()>0?"readonly":"" %> size="10" name="e-originalcode" id="e-originalcode" value="<%=SH.c(rs.getString("originalcode"))%>"/>
					<input type='button' class='button' name='checkButton' value='<%=getTranNoLink("web","validate",sWebLanguage) %>' onclick='checkOriginalCode()'/>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","domain",sWebLanguage)%></td>
				<td class='admin2'>
					<select class='text' <%=disabled%> name='e-domain' id='e-domain'>
						<%= SH.getNUPSDomainOptions(activeUser, rs.getString("domain")) %>
					</select>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","section",sWebLanguage)%></td>
				<td class='admin2'>
				<select class='text' name='e-sectioncode' id='e-sectioncode' onchange='if(this.value*1==3){document.getElementById("e-domain").value="MED";};editNUPSExtended(document.getElementById("e-code").value)'>
					<%= SH.getNUPSSectionOptions(activeUser, SH.c(rs.getString("sectioncode")),sWebLanguage) %>
				</select>
				</td>
			</tr>
			<tr><td colspan='2'><div id='nupsdataextended'/></td></tr>
			<tr>
				<td colspan='2'>
					<%if(activeUser.getAccessRight("nups.manage.edit")||code.split("\\.").length>1){ %>
						<input type='button' class='button' name='saveButton' value='<%=getTranNoLink("web","save",sWebLanguage) %>' onclick='checkSaveNUPS();'/>
					<%} %>
					<input type='button' class='button' name='cancelButton' value='<%=getTranNoLink("web","cancel",sWebLanguage) %>' onclick='searchNUPS();'/>
					<%if(activeUser.getAccessRight("nups.manage.delete")||code.split("\\.").length>1){ %>
						<input type='button' class='button' name='deleteButton' value='<%=getTranNoLink("web","delete",sWebLanguage) %>' onclick='deleteNUPS();'/>
					<%} %>
					<span id='nupsmessage'/>
				</td>
			</tr>
		<%
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>