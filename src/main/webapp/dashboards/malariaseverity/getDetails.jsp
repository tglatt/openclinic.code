<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='4'><%=getTran(request,"web","malriaseverity",sWebLanguage) %></td>
		</tr>
		<tr class='admin'>
			<td><%=getTran(request,"web","date",sWebLanguage) %></td>
			<td>ID</td>
			<td><%=getTran(request,"web","patient",sWebLanguage) %></td>
			<td><%=getTran(request,"gfmalaria","severity",sWebLanguage) %></td>
		</tr>
		<%
		Hashtable<String,String> diagnoses = new Hashtable<String,String>();
		String labels = "'"+getTranNoLink("gfmalaria","simple",sWebLanguage)+"','"+getTranNoLink("gfmalaria","severe",sWebLanguage)+"','"+getTranNoLink("gfmalaria","other",sWebLanguage)+"','?'";
		Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsByTypeBetween("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GF_MALARIA_ADMISSION", SH.getDateAdd(SH.getToday(), -SH.getTimeDay()*30), SH.getTomorrow());
		for(int n=0;n<transactions.size();n++){
			TransactionVO transaction = transactions.elementAt(n);
			String diag=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRESUMEDDIAGNOSIS");
			if(diag.length()>0){
				diagnoses.put(transaction.getEncounter().getUid(),diag+":"+transaction.getEncounter().getPatientUID()+";"+transaction.getPatient().getFullName()+";"+SH.formatDate(transaction.getUpdateTime()));
			}
			else if(diagnoses.get(transaction.getEncounter().getUid())==null){
				diagnoses.put(transaction.getEncounter().getUid(),"99;:"+transaction.getEncounter().getPatientUID()+";"+transaction.getPatient().getFullName()+";"+SH.formatDate(transaction.getUpdateTime()));
			}
		}
		transactions = MedwanQuery.getInstance().getTransactionsByTypeBetween("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GF_MALARIA_DISCHARGE", SH.getDateAdd(SH.getToday(), -SH.getTimeDay()*30), SH.getTomorrow());
		for(int n=0;n<transactions.size();n++){
			TransactionVO transaction = transactions.elementAt(n);
			String diag=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FINALDIAGNOSIS");
			if(diag.length()>0){
				if(diag.length()>0){
					diagnoses.put(transaction.getEncounter().getUid(),diag+":"+transaction.getEncounter().getPatientUID()+";"+transaction.getPatient().getFullName()+";"+SH.formatDate(transaction.getUpdateTime()));
				}
				else if(diagnoses.get(transaction.getEncounter().getUid())==null){
					diagnoses.put(transaction.getEncounter().getUid(),"99;:"+transaction.getEncounter().getPatientUID()+";"+transaction.getPatient().getFullName()+";"+SH.formatDate(transaction.getUpdateTime()));
				}
			}
		}
		for(int i=0;i<"1;:2;:3;:99;".split(":").length;i++){
			Iterator<String> encounteruids = diagnoses.keySet().iterator();
			while(encounteruids.hasNext()){
				String id=encounteruids.next();
				String personid=diagnoses.get(id).split(":")[1].split(";")[0];
				String fullname=diagnoses.get(id).split(":")[1].split(";")[1];
				String date=diagnoses.get(id).split(":")[1].split(";")[2];
				String severity=diagnoses.get(id).split(":")[0];
				if(diagnoses.get(id).startsWith("1;:2;:3;:99;".split(":")[i])){
					out.println("<tr><td class='admin'>"+date+"</td><td class='admin2'>"+personid+"</td><td class='admin2'><a href='javascript:openPatient("+personid+")'>"+fullname+"</a></td><td class='admin2'>"+getTranNoLink("gfmalaria","simple,severe,other,?".split(",")[i],sWebLanguage)+"</td></tr>");
				}
			}
		}
		%>
	</table>
</form>

<script>
	function openPatient(uid){
		window.open('<%=sCONTEXTPATH%>/main.jsp?Page=/curative/index.jsp&PersonID='+uid,"OpenClinic-Malaria","toolbar=no,status=no,scrollbars=yes,resizable=yes,menubar=yes,width=1024,height=600").moveTo((screen.width-1024)/2,(screen.height-600)/2);
	}
</script>