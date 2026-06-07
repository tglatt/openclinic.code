<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String s = SH.c((String)session.getAttribute(SH.p(request,"attribute")));
	if((SH.p(request,"attribute").equalsIgnoreCase("malariaProbabilityAnalysis") || SH.p(request,"attribute").equalsIgnoreCase("malariaDifferentialDiagnosis")) && SH.cs("countrycode","").equalsIgnoreCase("bi")){
		out.println(getTran(request,"web","openaiwarning.malaria",sWebLanguage)+"<p/>");
	}
	out.println(s.replaceAll("```html", "").replaceAll("```",""));
%>
