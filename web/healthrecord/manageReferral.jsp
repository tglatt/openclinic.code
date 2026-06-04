<%@page import="be.openclinic.sync.GHBNetwork"%>
<%@page import="be.mxs.common.model.vo.healthrecord.ItemContextVO"%>
<%@page import="be.openclinic.finance.Insurance"%>
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
	String accessright="examination.referral";
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
        <tr>
        	<td class="admin"><%=getTran(request,"web","typeoftransfer",sWebLanguage) %></td>
        	<td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "transfertype", "ITEM_TYPE_TYPEOFTRANSFER", sWebLanguage, false, "", "") %></td>
        	<td class="admin"><%=getTran(request,"web","typeoftransportation",sWebLanguage) %></td>
        	<td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "transporttype", "ITEM_TYPE_TYPEOFTRANSPORTATION", sWebLanguage, false, "", "") %></td>
        </tr>
        <tr>
        	<td class="admin"><%=getTran(request,"web","destinationservice",sWebLanguage) %></td>
        	<td class="admin2"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_DESTINATIONSERVICE", 60, 1) %></td>
        	<td class="admin"><%=getTran(request,"web","destinationcareprovider",sWebLanguage) %></td>
        	<td class="admin2"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_DESTINATIONCAREPROVIDER", 60, 1) %></td>
        </tr>
        <tr>
        	<td class="admin"><%=getTran(request,"web","appointmentmade",sWebLanguage) %></td>
        	<td class="admin2">
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_APPOINTMENTDATE", sWebLanguage, sCONTEXTPATH) %>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_APPOINTMENTHOUR", sWebLanguage, "", 0, 23) %> : <%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_APPOINTMENTMINUTE", sWebLanguage, "", 0, 59) %>
        	</td>
        	<td class="admin"><%=getTran(request,"web","healthinsurance",sWebLanguage) %></td>
        	<%
        		if(((TransactionVO)transaction).isNew()){
        			String sInsurances="";
        			Vector<Insurance> insurances = Insurance.getCurrentInsurances(activePatient.personid);
        			for(int n=0;n<insurances.size();n++){
        				if(sInsurances.length()>0){
        					sInsurances+=", ";
        				}
        				Insurance insurance = insurances.elementAt(n);
        				sInsurances+=insurance.getInsurar().getName()+(SH.c(insurance.getInsuranceNr()).length()==0?"":" ["+insurance.getInsuranceNr()+"]");
        			}
        			((TransactionVO)transaction).getItem(SH.ITEM_PREFIX+"ITEM_TYPE_HEALTHINSURANCE").setValue(sInsurances);
        		}
        		
        	%>
        	<td class="admin2"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_HEALTHINSURANCE", 60, 1) %></td>
        </tr>
        <tr>
        	<td colspan='4' class='admin2'><hr/></td>
        </tr>
        <tr>
        	<td class='admin2' colspan='4'><%writeVitalSigns(pageContext); %></td>
        </tr>
        <tr>
        	<td class="admin"><%=getTran(request,"web","findings",sWebLanguage) %></td>
        	<td class="admin2"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_FINDINGS", 60, 1) %></td>
        	<td class="admin"><%=getTran(request,"web","treatment",sWebLanguage) %></td>
        	<td class="admin2"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_TREATMENT", 60, 1) %></td>
        </tr>
        <tr>
        	<td class="admin"><%=getTran(request,"web","reasonforreferral",sWebLanguage) %></td>
        	<td class="admin2"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_REASONFORREFERRAL", 60, 1) %></td>
        	<%if(((TransactionVO)transaction).isNew()){ %>
        		<td class='admin2' colspan='2'></td>
        	<%}else{
        		if(((TransactionVO)transaction).getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORIGINALUID").length()==0){
        			((TransactionVO)transaction).getItems().add(new ItemVO(MedwanQuery.getInstance().getOpenclinicCounter("ItemID"), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORIGINALUID",SH.ci("ghb_ref_serverid",((TransactionVO)transaction).getServerId())+"."+((TransactionVO)transaction).getTransactionId(),((TransactionVO)transaction).getUpdateTime(),(ItemContextVO)null));
        		}
        	%>
	        	<td class="admin"><%=getTran(request,"web","referralid",sWebLanguage) %></td>
	        	<td class="admin2">
	        		<font style='font-size: 12px;color: red; font-weight: bolder'><%=((TransactionVO)transaction).getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_ORIGINALUID") %>
	        			[<i><%= getTran(request,"web","origin",sWebLanguage)+": "+GHBNetwork.getServerNameById(((TransactionVO)transaction).getItemValue(SH.ITEM_PREFIX+"ITEM_TYPE_ORIGINALUID").split("\\.")[0])%></i>]	
	        		</font>
	        	</td>
        	<%} %>
        </tr>
    </table>
    <table width="100%" class="list" cellspacing="1">
    	<tr class='admin'>
    		<td align='center'><%SH.setIncludePage(customerInclude("healthrecord/diagnosesEncodingNoRFE.jsp"),pageContext);%></td>
    	</tr>
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
    </table>            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	<%
		String sCounterReferralButton="";
		if(((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERRAL_SOURCESITE").length()>0){
			sCounterReferralButton="<input class='button' type='button' name='buttonCounterReferral' id='buttonCounterReferral' value='"+getTranNoLink("web","counterreferral",sWebLanguage)+"' onclick='doCounterReferral()'/>";
		}
	%>
	<%=getButtonsHtml(request,activeUser,activePatient,accessright,sWebLanguage,true,sCounterReferralButton)%>
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
  
  function doCounterReferral(){
	  var url = "<%=sCONTEXTPATH%>/healthrecord/createTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_COUNTERREFERRAL&referenceUID=<%=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORIGINALUID")%>";
	  window.location.href=url;
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