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
			<td><%=getTran(request,"gfmalaria","outcome",sWebLanguage) %></td>
		</tr>
		<%
		Hashtable<String,String> outcomes = new Hashtable<String,String>();
		String labels = "'"+getTranNoLink("gfmalaria.evolution2","1",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","2",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","3",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","4",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","5",sWebLanguage)+"','"+getTranNoLink("gfmalaria.evolution2","6",sWebLanguage)+"'";
		Vector<TransactionVO> transactions = MedwanQuery.getInstance().getTransactionsByTypeBetween("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GF_MALARIA_DISCHARGE", SH.getDateAdd(SH.getToday(), -SH.getTimeDay()*30), SH.getTomorrow());
		for(int n=0;n<transactions.size();n++){
			TransactionVO transaction = transactions.elementAt(n);
			String outcome=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVOLUTION");
			if(outcome.length()>0){
				outcomes.put(transaction.getEncounter().getUid(),outcome+":"+transaction.getEncounter().getPatientUID()+";"+transaction.getPatient().getFullName()+";"+SH.formatDate(transaction.getUpdateTime()));
			}
		}
		for(int i=0;i<6;i++){
			Iterator<String> encounteruids = outcomes.keySet().iterator();
			while(encounteruids.hasNext()){
				String id=encounteruids.next();
				String personid=outcomes.get(id).split(":")[1].split(";")[0];
				String fullname=outcomes.get(id).split(":")[1].split(";")[1];
				String date=outcomes.get(id).split(":")[1].split(";")[2];
				String outcome=getTranNoLink("gfmalaria.evolution2",outcomes.get(id).split(":")[0],sWebLanguage);
				if(outcomes.get(id).startsWith(i+"")){
					out.println("<tr><td class='admin'>"+date+"</td><td class='admin2'>"+personid+"</td><td class='admin2'><a href='javascript:openPatient("+personid+")'>"+fullname+"</a></td><td class='admin2'>"+outcome+"</td></tr>");
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