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
	String accessright="teleconsultation";
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
        	if(tran.isNew() || tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SESSIONKEY").trim().length()==0){
        		tran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SESSIONKEY").setValue(SH.getRandomPassword(5));
        	}
        %>
		<tr class='admin'><td colspan='4'><%=getTran(request,"web","applicant",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","healthfacility",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_DESTINATIONID") %>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_DESTINATIONNAME", 50) %>
				<img id='syncservers' style='vertical-align: middle' src='<%=sCONTEXTPATH %>/_img/icons/icon_sync.gif' name='syncButton' title='<%=getTranNoLink("web.manage","synchronise",sWebLanguage) %>' onclick='syncServers()'/>
				<img style='vertical-align: middle' src='<%=sCONTEXTPATH %>/_img/icons/icon_search.png' name='searchButton' title='<%=getTranNoLink("web","search",sWebLanguage) %>' onclick='searchServers()'/>
				<div id="autocomplete_destination" class="autocomple"></div>
			</td>
			<td class='admin'><%=getTran(request,"web","careprovider",sWebLanguage) %></td>
			<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_CAREPROVIDER", 40) %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","telephone",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_CAREGIVERPHONE", 20) %>
			</td>
			<td class='admin'><%=getTran(request,"web","email",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_CAREGIVEREMAIL", 40) %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","remotepatientid",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_PATIENTID", 20) %>
			</td>
		</tr>
		<tr class='admin'><td colspan='4'><%=getTran(request,"web","request",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","requestdatetime",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_REQUESTDATE", sWebLanguage, sCONTEXTPATH) %>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_REQUESTHOUR", 5) %>
			</td>
			<td class='admin'><%=getTran(request,"web","appointmentdatetime",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_APPOINTMENTDATE", sWebLanguage, sCONTEXTPATH) %>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_APPOINTMENTHOUR", 5) %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","sessionkey",sWebLanguage) %></td>
			<td class='admin2'><font style='font-size: 14px;font-weight: bolder'><%=tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SESSIONKEY") %></font>
				<img onclick='opensmartglasses("<%=tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SESSIONKEY") %>");' style='vertical-align: middle' height='20px' src='<%=sCONTEXTPATH%>/_img/themes/default/smartglasses.png'/>
				<%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_SESSIONKEY")%>
			</td>
			<td class='admin'><%=getTran(request,"web","indication",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_INDICATION", "teleconsultation.indication", sWebLanguage, "") %>
				&nbsp;<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_INDICATION_TEXT", 20, 1) %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","specialist",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultNomenclatureField(session, tran, "ITEM_TYPE_SPECIALIST", "teleconsultation.specialist", 50, sWebLanguage, sCONTEXTPATH, "")%>
			</td>
			<td class='admin'><%=getTran(request,"openclinic.chuk","duration",sWebLanguage) %></td>
			<td class='admin'>
				<%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_DURATION", 5, 1, 300, sWebLanguage) %> min
			</td>
		</tr>
		<tr class='admin'><td colspan='4'><%=getTran(request,"web","clinicalinformation",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","history",sWebLanguage) %></td>
			<td class='admin'>
				<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_HISTORY", 50, 1) %>
			</td>
			<td class='admin'><%=getTran(request,"web","complaints",sWebLanguage) %></td>
			<td class='admin'>
				<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_COMPLAINTS", 50, 1) %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","signsandsymptoms",sWebLanguage) %></td>
			<td class='admin'>
				<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_SYMPTOMS", 50, 1) %>
			</td>
			<td class='admin'><%=getTran(request,"web","diagnosis",sWebLanguage) %></td>
			<td class='admin'>
				<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_DIAGNOSIS", 50, 1) %>
			</td>
		</tr>
		<tr class='admin'><td colspan='4'><%=getTran(request,"web","conclusions",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","referralneeded",sWebLanguage) %></td>
			<td class='admin'>
				<%=SH.writeDefaultRadioButtons(tran, request, "teleconsultation.referral", "ITEM_TYPE_REFERRALNEEDED", sWebLanguage, false, "", "") %>
			</td>
			<td class='admin'><%=getTran(request,"web","treatment",sWebLanguage) %></td>
			<td class='admin'>
				<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_TREATMENT", 50, 1) %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","otherinstructions",sWebLanguage) %></td>
			<td class='admin' colspan='3'>
				<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_OTHERINSTRUCTIONS", 100, 1) %>
			</td>
		</tr>
    </table>
    <table width="100%" class="list" cellspacing="1">
    	<tr>
			<%-- DIAGNOSES --%>
			<td style="vertical-align:top;padding:0" class="admin2">
                <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
			</td>
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

	function syncServers(noshow){
	    var url = '<c:url value="/util/updateGHBServers.jsp"/>'+
	              '?ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      parameters: "domain=<%=MedwanQuery.getInstance().getConfigString("ghb_ref_projectdomain","")%>",
	      onSuccess: function(resp){
	    	  if(noshow){
	    		 //donotinform 
		    		 document.getElementById('syncservers').src='<%=sCONTEXTPATH %>/_img/icons/icon_check.png';
		    		 document.getElementById('syncservers').title='<%=getTranNoLink("web","serverssynchronized",sWebLanguage)%>';
	    	  }
	    	  else{
		    	  if(!resp.responseText.includes("<ERROR")){
		    		  alert('<%=getTranNoLink("web","serverssynchronizedfordomain",sWebLanguage)+" ["+MedwanQuery.getInstance().getConfigString("ghb_ref_projectdomain","")+"]"%>');
		    	  }
		    	  else{
		    		  alert(resp.responseText.trim());
		    	  }
	      	  }
	      }
	    });
	}
	var myautocompleter = new Ajax.Autocompleter('ITEM_TYPE_DESTINATIONNAME','autocomplete_destination','util/showGHBServers.jsp',{
		  minChars:1,
		  method:'post',
		  afterUpdateElement:afterAutoComplete,
		  callback:composeCallbackURL
		});
		
	function afterAutoComplete(field,item){
	  var regex = new RegExp('[-0123456789.]*-idcache','i');
	  var nomimage = regex.exec(item.innerHTML);
	  var id = nomimage[0].replace('-idcache','');
	  document.getElementById("ITEM_TYPE_DESTINATIONID").value = id;
	  document.getElementById("ITEM_TYPE_DESTINATIONNAME").value=id+" - "+document.getElementById("ITEM_TYPE_DESTINATIONNAME").value.substring(0,document.getElementById("ITEM_TYPE_DESTINATIONNAME").value.indexOf(id));
	}
		
	function composeCallbackURL(field,item){
	  var url = "";
	  if(field.id=="ITEM_TYPE_DESTINATIONNAME"){
		url = "findName="+field.value;
	  }
	  return url;
	}
	function searchServers(){
		openPopup("_common/search/searchGHBServers.jsp&PopuWidth=400&PopupHeight=400");
	}
	function opensmartglasses(key){
		openPopup("util/setupTelemedicineSession.jsp&PopupWidth=500&sessionkey1="+key+"&PopupHeight=200");
	}
	syncServers(true);
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        