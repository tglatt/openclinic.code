<%@ page import="be.openclinic.medical.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<% String accessright="mspls.registry.cpn";
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
            <td class="admin" width='20%'><%=getTran(request,"web", "gestity", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_GESTITY", 3, 0,20,sWebLanguage,"if(this.value==0){document.getElementById(\"cb2.1\").checked=true;}else if(this.value>0){document.getElementById(\"cb2.1\").checked=false;}document.getElementById(\"cb2.1\").onclick();loadrows();") %>
            </td>
            <td class="admin" width='20%'><%=getTran(request,"web", "parity", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_PARITY", 3, 0,20,sWebLanguage) %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "abortion", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_ABORTION", 3, 0,20,sWebLanguage) %>
            </td>
            <td class="admin"><%=getTran(request,"web", "stillbirth", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_SILLBIRTH", 3, 0,20,sWebLanguage) %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "childrenalive", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_CHILDRENALIVE", 3, 0,20,sWebLanguage) %>
            </td>
            <td class="admin"><%=getTran(request,"web", "childrendead", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_CHILDRENDEAD", 3, 0,20,sWebLanguage) %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "ddr", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_DDR",sWebLanguage, sCONTEXTPATH) %>
            </td>
            <td class="admin"><%=getTran(request,"web", "dpa", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_DPA",sWebLanguage, sCONTEXTPATH) %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "pregnancyage", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_PREGNANCYAGE", 5, 0,45,sWebLanguage) %>SA
            </td>
            <td class="admin"><%=getTran(request,"web", "weight", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_WEIGHT", 3, 0,200,sWebLanguage) %>kg
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "pb", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_PB", 3, 0,30,sWebLanguage) %>Cm
            </td>
             <td class="admin"><%=getTran(request,"web","temperature",sWebLanguage) %></td>
            <td class='admin2' colspan='1'>
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_TEMPERATURE", 3, 0,46,sWebLanguage) %>�C
             </td>
		</tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "TA", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_TA_1", 3, 0,100,sWebLanguage) %>/
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_TA_2", 3, 0,100,sWebLanguage) %>&nbsp&nbsp&nbsp
				<b><%=getTran(request,"web","moretha14_9",sWebLanguage) %>:</b> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_MORETHAN_14_9", sWebLanguage, false, "", "") %>
             </td>
             <td class="admin"><%=getTran(request,"web", "uterineheight", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_UTERINEHEIGHT", 3, 0,1000,sWebLanguage) %>cm
            	<b><%=getTran(request,"web","progress",sWebLanguage) %>:</b> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_PROGRESS", sWebLanguage, false, "", "") %> 
            </td>
		</tr>
        
        
         <tr class='admin'><td colspan='4' align="center"><%=getTran(request,"web","riskfactor",sWebLanguage) %></td></tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "age", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPN_AGEGROUP", "age.group", sWebLanguage, "") %>
            </td>
            <td class="admin"><%=getTran(request,"web", "parity.type", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPN_PARITYTYPE", "parity.type", sWebLanguage, "") %>
            </td>
        </tr>
        <tr>
			<td class="admin"><%=getTran(request,"web", "stillbirth_history", sWebLanguage)%></td>
        	<td class='admin2' colspan='1'> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_STILLBIRTH_HISTORY", sWebLanguage, false, "", "") %>
            </td>
             <td class="admin"><%=getTran(request,"web", "premature-delivery", sWebLanguage)%></td>
             <td class='admin2' colspan='1'> 
             	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_PREMATURE_DELIVERY", sWebLanguage, false, "", "") %>
             </td>
		</tr>
		<tr>
			<td class="admin"><%=getTran(request,"web", "abortionon2ndsemester", sWebLanguage)%></td>
        	<td class='admin2' colspan='1'> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_ABORTION_2_SEMESTER", sWebLanguage, false, "", "") %>
            </td>
             <td class="admin"><%=getTran(request,"web", "csection", sWebLanguage)%></td>
             <td class='admin2' colspan='1'> 
             	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CSECTION", sWebLanguage, false, "", "") %>
             </td>
		</tr>
		<tr>
			<td class="admin"><%=getTran(request,"web", "lastdeliverywithcomplication", sWebLanguage)%></td>
        	<td class='admin2' colspan='1'> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_LASTDELIVERY_WITH_COMPLICATION", sWebLanguage, false, "", "") %>
            </td>
             <td class="admin"><%=getTran(request,"web", "height", sWebLanguage)%></td>
             <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPN_HEIGHTGROUP", "height.group", sWebLanguage, "") %>
            </td>
		</tr>
		<tr>
            <td class="admin"><%=getTran(request,"web", "weight", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPN_WEIGHTGROUP", "weight.group", sWebLanguage, "") %>
            </td>
            <td class="admin"><%=getTran(request,"web", "pelvis.malformation", sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_PELVIS_MALFORMATION", sWebLanguage, false, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "chronic.illness", sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_CHRONIC_ILLNESS", sWebLanguage, false, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web", "fistula", sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_FISTULA", sWebLanguage, false, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "knownhiv", sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_KNOWN_HIV", sWebLanguage, false, "", "") %>
            </td>
            <td class="admin"><%=getTran(request,"web", "partenerwithknownhiv", sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_PARTENER_WITH_KNOWNHIV", sWebLanguage, false, "", "") %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "ABO", sWebLanguage)%></td>
            <td class="admin2" colspan="1">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPN_ABO", "abobloodgroup", sWebLanguage, "") %>
            </td>
            <td class="admin"><%=getTran(request,"web", "other", sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_OTHER_RISKFACTOR", 20, 1) %></td>
        </tr>
        <tr class='admin'><td colspan='4' align="center"><%=getTran(request,"web","decision",sWebLanguage) %></td></tr>
        <tr>
            <td class="admin"><%=getTran(request,"web", "decision", sWebLanguage)%></td>
            <td class="admin2" colspan="1">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPN_DECISION", "cpn.decision", sWebLanguage, "") %>
            </td>
            <td class="admin2" colspan="1">
            	<%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPN_DECISION2", "cpn.otherdecision", sWebLanguage, "") %>
            </td>
            <td class="admin2">
            	<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_DECISION_OTHER", 20, 1) %></td>
        </tr>
         <tr class='admin'><td colspan='4' align="center"><%=getTran(request,"web","results",sWebLanguage) %></td></tr>
         <tr>
            <td class="admin"><%=getTran(request,"web", "presentation", sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_PRESENTATION", 20, 2) %></td>
            <td class="admin"><%=getTran(request,"web","vicieuse",sWebLanguage) %></td>
            <td class="admin2">
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_VICIEUSE", sWebLanguage, false, "", "") %><p>
             </td>
		</tr>
		<tr>
			<td class="admin"><%=getTran(request,"web", "pallor", sWebLanguage)%></td>
			<td class='admin2' colspan='1'>
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_PALLOR", sWebLanguage, false, "", "") %><p>
             </td>
             <td class="admin"><%=getTran(request,"web", "oedema", sWebLanguage)%></td>
             <td class='admin2' colspan='1'>
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_OEDEMA", sWebLanguage, false, "", "") %><p>
             </td>
		</tr>
		<tr>
             <td class="admin"><%=getTran(request,"web", "heart_breath", sWebLanguage)%></td>
             <td class='admin2' colspan='1'> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_HEART_BREATH", sWebLanguage, false, "", "") %><p>
             </td>
             <td class="admin"><%=getTran(request,"web", "foetal_movement", sWebLanguage)%></td>
             <td class='admin2' colspan='1'>
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_FOETALMOUVEMENT", sWebLanguage, false, "", "") %><p>
             </td>
		</tr>
		<tr>
        	<td class="admin"><%=getTran(request,"web", "uterine_contraction", sWebLanguage)%></td>
        	<td class='admin2' colspan='1'> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_UTERINECONTRACTION", sWebLanguage, false, "", "") %><p>
             </td>
             <td class="admin"><%=getTran(request,"web","bleeding",sWebLanguage) %></td>
             <td class ="admin2">
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_BLEEDING", sWebLanguage, false, "", "") %><p>
             </td>
         </tr>
         <tr>
         	<td class="admin"><%=getTran(request,"web","vaginal_ulcerations",sWebLanguage) %></td>
         	<td class='admin2' colspan='1'>
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_VAGINAL_ULCERATIONS", sWebLanguage, false, "", "") %><p>
             </td>
             <td class="admin"><%=getTran(request,"web","fluidloss",sWebLanguage) %></td>
             <td class='admin2' colspan='1'> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_FLUIDLOSS", sWebLanguage, false, "", "") %><p>
                <%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CPN_FLUIDLOSS_TYPE", "cpn.fluidloss", sWebLanguage, "") %>
             </td>
		</tr>
        
		<tr>
         	<td class="admin"><%=getTran(request,"web","fer",sWebLanguage) %></td>
         	<td class='admin2' colspan='1'>
                 <%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_FER", 3, 0,30,sWebLanguage) %>
             </td>
             <td class="admin"><%=getTran(request,"web","albendazole",sWebLanguage) %></td>
             <td class='admin2' colspan='1'> 
                <%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_ALBENDAZOLE", 3, 0,20,sWebLanguage) %>
             </td>
		</tr>
		<tr>
			<td class= "admin"><%=getTran(request,"web","preventive_traitment",sWebLanguage) %></td>
        	<td class='admin2' colspan='1'> 
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CPN_PREVENTIVE_TRAITMENT", sWebLanguage, false, "", "") %><p>
             </td>
             <td class="admin"><%=getTran(request,"web", "mosquito", sWebLanguage)%></td>
            <td class="admin2">
            	<%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_DATE_MOSQUITOGIVEN",sWebLanguage, sCONTEXTPATH) %>
            </td>
		</tr>
		<tr>
			<td class="admin"><%=getTran(request,"web","ptme_protocol",sWebLanguage) %></td>
			<td class='admin2' colspan='1'>
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "protocoleptme", "ITEM_TYPE_CPN_PTME_PROTOCOL", sWebLanguage, false, "", "") %><p>
             </td>
             <td class="admin"><%=getTran(request,"web","cpnlocation",sWebLanguage) %></td>
			<td class='admin2' colspan='1'>
                <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "cdshp", "ITEM_TYPE_CPN_LOCATION", sWebLanguage, false, "", "") %><p>
             </td>
		</tr>
		<tr>
             <td class='admin' >
                <%=getTran(request,"web","Observation",sWebLanguage) %>
            </td>
            <td class='admin2'><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_CPN_OBSERVATION", 30, 2) %>
            </td>

			<td class="admin"><%=getTran(request,"web", "appointment", sWebLanguage)%></td>
            <td class="admin2" colspan='4'>
            	<%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_CPN_APPOINTMENT",sWebLanguage, sCONTEXTPATH) %>
            </td>
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