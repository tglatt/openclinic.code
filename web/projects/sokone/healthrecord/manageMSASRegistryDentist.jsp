<%@page import="be.openclinic.pharmacy.Product"%>
<%@page import="be.openclinic.medical.Prescription"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"msas.registry.dentist","select",activeUser)%>
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
        	<td width="50%" valign='top'>
	        	<table width='100%'>
		        	<tr>
			            <td class="admin" id='pregnantlabel'><%=getTran(request,"web","pregnantwomen",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN", sWebLanguage, false, "", "") %></td>
			            <td class="admin"><%=getTran(request,"web","newcase",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DENTIST_NEWCASE", sWebLanguage, false, "", "") %>
			            </td>
			            <% if(activePatient.gender.toLowerCase().startsWith("m")){ %>
			            	<script>
		            			document.getElementById("ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN.0").checked=false;
		            			document.getElementById("ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN.0").disabled=true;
		            			document.getElementById("ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN.1").checked=false;
		            			document.getElementById("ITEM_TYPE_MSAS_CONS_PREGNANTWOMEN.1").disabled=true;
		            			document.getElementById("pregnantlabel").style='color: grey';
			            	</script>
			            <% } %>
			        </tr>
		        	<tr>
			            <td class='admin'><%=getTran(request,"msas","cao",sWebLanguage) %>/<%=getTran(request,"msas","co",sWebLanguage) %></td>
			            <td class="admin2" >
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DENTIST_CAO", 10, sWebLanguage) %>/<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DENTIST_CO", 10, sWebLanguage) %>
			            </td>
						  <td class='admin'><%=getTran(request,"web","paymentmode",sWebLanguage) %></td>
			            <td class="admin2">
			            			<%=SH.writeDefaultSelect(request,(TransactionVO) transaction, "ITEM_TYPE_MSAS_DENTIST_PAYMENT_MODE", "msas.dentist.paymentmode", sWebLanguage, "") %>
			              </td>
			        </tr>
		        	<tr>
			            <td class="admin"><%=getTran(request,"web","referral",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultSelect(request,(TransactionVO) transaction, "ITEM_TYPE_MSAS_DENTIST_REFERENCE", "msas.dentist.reference", sWebLanguage, "") %>
			            </td>
			            <td class="admin"><%=getTran(request,"web", "treatment", sWebLanguage)%></td>
			            <td class="admin2"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DENTIST_TREATMENT", 35, 2) %></td>
			        </tr>
			        
			        <tr>
			            <td class="admin" rowspan="2"><%=getTran(request,"web", "disease.problem", sWebLanguage)%></td>
			            <td class="admin2" colspan="3">
			                <%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.dentist.problems.single", "ITEM_TYPE_MSAS_DENTIST_PROBLEMS_SINGLE", sWebLanguage, true,"","|&nbsp;&nbsp;") %>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin2" colspan="3">
			                <%=SH.writeDefaultCountBoxes((TransactionVO)transaction, request, "msas.dentist.problems.multi", "ITEM_TYPE_MSAS_DENTIST_PROBLEMS_MULTI", sWebLanguage, true,"","|&nbsp;&nbsp;",10) %>
			            </td>
			        </tr>
			         <script>
			         function displayNumberOfTooth() {
			        	    const value = document.getElementById('problem1').value;
			        	    const value2 = document.getElementById('problem2').value;
			        	    const value3 = document.getElementById('problem3').value;
			        	    const numberOfTooth = document.getElementById('numberoftooth1');
			        	    const numberOfTooth2 = document.getElementById('numberoftooth2');
			        	    const numberOfTooth3 = document.getElementById('numberoftooth3');
			        	    if (value =='2' || value == '3'|| value == '4'|| value == '5'|| value == '19'|| value == '21') {
			        	        numberOfTooth.style.display = '';
			        	    }
			        	    else {
			        	        numberOfTooth.style.display = 'none';
			        	    }
			        	    if (value2 =='2' || value2 == '3'|| value2 == '4'|| value2 == '5'|| value2 == '19'|| value2 == '21') {
			        	        numberOfTooth2.style.display = '';
			        	    }
			        	    else {
			        	        numberOfTooth2.style2.display = 'none';
			        	    }
			        	    if (value3 =='2' || value3 == '3'|| value3 == '4'|| value3 == '5'|| value3 == '19'|| value3 == '21') {
			        	        numberOfTooth3.style.display = '';
			        	    }
			        	    else {
			        	       numberOfTooth.style3.display = 'none';
			        	    }
			        	}
			         displayNumberOfTooth()
			            
			            </script>
			        <tr>
			            <td class="admin"><%=getTran(request,"web", "therapeuticacts", sWebLanguage)%></td>
			            <td class="admin2" colspan="3">
			                <%=SH.writeDefaultCountBoxes((TransactionVO)transaction, request, "msas.dentist.acts2", "ITEM_TYPE_MSAS_DENTIST_ACTS", sWebLanguage, true,"","|&nbsp;&nbsp;",10) %>
			            </td>
			        </tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web", "consultation.observations", sWebLanguage)%></td>
			            <td colspan="3" class="admin2"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DENTIST_OBSERVATION", 50, 2) %></td>
			        </tr>
	            </table>
	        </td>
	        <%-- DIAGNOSES --%>
	    	<td valign='top'>
		    	<table width='100%'>
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
	    <%=getButtonsHtml(request,activeUser,activePatient,"msas.registry.dentist",sWebLanguage)%>
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
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>