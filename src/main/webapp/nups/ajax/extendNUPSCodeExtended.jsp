<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
<%
	String code=SH.p(request,"code");
	String sectioncode=SH.p(request,"sectioncode");
	Connection conn = SH.getOpenClinicConnection();
	String sql="select * from nupsref where nups=?";
	PreparedStatement ps = conn.prepareStatement(sql);
	ps.setString(1,code);
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		if(sectioncode.length()>0 && Double.parseDouble(sectioncode)==3){
			String label=SH.c(rs.getString("fr"));
			String[] name = new String[50];
			for(int n=0;n<label.split(";")[0].split("\\|").length;n++){
				name[n]=label.split(";")[0].split("\\|")[n];
			}
			String[] dci = new String[50];
			if(label.split(";").length>1){
				for(int n=0;n<label.split(";")[1].split("\\|").length;n++){
					dci[n]=label.split(";")[1].split("\\|")[n];
				}
			}
			String presentation="";
			if(label.split(";").length>2){
				presentation=label.split(";")[2];
			}
			String[] dose = new String[50];
			if(label.split(";").length>3){
				for(int n=0;n<label.split(";")[3].split("\\|").length;n++){
					dose[n]=label.split(";")[3].split("\\|")[n];
				}
			}
			String comment="";
			if(label.split(";").length>4){
				comment=label.split(";")[4];
			}
			%>
			<tr>
				<td class='admin'>Français</td>
				<td class='admin2' colspan='3'>
					<textarea class='text' cols="120" rows="2" name="e-fr" id="e-fr"><%=SH.c(rs.getString("fr")).split(";")[0]%></textarea>
				</td>
			</tr>
			<tr>
				<td class='admin'>English</td>
				<td class='admin2' colspan='3'>
					<textarea class='text' cols="120" rows="2" name="e-en" id="e-en"><%=SH.c(rs.getString("en")).split(";")[0]%></textarea>
				</td>
			</tr>
			<tr>
				<td class='admin'>Español</td>
				<td class='admin2' colspan='3'>
					<textarea class='text' cols="120" rows="2" name="e-es" id="e-es"><%=SH.c(rs.getString("es")).split(";")[0]%></textarea>
				</td>
			</tr>
			<tr>
				<td class='admin'>Portugues</td>
				<td class='admin2' colspan='3'>
					<textarea class='text' cols="120" rows="2" name="e-pt" id="e-pt"><%=SH.c(rs.getString("pt")).split(";")[0]%></textarea>
				</td>
			</tr>
			<tr>
				<td class='admin' width='10%'><%=getTran(request,"nups","presentation",sWebLanguage)%></td>
				<td class='admin2' width='40%'>
					<input type='hidden' name='presentation' id='presentation' value='<%=presentation%>'/>
					<select style='max-width: 250px' name='presentation' id='presentation' class='text' disabled>
						<%= ScreenHelper.writeSelect(request, "nups.presentation", presentation, sWebLanguage) %>
					</select>
				</td>
				<td class='admin' width='10%'><%=getTran(request,"nups","comment",sWebLanguage)%></td>
				<td class='admin2' width='40%'>
					<textarea disabled class='text' cols="60" rows="1" name="comment" id="comment"><%=comment%></textarea>
					<input type='hidden' name="e-fr" id="e-fr" value='<%=SH.c(rs.getString("fr"))%>'/>
					<input type='hidden' name="e-en" id="e-en" value='<%=SH.c(rs.getString("en"))%>'/>
					<input type='hidden' name="e-es" id="e-es" value='<%=SH.c(rs.getString("es"))%>'/>
					<input type='hidden' name="e-pt" id="e-pt" value='<%=SH.c(rs.getString("pt"))%>'/>
				</td>
			</tr>
		<%
		}
		else{
		%>
			<tr>
				<td class='admin'>Français</td>
				<td class='admin2'>
					<textarea class='text' cols="120" rows="2" name="e-fr" id="e-fr"><%=SH.c(rs.getString("fr"))%></textarea>
					<% if(!sWebLanguage.equalsIgnoreCase("fr")){ %>
						<input class="button" type="button" value="<%=getTranNoLink("Web","translate",sWebLanguage)%>" onclick="dotranslate('fr',document.getElementById('e-<%=sWebLanguage.toLowerCase() %>').value,'e-fr');">
					<% } %>
				</td>
			</tr>
			<tr>
				<td class='admin'>English</td>
				<td class='admin2'>
					<textarea class='text' cols="120" rows="2" name="e-en" id="e-en"><%=SH.c(rs.getString("en"))%></textarea>
					<% if(!sWebLanguage.equalsIgnoreCase("en")){ %>
						<input class="button" type="button" value="<%=getTranNoLink("Web","translate",sWebLanguage)%>" onclick="dotranslate('en',document.getElementById('e-<%=sWebLanguage.toLowerCase() %>').value,'e-en');">
					<% } %>
				</td>
			</tr>
			<tr>
				<td class='admin'>Español</td>
				<td class='admin2'>
					<textarea class='text' cols="120" rows="2" name="e-es" id="e-es"><%=SH.c(rs.getString("es"))%></textarea>
					<% if(!sWebLanguage.equalsIgnoreCase("es")){ %>
						<input class="button" type="button" value="<%=getTranNoLink("Web","translate",sWebLanguage)%>" onclick="dotranslate('es',document.getElementById('e-<%=sWebLanguage.toLowerCase() %>').value,'e-es');">
					<% } %>
				</td>
			</tr>
			<tr>
				<td class='admin'>Portugues</td>
				<td class='admin2'>
					<textarea class='text' cols="120" rows="2" name="e-pt" id="e-pt"><%=SH.c(rs.getString("pt"))%></textarea>
					<% if(!sWebLanguage.equalsIgnoreCase("pt")){ %>
						<input class="button" type="button" value="<%=getTranNoLink("Web","translate",sWebLanguage)%>" onclick="dotranslate('pt',document.getElementById('e-<%=sWebLanguage.toLowerCase() %>').value,'e-pt');">
					<% } %>
				</td>
			</tr>
		<%
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>