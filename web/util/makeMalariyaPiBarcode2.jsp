<%@page import="be.mxs.common.util.system.QrCodeUtil"%>
<%@page import="be.openclinic.medical.*"%>
<%@page import="be.openclinic.knowledge.ClinicalAssistant"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!
	private String getLastLabresult(Encounter encounter,String loinc,String personid){
		String s="";
		String sDateMin=SH.formatDate(new java.util.Date(encounter.getBegin().getTime()-SH.getTimeDay()*7));
		String sDateMax=SH.formatDate(SH.getTomorrow());
		if(encounter==null){
			encounter = Encounter.getActiveEncounter(personid);
		}
		if(encounter!=null){
			sDateMin =SH.formatDate(encounter.getBegin());
			if(encounter.getEnd()!=null){
				sDateMax=SH.formatDate(SH.dateAdd(encounter.getEnd(),SH.getTimeDay()));
			}
		}
		LabAnalysis analysis = LabAnalysis.getLabAnalysisByMedidocCode(loinc);
		if(analysis!=null){
			Vector<RequestedLabAnalysis> labs = RequestedLabAnalysis.find("", "", personid, analysis.getLabcode(), "", "", "", "", "", "", "", "", sDateMin, sDateMax, "", "DESC", false, "");
			for(int n=0;n<labs.size();n++){
				RequestedLabAnalysis anal = labs.elementAt(n);
				if(SH.c(anal.getResultValue()).length()>0){
					s=anal.getResultValue();
					n=labs.size();
				}
			}
		}
		return s;
	}
%>
<%
	String sBarcode=activePatient.personid+";"; //Person ID
	Encounter encounter = null;
	if(SH.p(request,"encounteruid").length()>0){
		encounter = Encounter.get(SH.p(request,"encounteruid"));
	}
	else{
		if(Encounter.getActiveEncounter(activePatient.personid)!=null){
			encounter = Encounter.getActiveEncounter(activePatient.personid);
		}
		else{
			encounter=Encounter.getLastEncounter(activePatient.personid);
		}
	}
	sBarcode+=SH.cs("malariyapi.serverid","0")+"."+encounter.getUid()+";"; //Encounter ID
	sBarcode+=SH.formatDate(SH.parseDate(SH.p(request,"trandate")),"yyMMdd")+";"; //Transaction date
	sBarcode+=activePatient.getAgeInMonths()+";"; //Age in months
	Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsBetween(activePatient.getPersonId(), SH.dateAdd(encounter.getBegin(), -SH.getTimeDay()*3),encounter.getBegin());
	boolean bFever=false;
	String referralcode="";
	for(int n=0;n<transactions.size() && !bFever;n++) {
		TransactionVO transaction = transactions.elementAt(n);
		if(ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE")) bFever=true;
		if(ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_TEMPERATURE")) bFever=true;
		if(ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNRKR_BIOMETRY_TEMPERATURE"))bFever=true;
		if(ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MALARIA_TEMPERATURE")) bFever=true;
		if(ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TEMPERATURE")) bFever=true;
		if(ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CPN_TEMPERATURE")) bFever=true;
		if(ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CPON_TEMPERATURE"))bFever=true;
		if(ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ADMISSION_FORM_EXAMINATION_TEMPERATURE")) bFever=true;
	}
	if(bFever){
		sBarcode+="d"; //Fever in past 3 days
	}
	if(activePatient.gender.equalsIgnoreCase("m")){
		sBarcode+="a"; //Gender
	}
	String s = getLastLabresult(encounter, "70569-9",activePatient.personid);
	if(s.toUpperCase().contains("POS") || s.toUpperCase().contains("+")){
		sBarcode+="j"; //Rapid test positive	
	}
	else if(s.toUpperCase().contains("NEG") || s.toUpperCase().contains("-")){
		sBarcode+="k"; //Rapid test negative	
	}
	s = getLastLabresult(encounter, "32700-7",activePatient.personid);
	if(s.toUpperCase().contains("POS") || s.toUpperCase().contains("+")){
		sBarcode+="l"; //Thick smear positive	
	}
	else if(s.toUpperCase().contains("NEG") || s.toUpperCase().contains("-")){
		sBarcode+="m"; //Thick smear negative	
	}
	transactions = MedwanQuery.getInstance().getTransactionsByEncounter(activePatient.getPersonId(), encounter.getUid());
	for(int n=0;n<transactions.size();n++) {
		TransactionVO transaction = transactions.elementAt(n);
		if(!sBarcode.contains("j") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REF_RAPIDTEST").contains("1;")){
			sBarcode+="j"; //Rapid test positive	
		}
		if(referralcode.length()==0 && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MALARIYAPI_REFERRALCODE").length()>0){
			referralcode=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MALARIYAPI_REFERRALCODE"); //Referral code
		}
		if(!sBarcode.contains("j") && !sBarcode.contains("k") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REF_RAPIDTEST").contains("2;")){
			sBarcode+="k"; //Rapid test negative	
		}
		if(!sBarcode.contains("l") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REF_THICKSMEAR").contains("1;")){
			sBarcode+="l"; //Thick smear positive	
		}
		if(!sBarcode.contains("l") && !sBarcode.contains("m") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REF_THICKSMEAR").contains("2;")){
			sBarcode+="m"; //Thick smear negative	
		}
		if(!sBarcode.contains("b") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PREGNANTWOMEN").contains("1;")){
			sBarcode+="b"; //Pregnant women	
		}
		if(!sBarcode.contains("c") && (transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("1;") || ClinicalAssistant.isFever(transaction,"be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE"))){
			sBarcode+="c"; //Fever	
		}
		if(!sBarcode.contains("e") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("5;")){
			sBarcode+="e"; //Vomiting	
		}
		if(!sBarcode.contains("f") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MEDICALHISTORY").contains("1;")){
			sBarcode+="f"; //Malaria treatment in past 28 days
		}
		if(!sBarcode.contains("g") && transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("8;")){
			sBarcode+="g"; //Severe malnutrition
		}
		if(!sBarcode.contains("h") && (transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("2;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("9;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("a;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("b;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("3;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("4;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("c;"))
				){
			sBarcode+="h"; //Other signs such as such as chills, sweats, nausea, body aches, bitter taste, mild headache, fatigue
		}
		if(!sBarcode.contains("i") && (transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSIGNS").contains("1;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("03;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("04;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("15;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("02;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("09;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("01;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("16;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("08;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("11;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("07;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("10;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("12;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("13;") ||
				transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEVERITYSIGNS").contains("06;"))
				){
			sBarcode+="i"; //Danger signs such as coma, dyspnea, dehydration, confusion, convulsions, oliguria/anuria, jaundice, 
			   //severe headache, prostration, bloody diarrhea, anemia, hypoglycemia (i)
		}
	}
	sBarcode+=";"+referralcode;
%>
{
	"data":"<%=QrCodeUtil.toBase64QrCode(sBarcode,120,120) %>"
}