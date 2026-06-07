<%@ page import="be.openclinic.medical.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String accessright="mspls.registry.sta";
%>
<%=checkPermission(accessright,"select",activeUser)%>

<%!
    //--- GET KEYWORDS HTML -----------------------------------------------------------------------
	private String getKeywordsHTML(TransactionVO transaction, String itemId, String textField,
			                       String idsField, String language){
		StringBuffer sHTML = new StringBuffer();
		ItemVO item = transaction.getItem(itemId);
		if(item!=null && item.getValue()!=null && item.getValue().length()>0){
			String[] ids = item.getValue().split(";");
			String keyword = "";
			
			for(int n=0; n<ids.length; n++){
				if(ids[n].split("\\$").length==2){
					keyword = getTran(null,ids[n].split("\\$")[0],ids[n].split("\\$")[1] , language);
					
					sHTML.append("<a href='javascript:deleteKeyword(\"").append(idsField).append("\",\"").append(textField).append("\",\"").append(ids[n]).append("\");'>")
					      .append("<img width='8' src='"+sCONTEXTPATH+"/_img/themes/default/erase.png' class='link' style='vertical-align:-1px'/>")
					     .append("</a>")
					     .append("&nbsp;<b>").append(keyword).append("</b> | ");
				}
			}
		}
		
		String sHTMLValue = sHTML.toString();
		if(sHTMLValue.endsWith("| ")){
			sHTMLValue = sHTMLValue.substring(0,sHTMLValue.lastIndexOf("| "));
		}
		
		return sHTMLValue;
	}
%>

<%--
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
  --%> 
    
   
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
	<% TransactionVO tran = (TransactionVO)transaction; %>
	  
    <div style="padding-top:5px;"></div>
    
    <table class="list" width='100%' cellpadding="1" cellspacing="1"> 
    	<tr>
    			<td class="admin"><%=getTran(request,"web", "mas_number", sWebLanguage)%></td>
           		<td class="admin2"><%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MAS_NUMBER", 3, 0,1000,sWebLanguage) %></td>
	            <td class="admin"><%=getTran(request,"web", "sta_code", sWebLanguage)%></td>
	            <td class="admin2">	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_STA_CODE", 3, 0,1000,sWebLanguage) %></td>
                <td class='admin'><%=getTran(request,"web","sta_name",sWebLanguage) %></td>
                <td class='admin2'><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_STA_NAME", 10, 1) %></td>   	         
        </tr>
        <tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","admission_reason",sWebLanguage) %></td></tr>
        <tr>
           		<td class="admin"><%=getTran(request,"web", "pb", sWebLanguage)%></td>
	            <td class="admin2"><%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_STA_PB", 3, 0,1000,sWebLanguage) %>mm</td>
	            <td class="admin"><%=getTran(request,"web", "pt", sWebLanguage)%></td>
	            <td class="admin2">	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_STA_PT", 3, 0,1000,sWebLanguage) %></td>
                <td class="admin"><%=getTran(request,"web", "oedema", sWebLanguage)%></td>
                <td class="admin2"><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_STA_OEDEMA", sWebLanguage, false, "", "") %></td>
        </tr>
        <tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","",sWebLanguage) %></td></tr>
            
        
        <tr>
                <td class="admin"><%=getTran(request,"web", "breastfeeding", sWebLanguage)%></td>
                <td class='admin2' >
                    <%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_STA_BREASTFEEDING", sWebLanguage, false, "", "") %>
                </td>
                <td class="admin"><%=getTran(request,"web", "twin", sWebLanguage)%></td>
                <td class='admin2' colspan="3">
                    <%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_STA_TWIN", sWebLanguage, false, "", "") %>
                </td>
                
            </tr>
            <tr>
            	<td class="admin"><%=getTran(request,"web","accompanying_person",sWebLanguage) %></td>
                <td class='admin2' >
                    <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_STA_ACCOMPANYING_PERSON", 10, 1) %>
                </td>
            	<td class="admin"><%=getTran(request,"web", "goodhealth", sWebLanguage)%></td>
                <td class="admin2">	<%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_STA_GOODHEALTH", sWebLanguage, false, "", "") %></td>
                <td class="admin"><%=getTran(request,"web", "aliveparents", sWebLanguage)%></td>
                <td class="admin2"><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_STA_ALIVEPARENTS", sWebLanguage, false, "", "") %></td>
                
            </tr>
            <tr> 
            	<td class='admin'><%=getTran(request,"web","particularproblem",sWebLanguage) %></td>
                <td class='admin2'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_STA_PARTICULAR_PROBLEM", 20, 1) %></td>
                <td class="admin"><%=getTran(request,"web", "vaccination", sWebLanguage)%></td>
                <td class='admin2'><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_STA_VACCINATION", sWebLanguage, false, "", "") %></td> 
                <td class="admin"><%=getTran(request,"web", "vaccination_card", sWebLanguage)%></td>
                <td class='admin2'><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_STA_VACCINATION_CARD", sWebLanguage, false, "", "") %></td>     
            </tr>
            <tr>
            	<td class='admin'><%=getTran(request,"web","rougeole",sWebLanguage) %></td>
                <td class='admin2' colspan="5">
                    <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_ROUGEOLE_1", 20, 1) %>
                    <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_ROUGEOLE_2", 20, 1) %>
                </td>
            </tr>
            <tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","INFORMATIONADMISSION",sWebLanguage) %></td></tr>
        	<tr>
                <td class='admin'><%=getTran(request,"web","avantdebuttraitement",sWebLanguage) %></td>
                <td class='admin'><%=getTran(request,"sta","reference",sWebLanguage) %></td>
                <td class="admin2"><%=SH.writeDefaultRadioButtons(tran, request, "sta.reference","ITEM_TYPE_REFERENCE", sWebLanguage, false, "", "") %></td>
                 <td class='admin'><%=getTran(request,"web","other_reference",sWebLanguage) %></td>
                <td class='admin2' colspan="2"><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_OTHER_REFERENCE", 20, 2) %></td>
                
            </tr>
            <tr>
            	<td class='admin'><%=getTran(request,"web","duranttraitement",sWebLanguage) %></td>
            	<td class='admin'><%=getTran(request,"web","internal_transfert",sWebLanguage) %></td>
                <td class='admin2' ><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_INTERNALTRANSFER", sWebLanguage, false, "", "") %></td>
               <td class='admin'><%=getTran(request,"web","center.type",sWebLanguage) %></td>
                <td class='admin2' colspan="2"><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_STA_CENTER_TYPE", 20, 2) %></td>
            </tr>
            <tr>
            	<td class='admin'><%=getTran(request,"web","center.name",sWebLanguage) %></td>
                <td class='admin2' colspan='2'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_CENTER_NAME", 20, 2) %></td>
                <td class='admin'><%=getTran(request,"web","center.patientnumber",sWebLanguage) %></td>
                <td class='admin2' colspan="2"><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_CENTER_PATIENTNUMBER", 20, 2) %></td>
            </tr>
            <tr>  
                <td class='admin' ><%=getTran(request,"web","admission.date",sWebLanguage) %></td>
                <td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_ADMISSIONDATE", sWebLanguage, sCONTEXTPATH) %></td>
                <td class="admin"><%=getTran(request,"web", "admission.type", sWebLanguage)%></td>
                <td class="admin2" colspan='1'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "mspls.admission.type", "ITEM_TYPE_ADMISSIONTYPE", sWebLanguage, false) %></td>
                <td class='admin' ><%=getTran(request,"web","transfertdate",sWebLanguage) %></td>
                <td class='admin2'colspan="1"><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TRANSFERTDATE", sWebLanguage, sCONTEXTPATH) %></td>
            </tr>
            <tr>
                
           </tr>
           <tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","interogation",sWebLanguage) %></td></tr>
            <tr>
                <td class="admin"><%=getTran(request,"web", "patient.healthstate", sWebLanguage)%></td>
                <td class='admin2' ><%=SH.writeDefaultRadioButtons(tran, request, "sta.healthstate", "ITEM_TYPE_HEALTHSTATE", sWebLanguage, false, "", "") %></td>
                <td class="admin"><%=getTran(request,"web", "handicap", sWebLanguage)%></td>
                <td class="admin2"><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_HANDICAP", sWebLanguage, false, "", "") %></td>
                <td class='admin' ><%=getTran(request,"web", "breathing", sWebLanguage)%></td>
                <td class='admin2' ><%=SH.writeDefaultRadioButtons(tran, request, "breathing.type", "ITEM_TYPE_BREATHING", sWebLanguage, false, "", "") %></td>
             </tr>
             <tr>
             	<td class='admin'><%=getTran(request,"web", "eye", sWebLanguage)%></td>
                <td class='admin2'>   <%=SH.writeDefaultRadioButtons(tran, request, "eye.illness", "ITEM_TYPE_EYE", sWebLanguage, false, "", "") %></td>
                <td class="admin"><%=getTran(request,"web", "skin.problem", sWebLanguage)%></td>
                <td class="admin2"><%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_SKIN_PROBLEM", sWebLanguage, false, "", "") %>
                    <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_SKIN_PROBLEM_TEXT", 10, 1) %>
                </td>
             	<td class="admin"><%=getTran(request,"web", "oedema", sWebLanguage)%></td>
                <td class="admin2">
                    <%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_STA_OEDEMA_LEVEL", "mspls.sta.oedeme", sWebLanguage, "") %>
                   
                </td>
                
                
        </tr>
         <tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","education.courses",sWebLanguage) %></td></tr>
         <tr>
        	<td class='admin' ><%=getTran(request,"web","malnutrition",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_STA_TRAINING_MALNUTRUTION", sWebLanguage, sCONTEXTPATH) %></td>
            <td class='admin' ><%=getTran(request,"web","Diarrhee.fever.ira",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_STA_TRAINING_DIARRHEE_FEVER_IRA", sWebLanguage, sCONTEXTPATH) %></td>
            <td class='admin' ><%=getTran(request,"web","infection",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_STA_TRAINING_INFECTION", sWebLanguage, sCONTEXTPATH) %></td>
        </tr>  
         <tr>
        	<td class='admin' ><%=getTran(request,"web","game.stimulation",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_STA_TRAINING_GAME_STIMULATION", sWebLanguage, sCONTEXTPATH) %></td>
            <td class='admin' ><%=getTran(request,"web","nutrition.infantcare",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_STA_TRAINING_NUTRITION_INFANTCARE", sWebLanguage, sCONTEXTPATH) %></td>
            <td class='admin' ><%=getTran(request,"web","sta.hygiene",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_STA_TRAINING_HYGIENE", sWebLanguage, sCONTEXTPATH) %></td>
        </tr>   
        <tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","homevisit",sWebLanguage) %></td></tr>
        <tr>
            <td class='admin' ><%=getTran(request,"web","homevisit.reason",sWebLanguage) %></td>
            <td class='admin2' colspan='1'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_STA_HOMEVISIT_REASON", 20, 2) %></td>
            <td class='admin' ><%=getTran(request,"web","homevisit.date",sWebLanguage) %></td>    
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_HOMEVISIT_DATE", sWebLanguage, sCONTEXTPATH) %></td>
            <td class='admin' ><%=getTran(request,"web","conclusion",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_HOMEVISIT_CONCLUSION", 10, 2) %></td>
        </tr>    
        <tr>
            <td class='admin' ><%=getTran(request,"web","homevisit.reason2",sWebLanguage) %></td>
            <td class='admin2' colspan='1'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_STA_HOMEVISIT_REASON2", 20, 2) %></td>
            <td class='admin' ><%=getTran(request,"web","homevisit.date",sWebLanguage) %></td>    
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_HOMEVISIT_DATE2", sWebLanguage, sCONTEXTPATH) %></td>
            <td class='admin' ><%=getTran(request,"web","conclusion",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_HOMEVISIT_CONCLUSION2", 10, 2) %></td>
        </tr> 
        <tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","internal_transfer",sWebLanguage) %></td></tr>
        <tr>
            <td class='admin'><%=getTran(request,"web","datetransfer",sWebLanguage) %></td>
            <td class='admin2' ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TRANSFER_DATE", sWebLanguage, sCONTEXTPATH) %></td>
            <td class='admin'><%=getTran(request,"web","transferreason",sWebLanguage) %></td>
            <td class='admin2'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_TRANSFER_RAISON", 10, 1) %></td>
            <td class='admin'><%=getTran(request,"web","transfer.centername",sWebLanguage) %></td>
            <td class='admin2'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_TRANSFER_CENTERNAME", 10, 1) %></td>
        </tr> 
        <tr>
            <td class='admin'><%=getTran(request,"web","transfer.results",sWebLanguage) %></td>
            <td class='admin2' ><%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TRANSFER_RESULT", "transfer.results", sWebLanguage, "") %>
            <td class='admin'><%=getTran(request,"web","transfer.return",sWebLanguage) %></td>
         	<td class='admin2' colspan="2"><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_TRANSFER_RETURNDATE", sWebLanguage, sCONTEXTPATH) %></td>
        </tr> 
         <tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","sta.dicharge",sWebLanguage) %></td></tr>
         <tr>
            <td class='admin'><%=getTran(request,"web","dicharge.date",sWebLanguage) %></td>
         	<td class='admin2' colspan="5"><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_STA_DISCHARGE_DATE", sWebLanguage, sCONTEXTPATH) %></td>
        </tr> 
        <tr>
           <td class='admin' ><%=getTran(request,"web","discharge.state",sWebLanguage) %></td>
	       <td class='admin2'><%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_STA_DISCHARGE_STATE", "sta.dischargestate", sWebLanguage, "") %></td>
            <td class='admin' ><%=getTran(request,"web","discharge.other",sWebLanguage) %></td>
            <td class='admin2' colspan="1"><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_STA_DISCHARGE_OTHER", 30, 1) %></td>
            <td class='admin' ><%=getTran(request,"web","discharge.observation",sWebLanguage) %></td>
            <td class='admin2' colspan="1"><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_STA_DISCHARGE_OBSERVATION", 30, 1) %></td>
        </tr>
    </table>
    
    <div style="padding-top:5px;"></div>
    
    <%-- KEYWORDS for DIAGNOSES -----------------------------------------------------------------%>
    
    <div style="padding-top:5px;"></div>
    
    <%-- DIAGNOSES --%>
    <%//ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncodingWide.jsp"),pageContext);%>            
    	    
    <%-- BUTTONS --%>
    <%//=ScreenHelper.alignButtonsStart()%>
    <%//=getButtonsHtml(request,activeUser,activePatient,"occup.healthcenter.contact",sWebLanguage)%>
    <%//=ScreenHelper.alignButtonsStop()%>
        
	<%=ScreenHelper.contextFooter(request)%>
 
 <%-- </form> --%>

<script>
  <%-- SUBMIT FORM --%>

</script>