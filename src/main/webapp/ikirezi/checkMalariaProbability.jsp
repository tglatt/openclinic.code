<%@page import="be.openclinic.medical.*"%>
<%@page import="be.openclinic.knowledge.OpenAI"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	SH.syslog("Analyzing malaria rules");
	java.util.Date start = new java.util.Date(); 
	session.setAttribute("malariaProbabilityAnalysis", "Error in processing request");
	String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + "/ikirezi/malaria.xml";
	SAXReader reader = new SAXReader(false);
	Document document = reader.read(new URL(sDoc));
	StringBuffer sInfo = new StringBuffer();
	if(document.getRootElement().element("probability_"+SH.cs("countrycode","").toLowerCase())!=null){
		sInfo.append(document.getRootElement().element("probability_"+SH.cs("countrycode","").toLowerCase()).attributeValue(sWebLanguage)+";");
	}
	else{
		sInfo.append(document.getRootElement().element("probability").attributeValue(sWebLanguage)+";");
	}
	Iterator<Element> rules = document.getRootElement().elementIterator("rule");
	while(rules.hasNext()){
		Element rule = rules.next();
		if(SH.c(rule.attributeValue("type")).equalsIgnoreCase("lab")){
			String loinc = SH.c(rule.attributeValue("loinc"));
			String value = SH.c(rule.attributeValue("value"));
			//Find latest lab result for the actual encounter
			LabAnalysis analysis = LabAnalysis.getLabAnalysisByMedidocCode(loinc);
			if(analysis!=null){
				String sDateMin=SH.formatDate(new java.util.Date(new java.util.Date().getTime()-SH.getTimeDay()*7));
				String sDateMax=SH.formatDate(SH.getTomorrow());
				Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
				if(activeEncounter!=null){
					sDateMin =SH.formatDate(activeEncounter.getBegin());
					if(activeEncounter.getEnd()!=null){
						sDateMax=SH.formatDate(activeEncounter.getEnd());
					}
				}
				Vector<RequestedLabAnalysis> labs = RequestedLabAnalysis.find("", "", activePatient.personid, analysis.getLabcode(), "", value, "", "", "", "", "", "", sDateMin, sDateMax, "", "DESC", false, "");
				for(int n=0;n<labs.size();n++){
					RequestedLabAnalysis anal = labs.elementAt(n);
					if(SH.c(anal.getResultValue()).length()>0){
						if(SH.c(rule.attributeValue("addvalue")).equalsIgnoreCase("1")){
							if(rule.attributeValue(sWebLanguage).length()>0){
								sInfo.append(rule.attributeValue(sWebLanguage)+": "+anal.getResultValue()+" "+anal.getResultComment()+";");
							}
							else{
								sInfo.append(SH.p(request,rule.attributeValue("id"))+";");
							}
						}
						else{
							sInfo.append(rule.attributeValue(sWebLanguage)+";");
						}
						n=labs.size();
					}
				}
			}
		}
		else if(SH.p(request,rule.attributeValue("id")).length()>0){
			if(SH.c(rule.attributeValue("value")).length()>0 && !SH.c(rule.attributeValue("value")).equalsIgnoreCase(SH.p(request,rule.attributeValue("id")))){
				continue;
			}
			if(SH.c(rule.attributeValue("addvalue")).equalsIgnoreCase("1")){
				if(rule.attributeValue(sWebLanguage).length()>0){
					sInfo.append(rule.attributeValue(sWebLanguage)+": "+SH.p(request,rule.attributeValue("id"))+";");
				}
				else{
					sInfo.append(SH.p(request,rule.attributeValue("id"))+";");
				}
			}
			else{
				sInfo.append(rule.attributeValue(sWebLanguage)+";");
			}
		}
	}
	int age = activePatient.getAge();
	String sa = getTranNoLink("web","years",sWebLanguage);
	if(age<5){
		age = activePatient.getAgeInMonths();
		sa = getTranNoLink("web","months",sWebLanguage);
	}
	sInfo.append(getTranNoLink("web","age",sWebLanguage)+": "+age+" "+sa+";");
	sInfo.append(getTranNoLink("web","gender",sWebLanguage)+": "+getTranNoLink("gender",activePatient.gender,sWebLanguage)+";");
	sInfo.append(document.getRootElement().element("htmlformat").attributeValue(sWebLanguage)+";");
	SH.syslog("-------------------------------");
	SH.syslog(sInfo.toString());
	SH.syslog("-------------------------------");
	String s = OpenAI.getTextResponse(sInfo.toString().replaceAll("```html", "").replaceAll("```",""));
	session.setAttribute("malariaProbabilityAnalysis", s); 
	SH.syslog("Result generated in "+(new java.util.Date().getTime()-start.getTime())/1000+" seconds");
%>
