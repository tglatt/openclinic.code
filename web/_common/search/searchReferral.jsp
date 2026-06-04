<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String referralField = SH.p(request,"referralField");
	String referralUID = SH.p(request,"referralUID");
%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td><%=getTran(request,"web","date",sWebLanguage) %></td>
			<td><%=getTran(request,"web","origin",sWebLanguage) %></td>
			<td><%=getTran(request,"web","caregiver",sWebLanguage) %></td>
		</tr>
		<%
			Vector transactions = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_REFERRAL");
			for(int n=0;n<transactions.size();n++){
				TransactionVO transaction = (TransactionVO)transactions.elementAt(n);
                ItemVO encounteritem = transaction.getItem(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CONTEXT_ENCOUNTERUID");
                String servicecode="";
                if(encounteritem!=null){
                	Encounter encounter = Encounter.get(encounteritem.getValue());
                	if(encounter!=null){
                		servicecode= encounter.getServiceUID(transaction.getUpdateDateTime());
                	}
                }
				%>
				<tr>
					<td class='admin'><a href="javascript:selectUID('<%=transaction.getUid()%>')"><%=SH.getSQLDate(transaction.getUpdateTime()) %></a></td>
					<td class='admin2'><%=transaction.getItemValue(SH.ITEM_PREFIX+"ITEM_TYPE_REFERRAL_SOURCESITE").length()>0?transaction.getItemValue(SH.ITEM_PREFIX+"ITEM_TYPE_REFERRAL_SOURCESITE"):getTranNoLink("service",servicecode,sWebLanguage) %></td>
					<td class='admin2'><%=transaction.getItemValue(SH.ITEM_PREFIX+"ITEM_TYPE_REFERRAL_USER").length()>0?transaction.getItemValue(SH.ITEM_PREFIX+"ITEM_TYPE_REFERRAL_USER"):User.getFullUserName(transaction.getUser().getUserId()+"") %></td>
				</tr>
				<%
			}
		%>
	</table>
</form>
<script>
	function selectUID(id){
		window.opener.document.getElementById('<%=referralField%>').value=id;
		window.close();
	}
</script>
