<%@page import="com.pixelmed.dicom.PersonIdentification"%>
<%@page import="be.openclinic.finance.Insurance"%>
<%@page import="java.util.Vector"%>
<%@page import="be.openclinic.openimis.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
String natreg = SH.p(request,"natreg");
String personid="";
try{
	GraphQLInsuree insuree = GraphQLInsuree.get(natreg);
	if(insuree!=null){
		AdminPerson person = new AdminPerson();
		personid = AdminPerson.getPersonIdByNatReg(natreg);
		if(personid!=null){
			person = AdminPerson.get(personid);
		}
		System.out.println("personid="+person.personid);
		person.adminextends.put("openimis.id",insuree.getId());
		person.adminextends.put("openimis.uuid",insuree.getUuid());
		if(insuree.getValidityFrom()!=null){
			person.begin=SH.formatDate(insuree.getValidityFrom());
		}
		if(insuree.getValidityTo()!=null){
			person.end=SH.formatDate(insuree.getValidityTo());
		}
		person.lastname=insuree.getLastName().toUpperCase();
		person.firstname=insuree.getOtherNames().toUpperCase();
		person.gender=insuree.getGender();
		if(insuree.getDob()!=null){
			person.dateOfBirth=SH.formatDate(insuree.getDob());
		}
		person.comment2=insuree.getMarital();
		person.comment3=insuree.isHead()?"1":"0";
		person.updateuserid=activeUser.userid;
		person.setID("natreg", natreg);
		person.sourceid="4";
		
		AdminPrivateContact apc = new AdminPrivateContact();
		if(person.privateContacts.size()>0){
			apc=(AdminPrivateContact)(person.privateContacts.elementAt(0));
		}
		else{
			person.privateContacts.add(apc);	
		}
		apc.telephone=insuree.getPhone();
		apc.email=insuree.getEmail();
		apc.businessfunction=insuree.getProfession();
		if(SH.cs("countrycode","GM").equalsIgnoreCase("NE")){
			apc.address=insuree.getVillage();
			apc.district=insuree.getLga();
			apc.city=insuree.getDistrict();
			apc.sector=insuree.getDistrict();
			Connection conn = SH.getAdminConnection();
			PreparedStatement ps = conn.prepareStatement("select * from nigerzipcodes where district=? and city=?");
			ps.setString(1,apc.district);
			ps.setString(2,apc.city);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				apc.sanitarydistrict=rs.getString("region");
				apc.zipcode=rs.getString("zipcode");
				apc.country="NE";
			}
			rs.close();
			ps.close();
			conn.close();
		}
		else{
			apc.province=insuree.getRegion();
			apc.sector=insuree.getLga();
			apc.district=insuree.getDistrict();
			apc.city=insuree.getVillage();
		}
		
		person.store();
		personid=person.personid;
		//Now add/update the insurance policies
		boolean bDefaultSet = false;
		HashSet<String> pols = new HashSet();
		for(int n=0;n<insuree.getInsureePolicies().size();n++){
			GraphQLInsureePolicy policy = insuree.getInsureePolicies().get(n);
			if(pols.contains(policy.getUuid())){
				continue;
			}
			pols.add(policy.getUuid());
			Insurance insurance = new Insurance();
			Vector insurances = Insurance.findInsurances("", "", "", policy.getUuid());
			for(int i=0;i<insurances.size();i++){
				Insurance ins = (Insurance)insurances.elementAt(i);
				if(ins.getPatientUID().equalsIgnoreCase(SH.c(person.personid))){
					insurance = ins;
					break;
				}
			}
			insurance.setUpdateUser(activeUser.userid);
			insurance.setPatientUID(person.personid);
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
			if(!bDefaultSet && (insurance.getStop()==null || insurance.getStop().after(new java.util.Date()))){
				insurance.setDefaultInsurance(1);
				bDefaultSet=true;
			}
			else{
				insurance.setDefaultInsurance(0);
			}
			insurance.setComment(SH.c(policy.getProductName())+"\n["+SH.c(policy.getOfficerCode())+"] "+SH.c(policy.getOfficerLastName()).toUpperCase()+", "+SH.c(policy.getOfficerOtherNames()));
			if(insurance.getInsurar()!=null){
				insurance.setType(insurance.getInsurar().getType());
			}
			insurance.store();
		}
	}
}
catch(Exception e){
	e.printStackTrace();
}
%>
{"personid":"<%=personid %>"}