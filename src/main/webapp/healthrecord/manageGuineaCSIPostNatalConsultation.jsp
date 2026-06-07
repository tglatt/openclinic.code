
<%@page errorPage="/includes/error.jsp"%>
<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO,
                be.mxs.common.model.vo.healthrecord.ItemVO,
                be.openclinic.pharmacy.Product,
                java.text.DecimalFormat,
                be.openclinic.medical.Problem,
                be.openclinic.medical.Diagnosis,
                be.openclinic.system.Transaction,
                be.openclinic.system.Item,
                be.openclinic.medical.Prescription,
                java.util.*" %>
<%@ page import="java.sql.Date" %>
<%@ page import="be.openclinic.medical.PaperPrescription" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"mshp.csi.cpon","select",activeUser)%>

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
        	<td width="50%" valign='top'>
	        	<table width='100%'>
	        	<tr>
	        			
						<td class='admin'><%=getTran(request,"web","yearnum",sWebLanguage) %></td>
        				<td class='admin2' colspan="3"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_YEARNUM",10, 1)%></td>
        		
			      
			        </tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","age.mother",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><b><%=activePatient.getAgeOnDate(((TransactionVO)transaction).getUpdateTime()) %></b> <%=getTran(request,"web","years",sWebLanguage).toLowerCase() %></td>
			            <td class='admin'><%=getTran(request,"web","parity",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><input class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_PARITY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_PARITY" property="value"/>"/></td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web.msas","deliverydate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
	                        <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_DELIVERYDATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_DELIVERYDATE" property="value" formatType="date"/>" id="deliverydate" onblur='checkDate(this);' onchange='calculateAge();' onfocus='calculateAge();' onkeyup='calculateAge();'/>
	                        <script>writeMyDate("deliverydate", "<c:url value="/_img/icons/icon_agenda.png"/>", "<%=getTran(null,"Web","PutToday",sWebLanguage)%>");</script>
			            </td>
			            <td class='admin'><%=getTran(request,"web","delivery.location",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_DELIVERYLOCATION" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.deliverylocation",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_DELIVERYLOCATION"),sWebLanguage,false,true) %>
			                </select>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","delivery.type",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_DELIVERYTYPE" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.deliverytype",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_DELIVERYTYPE"),sWebLanguage,false,true) %>
			                </select>
			            </td>
			            <td class='admin'><%=getTran(request,"web","cpon.order",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBox(tran, request, "yesno", "ITEM_TYPE_PRELIMINARY", sWebLanguage, "") %><%=getTran(request,"web","preliminary",sWebLanguage) %>
			            	<br/><span id="cponorder" name="cponorder"></span>
			            	<input type="hidden" id="cponorderfield" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CPONORDER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CPONORDER" property="value"/>"/>
			            </td>
	        		</tr>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child",sWebLanguage)%>&nbsp;</td>
	        		</tr>
			        <tr>
			            <td class='admin'><%=getTran(request,"Web.Occup","seen",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_CHILDSEEN", sWebLanguage, sCONTEXTPATH) %>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_WEIGHT", 10, 0, 150, sWebLanguage) %> kg
			            </td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEIGHT", 10, 0, 250, sWebLanguage) %> cm
			            </td>
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
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' >
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE", 10, 5, 50, sWebLanguage) %> cm
			            </td>
			            <!--AJOUTER LE 04 02 2025 / DEBUT -->
			            
			             <td class='admin'><%=getTran(request,"web","sousmethodkangorou",sWebLanguage)%>&nbsp;</td>
				         <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_SOUS_DELIVERIES_SOUS_METHOD_KANGOROU", sWebLanguage, false, "", "") %></td>
		        		<!--AJOUTER LE 04 02 2025 / FIN -->
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","temperature",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><input class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TEMPERATURE" property="value"/>"/>°C</td>
			            <td class='admin' rowspan="2"><%=getTran(request,"web","child.status",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" rowspan="2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_CHILDSTATUS" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.childstatus",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_CHILDSTATUS"),sWebLanguage,false,true) %>
			                </select><br/>
			                <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_MSAS_POSTNATAL_CHILDASPHYXIA", sWebLanguage, "") %><%=getTran(request,"web","asphyxia",sWebLanguage)%>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "gender", "ITEM_TYPE_MSAS_POSTNATAL_CHILDGENDER", sWebLanguage, false, "", "") %></td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","umbilicus.status",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_UMBILICUSSTATUS" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.umbilicusstatus",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_UMBILICUSSTATUS"),sWebLanguage,false,true) %>
			                </select>
			            </td>
			            <td class="admin"><%=getTran(request,"web","infection.treatment",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><input class="text" type="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_INFECTIONTREATMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_INFECTIONTREATMENT" property="value"/>"/></td>
			        </tr>
			        <tr>
			            <td class='admin'><%=getTran(request,"web","bcg",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_BCG", sWebLanguage, sCONTEXTPATH) %>
			            </td>
			            <td class='admin'><%=getTran(request,"web","polio",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_POLIO", sWebLanguage, sCONTEXTPATH) %>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin'><%=getTran(request,"web","hepatitisb",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_HEPATITISB", sWebLanguage, sCONTEXTPATH) %>
			            </td>
			            <td class="admin"><%=getTran(request,"web","milda",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_MILDA" property="itemId"/>]>.value" value="medwan.common.true"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_MILDA;value=medwan.common.true"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","yes",sWebLanguage) %></label>
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_MILDA" property="itemId"/>]>.value" value="medwan.common.false"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_MILDA;value=medwan.common.false"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","no",sWebLanguage) %></label>
			            </td>
			        </tr>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child2",sWebLanguage)%>&nbsp;<img id='img_child2' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='if(this.src.indexOf("plus.png")>-1){this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png";document.getElementById("child2").style.display="";}else{this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png";document.getElementById("child2").style.display="none";}'>&nbsp;</td>
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
	        		<tr id='child2' style='display: <%=sChild2Display%>'>
	        			<td colspan='4'>
	        				<table width='100%'>
						        <tr>
						            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_WEIGHT_2", 10, 0, 150, sWebLanguage) %> kg
						            </td>
						            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEIGHT_2", 10, 0, 250, sWebLanguage) %> cm
						            </td>
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
						            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2' >
						            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE_2", 10, 5, 50, sWebLanguage) %> cm
						            </td>
						            
			             <td class='admin'><%=getTran(request,"web","sousmethodkangorou",sWebLanguage)%>&nbsp;</td>
				         <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_SOUS_DELIVERIES_SOUS_METHOD_KANGOROU_2", sWebLanguage, false, "", "") %></td>
		        		
						        </tr>
					        	<tr>
						            <td class="admin"><%=getTran(request,"web","temperature",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_TEMPERATURE_2", 10, 20, 50, sWebLanguage) %>
						            <td class='admin' rowspan="2"><%=getTran(request,"web","child.status",sWebLanguage)%>&nbsp;</td>
						            <td class="admin2" rowspan="2">
						            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_CHILDSTATUS_2", "msas.childstatus", sWebLanguage, "") %><br/>
						                <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_MSAS_POSTNATAL_CHILDASPHYXIA_2", sWebLanguage, "") %><%=getTran(request,"web","asphyxia",sWebLanguage)%>
						            </td>
						        </tr>
					        	<tr>
						            <td class="admin"><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "gender", "ITEM_TYPE_MSAS_POSTNATAL_CHILDGENDER_2", sWebLanguage, false, "", "") %></td>
						        </tr>
					        	<tr>
						            <td class='admin'><%=getTran(request,"web","umbilicus.status",sWebLanguage)%>&nbsp;</td>
						            <td class="admin2">
						            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_UMBILICUSSTATUS_2", "msas.umbilicusstatus", sWebLanguage, "") %>
						            </td>
						            <td class="admin"><%=getTran(request,"web","infection.treatment",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_INFECTIONTREATMENT_2", 25) %>
						            </td>
						        </tr>
						        <tr>
						            <td class='admin'><%=getTran(request,"web","bcg",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_BCG_2", sWebLanguage, sCONTEXTPATH) %>
						            </td>
						            <td class='admin'><%=getTran(request,"web","polio",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_POLIO_2", sWebLanguage, sCONTEXTPATH) %>
						            </td>
						        </tr>
						        <tr>
						            <td class='admin'><%=getTran(request,"web","hepatitisb",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_HEPATITISB_2", sWebLanguage, sCONTEXTPATH) %>
						            </td>
						            <td class="admin"><%=getTran(request,"web","milda",sWebLanguage)%>&nbsp;</td>
						            <td class="admin2">
						            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "truefalse", "ITEM_TYPE_MSAS_POSTNATAL_MILDA_2", sWebLanguage, false, "", "") %>
						            </td>
						        </tr>
	        				</table>
	        			</td>
	        		</tr>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child3",sWebLanguage)%>&nbsp;<img id='img_child3' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='if(this.src.indexOf("plus.png")>-1){this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png";document.getElementById("child3").style.display="";}else{this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png";document.getElementById("child3").style.display="none";}'>&nbsp;</td>
	        		</tr>
	        		<tr id='child3' style='display: <%=sChild3Display%>'>
	        			<td colspan='4'>
	        				<table width='100%'>
						        <tr>
						            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_WEIGHT_3", 10, 0, 150, sWebLanguage) %> kg
						            </td>
						            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEIGHT_3", 10, 0, 250, sWebLanguage) %> cm
						            </td>
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
						            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2' >
						            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE_3", 10, 5, 50, sWebLanguage) %> cm
						            </td>
						            
			             <td class='admin'><%=getTran(request,"web","sousmethodkangorou",sWebLanguage)%>&nbsp;</td>
				         <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_SOUS_DELIVERIES_SOUS_METHOD_KANGOROU_3", sWebLanguage, false, "", "") %></td>
		        		
						        </tr>
					        	<tr>
						            <td class="admin"><%=getTran(request,"web","temperature",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_TEMPERATURE_3", 10, 20, 50, sWebLanguage) %>
						            <td class='admin' rowspan="2"><%=getTran(request,"web","child.status",sWebLanguage)%>&nbsp;</td>
						            <td class="admin2" rowspan="2">
						            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_CHILDSTATUS_3", "msas.childstatus", sWebLanguage, "") %><br/>
						                <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_MSAS_POSTNATAL_CHILDASPHYXIA_3", sWebLanguage, "") %><%=getTran(request,"web","asphyxia",sWebLanguage)%>
						            </td>
						        </tr>
					        	<tr>
						            <td class="admin"><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "gender", "ITEM_TYPE_MSAS_POSTNATAL_CHILDGENDER_3", sWebLanguage, false, "", "") %></td>
						        </tr>
					        	<tr>
						            <td class='admin'><%=getTran(request,"web","umbilicus.status",sWebLanguage)%>&nbsp;</td>
						            <td class="admin2">
						            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_UMBILICUSSTATUS_3", "msas.umbilicusstatus", sWebLanguage, "") %>
						            </td>
						            <td class="admin"><%=getTran(request,"web","infection.treatment",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_INFECTIONTREATMENT_3", 25) %>
						            </td>
						        </tr>
						        <tr>
						            <td class='admin'><%=getTran(request,"web","bcg",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_BCG_3", sWebLanguage, sCONTEXTPATH) %>
						            </td>
						            <td class='admin'><%=getTran(request,"web","polio",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_POLIO_3", sWebLanguage, sCONTEXTPATH) %>
						            </td>
						        </tr>
						        <tr>
						            <td class='admin'><%=getTran(request,"web","hepatitisb",sWebLanguage)%>&nbsp;</td>
						            <td class='admin2'>
						            	<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_HEPATITISB_3", sWebLanguage, sCONTEXTPATH) %>
						            </td>
						            <td class="admin"><%=getTran(request,"web","milda",sWebLanguage)%>&nbsp;</td>
						            <td class="admin2">
						            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "truefalse", "ITEM_TYPE_MSAS_POSTNATAL_MILDA_3", sWebLanguage, false, "", "") %>
						            </td>
						        </tr>
	        				</table>
	        			</td>
	        		</tr>
					<tr>
						<td colspan="4">
					      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
						</td>
					</tr>
	            </table>
	        </td>
	        <%-- DIAGNOSES --%>
	    	<td valign="top">
	    		<table width="100%">
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","mother",sWebLanguage)%>&nbsp;</td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web.occup","seen",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan='3'>
			            	<%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_MOTHERSEEN", sWebLanguage, sCONTEXTPATH) %>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_MOTHERWEIGHT")%> id="weight" class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MOTHERWEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MOTHERWEIGHT" property="value"/>"/></td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_MOTHERHEIGHT")%> class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MOTHERHEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MOTHERHEIGHT" property="value"/>"/></td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","temperature",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><input class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOTHERTEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOTHERTEMPERATURE" property="value"/>"/>°C</td>
			            <td class="admin"><%=getTran(request,"web","pulse",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><input class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOTHERPULSE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOTHERPULSE" property="value"/>"/></td>
			        </tr>
			        <tr>
			            
			           
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","bloodpressure",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' > 
			            	<input class="text" type="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOTHERSYSTOLICBP" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOTHERSYSTOLICBP" property="value"/>"/>/
			            	<input class="text" type="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOTHERDIASTOLICBP" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOTHERDIASTOLICBP" property="value"/>"/>mmHg
			            </td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' >
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_MOTHER_ARM_CIRCUMFERENCE", 10, 25, 50, sWebLanguage) %> cm
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","generalstatus",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERGENERALSTATUS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERGENERALSTATUS" property="value"/></textarea>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","mucosa",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERMUCOSA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERMUCOSA" property="value"/></textarea>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","oedema",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHEROEDEMA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHEROEDEMA" property="value"/></textarea>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","breasts",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERBREASTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERBREASTS" property="value"/></textarea>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","uterus.inversion",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERUTERUSINVERSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERUTERUSINVERSION" property="value"/></textarea>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","tv",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERTV" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_MOTHERTV" property="value"/></textarea>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","fistula",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			                <%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.fistula", "ITEM_TYPE_MSAS_POSTNATAL_FISTULA", sWebLanguage, false) %>
			                <br/><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.fistula.treatment", "ITEM_TYPE_MSAS_POSTNATAL_FISTULA_TREATMENT", sWebLanguage, false) %>
			            </td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","mothercondition",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="3">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.mothercondition", "ITEM_TYPE_MSAS_POSTNATAL_MOTHERCONDITION", sWebLanguage, true) %>
			                <br/>
			                <%=getTran(request,"web","other",sWebLanguage) %>: 
			                 <%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_MOTHER_CONDITION_OTHER", 30, 3)%>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","vat",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MOTHERVAT", "msas.vatrank", sWebLanguage, "") %>
			            </td>
			            <td class="admin"><%=getTran(request,"web","iron",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_IRON" property="itemId"/>]>.value" value="medwan.common.true"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_IRON;value=medwan.common.true"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","yes",sWebLanguage) %></label>
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_IRON" property="itemId"/>]>.value" value="medwan.common.false"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_IRON;value=medwan.common.false"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","no",sWebLanguage) %></label>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web","vita",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_VITA", sWebLanguage, "") %>
			            </td>
			            <td class="admin"><%=getTran(request,"web","milda",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_MILDA", sWebLanguage, "") %>
			            </td>
			        </tr>
			        <tr><td colspan='4'><hr/></td></tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web","hivstatus",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_HIVSTATUS", "gn.hivstatus", sWebLanguage, "") %>
			            </td>
			            <td class="admin"><%=getTran(request,"web","pretestcounceling",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_PRETESTCOUNCELING", sWebLanguage, "") %>
			            </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","hivtest",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" >
			            	<%=SH.writeDefaultRadioButtons(tran, request, "posnegundetermined", "ITEM_TYPE_MSAS_POSTNATAL_HIV", sWebLanguage, false, "", "") %>
			            </td>
   						<td class="admin"   ><%=getTran(request,"web","motherptme",sWebLanguage)%></td>
   					    <td class="admin2" ><%=SH.writeDefaultCheckBoxes(tran, request, "motherptme", "ITEM_TYPE_MSAS_POSTNATAL_MOTHER_PTME", sWebLanguage, true)%></td>
           	 		</tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web","dateresultreceived",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DATE_RESUKT_RECEIVED", sWebLanguage, sCONTEXTPATH) %>
			            </td>
			            <td class="admin"><%=getTran(request,"web","posttestcounceling",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_POSTTESTCOUNCELING", sWebLanguage, "") %>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin" colspan='3'><%=getTran(request,"web","onsitecare",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ONSITECARE", sWebLanguage, "") %>
			            </td>
			        </tr>
			        <tr><td colspan='4'><hr/></td></tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","breastfeeding",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_BREASTFEEDING" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.breastfeeding",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_BREASTFEEDING"),sWebLanguage,false,true) %>
			                </select>
			            </td>
			            <td class='admin'><%=getTran(request,"web","contraception",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_CONTRACEPTION" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.contraception",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_CONTRACEPTION"),sWebLanguage,false,true) %>
			                </select>
			            </td>
			        </tr>
			        <tr>
    						<td class="admin"   ><%=getTran(request,"web","conseelingananje",sWebLanguage)%></td>
          					  <td class="admin2" colspan="3" ><%=SH.writeDefaultCheckBoxes(tran, request, "conseelingananje", "ITEM_TYPE_MSAS_POSTNATAL_MOTHER_CONSEELIN_AN_ANJE", sWebLanguage, true)%></td>
		
           	 </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","pf.analysis",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_PFANALYSIS" property="itemId"/>]>.value" value="medwan.common.true"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_PFANALYSIS;value=medwan.common.true"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","yes",sWebLanguage) %></label>
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_PFANALYSIS" property="itemId"/>]>.value" value="medwan.common.false"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_PFANALYSIS;value=medwan.common.false"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","no",sWebLanguage) %></label>
			            </td>
			            <td class='admin'><%=getTran(request,"web","pf.followup",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_PFFOLLOWUP" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.pf",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_PFFOLLOWUP"),sWebLanguage,false,true) %>
			                </select>
			            </td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","method",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_PFMETHOD", 30) %>
			            </td>
			            <td class="admin"><%=getTran(request,"web","pf.timing",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.pftiming", "ITEM_TYPE_MSAS_POSTNATAL_PFTIMING", sWebLanguage, false, "", "") %>
			            </td>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"web","sentby",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_SENTBY", 30) %>
			            </td>
			            <td class="admin"><%=getTran(request,"web","referredto",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_POSTNATAL_REFERREDTO", 30) %>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web", "consultation.observations", sWebLanguage)%></td>
			            <td colspan="3" class="admin2">
			                <textarea rows="2" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_OBSERVATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_POSTNATAL_OBSERVATIONS" property="value"/></textarea>
			            </td>
			        </tr>
	    		</table>
	    	</td>
        </tr>
    </table>
            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"msas.registry.postnatal",sWebLanguage)%>
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
  
  function calculateAge(){
    var trandate = new Date();
    var d1 = document.getElementById('trandate').value.split("/");
    if(d1.length == 3){
        // actual transaction date
        trandate.setDate(d1[0]);
        trandate.setMonth(d1[1] - 1);
        trandate.setFullYear(d1[2]);
        var deldate = new Date();
        var d1 = document.getElementById('deliverydate').value.split("/");
        if(d1.length == 3){
        	deldate.setDate(d1[0]);
        	deldate.setMonth(d1[1] - 1);
        	deldate.setFullYear(d1[2]);
            //Calculate number of days elapsed between last menstruation date and actual transaction date 
            var timeElapsed = trandate.getTime() - deldate.getTime();
            timeElapsed = timeElapsed / (1000 * 3600 * 24);
    		if (!isNaN(timeElapsed) && timeElapsed >= 0 && timeElapsed < 3) {
    			document.getElementById("cponorder").innerHTML="<b>CPoN 1 / J1-J3</b>";
    			document.getElementById("cponorderfield").value="CPoN 1 (J1-J3)";
    		}
    		else if (!isNaN(timeElapsed) && timeElapsed >= 3 && timeElapsed < 8) {
    			document.getElementById("cponorder").innerHTML="<b>CPoN 1 / J4-J8</b>";
    			document.getElementById("cponorderfield").value="CPoN 1 (J4-J8)";
    		}
    		else if (!isNaN(timeElapsed) && timeElapsed >= 8 && timeElapsed < 15) {
    			document.getElementById("cponorder").innerHTML="<b>CPoN 2 / J9-J15</b>";
    			document.getElementById("cponorderfield").value="CPoN 2 (J9-J15)";
    		}
    		else if (!isNaN(timeElapsed) && timeElapsed >= 15 && timeElapsed < 41) {
    			document.getElementById("cponorder").innerHTML="<b>CPoN 3 / J16-J41</b>";
    			document.getElementById("cponorderfield").value="CPoN 3 (J16-J41)";
    		}
    		else if (!isNaN(timeElapsed) && timeElapsed >= 41) {
    			document.getElementById("cponorder").innerHTML="<b>CPoN 3 / J42</b>";
    			document.getElementById("cponorderfield").value="CPoN 3 (J42)";
    		}
        }
    }
  }
  
  calculateAge();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>