<%@page import="be.openclinic.medical.*"%>
<%@page import="be.openclinic.knowledge.OpenAI"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	SH.syslog("Analyzing ICD10");
	java.util.Date start = new java.util.Date(); 
	session.setAttribute("checkICD10code", "Error in processing request");
	StringBuffer sInfo=new StringBuffer();
	sInfo.append("Quels sont les codes CIM10 compatibles avec: "+request.getParameter("keywords")+" ; Formattez le résultat en HTML;Remplacez les caractères unicode au delà de 125 par leur code HTML escape;");
	String s = OpenAI.getTextResponse(sInfo.toString().replaceAll("```html", "").replaceAll("```",""));
	session.setAttribute("checkICD10code", s); 
	SH.syslog("Result generated in "+(new java.util.Date().getTime()-start.getTime())/1000+" seconds");
%>
