<%@page import="be.openclinic.reporting.Register"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	//Find all vaccination registry entries for this patient
	SortedMap vaccinations = new TreeMap();
	SortedSet<String> columns = new TreeSet();
	String sTypes = "ALBENDAZOLE;VITAMINA;BCG;HEPB;VAP;VPI;DTCHIB;ROTA;PNEUMO;VAR;MALARIA;CPP";
	Vector vaccinationRegistries = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSPLS_REGISTRY_CHILDVACCINATION");
	for(int n=0;n< vaccinationRegistries.size();n++){
		TransactionVO transaction = (TransactionVO)vaccinationRegistries.elementAt(n);
		String sDate = new SimpleDateFormat("yyyyMMdd").format(transaction.getUpdateTime());
		columns.add(sDate);
		for(int i=0;i<sTypes.split(";").length;i++){
			String sType=sTypes.split(";")[i];
			String sVaccin = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_"+sType);
			if(sVaccin.length()>0){
				vaccinations.put(sDate+";ITEM_TYPE_"+sType,sVaccin);
			}
		}
	}
	//Now show them on the screen
	out.println("<table width='100%'>");
	out.println("<tr class='admin'><td colspan='"+(columns.size()+1)+"'>"+getTran(request,"web","vaccinationcard",sWebLanguage)+"</td></tr>");
	out.println("<tr><td/>");
	Iterator<String> iColumns = columns.iterator();
	while(iColumns.hasNext()){
		java.util.Date date = new SimpleDateFormat("yyyyMMdd").parse(iColumns.next());
		String age= activePatient.getAgeInMonthsOnDate(date)+" "+getTran(request,"web","months",sWebLanguage);
		if(activePatient.getAgeInMonthsOnDate(date)>59){
			age= activePatient.getAgeOnDate(date)+" "+getTran(request,"web","years",sWebLanguage);
		}
		out.println("<td class='admin'>"+SH.formatDate(date)+"<br/>"+age+"</td>");
	}
	out.println("</tr>");
	for(int n=0;n<sTypes.split(";").length;n++){
		String sType=sTypes.split(";")[n];
		out.println("<tr><td class='admin'>"+getTran(request,"web", sType.toLowerCase(), sWebLanguage)+"</td>");
		iColumns = columns.iterator();
		while(iColumns.hasNext()){
			String sDate=iColumns.next();
			String s="";
			if(vaccinations.get(sDate+";ITEM_TYPE_"+sType)!=null){
				s=getTran(request,"mspls.vacc."+sType.toLowerCase(),(String)vaccinations.get(sDate+";ITEM_TYPE_"+sType),sWebLanguage);
			}
			out.println("<td class='admin2'>"+s+"</td>");
		}
		out.println("</tr>");
	}
	out.println("</table>");
%>
