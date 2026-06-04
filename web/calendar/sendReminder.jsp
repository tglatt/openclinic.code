<%@page import="be.openclinic.reporting.MessageNotifier"%>
<%@page import="be.openclinic.adt.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	boolean bOk=false;
	String begin=SH.p(request,"begin");
	String beginhour=SH.p(request,"beginhour");
	String beginminutes=SH.p(request,"beginminutes");
	String email=SH.p(request,"email");
	String sms=SH.p(request,"sms");
	String patientuid=SH.p(request,"patientuid");
	String sLanguage=SH.cs("patientAppointmentReminderLanguage", "fr");
	AdminPerson patient = AdminPerson.get(patientuid);
	if(patient.isNotEmpty()){
		if(patient.language.toLowerCase().startsWith("f")) {
			sLanguage="fr";
		}
		else if(patient.language.toLowerCase().startsWith("e")) {
			sLanguage="en";
		}
		String sResult = ScreenHelper.getTranNoLink("web", "patientappointmentreminder",sLanguage);
		sResult=sResult.replaceAll("#patientname#", patient.getFullName());
		sResult=sResult.replaceAll("#appointmentdate#",begin+" "+getTranNoLink("web","at",sLanguage)+" "+SH.padLeft(beginhour,"0",2)+":"+SH.padLeft(beginminutes,"0",2));
		if(email.length()>0) {
			MessageNotifier.SpoolMessage(MedwanQuery.getInstance().getOpenclinicCounter("OC_MESSAGES"), "simplemail", sResult, email, "appointmentreminder", sLanguage);
			bOk=true;
		}
		if(sms.length()>0) {
			MessageNotifier.SpoolMessage(MedwanQuery.getInstance().getOpenclinicCounter("OC_MESSAGES"), "sms", sResult, sms, "appointmentreminder", sLanguage);
			bOk=true;
		}
	}
	if(bOk){
		out.println("<OK>");
	}
%>
