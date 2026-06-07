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
	String accessright="mspls.malaria.discharge";
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
	    <tr class='admin'><td colspan='4'><%=getTran(request,"web","evolution",sWebLanguage) %></td></tr>
	    <tr>
			<td class='admin'><%=getTran(request,"web","evolution",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_EVOLUTION", "gfmalaria.evolution2", sWebLanguage, "") %>
			</td>
			<td class='admin' nowrap><%=getTran(request,"web","finaldiagnosis",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<%=SH.writeDefaultRadioButtons(tran, request, "gfmalaria.presumeddiagnosislimited", "ITEM_TYPE_FINALDIAGNOSIS", sWebLanguage, false, "onchange='checkFields()'", "") %>
				<%=SH.writeDefaultCheckBox(tran, request, "yesno", "ITEM_TYPE_OTHERDIAGNOSIS", sWebLanguage, "") %> <%=getTran(request,"web","other",sWebLanguage) %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","administeredtreatments",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_ADMINISTEREDTREATMENTS", 40, 2) %>
			</td>
			<td class='admin'><%=getTran(request,"web","porelais",sWebLanguage) %></td>
			<td id='simpletreatment2' class='admin2' colspan='3'>
				<%=getTran(request,"gfmalaria","artemeterlumifantrine",sWebLanguage) %>:
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TREATMENT_UNCOMPLICATED", "gfmalaria.treatment.uncomplicated", sWebLanguage, "") %>
				&nbsp;&nbsp;&nbsp;<%=getTran(request,"web","other",sWebLanguage) %>:
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TREATMENT_UNCOMPLICATED_OTHER", 20) %>
			</td>
		</tr>
	    <tr>
	        <td width ="<%=sTDAdminWidth%>" class='admin'><%=getTran(request,"web","dischargeauthorizationdate",sWebLanguage)%>&nbsp;</td>
	        <td class='admin2' colspan='3'>
	        	<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_HPRC_DISCHARGEDATE", sWebLanguage, sCONTEXTPATH) %>
	        </td>
	    </tr>

	    
	    <%--  RAPPORTAGE --%>
	    <tr>
	        <td width ="<%=sTDAdminWidth%>" class='admin'><%=getTran(request,"web","rapportage",sWebLanguage)%>&nbsp;</td>
	        <td class='admin2' colspan='3'>
	        	<table width='100%'>
	        		<tr>
	        			<td><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "1", "ITEM_TYPE_MATERNALDEATH", activePatient.gender.equalsIgnoreCase("m")?"disabled":"") %><%=getTran(request,"web","maternaldeath",sWebLanguage) %></td>
	        			<td><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "1", "ITEM_TYPE_PERINATALDEATH", "") %><%=getTran(request,"web","perinataldeath",sWebLanguage) %></td>
	        			<td><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "1", "ITEM_TYPE_POSTACTINFECTION", "") %><%=getTran(request,"web","postactinfection",sWebLanguage) %></td>
	        		</tr>
	        	</table>
	        </td>
	    </tr>
		
		<%--  Patient avec Anemie ou transfuse / tdr positive --%>
	    <tr>
			
			<td width ="<%=sTDAdminWidth%>" class='admin'><%=getTran(request,"web","anemy_transfusion",sWebLanguage)%>&nbsp;</td>
			<td colspan='3'>	
				<table width='100%'>
					<tr>	
						<td class='admin2'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "1", "ITEM_TYPE_PATIENTWITHANEMIAORTRANSFUSION", "") %></td>
						<td width ="<%=sTDAdminWidth%>" class='admin'><%=getTran(request,"web","tdr_positive",sWebLanguage)%>&nbsp;</td>
						<td class='admin2'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "1", "ITEM_TYPE_PATIENTWITH_TDR_POSITIVE", "") %></td>
					</tr>
				</table>
			</td>
	    </tr>
		
	    <%--  DONNEES CLINIQUES --%>
		<tr>
			<td class='admin'><%=getTran(request,"web","clinicalsummary",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_OBSERVATIONS", 80, 2) %>
			</td>
		</tr>
	    <tr>
	        <td class="admin"><%=getTran(request,"web.occup","nosocomial.infections",sWebLanguage)%>&nbsp;</td>
	        <td class="admin2" colspan='3'>
	  			<table width='100%'>
	  				<tr>
	   					<td class="admin2">
	         				<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "nosocomial.infections", "ITEM_TYPE_NOSOCOMIAL_INFECTIONS", sWebLanguage, true) %>
	         			</td>
					</tr>
				</table>			            		
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
    <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncodingWide.jsp"),pageContext);%>            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,accessright,sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>  
function checkFields(){
	  if(document.getElementById("ITEM_TYPE_PRESUMEDDIAGNOSIS.1").checked){
		  document.getElementById("simpletreatment1").style.textDecoration='';
		  document.getElementById("simpletreatment2").style.textDecoration='';
		  document.getElementById("severetreatment1").style.textDecoration='line-through';
		  document.getElementById("severetreatment2").style.textDecoration='line-through';
		  document.getElementById("severetreatment3").style.textDecoration='line-through';
	  }
	  else if(document.getElementById("ITEM_TYPE_PRESUMEDDIAGNOSIS.2").checked){
		  document.getElementById("simpletreatment1").style.textDecoration='line-through';
		  document.getElementById("simpletreatment2").style.textDecoration='line-through';
		  document.getElementById("severetreatment1").style.textDecoration='';
		  document.getElementById("severetreatment2").style.textDecoration='';
		  document.getElementById("severetreatment3").style.textDecoration='';
	  }
	  else{
		  document.getElementById("simpletreatment1").style.textDecoration='';
		  document.getElementById("simpletreatment2").style.textDecoration='';
		  document.getElementById("severetreatment1").style.textDecoration='';
		  document.getElementById("severetreatment2").style.textDecoration='';
		  document.getElementById("severetreatment3").style.textDecoration='';
	  }
	  if(document.getElementById("ITEM_TYPE_SEVERITYSIGNS.14").checked){
		  document.getElementById("ITEM_TYPE_SEVERITYSIGNS_OTHER").style.display='';
	  }
	  else{
		  document.getElementById("ITEM_TYPE_SEVERITYSIGNS_OTHER").style.display='none';
	  }
	  if(document.getElementById("ITEM_TYPE_OTHERSIGNS.6").checked){
		  document.getElementById("ITEM_TYPE_OTHERSIGNS_OTHER").style.display='';
	  }
	  else{
		  document.getElementById("ITEM_TYPE_OTHERSIGNS_OTHER").style.display='none';
	  }
	}
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
  checkFields();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        