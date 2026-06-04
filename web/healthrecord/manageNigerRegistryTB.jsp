<%@page import="be.mxs.common.model.vo.healthrecord.util.*"%>
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
	String accessright="ne.tb";
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
        <% 
        	TransactionVO tran = (TransactionVO)transaction; 
        	SH.populateTransactionWithLastItemValues(tran,activePatient.personid);
        %>
        <tr>
			<td class='admin'><%=getTran(request,"web","tbidentifier",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TB_IDENTIFIER", 30) %></td>
			<td class='admin'><%=getTran(request,"web","enrolementtype",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TB_ENROLEMENTTYPE", 30) %></td>
        </tr>
        <tr>
			<td class='admin'><%=getTran(request,"web","treatmentunit",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TB_TREATMENTUNIT", 30) %></td>
			<td class='admin'><%=getTran(request,"web","treatmentstart",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TB_START", sWebLanguage, sCONTEXTPATH) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","regime",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TB_REGIME", "niger.tb.regime", sWebLanguage, "") %></td>
        	<td class='admin'><%=getTran(request,"web","form",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultRadioButtons(tran, request, "niger.tb.form", "ITEM_TYPE_TB_FORM", sWebLanguage, false, "", "")%></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","patienttype",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TB_PATIENTTYPE", "niger.tb.patienttype", sWebLanguage, "") %></td>
        	<td class='admin'><%=getTran(request,"web","comingfrom",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TB_COMINGFROM", 30) %></td>
        </tr>
        <tr class='admin'>
        	<td colspan='4'><%=getTran(request,"web","labresults",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","beforetreatment",sWebLanguage) %></td>
        	<td class='admin' colspan='3'>
        		<table width='100%'>
        			<tr>
        				<td width='25%'><%=getTran(request,"web","microscopy",sWebLanguage) %></td>
        				<td width='15%'><%=getTran(request,"web","xpert",sWebLanguage) %></td>
        				<td width='30%'><%=getTran(request,"web","series",sWebLanguage) %></td>
        				<td width='30%'><%=getTran(request,"web","date",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<td><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TB_M1", "niger.tb.microscopy", sWebLanguage, "") %></td>
        				<td><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TB_XPERT", "niger.tb.xpert", sWebLanguage, "") %></td>
        				<td><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TB_SERIES1", 15) %></td>
        				<td><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TB_DATE1", sWebLanguage, sCONTEXTPATH) %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","2months",sWebLanguage) %></td>
        	<td class='admin' colspan='3'>
        		<table width='100%'>
        			<tr>
        				<td width='40%'><%=getTran(request,"web","microscopy",sWebLanguage) %></td>
        				<td width='30%'><%=getTran(request,"web","series",sWebLanguage) %></td>
        				<td width='30%'><%=getTran(request,"web","date",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<td><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TB_M2", "niger.tb.microscopy", sWebLanguage, "") %></td>
        				<td><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TB_SERIES2", 15) %></td>
        				<td><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TB_DATE2", sWebLanguage, sCONTEXTPATH) %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","5months",sWebLanguage) %></td>
        	<td class='admin' colspan='3'>
        		<table width='100%'>
        			<tr>
        				<td width='40%'><%=getTran(request,"web","microscopy",sWebLanguage) %></td>
        				<td width='30%'><%=getTran(request,"web","series",sWebLanguage) %></td>
        				<td width='30%'><%=getTran(request,"web","date",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<td><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TB_M5", "niger.tb.microscopy", sWebLanguage, "") %></td>
        				<td><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TB_SERIES5", 15) %></td>
        				<td><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TB_DATE5", sWebLanguage, sCONTEXTPATH) %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","endoftreatment",sWebLanguage) %></td>
        	<td class='admin' colspan='3'>
        		<table width='100%'>
        			<tr>
        				<td width='40%'><%=getTran(request,"web","microscopy",sWebLanguage) %></td>
        				<td width='30%'><%=getTran(request,"web","series",sWebLanguage) %></td>
        				<td width='30%'><%=getTran(request,"web","date",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<td><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TB_MEND", "niger.tb.microscopy", sWebLanguage, "") %></td>
        				<td><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TB_SERIESEND", 15) %></td>
        				<td><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TB_DATEEND", sWebLanguage, sCONTEXTPATH) %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr class='admin'>
        	<td colspan='4'><%=getTran(request,"web","treatmentresult",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","date",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TB_TREATMENTRESULTDATE", sWebLanguage, sCONTEXTPATH) %></td>
        	<td class='admin'><%=getTran(request,"web","result",sWebLanguage) %></td>
			<td class='admin2' nowrap><%=SH.writeDefaultRadioButtons(tran, request, "niger.tb.treatmentresult", "ITEM_TYPE_TB_TREATMENTRESULT", sWebLanguage, false, "", "")%></td>
        </tr>
        <tr class='admin'>
        	<td colspan='4'><%=getTran(request,"web","serologyandfollowup",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","serology",sWebLanguage) %></td>
			<td class='admin2' colspan='3'><%=SH.writeDefaultRadioButtons(tran, request, "niger.tb.serology", "ITEM_TYPE_TB_SEROLOGY", sWebLanguage, false, "", "")%></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","cotrimoxazole",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_TB_CTM", sWebLanguage, false, "", "")%></td>
        	<td class='admin'><%=getTran(request,"web","arv",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_TB_ARV", sWebLanguage, false, "", "")%></td>
        </tr>
        <tr class='admin'>
        	<td colspan='4'><%=getTran(request,"web","inhprophylaxis",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","kidsbelow5",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_TB_KIDSBELOW5", 5, 0, 20, sWebLanguage) %></td>
        	<td class='admin'><%=getTran(request,"web","kidsabove5",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_TB_KIDSABOVE5", 5, 0, 20, sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"tb","observations",sWebLanguage) %></td>
			<td class='admin2' colspan='3'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_TB_OBSERVATIONS", 80, 1)%></td>
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
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        