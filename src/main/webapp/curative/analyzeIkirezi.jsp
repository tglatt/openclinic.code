<%@page import="javax.xml.crypto.dsig.spec.C14NMethodParameterSpec"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	boolean checkDisease(Hashtable<String,Integer> ikireziSymptoms, String diseaseSymptoms, int needed){
		int matches = 0;
		Enumeration<String> e = ikireziSymptoms.keys();
		while(e.hasMoreElements()){
			String key = e.nextElement();
			if(ikireziSymptoms.get(key)==1 && diseaseSymptoms.contains("*"+key+"*")){
				matches++;
			}
		}
		return matches>=needed;
	}
%>
<%
	String message="<empty/>";
	Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
	if(encounter!=null){
		Hashtable<String,Integer> symptoms = encounter.getIkireziSymptoms();
		//Mpox
		if(checkDisease(symptoms, "*1*3*12*13*16*17*26*54*63*69*86*91*103*114*169*455*456*475*485*513*527*534*", 2)){
			if(!SH.c((String)session.getAttribute("mpoxcheck")).equalsIgnoreCase(encounter.getUid())){
				Vector<TransactionVO> mpoxTrans=MedwanQuery.getInstance().getTransactionsByEncounter(Integer.parseInt(activePatient.personid), encounter.getUid());
				boolean bMpoxExplored=false;
				for(int n=0;n<mpoxTrans.size();n++){
					TransactionVO tran = mpoxTrans.elementAt(n);
					if(tran.getTransactionType().toUpperCase().contains("MPOX")){
						bMpoxExplored=true;
						break;
					}
				}
				if(!bMpoxExplored){
					message=getTranNoLink("ikirezi.warning","mpox",sWebLanguage);
				}
				session.setAttribute("mpoxcheck", encounter.getUid());
			}
		}
	}
%>
{
	"message" :"<%=message %>"
}