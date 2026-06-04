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
	String accessright="msas.ficheConsPF";
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
			<td class='admin2' colspan='4'><%writeVitalSigns(pageContext); %></td>
		</tr>
  		 
  		 <tr class='admin'><td colspan='4'><%=getTran(request,"web","interrogatoire",sWebLanguage) %></td></tr>
  		 
  		 <tr>
           	<td class="admin" > <%=getTran(request,"web","postpartum",sWebLanguage)%></td>
            <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "postpartum","ITEM_TYPE_MSAS_FICHE_CONS_PF_POST_PARTUM" ,sWebLanguage,true,"", "")%></td>
   			<td class="admin" > <%=getTran(request,"web","nouvelledansPF",sWebLanguage)%></td>
   			<td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_NOUVELLE_DANS_PF",sWebLanguage, true, "", "")%></td>
  		 </tr>
  		 
  		 <tr>
   			<td class="admin" > <%=getTran(request,"web","changementmethode",sWebLanguage)%></td>
   			<td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_CHANGEMENT_METHODE",sWebLanguage, true, "", "")%></td>
   			<td class='admin'><%=getTran(request,"web","anciennemethode",sWebLanguage) %></td>
		<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_FICHE_CONS_PF_ANCIENNE_METHODE", "anciennemethode",sWebLanguage, "") %></td>
  		 </tr>
  		 
	     <tr>
           	  <td class="admin" > <%=getTran(request,"web","ethnie",sWebLanguage)%></td>
            <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "ethnie","ITEM_TYPE_MSAS_FICHE_CONS_PF_ETHNIE" ,sWebLanguage,true,"", "")%></td>
   			 <td class="admin" > <%=getTran(request,"web","religion",sWebLanguage)%></td>
            <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "religion","ITEM_TYPE_MSAS_FICHE_CONS_PF_RELIGION" ,sWebLanguage,true,"", "")%></td>
   		
   		<tr>   
   		<tr>         
             <td class="admin" > <%=getTran(request,"web","situationmatrimoniale",sWebLanguage)%></td>
            <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "situationmatrimoniale","ITEM_TYPE_MSAS_FICHE_CONS_PF_SITUATION_MATRIMONIALE" ,sWebLanguage,true,"", "")%></td>
             <td class="admin" > <%=getTran(request,"web","referee",sWebLanguage)%></td>
           <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "referee","ITEM_TYPE_MSAS_REFEREE" ,sWebLanguage,true,"", "")%></td>
  </tr>     
	     <tr>         
             <td class="admin" > <%=getTran(request,"web","niveauscolarisation",sWebLanguage)%></td>
            <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "niveauscolarite","ITEM_TYPE_MSAS_FICHE_CONS_PF_NIVEAU_INSTRUCTION" ,sWebLanguage,true,"", "")%></td>
   		  <td class="admin" > <%=getTran(request,"web","genrevie",sWebLanguage)%></td>
           <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "genrevie","ITEM_TYPE_MSAS_FICHE_CONS_PF_GENRE_VIE" ,sWebLanguage,true,"", "")%></td>
   		   
  </tr>
  
    <tr>         
            <td class="admin" > <%=getTran(request,"web","professionmari",sWebLanguage)%></td>
            <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "professionmari","ITEM_TYPE_MSAS_PROFESSION_MARI" ,sWebLanguage,true,"", "")%></td>
            <td class="admin" > <%=getTran(request,"web","sourceinformation",sWebLanguage)%></td>
            <td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "sourceinformation","ITEM_TYPE_MSAS_SOURCE_INFORMATION" ,sWebLanguage,true,"", "")%></td>
  </tr>
	
	<tr class='admin'><td colspan='4'><%=getTran(request,"web","examenclinique",sWebLanguage) %></td></tr>
	<tr class='admin'><td colspan='4'><%=getTran(request,"web","gynecologiques",sWebLanguage) %></td></tr>	
  <tr>   
	      <td class="admin" > <%=getTran(request,"web","menarches",sWebLanguage)%></td>
	       <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_MENARCHES", 10, 1, 30, sWebLanguage, "onBlur")%></td>
       	<td class="admin" > <%=getTran(request,"web","dureeregles",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_DUREERELES", 10, 1, 30, sWebLanguage, "onBlur")%></td>
       </tr>		
  <tr>   
	         
        <td class="admin" > <%=getTran(request,"web","cycle",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_CYCLE", 10, 1, 45, sWebLanguage, "onBlur")%></td>
        <td class="admin" > <%=getTran(request,"web","datederniereregles",sWebLanguage)%></td>
         <td class="admin2" ><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_DATEDERNIEREREGLES", sWebLanguage, sCONTEXTPATH)%></td>
		
        </tr>	
 
  	<tr class='admin'><td colspan='4'><%=getTran(request,"web","obstetricaux",sWebLanguage) %></td></tr>
	
	<tr>   
        <td class="admin" > <%=getTran(request,"web","enfantvivant",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_ENFANTVIVANT",10, 1, 45, sWebLanguage, "onBlur")%></td>
        <td class="admin" > <%=getTran(request,"web","mortsnes",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_MORTSNES",10, 1, 45, sWebLanguage, "onBlur")%></td>
  </tr>	
 
  <tr>   
	      
        <td class="admin" > <%=getTran(request,"web","avortement",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_AVORTEMENT",10, 1, 45, sWebLanguage, "onBlur")%></td>
        <td class="admin" > <%=getTran(request,"web","agedernierenfant",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_AGEDERNIERENFANT",10, 1, 45, sWebLanguage, "onBlur")%></td>
  </tr>		
   <tr>        
        <td class="admin"><%=getTran(request,"web","allaitementexclusifausein",sWebLanguage)%>&nbsp;</td>
		<td class="admin2" colspan='4'><%= SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_ALLAITEMENTEXCLUSIFAUSEIN", sWebLanguage, true, "", "") %>
		</td>
  </tr>	 
  
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","chirurgicaux",sWebLanguage) %></td></tr> 
   <tr>   
	      
         <td class="admin"><%=getTran(request,"web","chirurgicaux",sWebLanguage)%>&nbsp;</td>
         <td class="admin2" colspan='4'> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_CHIRURGICAUX",40, 2)%></td>
		</td>
  </tr>	
  
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","familiaux",sWebLanguage) %></td></tr> 
   <tr>      
        <td class="admin" > <%=getTran(request,"web","hypertensionarterielle",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_HYPERTENSIONARTERIELLE",sWebLanguage, true, "", "")%></td>
        <td class="admin" > <%=getTran(request,"web","diabete",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_DIABETE",sWebLanguage, true, "", "")%></td>
  </tr>	
  	
   <tr>      
   		<td class="admin" > <%=getTran(request,"web","drepanocytose",sWebLanguage)%></td>
        <td class="admin2" colspan='4'> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_DREPANOCYTOSE",sWebLanguage, true, "", "")%></td>
  </tr>	
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","medicaux",sWebLanguage) %></td></tr> 
   <tr>      
   		<td class="admin" > <%=getTran(request,"web","hta",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_HTA",sWebLanguage, true, "", "")%></td>
       <td class="admin" > <%=getTran(request,"web","diabete",sWebLanguage)%></td>
       <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_DIABETE",sWebLanguage, true, "", "")%></td>  
  </tr>	
  <tr> 
  	   <td class="admin" > <%=getTran(request,"web","migraine",sWebLanguage)%></td>
       <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_MIGRAINE",sWebLanguage, true, "", "")%></td>
       <td class="admin" > <%=getTran(request,"web","icteremoins1an",sWebLanguage)%></td>
       <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_ICTEREMOINS1AN",sWebLanguage, true, "", "")%></td>
  </tr>	
  <tr> 
  	   <td class="admin" > <%=getTran(request,"web","allergieaucuivre",sWebLanguage)%></td>
       <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_ALLERGIEAUCUIVRE",sWebLanguage, true, "", "")%></td>
       <td class="admin" > <%=getTran(request,"web","vihmedicaux",sWebLanguage)%></td>
       <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_VIH_MEDICAUX",sWebLanguage, true, "", "")%></td>
  </tr>	
   <tr>      
        <td class="admin" > <%=getTran(request,"web","autresmedicaux",sWebLanguage)%></td>
        <td class="admin2" colspan='4'> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_AUTRES_Medicaux",40, 2)%></td>
  </tr>	
   <tr class='admin'><td colspan='4'><%=getTran(request,"web","plaintes",sWebLanguage) %></td></tr> 
   <tr>      
        <td class="admin" > <%=getTran(request,"web","plaintes",sWebLanguage)%></td>
        <td class="admin2" colspan='4'> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_PLAINTES",40, 2)%></td>
  </tr>	
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","traitementencours",sWebLanguage) %></td></tr> 
   <tr>      
        <td class="admin" > <%=getTran(request,"web","tuberculose",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_TUBERCULOSE",sWebLanguage, true, "", "")%></td>
         <td class="admin" > <%=getTran(request,"web","vihtreatment",sWebLanguage)%></td>
       <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_VIH_TREATMENT",sWebLanguage, true, "", "")%></td>
  </tr>	
  </tr>	
  
  </tr>	
  <tr>      
        <td class="admin" > <%=getTran(request,"web","epilepsie",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_EPILEPSIE",sWebLanguage, true, "", "")%></td>
        <td class="admin" > <%=getTran(request,"web","autrestreatment",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_AUTRESTREATMENT",40, 2)%></td>
  </tr>	
  
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","examengeneral",sWebLanguage) %></td></tr> 
   <tr> 
  
  <tr>      
        <td class="admin" > <%=getTran(request,"web","exophtalmie",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_EXOPHTALMIE",sWebLanguage, true, "", "")%></td>
        <td class="admin" > <%=getTran(request,"web","varice",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_VARICE",sWebLanguage, true, "", "")%></td>
  </tr>	
  
  <tr>      
        <td class="admin" > <%=getTran(request,"web","oedemes",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_OEDEMES",sWebLanguage, true, "", "")%></td>
        <td class="admin" > <%=getTran(request,"web","muqueuses",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons(tran,request, "muqueuses","ITEM_TYPE_MSAS_MUQUEUSES" ,sWebLanguage,true,"", "")%></td>
  </tr>	
  
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","examenphysique",sWebLanguage) %></td></tr> 
   <tr>      
        <td class="admin" > <%=getTran(request,"web","thyroide",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons(tran,request, "thyroide","ITEM_TYPE_MSAS_FICHE_CONS_PF_THYROIDE" ,sWebLanguage,true,"", "")%></td>
        <td class="admin" > <%=getTran(request,"web","coeur",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons(tran,request, "coeur","ITEM_TYPE_MSAS_FICHE_CONS_PF_COEUR" ,sWebLanguage,true,"", "")%></td>
  </tr>
    <tr>      
        <td class="admin" > <%=getTran(request,"web","poumons",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_POUMONS",40, 2)%></td>
        <td class="admin" > <%=getTran(request,"web","ganglions",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_FICHE_CONS_PF_GANGLIONS",sWebLanguage, true, "", "")%></td>
  </tr>
    <tr>      
        <td class="admin" > <%=getTran(request,"web","foie",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultRadioButtons(tran,request, "foie","ITEM_TYPE_MSAS_FICHE_CONS_PF_FOIE" ,sWebLanguage,true,"", "")%></td>
        <td class="admin" > <%=getTran(request,"web","rate",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_RATE",40, 2)%></td>
  </tr>
    <tr>      
        <td class="admin" > <%=getTran(request,"web","peau",sWebLanguage)%></td>
        <td class="admin2" colspan='4'> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_PEAU",40, 2)%></td>
  </tr>
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","examengynecologique",sWebLanguage) %></td></tr> 
   <tr>      
        <td class="admin" > <%=getTran(request,"web","seins",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_SEINS",40, 2)%></td>
        <td class="admin" > <%=getTran(request,"web","vulve",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_VULVE",40, 2)%></td>
  </tr>
  <tr>      
        <td class="admin" > <%=getTran(request,"web","perinee",sWebLanguage)%></td>
        <td class="admin2" colspan='4'> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_PERINEE",40, 2)%></td>
  </tr>
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","examenspeculum",sWebLanguage) %></td></tr> 
   <tr>      
        <td class="admin" > <%=getTran(request,"web","vagin",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_VAGIN",40, 2)%></td>
        <td class="admin" > <%=getTran(request,"web","col",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_COL",40, 2)%></td>
  </tr>
 
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","touchervainal",sWebLanguage) %></td></tr> 
   <tr>      
        <td class="admin" > <%=getTran(request,"web","col",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_COL",40, 2)%></td>
        <td class="admin" > <%=getTran(request,"web","uterus",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_UTERUS",40, 2)%></td>
  </tr>
   <tr>      
        <td class="admin" > <%=getTran(request,"web","annexes",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_ANNEXES",40, 2)%></td>
        <td class="admin" > <%=getTran(request,"web","pertes",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_PERTES",40, 2)%></td>
  </tr>
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","examenscomplementatireseventuels",sWebLanguage) %></td></tr> 
   <tr>      
        <td class="admin" > <%=getTran(request,"web","examenscomplementatireseventuels",sWebLanguage)%></td>
        <td class="admin2" colspan='4'> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_EXAMENSCOMPLEMENTAIRESEVENTUELS",40, 2)%></td>
  </tr>
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","methodeappropriechoisie",sWebLanguage) %></td></tr> 
  
   <tr>   
   		<td class='admin'><%=getTran(request,"web","pilule",sWebLanguage) %></td>
		<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_FICHE_CONS_PF_PILULE", "pilule",sWebLanguage, "") %></td>      
        <td class="admin" > <%=getTran(request,"web","nombreplaquettesfournies",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_NOMBRE_PLAQUETTES_FOURNIES",10, 1, 45, sWebLanguage, "onBlur")%></td>   		   
  </tr>
  
  <tr>   
   		<td class='admin'><%=getTran(request,"web","diu",sWebLanguage) %></td>
		<td class='admin2' colspan='4' ><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_FICHE_CONS_PF_DIU", "diu",sWebLanguage, "") %>      
        &nbsp;<%=SH.writeDefaultRadioButtons(tran,request, "insertion","ITEM_TYPE_MSAS_FICHE_CONS_PF_INSERTION" ,sWebLanguage,true,"", "")%></td>  		   
  		
  </tr>
  
  <tr>
	<td class="admin"><%=getTran(request,"web","injectable",sWebLanguage)%></td>
	<td class='admin2'>
		<%=SH.writeDefaultRadioButtons(tran,request, "injectable","ITEM_TYPE_MSAS_FICHE_CONS_PF_INJECTABLE" ,sWebLanguage,true,"", "") %>
	</td>
	<td class="admin" > <%=getTran(request,"web","dosefournie",sWebLanguage)%></td>
	<td class="admin2" > <%=SH.writeDefaultRadioButtons(tran,request, "dosefournie","ITEM_TYPE_MSAS_FICHE_CONS_PF_DOSEFOURNIE" ,sWebLanguage,true,"", "")%></td>  		   
</tr>
	
	<tr>   
   		<td class='admin'><%=getTran(request,"web","implant",sWebLanguage) %></td>
		<td class='admin2' colspan='4'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_FICHE_CONS_PF_IMPLANT", "implant",sWebLanguage, "") %>      
         &nbsp;<%=SH.writeDefaultRadioButtons(tran,request, "insertion","ITEM_TYPE_MSAS_FICHE_CONS_PF_INSERTION" ,sWebLanguage,true,"", "")%></td>  		   
  		
  </tr>
  
  <tr>        
        <td class="admin2"> <%=SH.writeDefaultRadioButtons(tran,request, "avp","ITEM_TYPE_MSAS_FICHE_CONS_PF_AVP" ,sWebLanguage,true,"", "")%></td>  		   
  		<td class='admin'><%=getTran(request,"web","condoms",sWebLanguage) %></td>      
        <td class="admin2" colspan='4' > <%=SH.writeDefaultRadioButtons(tran,request, "condoms","ITEM_TYPE_MSAS_FICHE_CONS_PF_CONDOMS" ,sWebLanguage,true,"", "")%>		       
        &nbsp;<%=SH.writeDefaultRadioButtons(tran,request, "ligaturedestrompes","ITEM_TYPE_MSAS_FICHE_CONS_PF_LIGATURE_TROMPES" ,sWebLanguage,true,"", "")%></td>  		   
  		
  </tr>
  
  <tr>   
   		<td class='admin'><%=getTran(request,"web","methodenaturelle",sWebLanguage) %></td>
		<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_FICHE_CONS_PF_METHODE_NATURELLE", "methodenaturelle",sWebLanguage, "") %></td>      
        <td class="admin" > <%=getTran(request,"web","autresmethodes",sWebLanguage)%></td>
        <td class="admin2"> <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_AUTRES_METHODES",40, 2)%></td>   		  
  </tr>
  
  <tr class='admin'><td colspan='4'><%=getTran(request,"web","vistes",sWebLanguage) %></td></tr> 
   <tr>         
       <td class="admin" > <%=getTran(request,"web","observationsvisites",sWebLanguage)%></td>
       <td class="admin2" > <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_OBSERVATIONS_VISITES",40, 2)%></td>
       <td class="admin" > <%=getTran(request,"web","dateprochainrendezvous",sWebLanguage)%></td>
       <td class="admin2" colspan='4'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MSAS_FICHE_CONS_PF_DATE_PROCHAON_RENDEZ_VOUS", sWebLanguage, sCONTEXTPATH)%></td>
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