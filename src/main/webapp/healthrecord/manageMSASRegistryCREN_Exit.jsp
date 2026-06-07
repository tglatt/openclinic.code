<%@ page import="be.openclinic.medical.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"msas.registry.cren","select",activeUser)%>

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
    	<tr class='admin'><td colspan='4'><%=getTran(request,"web","discharge",sWebLanguage) %></td></tr>
		<tr>
		   	<td class='admin'><%=getTran(request,"web","dischargetype",sWebLanguage) %></td>
		   	<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CREN_DISCHARGETYPE", "msas.cre.dischargetype",sWebLanguage, "") %></td>
		   	<td class='admin'><%=getTran(request,"web","internaltransferto",sWebLanguage) %></td>
		   	<td class='admin2'>
		   		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.transferfrom", "ITEM_TYPE_CREN_TRANSFERTO", sWebLanguage, false, "", "") %>
		   		&nbsp;&nbsp;<%=getTran(request,"web","name",sWebLanguage) %>:
		   		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_CREN_TONAME", 50) %>
		   	</td>
		</tr>
		<tr>
		   	<td class='admin'><%=getTran(request,"web","masnumber",sWebLanguage) %></td>
		   	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_CREN_MAS", 20) %></td>
		   	<td class='admin2' colspan='2'>
	      		<%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "TEM_TYPE_MSAS_MALNUTRITION_SENTTOCOMMUNITYLEVEL", "") %><%=getTran(request,"web","senttocommunitylevel",sWebLanguage) %>
	      	</td>
		</tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","anthropometry",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin2' colspan='4'><%writeVitalSignsExit(pageContext); %></td>
		</tr>
		<tr>
		   	<td class='admin'><%=getTran(request,"web","minimumweight",sWebLanguage) %></td>
		   	<td class='admin2'>
		   		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_CREN_MINIMUMWEIGHTDATE", sWebLanguage, sCONTEXTPATH) %>
		   		&nbsp;&nbsp;<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_CREN_MINIMUMWEIGHT", 5, 0, 400, sWebLanguage) %> kg
		   	</td>
		   	<td class='admin'><%=getTran(request,"web","oedema",sWebLanguage) %></td>
			<td class='admin2'><%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_CREN_EXIT_OEDEMA", sWebLanguage, false,"","") %></td>
		</tr>	
		<tr>
			<td class="admin"><%=getTran(request,"web","vitamina",sWebLanguage)%>&nbsp;</td>
			<td class="admin2" ><%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.vitamina", "ITEM_TYPE_MSAS_SICKPED_VITAMINEA", sWebLanguage, false,"","") %></td>
			<td class="admin"><%=getTran(request,"web", "deworming", sWebLanguage)%></td>
			<td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.deworming", "ITEM_TYPE_MSAS_SICKPED_DEWORMING", sWebLanguage, false, "", "") %></td>
		</tr>
    	<tr>
    	<td class='admin'><%=getTran(request,"web","datesortie",sWebLanguage) %></td>
        	<td class='admin2' colspan="3">
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_CREN_DATE_SORTIE", sWebLanguage, sCONTEXTPATH) %></td>
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