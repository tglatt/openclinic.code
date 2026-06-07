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
	if(activePatient.gender.equalsIgnoreCase("m")){
		sBarcode+="a"; //Gender
	}
	if(SH.p(request,"ITEM_TYPE_PREGNANTWOMEN.1").equals("1")){
		sBarcode+="b"; //Pregnant women
	}
	if(SH.p(request,"ITEM_TYPE_OTHERSIGNS.1").equals("1")){
		sBarcode+="c"; //Fever
	}
	Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsBetween(activePatient.getPersonId(), SH.dateAdd(encounter.getBegin(), -SH.getTimeDay()*3),encounter.getBegin());
	boolean bFever=false;
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
	if(SH.p(request,"ITEM_TYPE_OTHERSIGNS.5").equals("1")){
		sBarcode+="e"; //Vomiting
	}
	if(SH.p(request,"ITEM_TYPE_MEDICALHISTORY.1").equals("1")){
		sBarcode+="f"; //Malaria treatment in past 28 days
	}
	if(SH.p(request,"ITEM_TYPE_OTHERSIGNS.8").equals("1")){
		sBarcode+="g"; //Severe malnutrition
	}
	if(SH.p(request,"ITEM_TYPE_OTHERSIGNS.2").equals("1") ||
	   SH.p(request,"ITEM_TYPE_OTHERSIGNS.9").equals("1") ||
	   SH.p(request,"ITEM_TYPE_OTHERSIGNS.a").equals("1") ||
	   SH.p(request,"ITEM_TYPE_OTHERSIGNS.b").equals("1") ||
	   SH.p(request,"ITEM_TYPE_OTHERSIGNS.3").equals("1") ||
	   SH.p(request,"ITEM_TYPE_OTHERSIGNS.4").equals("1") ||
	   SH.p(request,"ITEM_TYPE_OTHERSIGNS.c").equals("1")
	  ){
		sBarcode+="h"; //Other signs such as such as chills, sweats, nausea, body aches, bitter taste, mild headache, fatigue
	}
	if(SH.p(request,"ITEM_TYPE_OTHERSIGNS.2").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.03").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.04").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.15").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.02").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.09").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.06").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.01").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.16").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.08").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.11").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.07").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.10").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.12").equals("1") ||
	   SH.p(request,"ITEM_TYPE_SEVERITYSIGNS.13").equals("1")
	  ){
		sBarcode+="i"; //Danger signs such as coma, dyspnea, dehydration, confusion, convulsions, oliguria/anuria, jaundice, 
					   //severe headache, prostration, bloody diarrhea, anemia, hypoglycemia (i)
	}
	String s = getLastLabresult(encounter, "70569-9",activePatient.personid);
	if(s.toUpperCase().contains("POS") || s.toUpperCase().contains("+") || SH.p(request,"ITEM_TYPE_REF_RAPIDTEST.1").equals("1")){
		sBarcode+="j";
	}
	else if(s.toUpperCase().contains("NEG") || s.toUpperCase().contains("-") ||  SH.p(request,"ITEM_TYPE_REF_RAPIDTEST.2").equals("1")){
		sBarcode+="k";
	}
	s = getLastLabresult(encounter, "32700-7",activePatient.personid);
	if(s.toUpperCase().contains("POS") || s.toUpperCase().contains("+") || SH.p(request,"ITEM_TYPE_REF_THICKSMEAR.1").equals("1")){
		sBarcode+="l";
	}
	else if(s.toUpperCase().contains("NEG") || s.toUpperCase().contains("-") || SH.p(request,"ITEM_TYPE_REF_THICKSMEAR.2").equals("1")){
		sBarcode+="m";
	}
	sBarcode+=";"+SH.p(request,"ITEM_TYPE_MALARIYAPI_REFERRALCODE"); //Referral code
%>
{
	"data":"<%=QrCodeUtil.toBase64QrCode(sBarcode,120,120) %>"
}