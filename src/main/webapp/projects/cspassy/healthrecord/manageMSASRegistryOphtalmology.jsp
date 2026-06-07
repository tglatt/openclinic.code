<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"msas.registry.ophtalmology","select",activeUser)%>

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

        <%-- REFERENCE --%>
        <tr>
        	<td width="50%" valign='top'>
	        	<table width='100%'>
	        		<tr class='admin'><td colspan='4'><%=getTran(request,"web","referral",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","inward",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.referral.in", "ITEM_TYPE_MSAS_OPHTALMOLOGY_REFERRAL_IN", sWebLanguage, true) %>
			            </td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","outward",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.referral.out", "ITEM_TYPE_MSAS_OPHTALMOLOGY_REFERRAL_OUT", sWebLanguage, true) %>
			            </td>
			        </tr>
			        <!-- DEBUT : ajout  ITEM ITEM_TYPE_MSAS_OPHTALMOLOGY_DISABILITY -->
			          <tr class='admin'><td colspan='4'><%=getTran(request,"web","disability",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin2' colspan='4'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.disability", "ITEM_TYPE_MSAS_OPHTALMOLOGY_DISABILITY", sWebLanguage, false) %>
			            </td>
			        </tr>
			         <!-- FIN : ajout  ITEM ITEM_TYPE_MSAS_OPHTALMOLOGY_DISABILITY -->
			       
	        		<tr class='admin'><td colspan='4'><%=getTran(request,"web","visualstatus",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","vawithoutcorrection",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=getTran(request,"web","right",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITHOUT_RIGHT", "msas_ophtalmology.va", sWebLanguage, "") %>
			            </td>
			            <td class='admin2' colspan='2'>
			            	<%=getTran(request,"web","left",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITHOUT_LEFT", "msas_ophtalmology.va", sWebLanguage, "") %>
			            </td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","vawithcorrection",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=getTran(request,"web","right",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITH_RIGHT", "msas_ophtalmology.va", sWebLanguage, "onchange='getVisionStatus()'") %>
			            </td>
			            <td class='admin2' colspan='2'>
			            	<%=getTran(request,"web","left",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_AV_WITH_LEFT", "msas_ophtalmology.va", sWebLanguage, "onchange='getVisionStatus()'") %>
			            </td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","visionstatus",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS") %>
			            	<span id='vastatus' style='color: red;font-size: 14px;font-weight: bold'></span>
			            </td>
			        </tr>
			        <!-- DEBUT : ajout des ITEMS ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS_POSTJ_RIGHT et ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS_POSTJ_LEFT -->
			        <tr>
			            <td class='admin'><%=getTran(request,"web","visionstatuspost",sWebLanguage)%>&nbsp;</td>
			          
			             <td class='admin2'>
			            	<%=getTran(request,"web","right",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS_POSTJ_RIGHT", "msas_ophtalmology.va", sWebLanguage, "") %>
			            </td>
			            <td class='admin2' colspan='2'>
			            	<%=getTran(request,"web","left",sWebLanguage)%>: <%=SH.writeDefaultSelectUnsorted(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS_POSTJ_LEFT", "msas_ophtalmology.va", sWebLanguage, "") %>
			            </td>
			        </tr>
			         <!-- FIN : ajout des ITEMS ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS_POSTJ_RIGHT et ITEM_TYPE_MSAS_OPHTALMOLOGY_VASTATUS_POSTJ_LEFT -->
			       
	        		<tr class='admin'><td colspan='4'><%=getTran(request,"web","examination",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","signsandsymptoms",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultTextArea(session,(TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_SIGNSANDSYMPTOMS",40,1) %>
			            </td>
			        </tr>
			      
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","fundus",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultTextArea(session,(TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_FUNDUS",40,1) %>
			            </td>
			        </tr>
			        
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","eyetone",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultTextArea(session,(TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_EYETONE",40,1) %>
			            </td>
			        </tr>
			        <tr class='admin'><td colspan='4'><%=getTran(request,"web","treatments",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","medicals",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultTextArea(session,(TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_MEDICAL",40,1) %>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin'><%=getTran(request,"web","chururgical",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultTextArea(session,(TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_CHURURGICAL",40,1) %>
			            </td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","correction",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultTextArea(session,(TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_CORRECTION",40,1) %>
			            </td>
			        </tr>
	        		<tr class='admin'><td colspan='4'><%=getTran(request,"web","surgery",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin2' colspan='4'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.surgery", "ITEM_TYPE_MSAS_OPHTALMOLOGY_SURGERY", sWebLanguage, false) %>
			            </td>
			        </tr>
	        	
	            </table>
	        </td>
	        <%-- DIAGNOSES --%>
	    	<td class="admin2" style='vertical-align: top'>
	        	<table width='100%'>
	        			<tr class='admin'><td colspan='4'><%=getTran(request,"web","anesthesia",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin2' colspan='4'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.anesthesia", "ITEM_TYPE_MSAS_OPHTALMOLOGY_ANESTHESIA", sWebLanguage, false) %>
			            </td>
			        </tr>
	        		<tr class='admin'><td colspan='4'><%=getTran(request,"web","physicaltreatment",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin2' colspan='4'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.physicaltreatment", "ITEM_TYPE_MSAS_OPHTALMOLOGY_PHYSICALTREATMENT", sWebLanguage, false) %>
			            </td>
			        </tr>
	        		<tr class='admin'><td colspan='4'><%=getTran(request,"web","functionalexploration",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin2' colspan='4'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.functionalexploration", "ITEM_TYPE_MSAS_OPHTALMOLOGY_FUNCTIONALEXPLORATION", sWebLanguage, false) %>
			            </td>
			        </tr>
	        		<tr class='admin'><td colspan='4'><%=getTran(request,"web","ophtalmologicdiseases",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","catacracts",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.cataracts", "ITEM_TYPE_MSAS_OPHTALMOLOGY_CATARACTS", sWebLanguage, true) %>
			            </td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","ametropia",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.ametropia", "ITEM_TYPE_MSAS_OPHTALMOLOGY_AMETROPIA", sWebLanguage, true) %>
			            </td>
			        </tr>
	        		<tr><td colspan='4'><hr/></td></tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","other",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.ophtalmology.otherdiseases", "ITEM_TYPE_MSAS_OPHTALMOLOGY_OTHERDISEASES", sWebLanguage, false) %>
			            </td>
			        </tr>
			        <!-- DEBUT : ajout ITEM ITEM_TYPE_MSAS_OPHTALMOLOGY_OBSERVATION -->
			         <tr class='admin'><td colspan='4'><%=getTran(request,"web","observation",sWebLanguage)%></td></tr>
		        	<tr>
			            <td class='admin2' colspan='4'>
			            	<%=SH.writeDefaultTextArea(session,(TransactionVO)transaction, "ITEM_TYPE_MSAS_OPHTALMOLOGY_OBSERVATION",40,2) %>
		            </td>
		            <!-- FIN : ajout ITEM ITEM_TYPE_MSAS_OPHTALMOLOGY_OBSERVATION -->
			    </table>
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