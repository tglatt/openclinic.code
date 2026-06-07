<%@page import="be.openclinic.pharmacy.Product"%>
<%@page import="be.openclinic.medical.Prescription"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"msas.registry.consultations","select",activeUser)%>
<%!
    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product = new Product();
        product = product.get(sProductUid);

        if (product != null && product.getName() == null) {
            // search for product in product-history-table
            product = product.getProductFromHistory(sProductUid);
        }

        return product;
    }

    //--- GET ACTIVE PRESCRIPTIONS FROM RS --------------------------------------------------------
    private Vector getActivePrescriptionsFromRs(StringBuffer prescriptions, Vector vActivePrescriptions, String sWebLanguage) throws SQLException {
        Vector idsVector = new Vector();
        java.util.Date tmpDate;
        Product product = null;
        String sClass = "1", sPrescriptionUid = "", sDateBeginFormatted = "", sDateEndFormatted = "",
                sProductName = "", sProductUid = "", sPreviousProductUid = "", sTimeUnit = "", sTimeUnitCount = "",
                sUnitsPerTimeUnit = "", sPrescrRule = "", sProductUnit = "", timeUnitTran = "";
        DecimalFormat unitCountDeci = new DecimalFormat("#.#");
        SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;

        // frequently used translations
        String detailsTran = getTranNoLink("web", "showdetails", sWebLanguage),
                deleteTran = getTranNoLink("Web", "delete", sWebLanguage);
        Iterator iter = vActivePrescriptions.iterator();

        // run thru found prescriptions
        Prescription prescription;

        while (iter.hasNext()) {
            prescription = (Prescription)iter.next();
            sPrescriptionUid = prescription.getUid();
            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            idsVector.add(sPrescriptionUid);

            // format begin date
            tmpDate = prescription.getBegin();
            if (tmpDate != null) sDateBeginFormatted = stdDateFormat.format(tmpDate);
            else sDateBeginFormatted = "";

            // format end date
            tmpDate = prescription.getEnd();
            if (tmpDate != null) sDateEndFormatted = stdDateFormat.format(tmpDate);
            else sDateEndFormatted = "";

            // only search product-name when different product-UID
            sProductUid = prescription.getProductUid();
            if (!sProductUid.equals(sPreviousProductUid)) {
                sPreviousProductUid = sProductUid;
                product = getProduct(sProductUid);
                if (product != null) {
                    sProductName = product.getName();
                } else {
                    sProductName = "";
                }
                if (sProductName.length() == 0) {
                    sProductName = "<font color='red'>"+getTran(null,"web", "nonexistingproduct", sWebLanguage)+"</font>";
                }
            }

            //*** compose prescriptionrule (gebruiksaanwijzing) ***
            // unit-stuff
            sTimeUnit = prescription.getTimeUnit();
            sTimeUnitCount = Integer.toString(prescription.getTimeUnitCount());
            sUnitsPerTimeUnit = Double.toString(prescription.getUnitsPerTimeUnit());

            // only compose prescriptio-rule if all data is available
            if (!sTimeUnit.equals("0") && !sTimeUnitCount.equals("0") && !sUnitsPerTimeUnit.equals("0")) {
                sPrescrRule = getTran(null,"web.prescriptions", "prescriptionrule", sWebLanguage);
                sPrescrRule = sPrescrRule.replaceAll("#unitspertimeunit#", unitCountDeci.format(Double.parseDouble(sUnitsPerTimeUnit)));
                if (product != null) {
                    sProductUnit = product.getUnit();
                } else {
                    sProductUnit = "";
                }
                // productunits
                if (Double.parseDouble(sUnitsPerTimeUnit) == 1) {
                    sProductUnit = getTran(null,"product.unit", sProductUnit, sWebLanguage);
                } else {
                    sProductUnit = getTran(null,"product.unit", sProductUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#productunit#", sProductUnit.toLowerCase());

                // timeunits
                if (Integer.parseInt(sTimeUnitCount) == 1) {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", "");
                    timeUnitTran = getTran(null,"prescription.timeunit", sTimeUnit, sWebLanguage);
                } else {
                    sPrescrRule = sPrescrRule.replaceAll("#timeunitcount#", sTimeUnitCount);
                    timeUnitTran = getTran(null,"prescription.timeunits", sTimeUnit, sWebLanguage);
                }
                sPrescrRule = sPrescrRule.replaceAll("#timeunit#", timeUnitTran.toLowerCase());
            }

            //*** display prescription in one row ***
            prescriptions.append("<tr class='list"+sClass+"' onmouseover=\"this.style.cursor='pointer';\" onmouseout=\"this.style.cursor='default';\" title='"+detailsTran+"'>")
                    .append("<td align='center'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' border='0' title='"+deleteTran+"' onclick=\"doDelete('"+sPrescriptionUid+"');\">")
                    .append("<td onclick=\"doShowDetails('"+sPrescriptionUid+"');\" >"+sProductName+"</td>")
                    .append("<td onclick=\"doShowDetails('"+sPrescriptionUid+"');\" >"+sDateBeginFormatted+"</td>")
                    .append("<td onclick=\"doShowDetails('"+sPrescriptionUid+"');\" >"+sDateEndFormatted+"</td>")
                    .append("<td onclick=\"doShowDetails('"+sPrescriptionUid+"');\" >"+sPrescrRule.toLowerCase()+"</td>")
                    .append("</tr>");
        }
        return idsVector;
    }
%>
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
	<%TransactionVO tran = (TransactionVO)transaction;%>
    
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
			<td class='admin2' colspan='2'><%writeVitalSigns(pageContext); %></td>
		</tr>	
        <%-- DESCRIPTION --%>
        <tr>
        	<td width="60%" valign='top'>
	        	<table width='100%'>
		        	<tr>
			            <td class="admin" id='pregnantlabel'><%=getTran(request,"web","pregnantwomen",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <input id='pregnant' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN" property="itemId"/>]>.value" value="medwan.common.true"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN;value=medwan.common.true"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","yes",sWebLanguage) %></label>
			                <input id='notpregnant' type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN" property="itemId"/>]>.value" value="medwan.common.false"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN;value=medwan.common.false"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","no",sWebLanguage) %></label>
			            </td>
			            <td class='admin'><%=getTran(request,"web","newcase",sWebLanguage) %></td>
			            <td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "!ITEM_TYPE_MSAS_CONS_NEWCASE", sWebLanguage, false, "", "") %></td>
			            <% if(activePatient.gender.toLowerCase().startsWith("m")){ %>
			            	<script>
		            			document.getElementById("pregnant").checked=false;
		            			document.getElementById("pregnant").disabled=true;
		            			document.getElementById("notpregnant").checked=false;
		            			document.getElementById("notpregnant").disabled=true;
		            			document.getElementById("pregnantlabel").style='color: grey';
			            	</script>
			            <% } %>
			        </tr>
			        
			        
			        <tr>
			            <td class="admin" width='20%'><%=getTran(request,"web", "complaints.and.symptoms", sWebLanguage)%></td>
			            <td colspan="3" class="admin2">
			                <textarea rows="2" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_COMPLAINTS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_COMPLAINTS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin" width='20%'><%=getTran(request,"web", "clinicalexamination", sWebLanguage)%></td>
			            <td colspan="3" class="admin2">
			                <%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CONS_CLINICALEXAMINATION", 50, 2) %>
			            </td>
			        </tr>
                	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/sptField.jsp"),pageContext);%>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","tdr",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_TDR" property="itemId"/>]>.value">
			                	<option/>
				            	<%=ScreenHelper.writeSelect(request,"msas.tdr",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_TDR"),sWebLanguage,false,true) %>
			                </select>
			            </td>
			            <td class="admin"><%=getTran(request,"web", "other.paraclinical.exams", sWebLanguage)%></td>
			            <td class="admin2">
			            	<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CONS_OTHEREXAMS", 30,1) %>
			                <%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.otherexams","ITEM_TYPE_MSAS_CONS_OTHEREXAMS2", sWebLanguage, false) %>
			            </td>
			        </tr>
			          <tr>
			             <td class='admin'><%=getTran(request,"web","ivaivl",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' colspan="3"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "ivaivl", "ITEM_TYPE_MSAS__CONS_IVA_IVL",sWebLanguage,false,"","") %></td>
			     
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","referral",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_CONS_REFERENCE", "msas.reference", sWebLanguage, "") %>
			            </td>
			            <td class="admin"><%=getTran(request,"web", "treatment", sWebLanguage)%></td>
			            <td class="admin2">
			                <textarea rows="1" onKeyup="resizeTextarea(this,10);" class="text" cols="30" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_TREATMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_TREATMENT" property="value"/></textarea><br/>
			                <%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.treatments", "ITEM_TYPE_MSAS_TREATMENTS", sWebLanguage, false) %>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin">
			                <%=getTran(request,"web","familyplanning",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_FAMILYPLANNING" property="itemId"/>]>.value" value="medwan.common.true"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_FAMILYPLANNING;value=medwan.common.true"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","yes",sWebLanguage) %></label>
			                <input type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_FAMILYPLANNING" property="itemId"/>]>.value" value="medwan.common.false"
			                <mxs:propertyAccessorI18N name="transaction.items" scope="page"
			                                          compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_FAMILYPLANNING;value=medwan.common.false"
			                                          property="value" outputString="checked"/>><label><%=getTran(request,"web","no",sWebLanguage) %></label>
			            </td>
			            <td class="admin">
			                <%=getTran(request,"web","familyplanning.action",sWebLanguage)%>
			            </td>
			            <td class="admin2">
			                <input type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_FAMILYPLANNINGACTION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_FAMILYPLANNINGACTION" property="value"/>" class="text" size="30" >
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web", "consultation.observations", sWebLanguage)%></td>
			            <td colspan="3" class="admin2">
			                <textarea rows="2" onKeyup="resizeTextarea(this,10);" class="text" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_OBSERVATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_CONS_OBSERVATIONS" property="value"/></textarea>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.traumatisms", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_trauma' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("trauma","ITEM_TYPE_MSAS_CONS_TRAUMATISM")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td colspan="3" class="admin2">
			            	<div id='trauma' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.traumatism", "ITEM_TYPE_MSAS_CONS_TRAUMATISM", sWebLanguage, false,"onchange=\"checkImage('trauma','ITEM_TYPE_MSAS_CONS_TRAUMATISM')\"") %></div>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.hypertension", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_hta' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("hta","ITEM_TYPE_MSAS_CONS_HYPERTENSION")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td colspan="3" class="admin2">
			            	<div id='hta' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.hypertension", "ITEM_TYPE_MSAS_CONS_HYPERTENSION", sWebLanguage, false,"onchange=\"checkImage('hta','ITEM_TYPE_MSAS_CONS_HYPERTENSION')\"") %></div>
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
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.hemophilia", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_hemophilia' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("hemophilia","ITEM_TYPE_MSAS_CONS_HEMOPHILIA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td colspan="3" class="admin2">
			            	<div id='hemophilia' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.hemophilia", "ITEM_TYPE_MSAS_CONS_HEMOPHILIA", sWebLanguage, false,"onchange=\"checkImage('hemophilia','ITEM_TYPE_MSAS_CONS_HEMOPHILIA')\"") %></div>
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
			            <td colspan="3" class="admin2">
			            	<div id='bpco' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.bpco", "ITEM_TYPE_MSAS_CONS_BPCO", sWebLanguage, false,"onchange=\"checkImage('hemophilia','ITEM_TYPE_MSAS_CONS_BPCO')\"") %></div>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.asthma", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_asthma' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("asthma","ITEM_TYPE_MSAS_CONS_ASTHMA")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td colspan="3" class="admin2">
			            	<div id='asthma' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.asthma", "ITEM_TYPE_MSAS_CONS_ASTHMA", sWebLanguage, false,"onchange=\"checkImage('asthma','ITEM_TYPE_MSAS_CONS_ASTHMA')\"") %></div>
			            </td>
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.breastcancer", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_breastcancer' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("breastcancer","ITEM_TYPE_MSAS_CONS_BREASTCANCER")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td colspan="3" class="admin2">
			            	<div id='breastcancer' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.breastcancer", "ITEM_TYPE_MSAS_CONS_BREASTCANCER", sWebLanguage, false,"onchange=\"checkImage('breastcancer','ITEM_TYPE_MSAS_CONS_BREASTCANCER')\"") %></div>
			            </td>
			        </tr>
			        <tr>
			        	<td class='admin'><%=getTran(request,"web", "consultation.msas.raa", sWebLanguage)%></td>
			        	<td class='admin2' colspan='3'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.raa", "ITEM_TYPE_MSAS_CONS_RAA", sWebLanguage, false) %></td>
			        </tr>
			        <tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.msas.evacuation", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_evacuation' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("evacuation","ITEM_TYPE_MSAS_CONS_EVACUATION")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td colspan="3" class="admin2">
			                <div id='evacuation' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.evacuation", "ITEM_TYPE_MSAS_CONS_EVACUATION", sWebLanguage, false) %></div>
			            </td>
			        </tr>
	            </table>
	        </td>
	        <%-- DIAGNOSES --%>
	    	<td valign='top'>
		    	<table width='100%'>
		    		<% if(SH.ci("enableGuinea",0)==1){ %>
		    		<tr>
		    			<td>
		    				<table width='100%'>
		    					<tr>
		    						<td class='admin'><%=getTran(request,"web","service",sWebLanguage) %></td>
									<% if(tran.isNew()){ %>
		    						<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "!ITEM_TYPE_SERVICE", "gn.service", sWebLanguage, "onblur='setActiveService(this.value)'",(String)session.getAttribute("activeService")) %></td>
									<% }else{ %>
			    						<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "!ITEM_TYPE_SERVICE", "gn.service", sWebLanguage, "onblur='setActiveService(this.value)'") %></td>
			    					<% } %>
		    					</tr>
		    				</table>
		    			</td>
		    		</tr>
		    		<% } %>
		    		<tr>
		    			<td valign='top'><%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%></td>
		    		</tr>
	                <tr class="admin">
	                    <td align="center"><%=getTran(request,"Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></td>
	                </tr>
	                <tr>
	                	<td>
		                <%
		                    //--- DISPLAY ACTIVE PRESCRIPTIONS (of activePatient) ---------------------------------
		                    // compose query
		                    Vector vActivePrescriptions = Prescription.findActive(activePatient.personid,activeUser.userid,"","","","","","");
		
		                    StringBuffer prescriptions = new StringBuffer();
		                    Vector idsVector = getActivePrescriptionsFromRs(prescriptions, vActivePrescriptions , sWebLanguage);
		                    int foundPrescrCount = idsVector.size();
		
		                    if(foundPrescrCount > 0){
		                        %>
		                            <table width="100%" cellspacing="0" cellpadding="0" class="list">
		                                <%-- header --%>
		                                <tr class="admin">
		                                    <td width="22" nowrap>&nbsp;</td>
		                                    <td width="30%"><%=getTran(request,"Web","product",sWebLanguage)%></td>
		                                    <td width="15%"><%=getTran(request,"Web","begindate",sWebLanguage)%></td>
		                                    <td width="15%"><%=getTran(request,"Web","enddate",sWebLanguage)%></td>
		                                    <td width="40%"><%=getTran(request,"Web","prescriptionrule",sWebLanguage)%></td>
		                                </tr>
		
		                                <tbody class="hand"><%=prescriptions%></tbody>
		                            </table>
		                        <%
		                    }
		                    else{
		                        // no records found
		                        %><%=getTran(request,"web","noactiveprescriptionsfound",sWebLanguage)%><br><%
		                    }
		                    %>
		                </td>
	                </tr>
		    	</table>
	    	</td>
        </tr>
    </table>
            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"msas.registry.consultations",sWebLanguage)%>
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
	checkSection('hta','ITEM_TYPE_MSAS_CONS_HYPERTENSION');
	checkSection('diabetes','ITEM_TYPE_MSAS_CONS_DIABETES');
	checkSection('hemophilia','ITEM_TYPE_MSAS_CONS_HEMOPHILIA');
	checkSection('bpco','ITEM_TYPE_MSAS_CONS_BPCO');
	checkSection('asthma','ITEM_TYPE_MSAS_CONS_ASTHMA');
	checkSection('breastcancer','ITEM_TYPE_MSAS_CONS_BREASTCANCER');
	checkSection('evacuation','ITEM_TYPE_MSAS_CONS_EVACUATION');
	
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

  function setActiveService(service){
	  	var params = "attributeName=activeService&attributeValue="+service;
	  	var url = '<c:url value="/util/setSessionAttribute.jsp"/>';
	    new Ajax.Request(url,{
		      parameters: params,
		      onSuccess: function(resp){
		      }
		});
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