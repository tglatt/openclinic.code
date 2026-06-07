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
 <%
    String accessright="mspls.registry.cpn";
%>
<%=checkPermission(accessright,"select",activeUser)%>

<%!
    //--- GET PRODUCT -----------------------------------------------------------------------------
    private Product getProduct(String sProductUid) {
        // search for product in products-table
        Product product = Product.get(sProductUid);

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
                    sProductName = "<font color='red'>" + getTran(null,"web", "nonexistingproduct", sWebLanguage) + "</font>";
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
                    sProductUnit = getTran(null,"product.units", sProductUnit, sWebLanguage);
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
            prescriptions.append("<tr class='list" + sClass + "'  title='" + detailsTran + "'>")
                    .append("<td align='center'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.png' border='0' title='" + deleteTran + "' onclick=\"doDelete('" + sPrescriptionUid + "');\">")
                    .append("<td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sProductName + "</td>")
                    .append("<td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sDateBeginFormatted + "</td>")
                    .append("<td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sDateEndFormatted + "</td>")
                    .append("<td onclick=\"doShowDetails('" + sPrescriptionUid + "');\" >" + sPrescrRule.toLowerCase() + "</td>")
                    .append("</tr>");
        }
        return idsVector;
    }

    private class TransactionID {
        public int transactionid = 0;
        public int serverid = 0;
    }

    //--- GET MY TRANSACTION ID -------------------------------------------------------------------
    private TransactionID getMyTransactionID(String sPersonId, String sItemTypes, JspWriter out) {
        TransactionID transactionID = new TransactionID();
        Transaction transaction = Transaction.getSummaryTransaction(sItemTypes, sPersonId);
        try {
            if (transaction != null) {
                String sUpdateTime = ScreenHelper.getSQLDate(transaction.getUpdatetime());
                transactionID.transactionid = transaction.getTransactionId();
                transactionID.serverid = transaction.getServerid();
                out.print(sUpdateTime);
            }
        } catch (Exception e) {
            e.printStackTrace();
            if (Debug.enabled) Debug.println(e.getMessage());
        }
        return transactionID;
    }

    //--- GET MY ITEM VALUE -----------------------------------------------------------------------
    private String getMyItemValue(TransactionID transactionID, String sItemType, String sWebLanguage) {
        String sItemValue = "";
        Vector vItems = Item.getItems(Integer.toString(transactionID.transactionid), Integer.toString(transactionID.serverid), sItemType);
        Iterator iter = vItems.iterator();

        Item item;

        while (iter.hasNext()) {
            item = (Item) iter.next();
            sItemValue = item.getValue();//checkString(rs.getString(1));
            sItemValue = getTranNoLink("Web.Occup", sItemValue, sWebLanguage);
        }
        return sItemValue;
    }
%>
     <%-- 
    <form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    --%>
     <!--
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	-->
	<%//=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <%//=ScreenHelper.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_CONTEXT_DEPARTMENT") %>
    <%//=ScreenHelper.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_CONTEXT_CONTEXT") %>
    
    <%//=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%//=contextHeader(request,sWebLanguage)%>
    
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
   
		<tr>
			<td class="admin"><%=getTran(request,"web", "literacy_level", sWebLanguage)%></td>
			<td class="admin2">
				<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_LITERACY_LEVEL", "mspls.cpn.literacy_level", sWebLanguage, "") %>
            </td>
		</tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "married", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_MARRIED", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "withpartner", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_WITHPARTNER", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "cpnnumber", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPNNUMBER", "mspls.cpn.newnumber", sWebLanguage, "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "weeksamenorrhea", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_WEEKSAMENORRHEA", 5, 0, 45, sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "gestity", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_GESTITY", 5, 0, 20, sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "parity", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_PARITY", 5, 0, 20, sWebLanguage)%>
            </td>
        </tr>
        <tr>
			<td class="admin"><%=getTran(request,"web", "lifestyle", sWebLanguage)%></td>
			<td class="admin2">
				<%=ScreenHelper.writeDefaultCheckBoxes((TransactionVO)transaction, request, "mspls.cds.lifestyle", "ITEM_TYPE_LIFESTYLE", sWebLanguage, true) %>
			</td>
		</tr>
		<tr>
            <td class="admin"><%=getTran(request,"mspls", "hivbeforepregnancy", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_HIVBEFOREPREGNANCY", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "underarvsince", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_ARVSINCE", "mspls.cpn.arvsince", sWebLanguage, "") %>
            </td>
        </tr>
		<tr>
			<td class="admin"><%=getTran(request,"mspls", "HC_followup", sWebLanguage)%></td>
			<td class="admin2">
				<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "mspls_follup",  "ITEM_TYPE_FC_FOLLOWUP", sWebLanguage, true, "", "") %>
			</td>
		</tr>
		
        <tr>
            <td class="admin"><%=getTran(request,"mspls", "otherdiseasebeforepregnancy", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultCheckBoxes((TransactionVO)transaction, request, "mspls.cpn.otherdisease",  "ITEM_TYPE_DISEASEBEFOREPREGNANCY", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"mspls", "hivcounseling", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_HIVCOUNCELING", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "hivscreening", sWebLanguage)%></td>
            <td>
            	<table width='100%' cellspacing="0" cellpadding="0">
            		<tr>
            			<td class="admin2" width='30%' nowrap>
            				<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_HIVSCREENING", "mspls.cpn.hivscreening", sWebLanguage, "") %>
            			</td>
			            <td class="admin2" width='30%' nowrap>
			            	<%=getTran(request,"mspls", "resultreceived", sWebLanguage)%>:
			            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_RESULTRECEIVED", sWebLanguage, true, "", "") %>
			            </td>
			            <td class="admin2" width='30%' nowrap>
			            	<%=getTran(request,"mspls", "putonarv", sWebLanguage)%>:
			            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_PUTONARV", sWebLanguage, true, "", "") %>
			            </td>
            		</tr>
            	</table>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"mspls", "partnerscreeninghiv", sWebLanguage)%></td>
            <td>
            	<table width='100%' cellspacing="0" cellpadding="0">
            		<tr>
			            <td class="admin2" width='30%' nowrap>
			            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_PARTNERSCREENING", sWebLanguage, true, "", "") %>
			            </td>
			            <td class="admin2" width='30%' nowrap>
			            	<%=getTran(request,"mspls", "serodiscordance", sWebLanguage)%>:
			            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_SERODISCORDANT", sWebLanguage, true, "", "") %>
			            </td>
						<td class="admin2" width='30%' nowrap>
			            	<%=getTran(request,"mspls", "partnerputonarv", sWebLanguage)%>:
			            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_PARTNERPUTONARV", sWebLanguage, true, "", "") %>
			            </td>
            		</tr>
            	</table>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "syphilisscreening", sWebLanguage)%></td>
            <td>
            	<table width='100%' cellspacing="0" cellpadding="0">
            		<tr>
            			<td class="admin2" width='30%' nowrap>            	
            				<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_SYPHILISSCREENING", "posneg", sWebLanguage, "") %>
						</td>
			            <td class="admin2" width='30%' nowrap>
			            	<%=getTran(request,"mspls", "putontreatment", sWebLanguage)%>:
			            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_SYPHILISTREATMENT", sWebLanguage, true, "", "") %>
			            </td>
			            <td class="admin2" width='30%' nowrap>&nbsp;</td>
            		</tr>
            	</table>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"mspls", "partnerscreeningsyphilis", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_PARTNERSCREENING_SYPHILIS", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "hepatitisbnscreening", sWebLanguage)%></td>
            <td>
            	<table width='100%' cellspacing="0" cellpadding="0">
            		<tr>
            			<td class="admin2" width='30%' nowrap>            	
			            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_HEPATITISBSCREENING", "posneg", sWebLanguage, "") %>
						</td>
			            <td class="admin2" width='30%' nowrap>
			            	<%=getTran(request,"mspls", "alreadytreated", sWebLanguage)%>:
			            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_HEPATITISBTREATMENT", sWebLanguage, true, "", "") %>
			            </td>
			            <td class="admin2" width='30%' nowrap>&nbsp;</td>
            		</tr>
            	</table>
            </td>
        </tr>
		
        <tr>
            <td class="admin"><%=getTran(request,"web", "malnutritionscreening", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MALNUTRITIONSCREENING", "mspls.cpn.malnutritionresult", sWebLanguage, "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "anemia", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_ANEMIA", "mspls.cpn.anemia", sWebLanguage, "") %>
            </td>
        </tr>
		<tr>
            <td class="admin"><%=getTran(request,"web", "knowndiabetisbeforepregnancy", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_KNOWNDIABETIS_BEFOREPREGNANCY", "mspls.cpn.diabetis", sWebLanguage, "") %>
            </td>
        </tr>
		<tr>
            <td class="admin"><%=getTran(request,"web", "knownHTAbeforepregnancy", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_KNOWNHTA_BEFOREPREGNANCY", "mspls.cpn.hta", sWebLanguage, "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"mspls", "trimester", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "mspls.cpn.trimester",  "ITEM_TYPE_TRIMESTER", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "newrisk", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_NEWRISK", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "risk", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "!ITEM_TYPE_HASRISK", sWebLanguage, true, "", "") %>
            	<%=ScreenHelper.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_RISK", 60, 1) %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "vaccinationcompletebeforepregnancy", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_VACCCOMPLETE", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "tdvaccination", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TD", "mspls.cpn.td", sWebLanguage, "") %>
            </td>
        </tr>
		<tr>
            <td class="admin"><%=getTran(request,"web", "tetanusvaccination", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_VAT", "mspls.cpn.vat", sWebLanguage, "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "prevention", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultCheckBoxes((TransactionVO)transaction, request, "mspls.cpn.prevention", "ITEM_TYPE_PREVENTION", sWebLanguage, true) %>
				
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TIPIG", "mspls.cpn.tipig", sWebLanguage, "") %> TIPIg
            </td>
			
		
        <tr>
            <td class="admin"><%=getTran(request,"web", "newproblem", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_NEWPROBLEM", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "problem", sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_HASPROBLEM", "") %><%=getTran(request,"web","yes",sWebLanguage) %>&nbsp;
            	<%=ScreenHelper.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_PROBLEM", 60, 1) %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "counseling", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_COUNSELING", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "cpnreferral", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_REFERRAL", sWebLanguage, true, "", "") %>
            </td>
        </tr>
		</tr>
			<td class="admin"><%=getTran(request,"mspls", "gbvactiveresearch", sWebLanguage)%></td>
			<td class="admin2">
				<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_GBVACTIVERESEARCH", sWebLanguage, true, "", "") %>
			</td>
		</tr>
		<tr>
			<td class="admin"><%=getTran(request,"web", "gbvtypes", sWebLanguage)%></td>
			<td class="admin2">
				<%=ScreenHelper.writeDefaultCheckBoxes((TransactionVO)transaction, request, "mspls.cpon.gbvTypes", "ITEM_TYPE_GBVTYPES", sWebLanguage, true) %>
			</td>
		</tr>
		<tr>
			<td class="admin"><%=getTran(request,"web", "nextappointment", sWebLanguage)%></td>
			<td class="admin2">
				<%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_NEXTVISIT", sWebLanguage, sCONTEXTPATH) %>
			</td>
		</tr>
        <tr>
        	<td colspan='2'><%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%></td>
        </tr>
    </table>
    <table width="100%" class="list" cellspacing="1">
        <tr class="admin">
            <td align="center"><a href="javascript:openPopup('medical/managePrescriptionsPopup.jsp&amp;skipEmpty=1',900,400,'medication');void(0);"><%=getTran(request,"Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></a></td>
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
        <tr class="admin">
            <td align="center"><%=getTran(request,"curative","medication.paperprescriptions",sWebLanguage)%> (<%=ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime())%>)</td>
        </tr>
        <%
            Vector paperprescriptions = PaperPrescription.find(activePatient.personid,"",ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime()),ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime()),"","DESC");
            if(paperprescriptions.size()>0){
                out.print("<tr><td><table width='100%'>");
                String l="";
                for(int n=0;n<paperprescriptions.size();n++){
                    if(l.length()==0){
                        l="1";
                    }
                    else{
                        l="";
                    }
                    PaperPrescription paperPrescription = (PaperPrescription)paperprescriptions.elementAt(n);
                    out.println("<tr class='list"+l+"' id='pp"+paperPrescription.getUid()+"'><td valign='top' width='90px'><img src='_img/icons/icon_delete.png' onclick='deletepaperprescription(\""+paperPrescription.getUid()+"\");'/> <b>"+ScreenHelper.stdDateFormat.format(paperPrescription.getBegin())+"</b></td><td><i>");
                    Vector products =paperPrescription.getProducts();
                    for(int i=0;i<products.size();i++){
                        out.print(products.elementAt(i)+"<br/>");
                    }
                    out.println("</i></td></tr>");
                }
                out.print("</table></td></tr>");
            }
        %>
        <tr>
            <td><a href="javascript:openPopup('medical/managePrescriptionForm.jsp&amp;skipEmpty=1',650,430,'medication');void(0);"><%=getTran(request,"web","medicationpaperprescription",sWebLanguage)%></a></td>
        </tr>
    </table>            
	<%-- BUTTONS --%>
	<%//=ScreenHelper.alignButtonsStart()%>
	    <%//=getButtonsHtml(request,activeUser,activePatient,accessright,sWebLanguage)%>
	<%//=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
  <%--  </form> --%>

<script>
  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  if( document.getElementById('encounteruid').value=="" <%=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERRAL_SOURCESITE").length()==0 && request.getParameter("nobuttons")==null?"":" && 1==0"%>){
  	alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
  	searchEncounter();
  }	

  function searchUser(managerUidField,managerNameField){
	  openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no&FindServiceID=<%=MedwanQuery.getInstance().getConfigString("CCBRTEyeRegistryService")%>",650,600);
    document.getElementById(diagnosisUserName).focus();
  }


</script>
    
<%//=writeJSButtons("transactionForm","saveButton")%>