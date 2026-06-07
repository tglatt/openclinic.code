<%@page import="be.openclinic.finance.*"%>
<%@page import="javax.json.*"%>
<%@page import="be.openclinic.openimis.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@page import="com.fasterxml.jackson.databind.ObjectMapper"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String uuid=SH.p(request,"insurancenr");
	Insurance insurance = Insurance.get(SH.p(request,"insuranceuid"));
	GraphQLInsuree insuree = GraphQLInsuree.get(activePatient.getID("natreg"));
	if(insuree!=null && request.getParameter("copyFromOpenIMIS")!=null){
		activePatient.lastname = insuree.getLastName();
		activePatient.firstname = insuree.getOtherNames();
		activePatient.dateOfBirth = SH.formatDate(insuree.getDob());
		activePatient.gender = insuree.getGender();
		activePatient.getActivePrivate().telephone = insuree.getPhone();
		activePatient.getActivePrivate().email = insuree.getEmail();
		activePatient.getActivePrivate().province=insuree.getRegion();
		activePatient.getActivePrivate().sector=insuree.getLga();
		activePatient.getActivePrivate().district=insuree.getDistrict();
		activePatient.getActivePrivate().city=insuree.getVillage();
		activePatient.store();
		GraphQLInsureePolicy policy = insuree.getPolicy(uuid);
		insurance.setPatientUID(activePatient.personid);
		insurance.setUpdateUser(activeUser.userid);
		insurance.setStart(policy.getStartDate());
		insurance.setStop(policy.getExpiryDate());
		insurance.setInsuranceNr(policy.getUuid());
		insurance.setInsurarUid(SH.cs("OpenIMISDefaultInsurerUID",""));
		if(insuree.isHead()){
			insurance.setFamilycode("0");
		}
		String sLetter=getTranNoLink("openimis.coverageplan",policy.getProductCode(),"en");
		if(sLetter.equalsIgnoreCase(policy.getProductCode())){
			sLetter=SH.cs("OpenIMISDefaultCategoryLetter","A");
		}
		insurance.setInsuranceCategoryLetter(sLetter);
		if(insurance.getStop()==null || insurance.getStop().after(new java.util.Date())){
			insurance.setDefaultInsurance(1);
		}
		insurance.setComment(policy.getProductName()+"\n["+policy.getOfficerCode()+"] "+policy.getOfficerLastName()+", "+policy.getOfficerOtherNames());
		if(insurance.getInsurar()!=null){
			insurance.setType(insurance.getInsurar().getType());
		}
		insurance.store();	
		%>
		<script>window.opener.location.reload();window.close();</script>
		<%
	}
%>
<form name='transactionForm' method='post'>
	<table width='100%'>
	<%
	if(insuree!=null){
		boolean bDifferent=false;
		String sClass="";
		%>
		<tr class='admin'>
			<td><%=getTran(request,"web","ID",sWebLanguage)+": "+uuid %></td>
			<td>OpenClinic GA</td>
			<td>OpenIMIS</td>
		</tr>
		<tr>
			<%
				if(SH.c(insuree.getLastName()).length()==0 || activePatient.lastname.equalsIgnoreCase(insuree.getLastName())){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","lastname",sWebLanguage) %></td>
			<td class='admin2'><%=activePatient.lastname.toUpperCase() %></td>
			<td class='<%=sClass%>'><%=insuree.getLastName().toUpperCase() %></td>
		</tr>
		<tr>
			<%
				if(SH.c(insuree.getOtherNames()).length()==0 || activePatient.firstname.equalsIgnoreCase(insuree.getOtherNames())){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","firstname",sWebLanguage) %></td>
			<td class='admin2'><%=activePatient.firstname.toUpperCase() %></td>
			<td class='<%=sClass%>'><%=insuree.getOtherNames().toUpperCase() %></td>
		</tr>
		<tr>
			<%
				if(insuree.getDob()==null || activePatient.dateOfBirth.equalsIgnoreCase(SH.formatDate(insuree.getDob()))){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","dateofbirth",sWebLanguage) %></td>
			<td class='admin2'><%=activePatient.dateOfBirth %></td>
			<td class='<%=sClass%>'><%=SH.formatDate(insuree.getDob()) %></td>
		</tr>
		<tr>
			<%
				if(SH.c(insuree.getGender()).length()==0 || activePatient.gender.equalsIgnoreCase(insuree.getGender())){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","gender",sWebLanguage) %></td>
			<td class='admin2'><%=getTran(request,"gender",activePatient.gender,sWebLanguage) %></td>
			<td class='<%=sClass%>'><%=getTran(request,"gender",insuree.getGender(),sWebLanguage) %></td>
		</tr>
		<tr>
			<%
				if(SH.c(insuree.getPhone()).length()==0 || activePatient.getActivePrivate().telephone.equalsIgnoreCase(insuree.getPhone())){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","telephone",sWebLanguage) %></td>
			<td class='admin2'><%=activePatient.getActivePrivate().telephone %></td>
			<td class='<%=sClass%>'><%=insuree.getPhone() %></td>
		</tr>
		<tr>
			<%
				if(SH.c(insuree.getEmail()).length()==0 || activePatient.getActivePrivate().email.equalsIgnoreCase(insuree.getEmail())){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","email",sWebLanguage) %></td>
			<td class='admin2'><%=activePatient.getActivePrivate().email %></td>
			<td class='<%=sClass%>'><%=insuree.getEmail() %></td>
		</tr>
		<%
			GraphQLInsureePolicy policy = insuree.getPolicy(uuid);
		%>
		<tr>
			<%
				if(policy.getStartDate()==null || SH.formatDate(insurance.getStart()).equals(SH.formatDate(policy.getStartDate()))){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","startdate",sWebLanguage) %></td>
			<td class='admin2'><%=SH.formatDate(insurance.getStart()) %></td>
			<td class='<%=sClass%>'><%=SH.formatDate(policy.getStartDate()) %></td>
		</tr>
		<tr>
			<%
				if(insurance.getStop()==null || SH.formatDate(insurance.getStop()).equals(SH.formatDate(policy.getExpiryDate()))){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","expirydate",sWebLanguage) %></td>
			<td class='admin2'><%=SH.formatDate(insurance.getStop()) %></td>
			<td class='<%=sClass%>'><%=SH.formatDate(policy.getExpiryDate()) %></td>
		</tr>
		<tr>
			<%
				String policycomment=policy.getProductName()+"\n["+policy.getOfficerCode()+"] "+policy.getOfficerLastName()+", "+policy.getOfficerOtherNames();
				if(insurance.getComment().toString().equalsIgnoreCase(policycomment)){
					sClass="admin2";
				}
				else{
					sClass="adminred";
					bDifferent=true;
				}
			%>
			<td class='admin'><%=getTran(request,"web","email",sWebLanguage) %></td>
			<td class='admin2'><%=insurance.getComment() %></td>
			<td class='<%=sClass%>'><%=policycomment %></td>
		</tr>
		<%	if(bDifferent){ %>
				<tr>
					<td colspan='2'/>
					<td><input type='submit' name='copyFromOpenIMIS' value='<<< <%=getTranNoLink("web","copy",sWebLanguage)%>'></td>
				</tr>
		<%	}
	}
	else{
		%>
			<tr ><td colspan='3' style='font-size:12px;text-align: center'><br/><br/><br/><br/><img height='24px' src='<%=sCONTEXTPATH%>/_img/icons/icon_blinkwarning.gif'/> <%=getTran(request,"openimis","patientnotfound",sWebLanguage) %></td></tr>
		<%
	}
%>	
		
	</table>
</form>
