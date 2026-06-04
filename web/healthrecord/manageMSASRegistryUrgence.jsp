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
	String accessright="msas.urgence";
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
         		<td class="admin2" colspan="4" ><%writeVitalSigns(pageContext);%> </td>
  		 </tr>
  		 <tr>
  		  		<td class='admin'><%=getTran(request,"web","newcase",sWebLanguage) %></td>
			    <td class='admin2' ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "!ITEM_TYPE_MSAS_CONS_NEWCASE", sWebLanguage, false, "", "") %></td>
				<td class='admin'><%=getTran(request,"web","urgency",sWebLanguage) %></td>
			    <td class="admin2">  <%=SH.writeDefaultSelect(request, tran, "!ITEM_TYPE_MSAS_URGENCE_TYPE", "typeurgency",sWebLanguage, "")%></td>
           		
		</tr>   
		   
		  <tr>         
              <td class="admin" width="25%"> <%=getTran(request,"web","infoaccompagnant",sWebLanguage)%></td>
           	 <td class="admin2" width="25%"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_URGENCE_INFOACCOMPAGNANT",40, 2)%></td>
           	 <td class='admin'><%=getTran(request,"web","arrivaldate",sWebLanguage)%>&nbsp;</td>
			  <td class='admin2'><%= SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MSAS_URGENCE_ARRIVALDATE", sWebLanguage, sCONTEXTPATH) %>
	                         <%=getTran(request,"web", "hour", sWebLanguage)%>
	                         <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_URGENCE_ARRIVALHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_URGENCE_ARRIVALHOUR" property="value"/>" onblur="checkTime(this)">
	                         </td>
 		 </tr>
 		 <tr>         
              <td class="admin" > <%=getTran(request,"web","niveaugravite",sWebLanguage)%></td>
          		<td class="admin2">  <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_URGENCE_NIVEAU_GRAVITE", "niveaugravite",sWebLanguage, "")%></td>
           		<td class='admin'><%=getTran(request,"web","hourprise",sWebLanguage)%>&nbsp;</td>
			    <td class='admin2'><input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_URGENCE_ARRIVALHOURPRISE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_URGENCE_ARRIVALHOURPRISE" property="value"/>" onblur="checkTime(this)"></td>
 		 </tr>
 		  	<tr> 
              	<td class="admin" > <%=getTran(request,"web","niveau.urgence",sWebLanguage)%></td>
          		<td class="admin2" colspan="4">  <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_URGENCE_NIVEAU_URGENCE", "niveau.urgence",sWebLanguage, "")%></td>
       	 	</tr>
		 <tr>    
		  <td class="admin" > <%=getTran(request,"web","regulationmedical",sWebLanguage)%></td>
            <td class="admin2" colspan="4"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_URGENCE_REGULATION_MEDICAL", sWebLanguage, false, "", "") %>	
 			&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 			<%=getTran(request,"web","nameregulationmedical",sWebLanguage)%>&nbsp;&nbsp;
 			<%= SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_URGENCE_NAME_REGULATION_MEDICAL", 20) %>
 			 </td> 
 			</tr>
 			<tr> 
              	<td class="admin" > <%=getTran(request,"web","modearriver",sWebLanguage)%></td>
          		<td class="admin2">  <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_URGENCE_MODEARRIVER", "modearriver",sWebLanguage, "")%></td>
           		<td class="admin" > <%=getTran(request,"web","motifadmision",sWebLanguage)%></td>
          		<td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_URGENCE_MOTIF_ADMISSION",40, 2)%></td>
 		 	</tr>
 		 <tr> 
                <td class="admin" > <%=getTran(request,"web","hemocue",sWebLanguage)%></td>
          		<td class="admin2" > <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_URGENCE_HEMOCUE",40, 2)%></td>
           		<td class="admin" > <%=getTran(request,"web","glasgow",sWebLanguage)%></td>
          		<td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_URGENCE_GLASGOW",40, 2)%></td>
 		 </tr>
 		  <tr>    
		    	
          		<td class="admin"><%=getTran(request,"web","tdrpalu",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="4"><%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "tdrpalu", "ITEM_TYPE_MSAS_URGENCE_TDR_PALU", sWebLanguage, false,"","") %>
			                 </td>
 		 </tr>
 		 <tr> 
 		 		<td class="admin" > <%=getTran(request,"web","signediagnostic",sWebLanguage)%></td>
            	<td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_URGENCE_SIGNE_DIAGNOSTIC",40, 2)%></td>
				<td class='admin'><%=getTran(request,"web","ecg",sWebLanguage)%>&nbsp;</td>
			    <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_URGENCE_ECG", sWebLanguage, false, "", "") %></td>	
 		 </tr>
 		  <tr> 
 		 		 <td class="admin" > <%=getTran(request,"web","traitement",sWebLanguage)%></td>
            	<td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_URGENCE_TRAITEMENT",40, 2)%></td>
				 <td class='admin'><%=getTran(request,"web","sortidate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><%= SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MSAS_URGENCE_SORTIDATE", sWebLanguage, sCONTEXTPATH) %>
	                         <%=getTran(request,"web", "hour", sWebLanguage)%>
	                         <input type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_URGENCE_SORTIHOUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MSAS_URGENCE_SORTIHOUR" property="value"/>" onblur="checkTime(this)">
 	                  	</td>		
 		 </tr>
 		  <tr>  
 		  		<td class='admin'><%=getTran(request,"web","admission",sWebLanguage)%>&nbsp;</td>
			    <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_URGENCE_ADMISSION", sWebLanguage, false, "", "") %></td>	
 		  		<td class="admin" > <%=getTran(request,"web","modesorti",sWebLanguage)%></td>
          		<td class="admin2">  <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_URGENCE_MODESORTI", "modesorti",sWebLanguage, "")%></td>
 		 						 	
 		 </tr>
 		  <tr>  
 		  		<td class="admin" > <%=getTran(request,"web","responsable",sWebLanguage)%></td>
            	<td class="admin2" > <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_URGENCE_MEDECINRESPONSABLE",40, 1)%></td>
				 <td class="admin" > <%=getTran(request,"web","observation",sWebLanguage)%></td>
            	<td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_URGENCE_OBSERVATION",40, 2)%></td>
				 	
 		 </tr>
 		 	<tr>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.diabetes", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_diabetes' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("diabetes","ITEM_TYPE_MSAS_CONS_DIABETES")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='diabetes' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.diabetes", "ITEM_TYPE_MSAS_CONS_DIABETES", sWebLanguage, false,"onchange=\"checkImage('diabetes','ITEM_TYPE_MSAS_CONS_DIABETES')\"") %></div>
			            </td>
			            <td class='admin' style='vertical-align: top'>
			            	<table cellspacing="0" cellpadding="0" width="100%">
				            	<tr>
									<td width='99%' style='color:#505050;background-color: #C3D9FF; font-weight: bolder'><%=getTran(request,"web", "consultation.hypertension", sWebLanguage)%></td>	
									<td style='background-color: #C3D9FF'><img id='img_hta' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='toggleSection("hta","ITEM_TYPE_MSAS_CONS_HYPERTENSION")'>&nbsp;</td>			            		
				            	</tr>
			            	</table>
			            </td>
			            <td class="admin2">
			            	<div id='hta' style='display: none'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.hypertension", "ITEM_TYPE_MSAS_CONS_HYPERTENSION", sWebLanguage, false,"onchange=\"checkImage('hta','ITEM_TYPE_MSAS_CONS_HYPERTENSION')\"") %></div>
			            </td>
			    </tr>
 		
    </table>
    <table width="100%" class="list" cellspacing="1">
        <tr class="admin">
            <td align="center" colspan='2'><a href="javascript:openPopup('medical/managePrescriptionsPopup.jsp&amp;skipEmpty=1',900,400,'medication');void(0);"><%=getTran(request,"Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></a></td>
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
	        <%
            Vector paperprescriptions = PaperPrescription.find(activePatient.personid,"",ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime()),ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime()),"","DESC");
	        out.print("<td><table width='100%'>");
            if(paperprescriptions.size()>0){
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
            }
            %>	
            <tr>
                <td><a href="javascript:openPopup('medical/managePrescriptionForm.jsp&amp;skipEmpty=1',650,430,'medication');void(0);"><%=getTran(request,"web","medicationpaperprescription",sWebLanguage)%></a></td>
            </tr>
            <%
            out.print("</table></td>");
        %>
	   			<tr>
				        <%-- DIAGNOSES --%>
				    	<td colspan="4">
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
function toggleSection(id,elementId){
	if(document.getElementById(elementId).value.length==0 && document.getElementById(id).style.display==''){
		document.getElementById(id).style.display='none';
	}
	else{
		document.getElementById(id).style.display='';
	}
	checkImage(id,elementId);
}
function checkSection(id,elementId){
	if(document.getElementById(elementId).value.length>0){
		document.getElementById(id).style.display='';
	}
	checkImage(id,elementId);
}
function checkImage(id,elementId){
	if(document.getElementById(id).style.display=='none'){
		document.getElementById('img_'+id).style.display='';
		document.getElementById('img_'+id).src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png';
	}
	else if(document.getElementById(elementId).value.length==0){
		document.getElementById('img_'+id).style.display='';
		document.getElementById('img_'+id).src='<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png';
	}
	else{
		document.getElementById('img_'+id).style.display='none';
	}
}

checkSection('diabetes','ITEM_TYPE_MSAS_CONS_DIABETES');
checkSection('hta','ITEM_TYPE_MSAS_CONS_HYPERTENSION');


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