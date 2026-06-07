<%@page import="
                be.openclinic.system.Transaction
              " %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"msas.registry.deliveries","select",activeUser)%>

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
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)' onchange='calculateAge();'>
                <script>writeTranDate();</script>
            </td>
        </tr>
 <% TransactionVO tran = (TransactionVO)transaction; %>
        <tr>
        	<td width="100%" valign='top'>
	        	<table width='100%'>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","partogram.number",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><input class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PARTOGRAMNUMBER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PARTOGRAMNUMBER" property="value"/>"/></td>
			            <td class='admin'><%=getTran(request,"web","arrivaldate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
	                        <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_ARRIVALDATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_ARRIVALDATE" property="value" formatType="date"/>" id="arrivaldate" onblur='checkDate(this);' onchange='calculateDuration();' onfocus='calculateDuration();' onkeyup='calculateDuration();'/>
	                        <script>writeMyDate("arrivaldate", "<c:url value="/_img/icons/icon_agenda.png"/>", "<%=getTran(null,"Web","PutToday",sWebLanguage)%>");</script>
			                <%=getTran(request,"web", "hour", sWebLanguage)%>
			                <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_ARRIVALHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_ARRIVALHOUR" property="value"/>" onblur="checkTime(this)">
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","gestity",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_GESTITY", 5) %>
			            </td>
			            <td class='admin'><%=getTran(request,"web","parity",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_PARITY", 5) %>
			            </td>
	        		</tr>    		
	        	
	        		<tr>
			            
			            <td class='admin'><%=getTran(request,"web","weeksofpregnancy",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" ><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_WEEKS", 10, 1, 50, sWebLanguage) %></td>
	        			 <td class='admin'><%=getTran(request,"web","status.mother",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_MOTHERSTATUS" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.motherstatus",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_MOTHERSTATUS"),sWebLanguage,false,true) %>
			                </select>
			            </td>
	        		</tr>
	        		<tr>
			           <!-- Ajout d'un item ITEM_TYPE_MSAS_DELIVERIES_COMPLICATIONSCARE pour prendre en compte les Complications obstétricales directes et indirectes prises en charge locale et Référées  -->
			            <td class="admin" ><%=getTran(request,"web", "directcomplications", sWebLanguage)%></td>
			            <td class="admin2" >
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.delivery.directcomplications", "ITEM_TYPE_MSAS_DELIVERIES_DIRECTCOMPLICATIONS", sWebLanguage, false) %>
			            	<br/><br/><hr/><%=SH.writeDefaultRadioButtons(tran, request, "msas.delivery.indirectcomplicationscare", "ITEM_TYPE_MSAS_DELIVERIES_COMPLICATIONSCARE", sWebLanguage, false,"","") %>
		
			            </td>
	        		
			            <td class="admin" ><%=getTran(request,"web", "indirectcomplications", sWebLanguage)%></td>
			            <td class="admin2" >
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.delivery.indirectcomplications", "ITEM_TYPE_MSAS_DELIVERIES_INDIRECTCOMPLICATIONS", sWebLanguage, false) %>
			                <br/>
			               		                 
			                 
           					 <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_DELIVERIES_COMPLICATIONS", 30, 3)%>
					<br/><br/><hr/><%=SH.writeDefaultRadioButtons(tran, request, "msas.delivery.indirectcomplicationscare", "ITEM_TYPE_MSAS_DELIVERIES_INDIRECTCOMPLICATIONSCARE", sWebLanguage, false,"","") %>
		
			            </td>
	        		</tr>
	        		<!-- FIN Ajout d'un item ITEM_TYPE_MSAS_DELIVERIES_COMPLICATIONSCARE pour prendre en compte les Complications obstétricales directes et indirectes prises en charge locale et Référées  -->
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","prevention",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
							<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PREVENTION_VAT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PREVENTION_VAT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran(request,"web","vat",sWebLanguage) %>&nbsp;			            
							<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PREVENTION_IRON" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PREVENTION_IRON;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran(request,"web","iron",sWebLanguage) %>&nbsp;			            
							<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PREVENTION_HIV" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PREVENTION_HIV;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran(request,"web","hivtest",sWebLanguage) %>&nbsp;			            
						</td>			            
			            <td class='admin'><%=getTran(request,"web","ptme",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
							<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PTME_PROPOSED" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PTME_PROPOSED;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran(request,"web","proposed",sWebLanguage) %>&nbsp;			            
							<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PTME_ACCEPTED" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PTME_ACCEPTED;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran(request,"web","accepted",sWebLanguage) %>&nbsp;			            
							<input type="checkbox" class="hand" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PTME_DONE" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_PTME_DONE;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getTran(request,"web","performed",sWebLanguage) %>&nbsp;			            
						</td>			            
	        		</tr>
	        		<tr>
							<td class='admin'><%=getTran(request,"web","breastfeedingcounseling",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="4"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_BREASTFEEDING_COUNSELING", sWebLanguage, false, "", "") %></td>           
			           	</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","familyplanning",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="3">
			            	<%=getTran(request,"web","counseling",sWebLanguage)%>
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_FPCOUNSELING", sWebLanguage, false, "", "")%>
			            	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=getTran(request,"web","acceptation",sWebLanguage)%>
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_FPACCEPTATION", sWebLanguage, false, "", "")%>
			            	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=getTran(request,"web","method",sWebLanguage)%>
			            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_FPMETHOD", "msas.fpmethode", sWebLanguage, "") %>
			             </td>
	        		</tr> 
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","dischargedate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
	                        <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DISCHARGEDATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DISCHARGEDATE" property="value" formatType="date"/>" id="dischargedate" onblur='checkDate(this);' onchange='calculateDuration();' onfocus='calculateDuration();' onkeyup='calculateDuration();'/>
	                        <script>writeMyDate("dischargedate", "<c:url value="/_img/icons/icon_agenda.png"/>", "<%=getTran(null,"Web","PutToday",sWebLanguage)%>");</script>
			                <%=getTran(request,"web", "hour", sWebLanguage)%>
			                <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DISCHARGEHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DISCHARGEHOUR" property="value"/>" onblur="checkTime(this)">
			            <td class="admin" > <%=getTran(request,"web","admissionduration",sWebLanguage)%></td>
           	 					 <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran,"ITEM_TYPE_MSAS_DELIVERIES_ADMISSIONDURATION" , 3, 1, 100,sWebLanguage , "", "")%></td>
           		      
			            <tr>
			            <td class="admin"><%=getTran(request,"web", "consultation.observations", sWebLanguage)%></td>
			            <td colspan="3" class="admin2">
			                <textarea rows="2" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_OBSERVATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_OBSERVATIONS" property="value"/></textarea>
			            </td>
			        </tr>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child",sWebLanguage)%>&nbsp;</td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","presentation",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="4">  <%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_PRESENTATION", "msas.presentation",sWebLanguage, "")%>   </td>
			        </tr>
	        			<tr>
			            <td class='admin'><%=getTran(request,"web","deliverydate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'> <%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYDATE", sWebLanguage, sCONTEXTPATH) %>
	                         <%=getTran(request,"web", "hour", sWebLanguage)%>  &nbsp;&nbsp;&nbsp;
	                         <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYHOUR" property="value"/>" onblur="checkTime(this)">
			             </td>
			            <td class='admin'><%=getTran(request,"web","delivery.location",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYLOCATION", "msas.deliverylocation",sWebLanguage, "")%></td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","deliverytype",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE", "msas.deliverytype.cs",sWebLanguage, "")%>
			                &nbsp;<%=getTran(request,"msas","comment",sWebLanguage) %>: 
			                <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_COMMENT", 20) %>
			            </td>
			            <td class='admin'><%=getTran(request,"web","childbirthtype",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDBIRTHTYPE", "msas.childbirthtype",sWebLanguage, "")%>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","qualification",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="4"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_QUALIFICATION", "msas.qualification",sWebLanguage, "")%>
			             <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_MSAS_DELIVERIES_PARTOGRAMME", "") %><%=getTran(request,"web","partogrammedone",sWebLanguage) %>
			            </td>
			         </tr>
	        		<tr>
			            <td class="admin"><%=getTran(request,"web","child.cried",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_CRIED", sWebLanguage, false, "", "")%>
			            </td>
			            <td class='admin'><%=getTran(request,"web","childstatus",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.delivery.childstatus",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS"),sWebLanguage,false,true) %>
			                </select>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","infectionrisk",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_INFECTIONRISK", sWebLanguage, false, "", "")%>
			            </td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' >
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE", 10, 5, 50, sWebLanguage) %> cm
			            </td>
	        		</tr>
	        		<!--  Ajout d'un item ITEM_TYPE_MSAS_INFECTIONTREATMENT pour prendre en compte les infections traitées  et ITEM ITEM_TYPE_MSAS_DECES_AUDITES -->
	        		
	        		<tr>
	        		
	        		 <td class="admin"><%=getTran(request,"web","infection.treatment",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2' >
						            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_INFECTIONTREATMENT", 25) %>
						</td>
						 <td class='admin'><%=getTran(request,"web","decesaudites",sWebLanguage)%>&nbsp;</td>
				         <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DECES_AUDITES", sWebLanguage, false, "", "") %></td>
		        		
					</tr>
					<!--  fin ajout d'un item ITEM_TYPE_MSAS_INFECTIONTREATMENT pour prendre en compte les infections traitées  et ITEM ITEM_TYPE_MSAS_DECES_AUDITES  -->
	        		
	        		<tr>
	        		   			<td class='admin'><%=getTran(request,"web","newbornreferral",sWebLanguage)%>&nbsp;</td>
			            		<td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request,"yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREFERRAL", sWebLanguage, false, "", "") %></td> 
			             		<td class='admin'><%=getTran(request,"web","newbornantibiotic",sWebLanguage)%>&nbsp;</td>
	        			 		<td class="admin2"  ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNANTIBIOTIC", sWebLanguage, false, "", "") %></td>
	        		   </tr>
			           <tr>
	        		   				<td class='admin'><%=getTran(request,"web","newbornrevived",sWebLanguage)%>&nbsp;</td>
							 		<td class="admin2" colspan="4" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno","ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREVIVED", sWebLanguage, false, "", "") %></td>
	        		    </tr>
	        	  <tr>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.headcircumference",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEADCIRCUMFERENCE", 10, 10, 100, sWebLanguage) %> cm
			            </td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.thoraxcircumference",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_THORAXCIRCUMFERENCE", 10, 10, 200, sWebLanguage) %> cm
			            </td>
			        </tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.gender",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER"),sWebLanguage,false,true) %>
			                </select>
			            </td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_CHILDWEIGHT", 10, 0.1, 10, sWebLanguage) %></td>
	        		</tr>
	        				           
			           	<tr>
			           	<td class='admin'><%=getTran(request,"web","delivery.child.immediats",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.immediats", "ITEM_TYPE_MSAS_DELIVERIES_CARE_IMMEDIAT", sWebLanguage, false) %>
						</td>
			            <td class='admin'><%=getTran(request,"web","delivery.child.care",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.care", "ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED", sWebLanguage, false) %>
						</td>
									            
			           </tr>
	        		<tr>
	        		 <td class='admin'><%=getTran(request,"web","kangoroomethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO", sWebLanguage, false, "", "") %></td>
	        		
							<td class='admin'><%=getTran(request,"web","newbornweightkangoroomethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_NEWBORN", sWebLanguage, false, "", "") %></td>
	        				            
			           	</tr>
	        		<%
	        			String sChild2Display="none",sChild3Display="none";
	        			Iterator items = ((TransactionVO)transaction).getItems().iterator();
	        			while(items.hasNext()){
	        				ItemVO item = (ItemVO)items.next();
	        				if(item.getType().endsWith("_2") && SH.c(item.getValue()).length()>0){
	        					sChild2Display="";
	        				}
	        				else if(item.getType().endsWith("_3") && SH.c(item.getValue()).length()>0){
	        					sChild3Display="";
	        				}
	        			}
	        		%>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child2",sWebLanguage)%>&nbsp;<img id='img_child2' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='if(this.src.indexOf("plus.png")>-1){this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png";document.getElementById("child2").style.display="";}else{this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png";document.getElementById("child2").style.display="none";}'>&nbsp;</td>
	        		</tr>
	        		<tbody id='child2' style='display: <%=sChild2Display%>'>
	        			<tr>
			            <td class='admin'><%=getTran(request,"web","presentation",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="4">  <%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_PRESENTATION_2", "msas.presentation",sWebLanguage, "")%>   </td>
			        </tr>
	        			<tr>
			            <td class='admin'><%=getTran(request,"web","deliverydate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'> <%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYDATE_2", sWebLanguage, sCONTEXTPATH) %>
	                         <%=getTran(request,"web", "hour", sWebLanguage)%>  &nbsp;&nbsp;&nbsp;
        					<input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYHOUR_2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYHOUR_2" property="value"/>" onblur="checkTime(this)">
			             </td>
			            <td class='admin'><%=getTran(request,"web","delivery.location",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYLOCATION_2", "msas.deliverylocation",sWebLanguage, "")%></td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","deliverytype",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_2", "msas.deliverytype.cs",sWebLanguage, "")%>
			                &nbsp;<%=getTran(request,"msas","comment",sWebLanguage) %>: 
			                <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_COMMENT_2", 20) %>
			            </td>
			            <td class='admin'><%=getTran(request,"web","childbirthtype",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDBIRTHTYP_2", "msas.childbirthtype",sWebLanguage, "")%>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","qualification",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="4"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_QUALIFICATION_2", "msas.qualification",sWebLanguage, "")%>
			             <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_MSAS_DELIVERIES_PARTOGRAMME_2", "") %><%=getTran(request,"web","partogrammedone",sWebLanguage) %>
			            </td>
			         </tr>
	        			<tr>
				            <td class="admin"><%=getTran(request,"web","child.cried",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_CRIED_2", sWebLanguage, false, "", "")%>
				            </td>
				            <td class='admin'><%=getTran(request,"web","childstatus",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2", "msas.delivery.childstatus", sWebLanguage, "") %>
				            </td>
		        		</tr>
		        		<tr>
				            <td class='admin'><%=getTran(request,"web","infectionrisk",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_INFECTIONRISK_2", sWebLanguage, false, "", "")%>
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2' colspan='3'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE_2", 10, 5, 50, sWebLanguage) %> cm
				            </td>
		        		</tr>
		        		<!--  Ajout d'un item ITEM_TYPE_MSAS_INFECTIONTREATMENT pour prendre en compte les infections traitées  et ITEM ITEM_TYPE_MSAS_DECES_AUDITES  -->
	        		
		        		<tr>
	        		 <td class="admin"><%=getTran(request,"web","infection.treatment",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2' >
						            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_INFECTIONTREATMENT_2", 25) %>
						</td>
						 <td class='admin'><%=getTran(request,"web","decesaudites",sWebLanguage)%>&nbsp;</td>
				         <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DECES_AUDITES_2", sWebLanguage, false, "", "") %></td>
		        		
					</tr>
					<!--  fin Ajout d'un item ITEM_TYPE_MSAS_INFECTIONTREATMENT pour prendre en compte les infections traitées  et ITEM ITEM_TYPE_MSAS_DECES_AUDITES -->
	        		
		        		  <tr>
	        		   			<td class='admin'><%=getTran(request,"web","newbornreferral",sWebLanguage)%>&nbsp;</td>
			            		<td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request,"yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREFERRAL_2", sWebLanguage, false, "", "") %></td> 
			             		<td class='admin'><%=getTran(request,"web","newbornantibiotic",sWebLanguage)%>&nbsp;</td>
	        			 		<td class="admin2"  ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNANTIBIOTIC_2", sWebLanguage, false, "", "") %></td>
	        		 	  </tr>
			           <tr>
	        		   				<td class='admin'><%=getTran(request,"web","newbornrevived",sWebLanguage)%>&nbsp;</td>
							 		<td class="admin2" colspan="4" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno","ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREVIVED_2", sWebLanguage, false, "", "") %></td>
	        			            
			           </tr>
				        <tr>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.headcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEADCIRCUMFERENCE_2", 10, 10, 100, sWebLanguage) %> cm
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.thoraxcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_THORAXCIRCUMFERENCE_2", 10, 10, 200, sWebLanguage) %> cm
				            </td>
				        </tr>
		        		<tr>
				            <td class='admin'><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER_2", "msas.gender", sWebLanguage, "") %>
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_CHILDWEIGHT_2", 10, 0.1, 10, sWebLanguage) %></td>
		        		</tr>
		        		  	<tr>
			           	<td class='admin'><%=getTran(request,"web","careimmediats",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.immediats", "ITEM_TYPE_MSAS_DELIVERIES_CARE_IMMEDIAT_2", sWebLanguage, false) %>
						</td>
			            <td class='admin'><%=getTran(request,"web","careoffered",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.care", "ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED_2", sWebLanguage, false) %>
						</td>
						 </tr>
		        		<tr>		            
				            <td class='admin'><%=getTran(request,"web","kangoroomethod",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_2", sWebLanguage, false, "", "") %></td>
		        			<td class='admin'><%=getTran(request,"web","newbornweightkangoroomethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_NEWBORN_2", sWebLanguage, false, "", "") %></td>
	        				            
			           	</tr>
				    </tbody>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child3",sWebLanguage)%>&nbsp;<img id='img_child2' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='if(this.src.indexOf("plus.png")>-1){this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png";document.getElementById("child3").style.display="";}else{this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png";document.getElementById("child3").style.display="none";}'>&nbsp;</td>
	        		</tr>
	        		<tbody id='child3' style='display: <%=sChild3Display%>'>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","presentation",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="4">  <%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_PRESENTATION_3", "msas.presentation",sWebLanguage, "")%>   </td>
			        </tr>
	        			<tr>
			            <td class='admin'><%=getTran(request,"web","deliverydate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'> <%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYDATE_3", sWebLanguage, sCONTEXTPATH) %>
	                         <%=getTran(request,"web", "hour", sWebLanguage)%>  &nbsp;&nbsp;&nbsp;
        					<input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYHOUR_3" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYHOUR_3" property="value"/>" onblur="checkTime(this)">
			              </td>
			            <td class='admin'><%=getTran(request,"web","delivery.location",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYLOCATION_3", "msas.deliverylocation",sWebLanguage, "")%></td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","deliverytype",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_3", "msas.deliverytype.cs",sWebLanguage, "")%>
			                &nbsp;<%=getTran(request,"msas","comment",sWebLanguage) %>: 
			                <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_COMMENT_3", 20) %>
			            </td>
			            <td class='admin'><%=getTran(request,"web","childbirthtype",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDBIRTHTYP_3", "msas.childbirthtype",sWebLanguage, "")%>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","qualification",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="4"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_QUALIFICATION_3", "msas.qualification",sWebLanguage, "")%>
			             <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_MSAS_DELIVERIES_PARTOGRAMME_3", "") %><%=getTran(request,"web","partogrammedone",sWebLanguage) %>
			            </td>
			         </tr>
		        		<tr>
				            <td class="admin"><%=getTran(request,"web","child.cried",sWebLanguage)%>&nbsp;</td>
				           
				            <td class="admin2">
				            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_CRIED_3", sWebLanguage, false, "", "")%>
				            </td>
				            <td class='admin'><%=getTran(request,"web","childstatus",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3", "msas.delivery.childstatus", sWebLanguage, "") %>
				            </td>
		        		</tr>
		        		<tr>
				            <td class='admin'><%=getTran(request,"web","infectionrisk",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_INFECTIONRISK_3", sWebLanguage, false, "", "")%>
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2' colspan='3'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE_3", 10, 5, 50, sWebLanguage) %> cm
				            </td>
		        		</tr>
		        			<!--  Ajout d'un item ITEM_TYPE_MSAS_INFECTIONTREATMENT pour prendre en compte les infections traitées  et ITEM ITEM_TYPE_MSAS_DECES_AUDITES -->
	        		
		        		<tr>
	        		 <td class="admin"><%=getTran(request,"web","infection.treatment",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2' >
						            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_INFECTIONTREATMENT_3", 25) %>
						</td>
						 <td class='admin'><%=getTran(request,"web","decesaudites",sWebLanguage)%>&nbsp;</td>
				         <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DECES_AUDITES_3", sWebLanguage, false, "", "") %></td>
		        		
					</tr>
					<!--  fin Ajout d'un item ITEM_TYPE_MSAS_INFECTIONTREATMENT pour prendre en compte les infections traitées et ITEM ITEM_TYPE_MSAS_DECES_AUDITES -->
	        		
		        		 <tr>
	        		   			<td class='admin'><%=getTran(request,"web","newbornreferral",sWebLanguage)%>&nbsp;</td>
			            		<td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request,"yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREFERRAL_3", sWebLanguage, false, "", "") %></td> 
			             		<td class='admin'><%=getTran(request,"web","newbornantibiotic",sWebLanguage)%>&nbsp;</td>
	        			 		<td class="admin2"  ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNANTIBIOTIC_3", sWebLanguage, false, "", "") %></td>
	        		  </tr>
			           <tr>
	        		   				<td class='admin'><%=getTran(request,"web","newbornrevived",sWebLanguage)%>&nbsp;</td>
							 		<td class="admin2" colspan="4" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno","ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREVIVED_3", sWebLanguage, false, "", "") %></td>
	        		 </tr>
				        <tr>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.headcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEADCIRCUMFERENCE_3", 10, 10, 100, sWebLanguage) %> cm
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.thoraxcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_THORAXCIRCUMFERENCE_3", 10, 10, 200, sWebLanguage) %> cm
				            </td>
				        </tr>
		        		<tr>
				            <td class='admin'><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER_3", "msas.gender", sWebLanguage, "") %>
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_CHILDWEIGHT_3", 10, 0.1, 10, sWebLanguage) %></td>
		        		</tr>
		        		 	<tr>
			           	<td class='admin'><%=getTran(request,"web","careimmediats",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.immediats", "ITEM_TYPE_MSAS_DELIVERIES_CARE_IMMEDIAT_3", sWebLanguage, false) %>
						</td>
			            <td class='admin'><%=getTran(request,"web","careoffered",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.care", "ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED_3", sWebLanguage, false) %>
						</td>
					  </tr>
		        		<tr>			            
				            <td class='admin'><%=getTran(request,"web","kangoroomethod",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_3", sWebLanguage, false, "", "") %></td>
		        			<td class='admin'><%=getTran(request,"web","newbornweightkangoroomethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_NEWBORN_3", sWebLanguage, false, "", "") %></td>
	        				</tr>
				    </tbody>
					<tr>
						<td valign="top" colspan="4">
					      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
						</td>
					</tr>
	            </table>
	        </td>
        </tr>
    </table>
            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"msas.registry.deliveries",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
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
  
  function calculateDuration(){
    var arrivaldate = new Date();
    var d1 = document.getElementById('arrivaldate').value.split("/");
    if(d1.length == 3){
        // actual transaction date
        arrivaldate.setDate(d1[0]);
        arrivaldate.setMonth(d1[1] - 1);
        arrivaldate.setFullYear(d1[2]);
        var disdate = new Date();
        var d1 = document.getElementById('dischargedate').value.split("/");
        if(d1.length == 3){
        	disdate.setDate(d1[0]);
        	disdate.setMonth(d1[1] - 1);
        	disdate.setFullYear(d1[2]);
            //Calculate number of days elapsed between admission date and discharge date 
            var timeElapsed = disdate.getTime() - arrivaldate.getTime();
            timeElapsed = timeElapsed / (1000 * 3600 * 24);
    		if (!isNaN(timeElapsed) && timeElapsed >= 0) {
    			document.getElementById("admissionduration").innerHTML=timeElapsed;
    			document.getElementById("admduration").value=timeElapsed;
    		}
        }
    }
  }
  
  calculateDuration();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>
