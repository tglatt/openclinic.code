<%@page import="java.util.Vector"%>
<%@page import="be.openclinic.openimis.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	if(!GraphQL.isOpenIMISReachable()){
		%>
		<br/>
		<img height='20px' src='<%=sCONTEXTPATH%>/_img/icons/icon_blinkwarning.gif'/>
		<font style='color: red;font-size: 12px'><%=getTran(request,"openimis","unreachable",sWebLanguage) %></font>
		<%
	}
	else{
		String natreg = SH.p(request,"natreg");
		GraphQLInsuree insuree = GraphQLInsuree.get(natreg);
		if(insuree==null){
			%>
			<br/>
			<img height='16px' src='<%=sCONTEXTPATH%>/_img/icons/icon_erase.gif'/>
			<font style='color: red;font-size: 12px'><%=getTran(request,"openimis","patientnotfound",sWebLanguage) %></font>
			<%
		}
		else{
			%>
			<br/>
			<table width='100%'>
				<tr class='admin'>
					<td colspan='4'><%=getTran(request,"web","openimisrecord",sWebLanguage) %></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","validfrom",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.formatDate(insuree.getValidityFrom()) %></b></td>
					<td class='admin'><%=getTran(request,"web","validto",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.formatDate(insuree.getValidityTo()) %></b></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","id",sWebLanguage) %></td>
					<td class='admin2'><b><%=insuree.getId() %></b></td>
					<td class='admin'><%=getTran(request,"web","uuid",sWebLanguage) %></td>
					<td class='admin2'><b><%=insuree.getUuid() %></b></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","lastname",sWebLanguage) %></td>
					<td class='admin2'><b><%=insuree.getLastName().toUpperCase() %></b></td>
					<td class='admin'><%=getTran(request,"web","othernames",sWebLanguage) %></td>
					<td class='admin2'><b><%=insuree.getOtherNames() %></b></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","dateofbirth",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.formatDate(insuree.getDob()) %></b></td>
					<td class='admin'><%=getTran(request,"web","gender",sWebLanguage) %></td>
					<td class='admin2'><b><%=getTran(request,"gender",insuree.getGender(),sWebLanguage) %></b></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","headoffamily",sWebLanguage) %></td>
					<td class='admin2'><b><%=insuree.isHead()?getTran(request,"web","yes",sWebLanguage):getTran(request,"web","no",sWebLanguage) %></b></td>
					<td class='admin'><%=getTran(request,"web","maritalstatus",sWebLanguage) %></td>
					<td class='admin2'><b><%=getTran(request,"maritalstatus",insuree.getMarital(),sWebLanguage) %></b></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","telephone",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.c(insuree.getPhone()) %></b></td>
					<td class='admin'><%=getTran(request,"web","email",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.c(insuree.getEmail()) %></b></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","country",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.c(insuree.getCountry()) %></b></td>
					<td class='admin'><%=getTran(request,"web","country.department",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.c(insuree.getLga()) %></b></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","country.town",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.c(insuree.getDistrict()) %></b></td>
					<td class='admin'><%=getTran(request,"web","village",sWebLanguage) %></td>
					<td class='admin2'><b><%=SH.c(insuree.getVillage()) %></b></td>
				</tr>
				<tr>
					<td class='admin'><%=getTran(request,"web","profession",sWebLanguage) %></td>
					<td class='admin2' colspan='3'><b><%=SH.c(insuree.getProfession()) %></b></td>
				</tr>
				<tr class='admin'>
					<td colspan='4'><%=getTran(request,"web","insurancepolicies",sWebLanguage) %></td>
				</tr>
				<% 
					HashSet<String> pols = new HashSet();
					for(int n=0;n<insuree.getInsureePolicies().size();n++){
						GraphQLInsureePolicy policy = insuree.getInsureePolicies().elementAt(n);
						if(pols.contains(policy.getUuid())){
							continue;
						}
						pols.add(policy.getUuid());
						if(n>0){
					%>
						<tr><td colspan='4'><hr/></td>
					<%
					   }
					%>
						<tr>
							<td style='background-color: black;color: white;font-weight: bolder;height: 30px' colspan='4'><%=policy.getProductCode()+" - "+policy.getProductName() %></td>
						</tr>
						<tr>
							<td class='admin'><%=getTran(request,"web","id",sWebLanguage) %></td>
							<td class='admin2'><b><%=policy.getId() %></b></td>
							<td class='admin'><%=getTran(request,"web","uuid",sWebLanguage) %></td>
							<td class='admin2'><b><%=policy.getUuid() %></b></td>
						</tr>
						<tr>
							<td class='admin'><%=getTran(request,"web","startdate",sWebLanguage) %></td>
							<td class='admin2'><b><%=SH.formatDate(policy.getStartDate()) %></b></td>
							<td class='admin'><%=getTran(request,"web","expirydate",sWebLanguage) %></td>
							<td class='admin2'><b><%=SH.formatDate(policy.getExpiryDate()) %></b></td>
						</tr>
						<tr>
							<td class='admin'><%=getTran(request,"openimis","status",sWebLanguage) %></td>
							<td class='admin2'><b><%=getTran(request,"openimis.status",policy.getStatus()+"",sWebLanguage) %></b></td>
							<td class='admin'><%=getTran(request,"web","stage",sWebLanguage) %></td>
							<td class='admin2'><b><%=getTran(request,"openimis.stage",policy.getStage(),sWebLanguage) %></b></td>
						</tr>
						<tr>
							<td class='admin'><%=getTran(request,"web","officer",sWebLanguage) %></td>
							<td class='admin2' colspan='3'><b><%=SH.c(policy.getOfficerCode())+" - "+SH.c(policy.getOfficerLastName()).toUpperCase()+" "+SH.c(policy.getOfficerOtherNames()) %></b></td>
						</tr>
				<% } %>
			</table>
			<br/><center><input type='button' class='button' value='<%=getTranNoLink("web","loadopenimisrecord",sWebLanguage)%>' onclick='importOpenIMISInsuree("<%=natreg%>")'/></center>
			<%
		}
	}
%>