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
	String accessright="premature.admission";
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
        <!-- 
        	******************************************
        	* Code goes here 						 *
        	******************************************
        -->
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","child",sWebLanguage)%></td></tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","gestationalage",sWebLanguage) %></td>
        	<td class='admin2'><%= SH.writeDefaultSelect(request, tran, "!ITEM_TYPE_GESTATIONAL_AGE", sWebLanguage, "", 22, 42) %>
        	<td class='admin'><%=getTran(request,"web","birthweight",sWebLanguage) %></td>
        	<td class='admin2'><%= SH.writeDefaultNumericInput(session, tran, "!ITEM_TYPE_BIRTHWEIGHT", 5, 0, 7000, sWebLanguage) %> g
        </tr>
        <tr>
        	<td class='admin' rowspan="2"><%=getTran(request,"web","pathologies",sWebLanguage) %></td>
        	<td class='admin2' colspan="3"><%= SH.writeDefaultCheckBoxes(tran, request, "premature.disease","ITEM_TYPE_NEONATAL_DISEASE", sWebLanguage, true) %>
        </tr>
        <tr>
        	<td class='admin2' colspan="3"><%=getTran(request,"web","other",sWebLanguage) %>: <%= SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_NEONATAL_DISEASE_TEXT", 80, 1) %>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","snapscore",sWebLanguage) %> <a href='https://sfar.org/scores2/snap22.php' target='_new'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_info.gif'/></a></td>
        	<td class='admin2'><%= SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_SNAP", 5, 0, 115, sWebLanguage) %>
        	<td class='admin'><%=getTran(request,"web","snappescore",sWebLanguage) %> <a href='https://sfar.org/scores2/snap22.php' target='_new'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_info.gif'/></a></td>
        	<td class='admin2'><%= SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_SNAPPE", 5, 0, 162, sWebLanguage) %>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","cribscore",sWebLanguage) %> <a href='https://sfar.org/scores2/crib.php' target='_new'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_info.gif'/></a></td>
        	<td class='admin2'><%= SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_CRIB", 5, 0, 23, sWebLanguage) %>
        	<td class='admin'><%=getTran(request,"web","ntissscore",sWebLanguage) %> <a href='https://sfar.org/scores/ntiss.php' target='_new'><img src='<%=sCONTEXTPATH%>/_img/icons/icon_info.gif'/></a></td>
        	<td class='admin2' colspan="3"><%= SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_NTISS", 5, 0, 100, sWebLanguage) %>
        </tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","delivery",sWebLanguage)%></td></tr>
	   	<tr>
	         <td class='admin'><%=getTran(request,"web","deliverydate",sWebLanguage)%>&nbsp;</td>
	         <td class='admin2'>
	                   <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYDATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYDATE" property="value" formatType="date"/>" id="deliverydate" onblur='checkDate(this);'/>
	                   <script>writeMyDate("deliverydate", "<c:url value="/_img/icons/icon_agenda.png"/>", "<%=getTran(null,"Web","PutToday",sWebLanguage)%>");</script>
	             <%=getTran(request,"web", "hour", sWebLanguage)%>
	             <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYHOUR" property="value"/>" onblur="checkTime(this)">
	         </td>
	         <td class='admin'><%=getTran(request,"web","delivery.location",sWebLanguage)%>&nbsp;</td>
	         <td class="admin2">
	             <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYLOCATION" property="itemId"/>]>.value">
	             	<option/>
	          	<%=ScreenHelper.writeSelect(request,"msas.deliverylocation",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYLOCATION"),sWebLanguage,false,true) %>
	             </select>
	         </td>
	   	</tr>
	   	<tr>
	         <td class='admin'><%=getTran(request,"web","deliverytype",sWebLanguage)%>&nbsp;</td>
	         <td class="admin2">
	             <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE" property="itemId"/>]>.value">
	             	<option/>
	          	<%=ScreenHelper.writeSelect(request,"msas.deliverytype.cs",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE"),sWebLanguage,false,true) %>
	             </select>
	             &nbsp;<%=getTran(request,"msas","comment",sWebLanguage) %>: 
	             <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_COMMENT", 20) %>
	         </td>
	         <td class='admin'><%=getTran(request,"web","childbirthtype",sWebLanguage)%>&nbsp;</td>
	         <td class="admin2">
	             <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDBIRTHTYPE" property="itemId"/>]>.value">
	             	<option/>
	          	<%=ScreenHelper.writeSelect(request,"msas.childbirthtype",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_CHILDBIRTHTYPE"),sWebLanguage,false,true) %>
	             </select>
	         </td>
	   	</tr>
	   	<tr>
	         <td class='admin'><%=getTran(request,"web","qualification",sWebLanguage)%>&nbsp;</td>
	         <td class="admin2" colspan="3">
	             <select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_QUALIFICATION" property="itemId"/>]>.value">
	             	<option/>
	          	<%=ScreenHelper.writeSelect(request,"msas.qualification",((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_DELIVERIES_QUALIFICATION"),sWebLanguage,false,true) %>
	             </select>
	             <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_MSAS_DELIVERIES_PARTOGRAMME", "") %><%=getTran(request,"web","partogrammedone",sWebLanguage) %>
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
    <%-- DIAGNOSES --%>
    <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>            
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