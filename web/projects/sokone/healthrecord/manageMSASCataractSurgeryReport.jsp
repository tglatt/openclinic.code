<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"msas.cataract.surgery","select",activeUser)%>

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
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <tr>
        	<td width="100%" valign='top'>
	        	<table width='100%'>
	        		<tr class='admin'><td colspan='8'><%=getTran(request,"web","preoperativeexamination",sWebLanguage)%></td></tr>
	        		<tr>
	        			<td class='admin' rowspan='2'><%=getTran(request,"web","visualacuity",sWebLanguage)%></td>
			            <td class='admin'><%=getTran(request,"web","withcorrection",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=getTran(request,"web","right",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AV_WITH_RIGHT", "msas_ophtalmology.va", sWebLanguage, "") %>
			            </td>
			            <td class='admin2'>
			            	<%=getTran(request,"web","left",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AV_WITH_LEFT", "msas_ophtalmology.va", sWebLanguage, "") %>
			            </td>
			            <td class='admin' rowspan="2" style='vertical-align: top'><%=getTran(request,"web","category",sWebLanguage) %></td>
			            <td class='admin2' colspan="3" rowspan="2" style='vertical-align: top'><%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AV_CATEGORY", "msas_ophtalmology.vacat", sWebLanguage, "")%></td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","withbestcorrection",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=getTran(request,"web","right",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AV_WITHBEST_RIGHT", "msas_ophtalmology.va", sWebLanguage, "") %>
			            </td>
			            <td class='admin2'>
			            	<%=getTran(request,"web","left",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AV_WITHBEST_LEFT", "msas_ophtalmology.va", sWebLanguage, "") %>
			            </td>
			        </tr>
	        		<tr>
	        			<td class='admin' colspan='2'><%=getTran(request,"web","cristallineexamination",sWebLanguage)%></td>
	        			<td class='admin2' nowrap>
	        				<%=getTran(request,"web","right",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_CRISTALLINE_RIGHT", "msas.cristalline", sWebLanguage, "")%>
	        			</td>
	        			<td class='admin2' nowrap>
	        				<%=getTran(request,"web","left",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_CRISTALLINE_LEFT", "msas.cristalline", sWebLanguage, "")%>
	        			</td>
	        			<td class='admin' rowspan='2'><%=getTran(request,"web","clinicaldata",sWebLanguage)%></td>
	        			<td class='admin2' colspan='3' rowspan='2'><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_CLINICALDATA", 25, 3)%></td>
	        		</tr>
	        		<tr>
	        			<td class='admin' colspan='2'><%=getTran(request,"web","otherdiseaseoperatedeye",sWebLanguage)%></td>
	        			<td class='admin2' colspan='2'>
	        				<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.otherdiseaseoperatedeye", "ITEM_TYPE_MSAS_CATARACT_OTHERDISEASE", sWebLanguage, false)%>
	        				<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_OTHERDISEASE_OTHER", 40) %>
	        			</td>
	        		</tr>
	        		<tr>
	        			<td class='admin' colspan='2'><%=getTran(request,"web","eyetobeoperated",sWebLanguage)%></td>
	        			<td class='admin2' colspan='6'>
	        				<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "leftright", "ITEM_TYPE_MSAS_CATARACT_EYETOBEPERATED", sWebLanguage, false, "", "")%>
	        			</td>
	        		</tr>
	        		<tr>
	        			<td class='admin' colspan='2'><%=getTran(request,"web","refraction",sWebLanguage)%></td>
	        			<td class='admin2' colspan='2'>
	        				sph.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTION_SPH", 5)%>
	        				cyl.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTION_CYL", 5)%>
	        				ax.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTION_AX", 5)%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","biometrics",sWebLanguage)%></td>
	        			<td class='admin2' nowrap>
	        				K1<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_BIOMETRICS_K1", 5)%>
	        				K2<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_BIOMETRICS_K2", 5)%>
	        			</td>
	        		</tr>
	        		<tr>
	        			<td class='admin' colspan='2'><%=getTran(request,"web","refractionpostoptarget",sWebLanguage)%></td>
	        			<td class='admin2' colspan='2'>
	        				sph.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTION_SPH_TARGET", 5)%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","axiallength",sWebLanguage)%></td>
	        			<td class='admin2' nowrap>
	        				<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AXIALLENGTH", 5)%>
	        			</td>
	        		</tr>
	        		<tr class='admin'><td colspan='8'><%=getTran(request,"web","surgery",sWebLanguage)%></td></tr>
	        		<tr>
	        			<td class='admin'><%=getTran(request,"web","date",sWebLanguage)%></td>
	        			<td class='admin2' nowrap>
	        				<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_SURGERYDATE", sWebLanguage, sCONTEXTPATH)%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","surgeon",sWebLanguage)%></td>
	        			<td class='admin2'>
	        				<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_SURGEON", 30)%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","surgeontraining",sWebLanguage)%></td>
	        			<td class='admin2' colspan='3'>
	        				<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_SURGEONTRAINING","msas_cataract.surgeontraining", sWebLanguage, "")%>
	        			</td>
	        		</tr>
	        		<tr>
	        			<td class='admin' colspan='2'><%=getTran(request,"web","surgerytype",sWebLanguage)%></td>
	        			<td class='admin2' nowrap colspan='2'>
	        				<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_SURGERYTYPE","msas_cataract.surgerytype", sWebLanguage, "")%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","lio",sWebLanguage)%></td>
	        			<td class='admin2' nowrap colspan='3'>
	        				<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_LIO","msas_cataract.lio", sWebLanguage, "")%>
	        			</td>
	        		</tr>
	        		<tr>
	        			<td class='admin' colspan='2'><%=getTran(request,"web","cataractcomplications",sWebLanguage)%></td>
	        			<td class='admin2' colspan='6'>
	        				<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.cataractcomplications", "ITEM_TYPE_MSAS_CATARACT_COMPLICATIONS", sWebLanguage, false)%>
	        			</td>
	        		</tr>
	        		<tr>
	        			<td class='admin'><%=getTran(request,"web","incision",sWebLanguage)%></td>
	        			<td class='admin2'>
	        				<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_INCISION","msas_cataract.incision", sWebLanguage, "")%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","capsulotomy",sWebLanguage)%></td>
	        			<td class='admin2'>
	        				<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_CAPSULOTOMY","msas_cataract.capsulotomy", sWebLanguage, "")%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","stitch",sWebLanguage)%></td>
	        			<td class='admin2'>
	        				<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_STITCH","msas_cataract.stitch", sWebLanguage, "")%>
	        			</td>
	        		</tr>
	        		<tr>
	        			<td class='admin'><%=getTran(request,"web","liotype",sWebLanguage)%></td>
	        			<td class='admin2'>
	        				<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_LIOTYPE", 20)%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","liopower",sWebLanguage)%></td>
	        			<td class='admin2'>
	        				<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_LIOPOWER", 20)%>
	        			</td>
	        			<td class='admin'><%=getTran(request,"web","cataractcomment",sWebLanguage)%></td>
	        			<td class='admin2' colspan='3'>
	        				<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_COMMENT", 25, 1)%>
	        			</td>
	        		</tr>
	        		<tr class='admin'><td colspan='8'><%=getTran(request,"web","postoperativeva",sWebLanguage)%></td></tr>
	        		 
	        		<tr>
	        			<td colspan='8'>
	        				<table width='100%'>
	        					<tr class='admin'>
	        						<td nowrap width='20%')><%=getTran(request,"web","postopvisit",sWebLanguage)%></td>
	        						<td width='10%'><%=getTran(request,"web","date",sWebLanguage)%></td>
	        						<td width='10%'><%=getTran(request,"web","avcp",sWebLanguage)%></td>
	        						<td width='10%'><%=getTran(request,"web","avmc",sWebLanguage)%></td>
	        						<td/>
	        					</tr>
	        					<tr>
	        						<td class='admin'><%=getTran(request,"web","atdischarge",sWebLanguage)%></td>
	        						<td class='admin2' nowrap><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_POSTOPDATE_DISCHARGE", sWebLanguage, sCONTEXTPATH) %></td>
	        						<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AVCP_DISCHARGE", 5) %></td>
	        						<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AVMC_DISCHARGE", 5) %></td>
	        						<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.cataract.postoppars", "ITEM_TYPE_MSAS_CATARACT_POSTOPPARS_DISCHARGE", sWebLanguage, false)%></td>
	        					</tr>
	        					<tr>
	        						<td class='admin' width='10%'><%=getTran(request,"web","1-3PO",sWebLanguage)%></td>
	        						<td class='admin2'><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_POSTOPDATE_1-3PO", sWebLanguage, sCONTEXTPATH) %></td>
	        						<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AVCP_1-3PO", 5) %></td>
	        						<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AVMC_1-3PO", 5) %></td>
	        						<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.cataract.postoppars", "ITEM_TYPE_MSAS_CATARACT_POSTOPPARS_1-3PO", sWebLanguage, false)%></td>
	        					</tr>
	        					<tr>
	        						<td class='admin' width='10%'><%=getTran(request,"web","4-11PO",sWebLanguage)%></td>
	        						<td class='admin2'><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_POSTOPDATE_4-11PO", sWebLanguage, sCONTEXTPATH) %></td>
	        						<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AVCP_4-11PO", 5) %></td>
	        						<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AVMC_4-11PO", 5) %></td>
	        						<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.cataract.postoppars", "ITEM_TYPE_MSAS_CATARACT_POSTOPPARS_4-11PO", sWebLanguage, false)%></td>
	        					</tr>
	        					<tr>
	        						<td class='admin'><%=getTran(request,"web","12PO",sWebLanguage)%></td>
	        						<td class='admin2'><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_POSTOPDATE_12PO", sWebLanguage, sCONTEXTPATH) %></td>
	        						<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AVCP_12PO", 5) %></td>
	        						<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_AVMC_12PO", 5) %></td>
	        						<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.cataract.postoppars", "ITEM_TYPE_MSAS_CATARACT_POSTOPPARS_12PO", sWebLanguage, false)%></td>
	        					</tr>
	        				</table>
	        			</td>
	        		</tr>
   					<tr>
	        			<td colspan='8'>
	        				<table width='100%'>
	        					<tr>
			   						<td class='admin' width='20%'><%=getTran(request,"web","postoprefraction.4-11",sWebLanguage)%></td>
				        			<td class='admin2' width='20%'>
				        				sph.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTIONPO4-11_SPH", 5)%>
				        				cyl.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTIONPO4-11_CYL", 5)%>
				        				ax.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTIONPO4-11_AX", 5)%>
				        			</td>
			   						<td class='admin' width='20%'><%=getTran(request,"web","postoprefraction.12",sWebLanguage)%></td>
				        			<td class='admin2'>
				        				sph.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTIONPO12_SPH", 5)%>
				        				cyl.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTIONPO12_CYL", 5)%>
				        				ax.<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CATARACT_REFRACTIONPO12_AX", 5)%>
				        			</td>
				        		</tr>
				        	</table>
				        </td>
   					</tr>
	            </table>
	        </td>
        </tr>
        <tr>
	        <%-- DIAGNOSES --%>
	    	<td class="admin2" style='vertical-align: top'>
		      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
	    	</td>
	    </tr>
    </table>
            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"msas.registry.deceased",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  function getVisionStatus(){
	  var besteye=100.0;
	  if(document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITH_RIGHT").value.length>0){
		  besteye=document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITH_RIGHT").value*1.0;
	  }
	  if(document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITH_LEFT").value.length>0 && document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITH_LEFT").value*1>besteye){
		  besteye=document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITH_LEFT").value*1.0;
	  }
	  if(besteye>=1 && besteye<3){
		  document.getElementById("vastatus").innerHTML="<%=getTranNoLink("web","badsight",sWebLanguage)%>";
		  document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS").value="1";
	  }
	  else if(besteye>=0.5 && besteye<1){
		  document.getElementById("vastatus").innerHTML="<%=getTranNoLink("web","severebadsight",sWebLanguage)%>";
		  document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS").value="2";
	  }
	  else if(besteye<0.5){
		  document.getElementById("vastatus").innerHTML="<%=getTranNoLink("web","nosight",sWebLanguage)%>";
		  document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS").value="3";
	  }
	  else{
		  document.getElementById("vastatus").innerHTML="";
		  document.getElementById("ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS").value="";
	  }
  }

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
  
  getVisionStatus();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>