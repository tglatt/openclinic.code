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
	String accessright="msas.morgue";
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
        
      	<tr class='admin'><td colspan='4'><%=getTran(request,"web","defunt",sWebLanguage) %></td></tr>
      	<tr>
			 <td class='admin'><%=getTran(request,"web","datedeces",sWebLanguage)%>&nbsp;</td>
			  <td class='admin2' colspan="4">
	               <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_REGISTRY_MORGUE_DATE_DECES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_REGISTRY_MORGUE_DATE_DECES_GESTION" property="value" formatType="date"/>" id="datedeces" onblur='checkDate(this);' onchange='calculateDuration();' onfocus='calculateDuration();' onkeyup='calculateDuration();'/>
	               <script>writeMyDate("datedeces", "<c:url value="/_img/icons/icon_agenda.png"/>", "<%=getTran(null,"Web","PutToday",sWebLanguage)%>");</script>
			       <%=getTran(request,"web", "hour", sWebLanguage)%>
			       <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_REGISTRY_MORGUE_HOUR_DECES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_REGISTRY_MORGUE_HOUR_DECES_GESTION" property="value"/>" onblur="checkTime(this)">
			  </td>
	     </tr>
      	  <tr>      
	         <td class="admin"><%=getTran(request,"web","lieudeces",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_LIEU_DECES", 25)%></td>
	         <td class="admin"><%=getTran(request,"web","provenancecorps",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_PROVENANCE_CORPS", 25)%></td>
  		</tr>
  		 <tr class='admin'><td colspan='4'><%=getTran(request,"web","deposant",sWebLanguage) %></td></tr>
  		 <tr>      
	         <td class="admin"><%=getTran(request,"web","nomprenom",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_NOM_PRENOM_DEPOSANT", 25)%></td>
	         <td class="admin"><%=getTran(request,"web","cni",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_CNI_DEPOSANT", 25)%></td>
  		</tr>
  		<tr>      
	         <td class="admin"><%=getTran(request,"web","liendefunt",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_LIEN_DEFUNT_DEPOSANT", 25)%></td>
	         <td class="admin"><%=getTran(request,"web","telephone",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_TELEPHONE_DEPOSANT", 25)%></td>
  		</tr>
  		<tr>      
	         <td class="admin"><%=getTran(request,"web","adressdeposant",sWebLanguage)%></td>
	         <td class="admin2" colspan="4" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_ADRESSE_DEPOSANT", 25)%></td>
	    </tr>
			 <tr class='admin'><td colspan='4'><%=getTran(request,"web","gestioncorps",sWebLanguage) %></td></tr>
			 <tr>      
	         <td class="admin"><%=getTran(request,"web","numerocasier",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_NUMERO_CASIER", 25)%></td>
	         <td class="admin"><%=getTran(request,"web","actedeces",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_ACTES_DECES", 25)%></td>
  		</tr>
  		<tr>
			 <td class='admin'><%=getTran(request,"web","datesortie",sWebLanguage)%>&nbsp;</td>
			  <td class='admin2' colspan="4">
	               <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_REGISTRY_MORGUE_DATE_SORTIE_GESTION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_REGISTRY_MORGUE_DATE_SORTIE" property="value" formatType="date"/>" id="datesortie" onblur='checkDate(this);' onchange='calculateDuration();' onfocus='calculateDuration();' onkeyup='calculateDuration();'/>
	               <script>writeMyDate("datesortie", "<c:url value="/_img/icons/icon_agenda.png"/>", "<%=getTran(null,"Web","PutToday",sWebLanguage)%>");</script>
			       <%=getTran(request,"web", "hour", sWebLanguage)%>
			       <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_REGISTRY_MORGUE_HOUR_SORTIE_GESTION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_REGISTRY_MORGUE_HOUR_SORTIE" property="value"/>" onblur="checkTime(this)">
			  </td>
	     </tr>
	     <tr class='admin'><td colspan='4'><%=getTran(request,"web","leveecorps",sWebLanguage) %></td></tr>
  		 <tr>      
	         <td class="admin"><%=getTran(request,"web","nomprenom",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_NOM_PRENOM_PERSONNE_LEVEE_CORPS", 25)%></td>
	         <td class="admin"><%=getTran(request,"web","cni",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_CNI_DEPOSANT_PERSONNE_LEVEE_CORPS", 25)%></td>
  		</tr>
  		<tr>      
	         <td class="admin"><%=getTran(request,"web","liendefunt",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_LIEN_DEFUNT_PERSONNE_LEVEE_CORPS", 25)%></td>
	         <td class="admin"><%=getTran(request,"web","telephone",sWebLanguage)%></td>
	         <td class="admin2" ><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_TELEPHONE_PERSONNE_LEVEE_CORPS", 25)%></td>
  		</tr>
  		   <tr>      
	          <td class="admin"><%=getTran(request,"web","observation",sWebLanguage)%></td>
	         <td class="admin2" colspan="4"><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_REGISTRY_MORGUE_OBSERVATIONS",40, 2)%></td>
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