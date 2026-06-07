<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
<%
	SH.syslog("extending");
	String code=SH.p(request,"code");
	Connection conn = SH.getOpenClinicConnection();
	String sql="select * from nupsref where nups=?";
	PreparedStatement ps = conn.prepareStatement(sql);
	ps.setString(1,code);
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		%>
			<tr class='admin'><td colspan='2'><%=getTran(request,"nups","code",sWebLanguage) %></td></tr>
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
					<%=SH.c(rs.getString("nups")).length()>0?"&nbsp;"+SH.c(rs.getString(sWebLanguage)).split(";")[0]:"" %>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","suffix",sWebLanguage) %></td>
				<td class='admin2'>
					<%
						int newExtension = 0;
						sql = "select * from nupsref where nups like '"+code.split("\\.")[0]+".%'";
						PreparedStatement ps2 = conn.prepareStatement(sql);
						ResultSet rs2 = ps2.executeQuery();
						while(rs2.next()){
							try{
								int i = Integer.parseInt(rs2.getString("nups").split("\\.")[1]);
								if(i>newExtension){
									newExtension=i;
								}
							}
							catch(Exception e){
								e.printStackTrace();
							}
						}
						rs2.close();
						ps2.close();
						newExtension++;
					%>
					<input class='greytext' style='font-weight: bolder' type='text' size="10" readonly name="e-extension" id="e-extension" value="<%=newExtension%>"/>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","parentcode",sWebLanguage)%></td>
				<td class='admin2'>
					<input class='text' type='text' size="10" name="e-parent" id="e-parent" value="<%=SH.c(rs.getString("parent"))%>" onkeyup="getNomenclatureLabel();"/>
					<input type='button' class='button' name='nomenclatureButton' value='<%=getTranNoLink("web","search",sWebLanguage) %>' onclick='searchParentCode()'/>
                    &nbsp;&nbsp;&nbsp;<span style='color: darkblue;font-style: italic;font-size: 11px' id='nomenclatureText'/>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","originalcode",sWebLanguage)%></td>
				<td class='admin2'>
					<input class='text' type='text' size="10" name="e-originalcode" id="e-originalcode" value="<%=SH.c(rs.getString("originalcode"))%>"/>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","domain",sWebLanguage)%></td>
				<td class='admin2'>
					<input type='hidden' name='e-domain' id='e-domain' value='<%=SH.c(rs.getString("domain")) %>'/>
					<select class='text' disabled>
						<%= SH.getNUPSDomainOptions(activeUser, rs.getString("domain")) %>
					</select>
				</td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"nups","section",sWebLanguage)%></td>
				<td class='admin2'>
					<input type='hidden' name='e-sectioncode' id='e-sectioncode' value='<%=SH.c(rs.getString("sectioncode")) %>'/>
					<select class='text'  disabled>
						<%= SH.getNUPSSectionOptions(activeUser, SH.c(rs.getString("sectioncode")),sWebLanguage) %>
					</select>
				</td>
			</tr>
			<tr><td colspan='2'><div id='nupsdataextended'/></td></tr>
			<tr>
				<td colspan='2'>
					<input type='button' class='button' name='saveButton' value='<%=getTranNoLink("web","save",sWebLanguage) %>' onclick='checkSaveNUPS();'/>
					<input type='button' class='button' name='cancelButton' value='<%=getTranNoLink("web","cancel",sWebLanguage) %>' onclick='searchNUPS();'/>
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