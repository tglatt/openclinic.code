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
	String accessright="msas.ptme";
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
        <tr>
        	<td class='admin'><%=getTran(request,"web","nationalmothercode",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_NATIONALCODEOFMOTHER", 20) %></td>
        	<td class='admin'><%=getTran(request,"web","cpnorder",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_CPNORDER", sWebLanguage, "", 1, 8) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","dateconfirmedhiv",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DATECONFIRMEDHIV", sWebLanguage, sCONTEXTPATH) %></td>
        	<td class='admin'><%=getTran(request,"web","serologyprofilemother",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_SEROLOGYMOTHER", "msas.serologymother", sWebLanguage, "") %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","startarvmother",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_STARTARVMOTHER", sWebLanguage, sCONTEXTPATH) %></td>
        	<td class='admin'><%=getTran(request,"web","therapeuticschemamother",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_THERAPYMOTHER", 40, 1) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","gestationalage",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_GESTATIONALAGE", 4, 1, 50, sWebLanguage) %></td>
        	<td class='admin'><%=getTran(request,"web","foreseenterm",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_FORESEENTERM", sWebLanguage, sCONTEXTPATH) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","viralloadt3",sWebLanguage) %></td>
        	<td>
        		<table width='100%'>
        			<tr>
        				<td class='admin2' nowrap><%=getTran(request,"web","sampledate",sWebLanguage)  %>:<br/> <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_VIRALLOADDATE", sWebLanguage, sCONTEXTPATH) %></td>
        				<td class='admin2' nowrap><%=getTran(request,"web","resultdate",sWebLanguage)  %>:<br/> <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_VIRALLOADRESULTDATE", sWebLanguage, sCONTEXTPATH) %></td>
        				<td class='admin2' nowrap><%=getTran(request,"web","result",sWebLanguage)  %>:<br/> <%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_VIRALLOADRESULT", 10) %></td>
        			</tr>
        		</table>
        	</td>
        	<td class='admin'><%=getTran(request,"web","delivery",sWebLanguage) %></td>
        	<td>
        		<table width='100%'>
        			<tr>
        				<td class='admin2' nowrap><%=getTran(request,"web","date",sWebLanguage)  %>:<br/> <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DELIVERYDATE", sWebLanguage, sCONTEXTPATH) %></td>
        				<td class='admin2' nowrap><%=getTran(request,"web","lieu",sWebLanguage)  %>:<br/> <%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_DELIVERYLOCATION", 20) %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","arvprophylaxisnewborn",sWebLanguage) %></td>
        	<td>
        		<table width='100%'>
        			<tr>
        				<td class='admin2' nowrap><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_ARVNEWBORN", sWebLanguage, true, "", "") %></td>
        				<td class='admin2' nowrap><%=getTran(request,"web","date",sWebLanguage)  %>:<br/> <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_ARVNEWBORNDATE", sWebLanguage, sCONTEXTPATH) %></td>
        				<td class='admin2' nowrap><%=getTran(request,"msas","arvschema",sWebLanguage)  %>:<br/> <%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_ARVNEWBORNSCHEMA", 10) %></td>
        			</tr>
        		</table>
        	</td>
        	<td class='admin'><%=getTran(request,"web","partnerscreening",sWebLanguage) %></td>
        	<td>
        		<table width='100%'>
        			<tr>
        				<td class='admin2' nowrap><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_PARTNERSCREENING", sWebLanguage, true, "", "") %></td>
        				<td class='admin2' nowrap><%=getTran(request,"msas","profile",sWebLanguage)  %>:<br/> <%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_PARTNERPROFILE", 10) %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr class='admin'>
        	<td colspan="4"><%=getTran(request,"web","pcr",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td colspan="4">
        		<table width='100%'>
        			<tr>
        				<td class='admin'></td>
        				<td class='admin'><%=getTran(request,"pcr","childageinmonths",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","datesample",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","datesamplereceived",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","result",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<td class='admin'>PCR 1</td>
						<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_PCRCHILDAGE_1",10) %></td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_PCRSAMPLE_1", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_PCRSAMPLERECEIVED_1", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_PCRRESULT_1", "posneg", sWebLanguage, "") %></td>
        			</tr>
        			<tr>
        				<td class='admin'>PCR 2</td>
						<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_PCRCHILDAGE_2",10) %></td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_PCRSAMPLE_2", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_PCRSAMPLERECEIVED_2", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_PCRRESULT_2", "posneg", sWebLanguage, "") %></td>
        			</tr>
        			<tr>
        				<td class='admin'>PCR 3</td>
						<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_PCRCHILDAGE_3",10) %></td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_PCRSAMPLE_3", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_PCRSAMPLERECEIVED_3", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_PCRRESULT_3", "posneg", sWebLanguage, "") %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr>
        	<td colspan="4"><hr/></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","serology14m",sWebLanguage) %></td>
        	<td>
        		<table width='100%'>
        			<tr>
						<td class='admin2'><%=getTran(request,"serology","childageinmonths",sWebLanguage)  %>:<br/> <%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_SEROLOGYCHILDAGE",10) %></td>
						<td class='admin2'><%=getTran(request,"web","date",sWebLanguage)  %>:<br/> <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_SEROLOGYDATE", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=getTran(request,"web","result",sWebLanguage)  %>:<br/> <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_SEROLOGYRESULT", "posneg", sWebLanguage, "") %></td>
        			</tr>
        		</table>
        	</td>
        	<td class='admin'><%=getTran(request,"web","cotrimoxazoleprohylaxis",sWebLanguage) %></td>
        	<td>
        		<table width='100%'>
        			<tr>
						<td class='admin2'><%=getTran(request,"web","datebegin",sWebLanguage)  %>:<br/> <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_COTRIMOXAZOLEBEGIN", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=getTran(request,"web","dateend",sWebLanguage)  %>:<br/> <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_COTRIMOXAZOLEEND", sWebLanguage,sCONTEXTPATH) %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr class='admin'>
        	<td colspan="2"><%=getTran(request,"web","postnatalconsultations",sWebLanguage) %></td>
        	<td colspan="2"/>
        </tr>
        <tr>
        	<td colspan="2">
        		<table width='100%'>
        			<tr>
        				<td class='admin'></td>
        				<td class='admin'><%=getTran(request,"web","date",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","vaccinalstatus",sWebLanguage) %></td>
        				<td class='admin'><%=getTran(request,"web","familyplanningmethod",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<td class='admin'><%=getTran(request,"web","cpon",sWebLanguage)  %> 1</td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_CPONDATE_1", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_VACCINATIONSTATUS_1", "yesno", sWebLanguage, "") %></td>
						<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_FAMILYPLANNING_1",10) %></td>
        			</tr>
        			<tr>
        				<td class='admin'><%=getTran(request,"web","cpon",sWebLanguage)  %> 2</td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_CPONDATE_2", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_VACCINATIONSTATUS_2", "yesno", sWebLanguage, "") %></td>
						<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_FAMILYPLANNING_2",10) %></td>
        			</tr>
        			<tr>
        				<td class='admin'><%=getTran(request,"web","cpon",sWebLanguage)  %> 3</td>
						<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_CPONDATE_3", sWebLanguage,sCONTEXTPATH) %></td>
						<td class='admin2'><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_VACCINATIONSTATUS_3", "yesno", sWebLanguage, "") %></td>
						<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_FAMILYPLANNING_3",10) %></td>
        			</tr>
        		</table>
        	</td>
        	<td class='admin'><%=getTran(request,"msas","observations",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_OBSERVATIONS", 40, 3) %></td>
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