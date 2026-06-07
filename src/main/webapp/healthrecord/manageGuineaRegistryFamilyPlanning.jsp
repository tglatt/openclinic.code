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
<!-- 
	***********************************
	* Modify access right hereafter	  *
	***********************************
 -->
<%
	String accessright="mshp.familyplanning";
%>
<%=checkPermission(accessright,"select",activeUser)%>
<%!
 
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
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <%=ScreenHelper.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_CONTEXT_DEPARTMENT") %>
    <%=ScreenHelper.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_CONTEXT_CONTEXT") %>
    
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <table class="list" width="100%" cellspacing="1" cellpadding='0'>
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" colspan="4">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <% TransactionVO tran = (TransactionVO)transaction; %>
        <tr><td colspan='4' class='adminblack'><%=getTran(request,"web","register",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","range",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_RANGE", "fp.range", sWebLanguage, "") %></td>
			<td class='admin'><%=getTran(request,"web","usertype",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_USERTYPE", "gn.fp.usertype", sWebLanguage, "") %>
			</td>
		</tr>
		<tr class='admin'><td colspan='4'><%=getTran(request,"web","methods",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin'><%=getTran(request,"pf","pill",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_COC", "") %>COC | <%=getTran(request,"pf","quantity",sWebLanguage) %>: <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_COC_QUANTITY", 4, 0, 9999, sWebLanguage) %>&nbsp;&nbsp;&nbsp;&nbsp;
				<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_COP", "") %>COP | <%=getTran(request,"pf","quantity",sWebLanguage) %>: <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_COP_QUANTITY", 4, 0, 9999, sWebLanguage) %>
			</td>
			<td class='admin'><%=getTran(request,"web","injection",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_INJECTION", "fp.injection", sWebLanguage, "") %>
				<%=SH.writeDefaultRadioButtons(tran, request, "gn.injector", "ITEM_TYPE_INJECTOR", sWebLanguage, false, "onchange='checkInjector()'", "") %>
				<span id='autoinject'><br/><%=SH.writeDefaultCheckBoxes(tran, request, "autoinjection", "ITEM_TYPE_AUTOINJECTION", sWebLanguage, false) %> <%=getTran(request,"web","quantity",sWebLanguage) %>: <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_AUTOINJECTION_QUANTITY", 4, 0, 50, sWebLanguage) %></span>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","preservatives",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_MALE_PRESERVATIVE", "") %><%=getTran(request,"web","male",sWebLanguage) %> | <%=getTran(request,"pf","quantity",sWebLanguage) %>: <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MALE_PRESERVATIVE_QUANTITY", 4, 0, 9999, sWebLanguage) %>&nbsp;&nbsp;&nbsp;&nbsp;
				<%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_FEMALE_PRESERVATIVE", "") %><%=getTran(request,"web","female",sWebLanguage) %> | <%=getTran(request,"pf","quantity",sWebLanguage) %>: <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_FEMALE_PRESERVATIVE_QUANTITY", 4, 0, 9999, sWebLanguage) %>
			</td>
			<td class='admin'><%=getTran(request,"web","implant",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_IMPLANT", "fp.implant", sWebLanguage, "") %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","othermethods",sWebLanguage) %></td>
			<td class='admin2' colspan='3'><%=SH.writeDefaultCheckBoxes(tran, request, "fp.othermethods", "ITEM_TYPE_OTHERMETHODS", sWebLanguage, true) %></td>
		</tr>
		<tr class='admin'><td colspan='4'><hr/></td></tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","initialhivstatus",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_INITIALHIVSTATUS", "fp.initialstatus", sWebLanguage, "") %></td>
			<td class='admin'><%=getTran(request,"web","hivtestresult",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_HIVRESULT", "fp.hivresult", sWebLanguage, "") %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","counseling",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultCheckBoxes(tran, request, "fp.hivcounseling", "ITEM_TYPE_HIVCOUNSELING", sWebLanguage, true) %></td>
			<td class='admin'><%=getTran(request,"web","hivdateresults",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DATE_HIVRESULTSRETRIEVAL", sWebLanguage, sCONTEXTPATH) %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","carelocation",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultRadioButtons(tran, request, "fp.carelocation", "ITEM_TYPE_CARELOCATION", sWebLanguage, false, "", "") %></td>
			<td class='admin'><%=getTran(request,"msas","observations",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_OBSERVATIONS", 40, 1) %></td>
		</tr>
        <tr><td colspan='4' class='adminblack'><%=getTran(request,"web","clinicalsheet",sWebLanguage) %></td></tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "datelatestperiod", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultDateInput(session, tran, "ITEM_TYPE_ANC_LATESTPERIOD", sWebLanguage, sCONTEXTPATH)%>
            </td>
            <td class="admin"><%=getTran(request,"web", "childrenalive", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, tran, "ITEM_TYPE_ANC_CHILDRENALIVE", sWebLanguage, "",0,20) %>
            </td>
        </tr>
		<tr>
			<td class='admin2' colspan='4'><%writeVitalSigns(pageContext); %></td>
		</tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","contraceptionused",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesno",  "ITEM_TYPE_ANC_CONTRACEPTIONUSED", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web", "contraceptiontype", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastTextInput(request, tran, "ITEM_TYPE_ANC_CONTRACEPTIONTYPE", 20, "") %>
            	<%=getTran(request,"web", "where", sWebLanguage)%>
            	<%=ScreenHelper.writeDefaultLastTextInput(request, tran, "ITEM_TYPE_ANC_CONTRACEPTIONWHERE", 20, "") %>
            </td>
        </tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","antecedents",sWebLanguage) %></td></tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","breastmass",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_BREASTMASS", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","hypertension",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_HYPERTENSION", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","migraine",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_MIGRAINE", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","recenticterus",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_RECENTICTERUS", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","varices",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_VARICES", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","tbtreatment",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_TBTREATMENT", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","cardiopathy",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_CARDIOPATHY", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","diabetes",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_DIABETES", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","drepanocytosis",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_DREPANOCYTOSIS", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","other",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_OTHERDISEASE", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","gynecologyexamination",sWebLanguage) %></td></tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","vulvaaspect",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultTextArea(session, tran, "ITEM_TYPE_ANC_VULVAASPECT", 40, 1) %>
            </td>
            <td class="admin"><%=getTran(request,"web", "vaginalmucosaaspect", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultTextArea(session, tran, "ITEM_TYPE_ANC_VAGINAMUCOSAASPECT", 40, 1) %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","vaginalsecretion",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons(tran, request, "yesno",  "ITEM_TYPE_ANC_VAGINALSECRETION", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web", "vaginaltouche", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultTextArea(session, tran, "ITEM_TYPE_ANC_VAGINALTOUCHE", 40, 1) %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"anc","iva",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons(tran, request, "posnegnotdone",  "ITEM_TYPE_ANC_IVA", sWebLanguage, false, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"anc","ivl",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons(tran, request, "posnegnotdone",  "ITEM_TYPE_ANC_IVL", sWebLanguage, false, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","std",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons(tran, request, "yesno",  "ITEM_TYPE_ANC_STD", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","treatment",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultTextArea(session, tran, "ITEM_TYPE_ANC_STDTREATMENT", 40, 1) %>
            </td>
        </tr>
        <tr><td colspan='4'><hr/></td></tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","eup",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_EUP", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","genitaltumor",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_GENITALTUMOR", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","pelvicinfection",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_PELVICINFECTION", sWebLanguage, true, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","abundantperiods",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultLastRadioButtons((TransactionVO)transaction, request, "yesnounknown",  "ITEM_TYPE_ANC_ABUNDANTPERIODS", sWebLanguage, true, "", "") %>
            </td>
        </tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","contraception",sWebLanguage) %></td></tr>
        <tr>
        	<td colspan='4'>
        		<table width='100%'>
        			<tr>
        				<td class='admin' rowspan='2'><%=getTran(request,"web","method",sWebLanguage) %></td>
        				<td class='admin' colspan='2'><%=getTran(request,"web","pill",sWebLanguage) %></td>
        				<td class='admin' colspan='2'><%=getTran(request,"web","injectables",sWebLanguage) %></td>
        				<td class='admin' rowspan='2'><%=getTran(request,"web","iud",sWebLanguage) %></td>
        				<td class='admin' colspan='2'><%=getTran(request,"web","implants",sWebLanguage) %></td>
        				<td class='admin' colspan='2'><%=getTran(request,"web","condoms",sWebLanguage) %></td>
        				<td class='admin' rowspan='2'><%=getTran(request,"web","spermicide",sWebLanguage) %></td>
        				<td class='admin' rowspan='2'><%=getTran(request,"web","other",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<td class='admin'><%=getTran(request,"web","coc",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","cop",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","im",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","sc",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","jadel",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","implanon",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","male",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","female",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<td class='admin'><%=getTran(request,"web","desired",sWebLanguage) %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_COC", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_COP", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_IM", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_SC", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_IUD", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_JADEL", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_IMPLANON", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_MALECONDOM", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_FEMALECONDOM", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_DESIRED_SPERMICIDE", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_ANC_DESIRED_OTHER", 20, "") %></td>
        			</tr>
        			<tr>
        				<td class='admin'><%=getTran(request,"web","prescribed",sWebLanguage) %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_COC", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_COP", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_IM", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_SC", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_IUD", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_JADEL", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_IMPLANON", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_MALECONDOM", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_FEMALECONDOM", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_ANC_PRESCRIBED_SPERMICIDE", "") %></td>
        				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_ANC_PRESCRIBED_OTHER", 20, "") %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr><td colspan='4'><hr/></td></tr>
        <tr>
            <td class="admin"><%=getTran(request,"web","fpstop",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_FPSTOP", sWebLanguage, "") %>
            </td>
            <td class="admin"><%=getTran(request,"web","otherdecision",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultTextArea(session, tran, "ITEM_TYPE_ANC_OTHERDECISION", 40, 1) %>
            </td>
        </tr>
    </table>
    <table width="100%" class="list" cellspacing="1">
        <tr class="admin">
            <td align="center"><a href="javascript:openPopup('medical/managePrescriptionsPopup.jsp&amp;skipEmpty=1',900,400,'medication');void(0);"><%=getTran(request,"Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></a></td>
        </tr>
        <tr>
            <td id='activeprescriptions'>
            	<script>
            		function loadActivePrescriptions(){
           		    	var url = '<c:url value="/pharmacy/getActivePrescriptions.jsp"/>?ts='+new Date();
           		      	new Ajax.Request(url,{
           			  		method: "GET",
           		        	parameters: "",
           		        	onSuccess: function(resp){
           		        		document.getElementById('activeprescriptions').innerHTML=resp.responseText;
           		        	}
           		      	});
            		}
                	loadActivePrescriptions();
            	</script>
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
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,accessright,sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

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

  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO,activeUser,"document.transactionForm.submit();"));
    %>
  }
  function checkInjector(){
	  if(document.getElementById("ITEM_TYPE_INJECTOR.2").checked){
		  document.getElementById('autoinject').style.display='';
	  }
	  else{
		  document.getElementById('autoinject').style.display='none';
	  }
  }
  checkInjector();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        