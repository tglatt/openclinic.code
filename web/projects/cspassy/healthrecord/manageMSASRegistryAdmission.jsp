<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"msas.registry.admission","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" colspan="2">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- DESCRIPTION --%>
        <tr>
        	<td width="60%" valign='top'>
	        	<table width='100%'>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","pregnantwomen",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_ADMISSION_PREGNANTWOMEN" property="itemId"/>]>.value" value="medwan.common.true"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_ADMISSION_PREGNANTWOMEN;value=medwan.common.true"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","yes",sWebLanguage) %></label>
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_ADMISSION_PREGNANTWOMEN" property="itemId"/>]>.value" value="medwan.common.false"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_ADMISSION_PREGNANTWOMEN;value=medwan.common.false"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","no",sWebLanguage) %></label>
			            </td>
			            <td class="admin"><%=getTran(request,"web", "arrivaldiagnosis", sWebLanguage)%></td>
			          <td class="admin2"> <%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_ADMISSION_ARRIVALDIAGNOSIS",40, 2)%></td>
			        </tr>
					<tr>
			            <td class="admin"><%=getTran(request,"web","examenparaclinique",sWebLanguage)%>&nbsp;</td>
        			 	<td class="admin2"> <%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_ADMISSION_EXAMEN_PARACLINIQUE",40, 2)%></td>
         				
			            <td class="admin"><%=getTran(request,"web","complication",sWebLanguage)%>&nbsp;</td>
        			 	<td class="admin2"> <%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_ADMISSION_COMPLICATION",40, 2)%></td>
         			</tr>
         				<tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.diabetes", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_diabetes' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("diabetes","ITEM_TYPE_MSAS_CONS_DIABETES")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='diabetes' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.diabetes", "ITEM_TYPE_MSAS_CONS_DIABETES", sWebLanguage, false,"onchange=\"checkImage('diabetes','ITEM_TYPE_MSAS_CONS_DIABETES')\"") %></div>
			            </td>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.hypertension", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_hta' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("hta","ITEM_TYPE_MSAS_CONS_HYPERTENSION")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='hta' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.hypertension", "ITEM_TYPE_MSAS_CONS_HYPERTENSION", sWebLanguage, false,"onchange=\"checkImage('hta','ITEM_TYPE_MSAS_CONS_HYPERTENSION')\"") %></div>
			            </td>
			    </tr>
			         <tr>
			            <td class="admin"><%=getTran(request,"web", "consultation.observations", sWebLanguage)%></td>
			           	 <td class="admin2" colspan="4"> <%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_ADMISSION_OBSERVATIONS",40, 2)%></td>
			         
			     
			        </tr>
			         
			        
	            </table>
	        </td>
	        <%-- DIAGNOSES --%>
	    	<td class="admin2">
		      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
	    	</td>
        </tr>
    </table>
            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"msas.registry.admission",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
function toggleSection(id,elementId){
	if(document.getElementById(elementId).value.length==0 && document.getElementById(id).style.display==''){
		document.getElementById(id).style.display='none';
	}
	else{
		document.getElementById(id).style.display='';
	}
	checkImage(id,elementId);
}
function checkSection(id,elementId){
	if(document.getElementById(elementId).value.length>0){
		document.getElementById(id).style.display='';
	}
	checkImage(id,elementId);
}
function checkImage(id,elementId){
	if(document.getElementById(id).style.display=='none'){
		document.getElementById('img_'+id).style.display='';
		document.getElementById('img_'+id).src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png';
	}
	else if(document.getElementById(elementId).value.length==0){
		document.getElementById('img_'+id).style.display='';
		document.getElementById('img_'+id).src='<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png';
	}
	else{
		document.getElementById('img_'+id).style.display='none';
	}
}

checkSection('diabetes','ITEM_TYPE_MSAS_CONS_DIABETES');
checkSection('hta','ITEM_TYPE_MSAS_CONS_HYPERTENSION');

  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&Varcode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  if( document.getElementById('encounteruid').value=="" <%=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERRAL_SOURCESITE").length()==0 && request.getParameter("nobuttons")==null?"":" && 1==0"%>){
  	alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
  	searchEncounter();
  }	

  function searchUser(managerUidField,managerNameField){
	  openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no&FindServiceID=<%=MedwanQuery.getInstance().getConfigString("CCBRTEyeRegistryService")%>",650,600);
    document.getElementById(diagnosisUserName).focus();
  }

  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO,activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>