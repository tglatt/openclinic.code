<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<% TransactionVO tran = (TransactionVO)transaction; %>
	   <table class="list" width="100%" cellspacing="1">
		
	       <%-- VITAL SIGNS --%>
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.vital.signs",sWebLanguage)%>&nbsp;</td>
	           <td class="admin2">
	           	<table width="100%">
	           		<tr>
	           			<td nowrap><b><%=getTran(request,"openclinic.chuk","temperature",sWebLanguage)%>:</b></td><td nowrap><input id='temperature' type="text" class="text" <%=setRightClick(session,"[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(25,45,this)){alertDialog('Web.Occup','medwan.common.unrealistic-value');}}" size="5"/> °C</td>
	           			<td nowrap><b><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_HEIGHT")%> id="height" class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>" onBlur="alert()calculateBMI();"/> cm</td>
	           			<td nowrap><b><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%> id="weight" class="text" type="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>" onBlur="calculateBMI();"/> kg</td>
	           			<td nowrap><b><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.bmi",sWebLanguage)%>:</b></td><td nowrap><input id="BMI" class="text" type="text" size="5" name="BMI" readonly /></td>
	           		</tr>
	                <tr>
			            <td nowrap><b><%=getTran(request,"openclinic.chuk","sao2",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClick(session,"[GENERAL.ANAMNESE]ITEM_TYPE_SATURATION")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SATURATION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SATURATION" property="value"/>"/> %</td>
			            <td nowrap><b><%=getTran(request,"web","abdomencircumference",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClick(session,"ITEM_TYPE_ABDOMENCIRCUMFERENCE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMENCIRCUMFERENCE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ABDOMENCIRCUMFERENCE" property="value"/>"/> cm</td>
			            <td nowrap><b><%=getTran(request,"web","fhr",sWebLanguage)%>:</b></td><td nowrap><input <%=setRightClick(session,"ITEM_TYPE_FOETAL_HEARTRATE")%> type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOETAL_HEARTRATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOETAL_HEARTRATE" property="value"/>"/></td>
			            <td colspan='2'/>
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
	       </tr>
	
	       <%-- TEXT FIELDS --%>
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.clinical.patienttype",sWebLanguage)%>&nbsp;</td>
	           <td class="admin2">
	           	<table width='100%'>
	           		<tr>
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
			                
	           			</td>
	           			<td>
	            			<%=getTran(request,"web","pregnancyduration",sWebLanguage) %>: <input <%=setRightClick(session,"ITEM_TYPE_DELIVERY_AGE")%> type="text" class="text" size="3" id='ITEM_TYPE_PREGNANCYDURATION' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_AGE" property="value"/>" > <%=getTran(request,"web","weeks",sWebLanguage) %>
	           			</td>
	           		</tr>
	           	</table>
	           </td>
	       </tr>
	       <tr>
			<td class='admin'><%=getTran(request,"web", "consultation.performed.by", sWebLanguage)%></td>
			<td class='admin2'>
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
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.clinical.history",sWebLanguage)%>&nbsp;<%=SH.ci("enforceCompleteClinicalDataEntry",0)==1?"*":"" %></td>
	           <td class="admin2">
	               <textarea <%=SH.cdm()%> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_CLINICALHISTORY")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_CLINICALHISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_CLINICALHISTORY" property="value"/></textarea>
	           </td>
	       </tr>
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.physical.examination",sWebLanguage)%>&nbsp;<%=SH.ci("enforceCompleteClinicalDataEntry",0)==1?"*":"" %></td>
	           <td class="admin2">
	               <textarea <%=SH.cdm()%> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_PHYSICALEXAM")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_PHYSICALEXAM" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_PHYSICALEXAM" property="value"/></textarea>
	           </td>
	       </tr>
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.differential.diagnosis",sWebLanguage)%>&nbsp;<%=SH.ci("enforceCompleteClinicalDataEntry",0)==1?"*":"" %></td>
	           <td class="admin2">
	           	<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "!ITEM_TYPE_RMH_DIFFERENTIALDIAGNOSIS", 70, 2) %>
	           </td>
	       </tr>
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.clinical.summary",sWebLanguage)%>&nbsp;<%=SH.ci("enforceCompleteClinicalDataEntry",0)==1?"*":"" %></td>
	           <td class="admin2">
	               <textarea <%=SH.cdm()%> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_CLINICALSUMMARY")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_CLINICALSUMMARY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_CLINICALSUMMARY" property="value"/></textarea>
	           </td>
	       </tr>
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.investigations",sWebLanguage)%>&nbsp;<%=SH.ci("enforceCompleteClinicalDataEntry",0)==1?"*":"" %></td>
	           <td class="admin2">
	               <textarea <%=SH.cdm()%> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_INVESTIGATIONS")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_INVESTIGATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_INVESTIGATIONS" property="value"/></textarea>
	           </td>
	       </tr>
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.treatment",sWebLanguage)%>&nbsp;<%=SH.ci("enforceCompleteClinicalDataEntry",0)==1?"*":"" %></td>
	           <td class="admin2">
	               <textarea <%=SH.cdm()%> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_TREATMENT")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_TREATMENT" property="value"/></textarea>
	           </td>
	       </tr>
	       <tr>
	           <td class="admin"><%=getTran(request,"web.occup","alcohol.tobacco",sWebLanguage)%>&nbsp;</td>
	           <td class="admin2">
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
	        <td class="admin2">
	  			<table width='100%'>
	  				<tr>
	   					<td class="admin2">
	         				<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "nosocomial.infections", "ITEM_TYPE_NOSOCOMIAL_INFECTIONS", sWebLanguage, true) %>
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
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.final.diagnosis",sWebLanguage)%>&nbsp;<%=SH.ci("enforceCompleteClinicalDataEntry",0)==1?"*":"" %></td>
	           <td class="admin2">
	               <textarea <%=SH.cdm()%> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_FINALDIAGNOSIS")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FINALDIAGNOSIS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FINALDIAGNOSIS" property="value"/></textarea>
	           </td>
	       </tr>
	       <tr>
	           <td class="admin"><%=getTran(request,"Web.Occup","rmh.followup",sWebLanguage)%>&nbsp;<%=SH.ci("enforceCompleteClinicalDataEntry",0)==1?"*":"" %></td>
	           <td class="admin2">
	               <textarea <%=SH.cdm()%> onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_FOLLOWUP")%> class="text" cols="70" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FOLLOWUP" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_FOLLOWUP" property="value"/></textarea>
	           </td>
	       </tr>
	       <tr>
	           <td class="admin"><%=getTran(request,"web","rmhcomment",sWebLanguage)%>&nbsp;</td>
	           <td class="admin2">
	               <textarea onKeyup="resizeTextarea(this,10);limitChars(this,5000);" <%=setRightClick(session,"ITEM_TYPE_RMH_COMMENT")%> class="text" cols="70" rows="1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RMH_COMMENT" property="value"/></textarea>
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
    <div style="padding-top:5px;"></div>
    
    <%-- DIAGNOSES --%>
    <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncodingWide.jsp"),pageContext);%>            
