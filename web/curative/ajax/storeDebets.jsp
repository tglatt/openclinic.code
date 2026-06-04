<%@page import="be.openclinic.mobilemoney.MobileMoney"%>
<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String[] prestations = SH.p(request,"prestations").split("\\|");
	String wicketuid = SH.p(request,"wicketuid");
	String encounteruid = SH.p(request,"encounteruid");
	String encounterserviceuid = SH.p(request,"encounterserviceuid");
	String encountertype = SH.p(request,"encountertype");
	String encountermanager = SH.p(request,"encountermanager");
	String encounterorigin = SH.p(request,"encounterorigin");
	String reference = SH.p(request,"reference");
	String amount = SH.p(request,"amount");
	String invoiceuid = SH.p(request,"invoiceuid");
	String financialtransactionid = SH.p(request,"financialtransactionid");
	String comment = SH.p(request,"comment");
	session.setAttribute("defaultwicket",wicketuid);
	
	if(SH.p(request,"prestations").length()==0 && invoiceuid.length()>0){
		if(invoiceuid.split("\\.").length<2){
			invoiceuid=SH.getServerId()+"."+invoiceuid;
		}
		//This is an additionnal payment for an existing invoice, only store the payment
		PatientInvoice invoice = PatientInvoice.get(invoiceuid);
		WicketCredit wcredit = new WicketCredit();
		PatientCredit credit = new PatientCredit();
		credit.setAmount(Double.parseDouble(amount));
		credit.setCreateDateTime(new java.util.Date());
		credit.setCategory(SH.cs("defaultCreditCategory","1"));
		credit.setCurrency(SH.cs("currency","EUR"));
		credit.setDate(new java.util.Date());
		if(encounteruid.length()==0){
			Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
			if(activeEncounter!=null){
				encounteruid=activeEncounter.getUid();
			}
		}
		credit.setEncounterUid(encounteruid);
		credit.setPatientUid(activePatient.personid);
		credit.setType("patient.payment");
		credit.setUpdateUser(activeUser.userid);
		credit.setVersion(1);
		credit.setComment(comment);
		credit.setInvoiceUid(invoiceuid);
		credit.store();
		Vector credits = invoice.getCredits();
		credits.add(credit.getUid());
		invoice.setCredits(credits);
		invoice.setClosureDate(SH.formatDate(new java.util.Date()));
		invoice.setStatus("closed");
		invoice.setUpdateUser(activeUser.userid);
		invoice.setVersion(invoice.getVersion()+1);
		invoice.setComment(reference);
		invoice.store();
/*
		wcredit.setAmount(credit.getAmount());
		wcredit.setCategory(credit.getCategory());
		wcredit.setCreateDateTime(credit.getCreateDateTime());
		wcredit.setCurrency(credit.getCurrency());
		wcredit.setOperationDate(new Timestamp(credit.getDate().getTime()));
		wcredit.setOperationType(credit.getType());
		wcredit.setReferenceObject(new ObjectReference("PatientCredit",credit.getUid()));
		wcredit.setUpdateUser(activeUser.userid);
		wcredit.setVersion(1);
		wcredit.setWicketUID(wicketuid);
		wcredit.setComment(activePatient.lastname+" "+activePatient.firstname+" - "+invoice.getInvoiceNumber());
		wcredit.store();
		if(financialtransactionid.length()>0){
	   		MobileMoney.updateCreditOperationIds(financialtransactionid, credit.getUid(), wcredit.getUid());
		}
		*/
	}
	else {
		//Step 1: make sure there is an active encounter
		if(encounteruid.length()==0){
			//Create a new encounter
			Encounter encounter = new Encounter();
			encounter.setBegin(new java.util.Date());
			encounter.setCreateDateTime(new java.util.Date());
			encounter.setOrigin(encounterorigin);
			encounter.setPatientUID(activePatient.personid);
			encounter.setServiceUID(encounterserviceuid);
			encounter.setSituation(SH.cs("defaultEncounterSituation","1"));
			encounter.setType(encountertype);
			encounter.setManagerUID(encountermanager);
			encounter.setUpdateUser(activeUser.userid);
			encounter.setVersion(1);
			encounter.store();
			encounteruid=encounter.getUid();
		}
		//Step 2: store all debets
		Vector<Debet> debets = new Vector<Debet>();
		Insurance insurance = Insurance.getDefaultInsuranceForPatient(activePatient.personid);
		for(int n=0;n<prestations.length;n++){
			String[] components = prestations[n].split("\\~");
			if(components.length>3){
				Prestation prestation = Prestation.get(components[0]);
				if(prestation!=null){
					Debet debet = new Debet();
					debet.setPrestationUid(prestation.getUid());
					debet.setInsuranceUid(insurance.getUid());
					debet.setQuantity(Double.parseDouble(components[2]));
					if(insurance.getExtraInsurarUid().length()>0 && SH.p(request,"defaultExtraInsurar").equals("1")){
						debet.setAmount(0);
						debet.setExtraInsurarUid(insurance.getExtraInsurarUid());
						debet.setExtraInsurarAmount(debet.getQuantity()*prestation.getPatientPrice(insurance, insurance.getInsuranceCategoryLetter(),encountertype));
					}
					else{
						debet.setAmount(debet.getQuantity()*prestation.getPatientPrice(insurance, insurance.getInsuranceCategoryLetter(),encountertype));
					}
					debet.setInsurarAmount(debet.getQuantity()*prestation.getInsurarPrice(insurance, insurance.getInsuranceCategoryLetter(),encountertype));
					debet.setCreateDateTime(new java.util.Date());
					debet.setDate(new java.util.Date());
					debet.setEncounterUid(encounteruid);
					if(SH.c(prestation.getServiceUid()).length()>0){
						debet.setServiceUid(prestation.getServiceUid());
					}
					else{
						debet.setServiceUid(encounterserviceuid);
					}
					debet.setUpdateUser(activeUser.userid);
					debet.setVersion(1);
					debet.store();
					debets.add(debet);
				}
			}
		}
		//Step 3: register the payment
		Vector<String> credits = new Vector<String>();
		PatientCredit credit = new PatientCredit();
		WicketCredit wcredit = new WicketCredit();
		if(debets.size()>0){
			credit.setAmount(Double.parseDouble(amount));
			credit.setCreateDateTime(new java.util.Date());
			credit.setCategory(SH.cs("defaultCreditCategory","1"));
			credit.setCurrency(SH.cs("currency","EUR"));
			credit.setDate(new java.util.Date());
			credit.setEncounterUid(encounteruid);
			credit.setPatientUid(activePatient.personid);
			credit.setType("patient.payment");
			credit.setUpdateUser(activeUser.userid);
			credit.setVersion(1);
			credit.setComment(comment);
			credit.store();
			credits.add(credit.getUid());
		}
		//Step 4: if debets have been stored, then create invoice and create cash entry
		if(debets.size()>0){
			PatientInvoice invoice = new PatientInvoice();
			if(invoiceuid.length()>0){
				invoice.setUid(invoiceuid);
			}
			invoice.setBalance(0);
			invoice.setClosureDate(SH.formatDate(new java.util.Date()));
			invoice.setCreateDateTime(new java.util.Date());
			invoice.setCredits(credits);
			invoice.setDate(new java.util.Date());
			invoice.setDebets(debets);
			invoice.setPatientUid(activePatient.personid);
			invoice.setStatus("closed");
			invoice.setUpdateUser(activeUser.userid);
			invoice.setVersion(1);
			invoice.setComment(reference);
			invoice.store();
			invoiceuid=invoice.getUid();
			wcredit.setAmount(credit.getAmount());
			wcredit.setCategory(credit.getCategory());
			wcredit.setCreateDateTime(credit.getCreateDateTime());
			wcredit.setCurrency(credit.getCurrency());
			wcredit.setOperationDate(new Timestamp(credit.getDate().getTime()));
			wcredit.setOperationType(credit.getType());
			wcredit.setReferenceObject(new ObjectReference("PatientCredit",credit.getUid()));
			wcredit.setUpdateUser(activeUser.userid);
			wcredit.setVersion(1);
			wcredit.setWicketUID(wicketuid);
			wcredit.setComment(activePatient.lastname+" "+activePatient.firstname+" - "+invoice.getInvoiceNumber());
			wcredit.store();
		}
		//Step 5: if debets have been stored for a mobile money transaction, then update mobile money transaction
		if(debets.size()>0){
	   		MobileMoney.updateCreditOperationIds(financialtransactionid, credit.getUid(), wcredit.getUid());
		}
	}
%>
{
	"invoiceuid":"<%=invoiceuid %>"
}
