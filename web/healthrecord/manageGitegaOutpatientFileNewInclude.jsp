<%@ page import="be.openclinic.medical.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!

//--- GET KEYWORDS HTML -----------------------------------------------------------------------
	private String getKeywordsHTML(TransactionVO transaction, String itemId, String textField,
			                       String idsField, String language){
		StringBuffer sHTML = new StringBuffer();
		ItemVO item = transaction.getItem(itemId);
		if(item!=null && item.getValue()!=null && item.getValue().length()>0){
			String[] ids = item.getValue().split(";");
			String keyword = "";
			
			for(int n=0; n<ids.length; n++){
				if(ids[n].split("\\$").length==2){
					keyword = getTran(null,ids[n].split("\\$")[0],ids[n].split("\\$")[1] , language);
					
					sHTML.append("<a href='javascript:deleteKeyword(\"").append(idsField).append("\",\"").append(textField).append("\",\"").append(ids[n]).append("\");'>")
					      .append("<img width='8' src='"+sCONTEXTPATH+"/_img/themes/default/erase.png' class='link' style='vertical-align:-1px'/>")
					     .append("</a>")
					     .append("&nbsp;<b>").append(keyword.startsWith("/")?keyword.substring(1):keyword).append("</b> | ");
				}
			}
		}
		
		String sHTMLValue = sHTML.toString();
		if(sHTMLValue.endsWith("| ")){
			sHTMLValue = sHTMLValue.substring(0,sHTMLValue.lastIndexOf("| "));
		}
		
		return sHTMLValue;
	}

%>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <% TransactionVO tran = (TransactionVO)transaction; %>
	
    <table class="list" width='100%' cellpadding="1" cellspacing="1"> 
        <%-- VITAL SIGNS --%>
        <tr>
            <td class="admin" rowspan='3'><%=getTran(request,"Web.Occup","rmh.vital.signs",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" rowspan='3'>
            	<table width="100%">
            		<tr>
            			<td nowrap><b><%=getTran(request,"openclinic.chuk","temperature",sWebLanguage)%>:</b></td><td nowrap><input id='temperature' type="text" class="text" <%=setRightClick(session,"[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(25,45,this)){alertDialog('Web.Occup','medwan.common.unrealistic-value');}};checkFields();" size="5"/> °C</td>
            			<td nowrap><b><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_HEIGHT")%> id="height" class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>" onBlur="calculateBMI();"/> cm</td>
            			<td nowrap><b><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%> id="weight" class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>" onBlur="calculateBMI();"/> kg</td>
            			<td nowrap><b><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.bmi",sWebLanguage)%>:</b></td><td nowrap><input id="BMI" class="text" type="text" size="5" name="BMI" readonly /></td>
            		</tr>
	                <tr>
			            <td nowrap><b><%=getTran(request,"openclinic.chuk","sao2",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClick(session,"[GENERAL.ANAMNESE]ITEM_TYPE_SATURATION")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SATURATION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SATURATION" property="value"/>"/> %</td>
			            <td nowrap><b><%=getTran(request,"web","abdomencircumference",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClick(session,"ITEM_TYPE_ABDOMENCIRCUMFERENCE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMENCIRCUMFERENCE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMENCIRCUMFERENCE" property="value"/>"/> cm</td>
			            <td nowrap><b><%=getTran(request,"web","fhr",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClick(session,"ITEM_TYPE_FOETAL_HEARTRATE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOETAL_HEARTRATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOETAL_HEARTRATE" property="value"/>"/></td>
			            <td nowrap><b><%=getTran(request,"web","armcircumferenceshort",sWebLanguage)%>:</b></td><td nowrap><%= SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE", 5, 0, 100, sWebLanguage) %> cm</td>
	                </tr>
            		<tr>
            			<td nowrap colspan='2'><b><%=getTran(request,"Web.Occup","medwan.healthrecord.cardial.pression-arterielle",sWebLanguage)%>:</b></td>
            			<td nowrap colspan='2'><b><%=getTran(request,"openclinic.chuk","respiratory.frequency",sWebLanguage)%>:</b></td>
            			<td nowrap colspan='2'><b><%=getTran(request,"Web.Occup","medwan.healthrecord.cardial.frequence-cardiaque",sWebLanguage)%>:</b></td>
            			<td nowrap colspan='2'><b><%=getTran(request,"Web.Occup","medwan.healthrecord.weightforlength",sWebLanguage)%></b></td>
            		</tr>
            		<tr>
            			<td nowrap colspan='2'><input id="sbpr" <%=setRightClick(session,"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> / <input id="dbpr" <%=setRightClick(session,"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> mmHg</td>
            			<td nowrap colspan='2'><input type="text" class="text" <%=setRightClick(session,"[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY" property="value"/>" onBlur="isNumber(this)" size="5"/> /min</td>
            			<td nowrap colspan='2'><input <%=setRightClick(session,"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="value"/>" onblur="setHF(this);"> /min</td>
            			<td nowrap colspan='2'><input tabindex="-1" class="text" type="text" size="4" readonly name="WFL" id="WFL"><img id="wflinfo" style='display: none' src="<c:url value='/_img/icons/icon_info.gif'/>"/></td>
            		</tr>
            	</table>
            </td>
            <td class="admin"><%=getTran(request,"Web.Occup","rmh.clinical.patienttype",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<table width='100%'>
            		<tr valign='top'>
            			<td>
			                <select class="text" id='patienttype' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_PATIENTTYPE" property="itemId"/>]>.value">
			                	<%=ScreenHelper.writeSelect(request,"outpatient.type",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_PATIENTTYPE"),sWebLanguage) %>
			                </select>
            			</td>
            			<td>
			                <select class="text" id='patienttype2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_PATIENTTYPE2" property="itemId"/>]>.value">
								<option/>
			                	<%=ScreenHelper.writeSelect(request,"outpatient.type3",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_PATIENTTYPE2"),sWebLanguage) %>
			                </select>
			                <%=ScreenHelper.writeDefaultCheckBoxes((TransactionVO)transaction, request, "outpatient.type4", "ITEM_TYPE_RMH_PATIENTTYPE4", sWebLanguage, false) %>
            			</td>
            		</tr>
            		<tr>
            			<td>
			                <%=getTran(request,"web","pregnancyduration",sWebLanguage) %>
            			</td>
            			<td>
	            			<input id="ITEM_TYPE_PREGNANCYDURATION" <%=setRightClick(session,"ITEM_TYPE_DELIVERY_AGE")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE" property="value"/>" > <%=getTran(request,"web","weeks",sWebLanguage) %>
            			</td>
            		</tr>
            	</table>
            </td>
        </tr>
        <tr>
			<td class='admin'><%=getTran(request,"web", "consultation.performed.by", sWebLanguage)%></td>
			<td class='admin2' colspan="2">
				<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "caregiver.type", "ITEM_TYPE_CONSULTATION_PERFORMED_BY", sWebLanguage, false, "", "") %>
			</td>
        </tr>
		<tr>
			<td class='admin'><%=getTran(request,"gynecology", "timemdcalled", sWebLanguage)%></td>
			<td class='admin2'>
				<table width='100%' cellpadding="0" cellspacing="0">
					<tr>
						<td class='admin2'><%=ScreenHelper.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_DELIVERY_MD_CALLED", 5) %> h</td>
						<td class='admin' width='1%' nowrap><%=getTran(request,"gynecology", "timemdarrived", sWebLanguage)%>&nbsp;&nbsp;&nbsp;</td>
						<td class='admin2'><%=ScreenHelper.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_DELIVERY_MD_ARRIVED", 5) %> h</td>
					</tr>
				</table>
			</td>
		</tr>
    </table>
    <div style="padding-top:5px;"></div>
    
    <%-- KEYWORDS for DIAGNOSES -----------------------------------------------------------------%>
    <table class="list" width='100%' cellpadding="1" cellspacing="1">
        <tr> 
         	<td class="admin2" colspan='3' width='70%' style="vertical-align:top;padding:0px;">
         		<table width="100%" cellpadding="1" cellspacing="1">
			        <tr>
			            <td class="admin"><%=getTran(request,"Web.Occup","antecedents",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
						                <textarea <%=SH.cdm() %> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_CLINICALHISTORY")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_CLINICALHISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_CLINICALHISTORY" property="value"/></textarea>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>
         			<%-- Functional signs --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title1"><%=getTran(request,"web","functional.signs",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("functional.signs.ids","functional.signs.text","ikirezi2.functional.signs","keywords",this)'>
			         				<td class='admin2'>
			         					<textarea <%=SH.cdm("functional.signs.ids") %> class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_COMMENT" property="itemId"/>]>.value" id='functional.signs.comment' cols='45' ><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_COMMENT" property="value"/></textarea>
			         				</td>
			         				<td class='admin2' width='1%' nowrap style="text-align:center">
			         				    <img width='16' id='key1' class="link" src='<c:url value="/_img/themes/default/keywords.jpg"/>'/>
			         				</td>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='functional.signs.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_FUNCTIONALSIGNS_IDS","functional.signs.text","functional.signs.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='functional.signs.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_IDS" property="value"/>"/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Inspection --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title2"><%=getTran(request,"web","inspection",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("inspection.ids","inspection.text","ikirezi2.inspection","keywords",this)'>
			         				<td class='admin2'>
			         					<textarea <%=SH.cdm("inspection.ids") %> class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_COMMENT" property="itemId"/>]>.value" id='inspection.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='1%' style="text-align:center">
			         				    <img width='16' id='key2' class="link" src='<c:url value="/_img/themes/default/keywords.jpg"/>'/>
			         				</td>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='inspection.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_INSPECTION_IDS","inspection.text","inspection.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='inspection.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_IDS" property="value"/>"/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Palpation --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title3"><%=getTran(request,"web","palpation",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("palpation.ids","palpation.text","ikirezi2.palpation","keywords",this)'>
			         				<td class='admin2'>
			         					<textarea <%=SH.cdm("palpation.ids") %> class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_COMMENT" property="itemId"/>]>.value" id='palpation.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='1%' style="text-align:center">
			         				    <img width='16' id='key3' class="link" src='<c:url value="/_img/themes/default/keywords.jpg"/>'/>
			         				</td>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='palpation.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_PALPATION_IDS","palpation.text","palpation.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='palpation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_IDS" property="value"/>"/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Heart ausculation --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title4"><%=getTran(request,"web","auscultation",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("auscultation.ids","auscultation.text","ikirezi2.auscultation","keywords",this)'>
			         				<td class='admin2'>
			         					<textarea <%=SH.cdm("auscultation.ids") %> class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_COMMENT" property="itemId"/>]>.value" id='auscultation.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='1%' style="text-align:center">
			         				    <img width='16' id='key4' class="link" src='<c:url value="/_img/themes/default/keywords.jpg"/>'/>
			         				</td>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='auscultation.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_HEARTAUSCULTATION_IDS","auscultation.text","auscultation.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='auscultation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_IDS" property="value"/>"/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
			        <tr>
			            <td class="admin"><%=getTran(request,"Web.Occup","rmh.clinical.summary",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
						                <textarea id='commenttext' onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_CLINICALSUMMARY")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_CLINICALSUMMARY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_CLINICALSUMMARY" property="value"/></textarea>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"Web.Occup","rmh.investigations",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
						                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_INVESTIGATIONS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_INVESTIGATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_INVESTIGATIONS" property="value"/></textarea>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"Web.Occup","rmh.precancerlesions",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2' width='1%' nowrap>
						                <%= SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_RMH_UTERUSPRECANCER_SCREENING", "") %>
						                <%=getTran(request,"web","uterusprecancerscreening",sWebLanguage) %>&nbsp;
									</td>
			         				<td class='admin2' width='1%' nowrap>
						                <%= SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_RMH_UTERUSPRECANCER_POSITIVE", "") %>
						                <%=getTran(request,"web","uterusprecancerpositive",sWebLanguage) %>&nbsp;
									</td>
			         				<td class='admin2'>
						                <%= SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_RMH_UTERUSPRECANCER_TREATMENT", "") %>
						                <%=getTran(request,"web","uterusprecancertreatment",sWebLanguage) %>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web.occup","alcohol.tobacco",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr>
	         						<td class="admin2">
				            			<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "alcohol.tobacco", "ITEM_TYPE_ALCOHOL_TOBACCO", sWebLanguage, true) %>
				            		</td>
								</tr>
							</table>			            		
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web.occup","nosocomial.infections",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr>
	         						<td class="admin2">
				            			<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "nosocomial.infections", "ITEM_TYPE_NOSOCOMIAL_INFECTIONS", sWebLanguage, true) %>
				            		</td>
								</tr>
							</table>			            		
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"Web.Occup","rmh.treatment",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
						                <%= SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_RMH_SMALLSURGERY", "") %>
						                <b><%=getTran(request,"web","smallsurgery",sWebLanguage) %></b> =>
						                <%= SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "smallsurgery.type", "ITEM_TYPE_RMH_SMALLSURGERYTYPE", sWebLanguage, true) %>
									</td>
								</tr>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
						                <textarea <%=SH.cdm() %> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_TREATMENT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_TREATMENT" property="value"/></textarea>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"Web.Occup","rmh.differential.diagnosis",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
			         					<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_RMH_DIFFDIAGNOSIS", 80,2) %>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"Web.Occup","rmh.final.diagnosis",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
						                <textarea <%=SH.cdm() %> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_FINALDIAGNOSIS")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FINALDIAGNOSIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FINALDIAGNOSIS" property="value"/></textarea>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>
                	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/sptField.jsp"),pageContext);%>
			        <tr>
			            <td class="admin"><%=getTran(request,"Web.Occup","rmh.followup",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
						                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_FOLLOWUP")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FOLLOWUP" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FOLLOWUP" property="value"/></textarea>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web","rmhcomment",sWebLanguage)%>&nbsp;</td>
			            <td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("","","","keywords")'>
			         				<td class='admin2'>
						                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_COMMENT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_COMMENT" property="value"/></textarea>
									</td>
								</tr>
							</table>
			            </td>
			        </tr>         			
				    <%
				    	if(SH.ci("enableOutpatientMalariaExtension",0)==0){
				    		ScreenHelper.setIncludePage(customerInclude("healthrecord/notifications.jsp"),pageContext);
				    	}
				    	else{
				    		ScreenHelper.setIncludePage(customerInclude("healthrecord/malariaExtension.jsp"),pageContext);
				    	}
				    %>
         			<%-- Reference --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title6"><%=getTran(request,"web","reference",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("reference.ids","reference.text","reference","keywords",this)'>
			         				<td class='admin2'>
			         					<textarea class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_COMMENT" property="itemId"/>]>.value" id='reference.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='1%' style="text-align:center">
			         				    <img width='16' id='key6' class="link" src='<c:url value="/_img/themes/default/keywords.jpg"/>'/>
			         				</td>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='reference.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_REFERENCE_IDS","reference.text","reference.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='reference.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_IDS" property="value"/>"/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web","evolution",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%
			            		Encounter activeEncounter = Encounter.getActiveEncounter(activePatient.personid);
			            		if(activeEncounter!=null && checkString(activeEncounter.getOutcome()).length()>0){
			            			out.println(getTran(request,MedwanQuery.getInstance().getConfigString("encounterOutcomeType","encounter.outcome"),activeEncounter.getOutcome(),sWebLanguage)+"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
			            		}
			            	%>
			            	<a href='javascript:openEncounter()'><%=getTran(request,"web","editencounter",sWebLanguage) %></a>
			            </td>
			        </tr>
         		</table>
         	</td>
         	
         	<%-- KEYWORDS --%>
         	<td id='keywordstd' class="admin2" style="vertical-align:top;padding:0px;">
         		<div id='test'></div>
         		<div style="height:300px;overflow:auto;position: sticky;top: 0" id="keywords"></div>
         	</td>
         </tr>
    </table>
    <div style="padding-top:5px;"></div>
    
    <%-- DIAGNOSES --%>
    <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncodingWide.jsp"),pageContext);%>            
 