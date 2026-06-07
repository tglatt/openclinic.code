<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"msas.registry.sickchildren","select",activeUser)%>

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

        <tr>
        	<td width="100%" valign='top'>
	        	<table width='100%'>
			        <tr style='display: <%=SH.c(activePatient.getID("natreg")).length()==0 || ((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_SENTTOCIVILREGISTRATION").length()>0?"":"none"%>'>
			            <td class="adminred"><b><%=getTran(request,"web", "natregmissing", sWebLanguage)%></b></td>
			            <td class='admin2' colspan='3'><%=getTran(request,"web", "senttocivilregistration", sWebLanguage)%> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_CONS_SENTTOCIVILREGISTRATION", sWebLanguage, false, "", "") %></td>
			        </tr>
					<tr>
						<td class='admin2' colspan='4'><%writeVitalSigns(pageContext); %></td>
					</tr>	
				<!-- Ajout d'un item volet 1 (ITEM_TYPE_MSAS_VOLET1) -->
					<tr>
					  <td class='admin'><%=getTran(request,"web","volet1",sWebLanguage)%>&nbsp;</td>
				         <td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_VOLET1", sWebLanguage, false, "", "") %></td>
		        <!-- Fin Ajout d'un item volet 1 (ITEM_TYPE_MSAS_VOLET1) -->
		        			<td class="admin"><%=getTran(request,"web", "responsible.person", sWebLanguage)%></td>
			            
		        			<td class="admin2">
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="30" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_RESPONSIBLE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_RESPONSIBLE" property="value"/></textarea>
			            </td>
					</tr>
					<tr>			            
			            			            
			            <td class='admin'><%=getTran(request,"web","newcase",sWebLanguage) %></td>
			            <td class='admin2' colspan="4"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "!ITEM_TYPE_MSAS_CONS_NEWCASE", sWebLanguage, false, "", "") %></td>
			        </tr>
		        	<tr>			            
			            <td class="admin"><%=getTran(request,"web","nutritionstatus",sWebLanguage)%>&nbsp;</td>
			           <td class="admin2" colspan="4" >
			            	<%= SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.nutrition", "ITEM_TYPE_MSAS_SICKPED_NUTRITION", sWebLanguage, false) %>
			          	&nbsp; 
			               <br/> <br/><%=getTran(request,"web","senttocommunitylevel",sWebLanguage) %>	
			                <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "TEM_TYPE_MSAS_MALNUTRITION_SENTTOCOMMUNITYLEVEL", "") %><%=getTran(request,"web","community",sWebLanguage) %>			          	      
			            </td>			            
			         </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","referral",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CONS_REFERENCE", "msas.reference", sWebLanguage, "") %>
			            </td>
			            <td class="admin"><%=getTran(request,"web","oedema",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_OEDEMA" property="itemId"/>]>.value" value="medwan.common.true"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_OEDEMA;value=medwan.common.true"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","yes",sWebLanguage) %></label>
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_OEDEMA" property="itemId"/>]>.value" value="medwan.common.false"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_OEDEMA;value=medwan.common.false"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","no",sWebLanguage) %></label>
			            </td> 
			        </tr>
		        	<tr>
			            <td class="admin" rowspan="2"><%=getTran(request,"web","dangersigns",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" width="30%" rowspan="2">
			            	<%= SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.dangersigns", "ITEM_TYPE_MSAS_DANGERSIGNS", sWebLanguage, false) %>
			            </td>
			            <td class="admin"><%=getTran(request,"web", "signs.and.symptoms", sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="30" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_SIGNSANDSYMPTOMS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_SIGNSANDSYMPTOMS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web", "treatment", sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="30" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_TREATMENT" property="value"/></textarea>
			            </td>
			        </tr>
			         <tr class='admin'><td colspan="4"><%=getTran(request,"web","donneesvacinales",sWebLanguage) %></td></tr>
			     
			        <tr>
			            <td class="admin"><%=getTran(request,"web", "vaccinationstatus", sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="30" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_VACCINATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_VACCINATION" property="value"/></textarea>
			            </td>
			            <td class="admin"><%=getTran(request,"web", "deworming", sWebLanguage)%></td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.deworming", "ITEM_TYPE_MSAS_SICKPED_DEWORMING", sWebLanguage, false, "", "") %></td>
			        </tr>
			        <tr>
			             <td class="admin"><%=getTran(request,"web","vitamina",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.vitamina", "ITEM_TYPE_MSAS_SICKPED_VITAMINEA", sWebLanguage, false,"","") %>
			            </td>
			            <td class='admin' ><%=getTran(request,"web","site",sWebLanguage) %></td>
			        	<td class='admin2' ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request,"msas.site", "!ITEM_TYPE_MSAS_CONS_SITE", sWebLanguage, true, "", "")%></td>
			        </tr>
			         <tr class='admin'><td colspan="4"><%=getTran(request,"web","paludisme",sWebLanguage) %></td></tr>
			     
			         <tr>
			            <td class="admin"><%=getTran(request,"web","suspicionmalaria",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_SUSPICION_MALARIA", sWebLanguage, false, "", "") %>
			         	 <td class="admin"><%=getTran(request,"web","tdrpalu",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.tdr.malaria", "ITEM_TYPE_MSAS_TDR_MALARIA", sWebLanguage, false,"","") %></td>
			           
			        </tr>  
			        <tr>   
			          	<td class="admin"><%=getTran(request,"web","conformedirective",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_PALU_CONFORME_DIRECTIVES", sWebLanguage, false, "", "") %></td>
			         	<td class="admin"><%=getTran(request,"web","ge",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			     				<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CONS_GOUTTE_EPAISSE", "msas.tdr", sWebLanguage, "") %>
			                 	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.otherpalu","ITEM_TYPE_MSAS_CONS_OTHERPALU", sWebLanguage, false) %>
			            </td>
			        </tr>  
	         		<tr class='admin'><td colspan="4"><%=getTran(request,"web","examenparaclinique",sWebLanguage) %></td></tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web","tdrvih",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            		<%= SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "trdvih", "ITEM_TYPE_MSAS_SICKPED_TDR_VIH", sWebLanguage, true, "") %>
			            </td>
			           <td class="admin"><%=getTran(request,"web","testxpert",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" >
			            		<%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "testxpert", "ITEM_TYPE_MSAS_SICKPED_TDR_XPERT", sWebLanguage, true, "", "") %>
			            </td>
			        </tr>
			        <tr class='admin'><td colspan="4"><%=getTran(request,"web","respiration",sWebLanguage) %></td></tr>
			         <tr>
			          <td class="admin"><%=getTran(request,"web", "respiratory.movements", sWebLanguage)%></td>
			            <td class="admin2" colspan="4">
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="30" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_RESPIRATORYMOVEMENTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_RESPIRATORYMOVEMENTS" property="value"/></textarea>
			            </td>
			            <tr class='admin'><td colspan="4"><%=getTran(request,"web","other",sWebLanguage) %></td></tr>
			              <tr>
			            <td class="admin"><%=getTran(request,"web", "consultation.advice", sWebLanguage)%></td>
			            <td class="admin2">
			            	<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_SICKPED_ADVICE", 50, 2) %>
			            </td>
			            <td class="admin"><%=getTran(request,"web", "consultation.observations", sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea rows="2" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_OBSERVATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_SICKPED_OBSERVATIONS" property="value"/></textarea>
			            </td>
			        </tr>
			            
			        </tr>
			        <tr class='admin'><td colspan="4"><%=getTran(request,"web","integrationservices",sWebLanguage) %></td></tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web","mothermethodepf",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" ><%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_SICKPED_TDR_METHODE_PF", sWebLanguage, true, "", "") %>
			            </td>
			             <td class="admin"><%=getTran(request,"web","conduitetenir",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" ><%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "conduitetenir", "ITEM_TYPE_MSAS_SICKPED_TDR_CONDUITE_TENIR", sWebLanguage, true, "", "") %>
			            </td>
			        </tr>
		 		      
			        <tr class='admin'><td colspan="4"><%=getTran(request,"web","maladieschroniques",sWebLanguage) %></td></tr>
			     
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.traumatisms", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_trauma' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("trauma","ITEM_TYPE_MSAS_CONS_TRAUMATISM")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2" width='30%'>
			            	<div id='trauma' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.traumatism.child", "ITEM_TYPE_MSAS_CONS_TRAUMATISM", sWebLanguage, false,"onchange=\"checkImage('trauma','ITEM_TYPE_MSAS_CONS_TRAUMATISM')\"") %></div>
			            </td>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.diarrea", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_diarrea' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("diarrea","ITEM_TYPE_MSAS_CONS_DIARREA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2" width='30%'>
			            	<div id='diarrea' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.diarrea", "ITEM_TYPE_MSAS_CONS_DIARREA", sWebLanguage, false,"onchange=\"checkImage('diarrea','ITEM_TYPE_MSAS_CONS_DIARREA')\"") %></div>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.ira", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_ira' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("ira","ITEM_TYPE_MSAS_CONS_IRA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='ira' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ira", "ITEM_TYPE_MSAS_CONS_IRA", sWebLanguage, false,"onchange=\"checkImage('ira','ITEM_TYPE_MSAS_CONS_IRA')\"") %></div>
			            </td>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.anemia", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_anemia' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("anemia","ITEM_TYPE_MSAS_CONS_ANEMIA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='anemia' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.anemia", "ITEM_TYPE_MSAS_CONS_ANEMIA", sWebLanguage, false,"onchange=\"checkImage('anemia','ITEM_TYPE_MSAS_CONS_ANEMIA')\"") %></div>
			            </td>
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
			            <td colspan="3" class="admin2">
			            	<div id='diabetes' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.diabetes", "ITEM_TYPE_MSAS_CONS_DIABETES", sWebLanguage, false,"onchange=\"checkImage('diabetes','ITEM_TYPE_MSAS_CONS_DIABETES')\"") %></div>
			            </td>
	
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.bpco", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_bpco' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("bpco","ITEM_TYPE_MSAS_CONS_BPCO")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='bpco' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.bpco", "ITEM_TYPE_MSAS_CONS_BPCO", sWebLanguage, false,"onchange=\"checkImage('hemophilia','ITEM_TYPE_MSAS_CONS_BPCO')\"") %></div>
			            </td>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.asthma", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_asthma' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("asthma","ITEM_TYPE_MSAS_CONS_ASTHMA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='asthma' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.asthma", "ITEM_TYPE_MSAS_CONS_ASTHMA", sWebLanguage, false,"onchange=\"checkImage('asthma','ITEM_TYPE_MSAS_CONS_ASTHMA')\"") %></div>
			            </td>
			        </tr>			        
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.msas.drepanocytosis", sWebLanguage)%></td>	
							 		<td style='background-color: #C3D9FF'><img id='img_drepanocytosis' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("drepanocytosis","ITEM_TYPE_MSAS_CONS_DREPANOCYTOSIS")'>&nbsp;</td>			            		
				            	
							 	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='drepanocytosis' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.drepanocytosis", "ITEM_TYPE_MSAS_CONS_DREPANOCYTOSIS", sWebLanguage, false,"onchange=\"checkImage('drepanocytosis','ITEM_TYPE_MSAS_CONS_DREPANOCYTOSIS')\"") %></div>
			            </td>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.msas.raa", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_raa' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("raa","ITEM_TYPE_MSAS_CONS_RAA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='raa' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.raa", "ITEM_TYPE_MSAS_CONS_RAA", sWebLanguage, false,"onchange=\"checkImage('raa','ITEM_TYPE_MSAS_CONS_RAA')\"") %></div>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.msas.cancer", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_cancer' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("cancer","ITEM_TYPE_MSAS_CONS_CANCER")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='cancer' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.cancer", "ITEM_TYPE_MSAS_CONS_CANCER", sWebLanguage, false,"onchange=\"checkImage('cancer','ITEM_TYPE_MSAS_CONS_CANCER')\"") %></div>
			            </td>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.hemophilia", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_hemophilia' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("hemophilia","ITEM_TYPE_MSAS_CONS_HEMOPHILIA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='hemophilia' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.hemophilia", "ITEM_TYPE_MSAS_CONS_HEMOPHILIA", sWebLanguage, false,"onchange=\"checkImage('hemophilia','ITEM_TYPE_MSAS_CONS_HEMOPHILIA')\"") %></div>
			            </td>			          			        
			        </tr>
			        <tr>
			          <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.msas.mtn", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_rage' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("rage","ITEM_TYPE_MSAS_CONS_RAGE")'>&nbsp;</td>
								</tr>
			            	</table>
			            </td>
			            <td colspan="3" class="admin2">
			            	<div id='rage' style='display: none' >
			            		<table>
			            			<tbody>
			            				<tr>
			            					<td class='admin2'> <strong> Rage :</strong> &nbsp;&nbsp; <td ><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.rage", "ITEM_TYPE_MSAS_CONS_RAGE", sWebLanguage, false, "", "") %></td></td >
			            				</tr>
			            				<tr>
			            					<td class='admin2'> <strong> Evenimation : </strong>&nbsp;&nbsp; <td ><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.evenimation", "ITEM_TYPE_MSAS_CONS_EVENIMATION", sWebLanguage, false, "", "") %></td></td>
			            				</tr>
										<tr>
			            					<td class='admin2'><strong> Leishmaniose :</strong>  &nbsp;&nbsp; <td ><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.leishmaniosis", "ITEM_TYPE_MSAS_CONS_LEISHMANIOSIS", sWebLanguage, false, "", "") %></td></td>
			            				</tr>
			            				<tr>
			            					<td class='admin2'><strong> Mycétome : </strong> &nbsp;&nbsp; <td ><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.myteoma", "ITEM_TYPE_MSAS_CONS_MYCETOMA", sWebLanguage, false, "", "") %></td><td>
			            				</tr>
			            				<tr>
			            					<td class='admin2'> <strong> Dracunculose : </strong> &nbsp;&nbsp; <td ><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.dracunculosis", "ITEM_TYPE_MSAS_CONS_DRACUNCULOSIS", sWebLanguage, false, "", "") %></td></td>
			            				</tr>
			            				<tr>
			            					<td class='admin2'> <strong> Dengue : </strong>  &nbsp;&nbsp; <td ><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.dengue", "ITEM_TYPE_MSAS_CONS_DENGUE", sWebLanguage, false, "", "") %></td></td>
			            				</tr>
			            				<tr> 
			            					<td class='admin2'> <strong> Gale : </strong>  &nbsp;&nbsp;<td >  <%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.scabies", "ITEM_TYPE_MSAS_CONS_SCABIES", sWebLanguage, false, "", "") %></td></td>
			            				</tr>			            				
			            				<tr>
			            				<td class='admin2'>
			            					
			           							<strong> Géoelminthiasis  : </strong> 
			           						<td > 
			           							<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.geohelminthiasis", "ITEM_TYPE_MSAS_CONS_GEOHELMINTHIASIS", sWebLanguage, false, "", "") %>
			           						</td>
			           					</td>
			            				</tr>
			            				<tr>
			            					<td class='admin2'> <strong> Schistosomiase : </strong>  &nbsp;&nbsp; <td > <%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.schistosomiasis", "ITEM_TYPE_MSAS_CONS_SCHISTOSOMIASIS", sWebLanguage, false, "", "") %></td></td>
			            				</tr>
			            				<tr>
			            					<td class='admin2'> <strong> Filariose  : </strong>  &nbsp;&nbsp; <td ><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.filariosis", "ITEM_TYPE_MSAS_CONS_FILARIOSIS", sWebLanguage, false, "", "") %></td></td>
			            				</tr>
			            			</tbody>
			            		</table>
			            	</div>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.msas.cva", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_cva' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("cva","ITEM_TYPE_MSAS_CONS_CVA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td  class="admin2">
			                <div id='cva' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.cva", "ITEM_TYPE_MSAS_CONS_CVA", sWebLanguage, false) %></div>
			            </td>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.msas.evacuation", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_evacuation' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("evacuation","ITEM_TYPE_MSAS_CONS_EVACUATION")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td  class="admin2">
			                <div id='evacuation' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.evacuation", "ITEM_TYPE_MSAS_CONS_EVACUATION", sWebLanguage, false) %></div>
			            </td>
			        </tr>
				        
			        <tr>
				        <%-- DIAGNOSES --%>
				    	<td colspan="4">
					      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
				    	</td>
			        </tr>
	            </table>
	        </td>
        </tr>
    </table>
            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"msas.registry.sickchildren",sWebLanguage)%>
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
	checkSection('trauma','ITEM_TYPE_MSAS_CONS_TRAUMATISM');
	checkSection('diarrea','ITEM_TYPE_MSAS_CONS_DIARREA');
	checkSection('ira','ITEM_TYPE_MSAS_CONS_IRA');
	checkSection('anemia','ITEM_TYPE_MSAS_CONS_ANEMIA');
	checkSection('diabetes','ITEM_TYPE_MSAS_CONS_DIABETES');
	checkSection('hemophilia','ITEM_TYPE_MSAS_CONS_HEMOPHILIA');
	checkSection('bpco','ITEM_TYPE_MSAS_CONS_BPCO');
	checkSection('asthma','ITEM_TYPE_MSAS_CONS_ASTHMA');
	checkSection('drepanocytosis','ITEM_TYPE_MSAS_CONS_DREPANOCYTOSIS');
	checkSection('raa','ITEM_TYPE_MSAS_CONS_RAA');
	checkSection('cancer','ITEM_TYPE_MSAS_CONS_CANCER');
	checkSection('cva','ITEM_TYPE_MSAS_CONS_CVA');
	checkSection('rage','ITEM_TYPE_MSAS_CONS_RAGE');
 
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