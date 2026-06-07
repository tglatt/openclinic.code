<%@include file="/includes/validateUser.jsp"%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<% if(SH.ci("enableBurundi",0)==1){ %>
<tr>
	<td class='admin' style='border-top: solid'><%=getTran(request,"web","malaria",sWebLanguage) %></td>
	<td class='admin2' colspan='3' style='border-top: solid'>
		<table width='100%'>
			<tr>
				<td class='admin'><%=getTran(request,"web","diagnosis",sWebLanguage) %></td>
				<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "notification.malaria", "ITEM_TYPE_NOTIFICATION_MALARIA", sWebLanguage, false) %></td>
			</tr>
			<tr>
				<td class='admin'><%=getTran(request,"web","pregnantwomen",sWebLanguage) %></td>
				<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "notification.pregnantwomen", "ITEM_TYPE_NOTIFICATION_PREGNANTWOMEN", sWebLanguage, false, "", "") %></td>
			</tr>
			<tr>
				<td class='admin' rowspan='2'><%=getTran(request,"web","malariatreatment",sWebLanguage) %></td>
				<td class='admin2'>
					<%=getTran(request,"web","Artemether",sWebLanguage) %>
					<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "notification.malariatreatment", "ITEM_TYPE_NOTIFICATION_MALARIATREATMENT", sWebLanguage, false, "", "") %>
				</td>
			</tr>
			<tr>
				<td class='admin2'>
					<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "notification.malariatreatment2", "ITEM_TYPE_NOTIFICATION_MALARIATREATMENT2", sWebLanguage, false, "", "") %>
				</td>
			</tr>
		</table>
	</td>
</tr>
<tr>
	<td class='admin'><%=getTran(request,"web","diarrhea",sWebLanguage) %></td>
	<td class='admin2' colspan='3'>
		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "notification.diarrhea", "ITEM_TYPE_NOTIFICATION_DIARRHEA", sWebLanguage, false, "", "") %>
		&nbsp;&nbsp;&nbsp;<%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_NOTIFICATION_DIARRHEA_TREATED", "") %><%=getTran(request,"web","diarrheatreated",sWebLanguage) %>
	</td>
</tr>
<tr>
	<td class='admin' style='border-bottom: solid'><%=getTran(request,"web","pneumonie",sWebLanguage) %></td>
	<td  colspan='3' style='background-color: #DEEAFF;border-left:5px solid #DEEAFF;padding:1px;text-align:left;border-bottom: solid'>
		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_NOTIFICATION_PNEUMONIA", sWebLanguage, false, "", "") %>
		&nbsp;&nbsp;&nbsp;<%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_NOTIFICATION_PNEUMONIA_TREATED", "") %><%=getTran(request,"web","pneumoniatreated",sWebLanguage) %>
	</td>
</tr>
<% }%>