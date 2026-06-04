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
	String accessright="msas.traetment.vih";
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
    
             <tr class='admin'>
			        <td colspan='4'><%=getTran(request,"web","identification",sWebLanguage)%>&nbsp;</td>
	        </tr>
            <tr>
        		<td class='admin'><%=getTran(request,"web","statusmarital",sWebLanguage) %></td>
        		<td class='admin2' colspan="4">
        		<%=getTran(request,"web","nbrmariage",sWebLanguage) %>
        		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_NBRSMARIAGE", 5, sWebLanguage) %>
        		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        		<%=getTran(request,"web","monogamie",sWebLanguage) %>
        		&nbsp;&nbsp;
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.monogamie", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_MONOGAMIE", sWebLanguage, false, "", "") %>
        			&nbsp;&nbsp;&nbsp;
        		<%=getTran(request,"web","polygamie",sWebLanguage) %>
        		&nbsp;&nbsp;
        		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_POLYGAMIE", 5, sWebLanguage) %></td> 
        	 </tr>
        	  <tr>
        		<td class='admin'><%=getTran(request,"web","nbrschild",sWebLanguage) %></td>
        		<td class='admin2' colspan="4">
        		Inferieur 1 ans :
        		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_1ANS", 3, sWebLanguage) %>
        		&nbsp;&nbsp;
        		1-4 ans :
        		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_1_4ANS", 3, sWebLanguage) %>
				&nbsp;&nbsp;
				5-9 ans :
        		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_5_9ANS", 3, sWebLanguage) %>
				&nbsp;&nbsp;
				10-14 ans :
        		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_10_14ANS", 3, sWebLanguage) %>
        		&nbsp;&nbsp;
        		15-18 ans :
        		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_15_18ANS", 3, sWebLanguage) %></td> 
         </tr>
          <tr>
        		<td class='admin'><%=getTran(request,"web","popcles",sWebLanguage) %></td>
        		<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.popcles", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_POP_CLES", sWebLanguage, false, "", "") %></td> 
        		<td class='admin'><%=getTran(request,"web","educationlevel",sWebLanguage) %></td>
        		<td class='admin2' colspan=""><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.educationlevel", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_EDUCATIONLEVEL", sWebLanguage, false) %></td> 
        			
          </tr>
		 <tr>
				<td class='admin'><%=getTran(request,"web","popvul",sWebLanguage) %></td>
        		<td class='admin2' colspan='4'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.popvul", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_POP_VUL", sWebLanguage, false, "", "") %>
        		&nbsp;&nbsp;
        		Autres :
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_POP_VUL_OTHER", 20) %>
        		</td> 
         </tr>
            <tr>
        		<td class='admin'><%=getTran(request,"web","nationality",sWebLanguage) %></td>
        		<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_NATIONALITY", 30) %>
			     <td class='admin'><%=getTran(request,"web","schoolding",sWebLanguage) %></td>
        		<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_SCHOOLING", sWebLanguage, false, "", "") %></td> 
          </tr>
         <tr>
        		<td class='admin'><%=getTran(request,"web","otherfullname",sWebLanguage) %></td>
        		<td class='admin2' ><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_OTHER_FULLNAME", 30, 1)%></td> 
        		 <td class='admin'><%=getTran(request,"web","adressetel",sWebLanguage) %></td>
        		<td class='admin2' ><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_ADRESSE_TEL", 30, 1)%></td> 	
          </tr>
              <tr class='admin'>
			        <td colspan='4'><%=getTran(request,"web","hiv",sWebLanguage)%>&nbsp;</td>
	        </tr>
          <tr>
        	<td class="admin"><%=getTran(request,"web","profilvif",sWebLanguage) %></td>
        	<td class="admin2" colspan="4"><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_PROFILVIH", "profilvih", sWebLanguage, "") %></td>
        </tr>
          <tr>
        	<td class="admin"><%=getTran(request,"web","schema1",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_SCHEMA", 30) %>
			  <td class="admin"><%=getTran(request,"web","datedebut",sWebLanguage) %></td>
       		 <td class="admin2" ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATEDEBUT", sWebLanguage, sCONTEXTPATH) %></td>
          </tr>	
            <tr>
        	<td class="admin"><%=getTran(request,"web","schema2",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_SCHEMA_2", 30) %>
			  <td class="admin"><%=getTran(request,"web","datedebut2",sWebLanguage) %></td>
       		 <td class="admin2" ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATEDEBUT_2", sWebLanguage, sCONTEXTPATH) %></td>
          </tr>	
           <tr>
        		<td class="admin"><%=getTran(request,"web","schema3",sWebLanguage) %></td>
        		<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_SCHEMA_3", 30) %>
			 	<td class="admin"><%=getTran(request,"web","datedebut3",sWebLanguage) %></td>
       		 	<td class="admin2" ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATEDEBUT_3", sWebLanguage, sCONTEXTPATH) %></td>
          </tr>	
            <tr>
        		<td class="admin"><%=getTran(request,"web","transfert",sWebLanguage) %></td>
        		<td class='admin2' colspan="4"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.transfert", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_TRANSFERT", sWebLanguage, false, "", "") %>
        		&nbsp;&nbsp;&nbsp;
        		<%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATETRANSFERT", sWebLanguage, sCONTEXTPATH) %>
        		&nbsp;&nbsp;&nbsp;
        		lieu :
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_LIEU", 20) %></td>
          </tr>	
           <tr>
        		<td class="admin"><%=getTran(request,"web","deces",sWebLanguage) %></td>
        		<td class="admin2" ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATE_DECES", sWebLanguage, sCONTEXTPATH) %></td>
			 	<td class="admin"><%=getTran(request,"web","abandon",sWebLanguage) %></td>
       		 	<td class="admin2" ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATE_ABANDON", sWebLanguage, sCONTEXTPATH) %></td>
          </tr>
           <tr>
        		<td class="admin"><%=getTran(request,"web","pdv1",sWebLanguage) %></td>
        		<td class="admin2" ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATE_PDV", sWebLanguage, sCONTEXTPATH) %></td>
			 	<td class="admin"><%=getTran(request,"web","pdv2",sWebLanguage) %></td>
       		 	<td class="admin2" ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATE_PDV_2", sWebLanguage, sCONTEXTPATH) %></td>
		 </tr>
         <tr>
        		<td class="admin"><%=getTran(request,"web","pdv3",sWebLanguage) %></td>
       		 	<td class="admin2"  ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATE_PDV_3", sWebLanguage, sCONTEXTPATH) %></td>
        		<td class="admin"><%=getTran(request,"web","abandon",sWebLanguage) %></td>
       		 	<td class="admin2" ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATE_ABANDON", sWebLanguage, sCONTEXTPATH) %></td>	
          </tr>
           <tr>
        		<td class='admin'><%=getTran(request,"web","others",sWebLanguage) %></td>
        		<td class='admin2' colspan='4' ><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_OTHER", 30, 1)%></td> 
          </tr>
          <tr class='admin'>
			        <td colspan='4'><%=getTran(request,"web","traetment",sWebLanguage)%>&nbsp;</td>
	        </tr>
	         <tr>
			            <td class="admin"><%=getTran(request,"web", "schema.therapeutique", sWebLanguage)%></td>
			            <td class="admin2" colspan="4" >
			            	<p>
			            		<%=getTran(request,"web", "schema.therapeutique.arv", sWebLanguage)%>
			            		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_ARV", 30) %>&nbsp;&nbsp;
			            		<%=getTran(request,"web", "schema.therapeutique.lot", sWebLanguage)%>
			            		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_LOT", 10, 1, 100, sWebLanguage) %>
			            	</p>
			            	<p>
			            		<%=getTran(request,"web", "schema.therapeutique.arv", sWebLanguage)%>
			            		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_ARV2", 30) %>&nbsp;&nbsp;
			            		<%=getTran(request,"web", "schema.therapeutique.lot", sWebLanguage)%>
			            		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_LOT2", 10, 1, 100, sWebLanguage) %>
			            	</p>
			            	<p>
			            		<%=getTran(request,"web", "schema.therapeutique.arv", sWebLanguage)%>
			            		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_ARV3", 30) %>&nbsp;&nbsp;
			            		<%=getTran(request,"web", "schema.therapeutique.lot", sWebLanguage)%>
			            		<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_LOT3", 10, 1, 100, sWebLanguage) %>
			            	</p>			            	
			            </td>
			 </tr>
	         <tr>
			            <td class="admin"><%=getTran(request,"web", "duree", sWebLanguage)%></td>
			            <td class="admin2"  >
			            	<p>
			            		<%=getTran(request,"web", "duree.dt", sWebLanguage)%>
			            		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DUREE_DT", 10) %>&nbsp;&nbsp;&nbsp;&nbsp;
			            		<%=getTran(request,"web", "duree.ft", sWebLanguage)%>
			            		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DUREE_FT", 10) %>
			               	</p>			            	
			            </td>
			             <td class="admin"><%=getTran(request,"web","rdv",sWebLanguage) %></td>
       		 			<td class="admin2"  ><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATE_RDV", sWebLanguage, sCONTEXTPATH) %></td>
			            
			 </tr>
			<tr>
        		<td class='admin'><%=getTran(request,"web","nbrsttt",sWebLanguage) %></td>
        		<td class='admin2' colspan="4"><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_NBRS_TTT", 50, 2)%></td> 
            </tr>
             <tr>
			            <td class="admin"><%=getTran(request,"web", "cd4.cv", sWebLanguage)%></td>
			            <td class="admin2" colspan="4" >
			            	<p>
			            		<%=getTran(request,"web", "cd4", sWebLanguage)%>
			            		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_CD4", 30) %>&nbsp;&nbsp;
			            		<%=getTran(request,"web", "cd4.date", sWebLanguage)%>
			            		<%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_CD4_DATE", sWebLanguage, sCONTEXTPATH) %>
			            	</p>
			            	<p>
			            		<%=getTran(request,"web", "cv", sWebLanguage)%>
			            		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_CV", 30) %>&nbsp;&nbsp;
			            		<%=getTran(request,"web", "cv.date", sWebLanguage)%>
			            		<%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_CV_DATE", sWebLanguage, sCONTEXTPATH) %>
			            	</p>			            	
			            </td>
			 </tr>
             <tr>
			            <td class="admin"><%=getTran(request,"web", "ctx", sWebLanguage)%></td>
			            <td class="admin2"  ><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_CTX", 30) %></td>
			    		<td class='admin'><%=getTran(request,"web","ttttb",sWebLanguage) %></td>
        				<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_TTTTB", sWebLanguage, false, "", "") %></td> 
			 </tr>
             <tr>
			           <td class='admin'><%=getTran(request,"web","traetment.tb",sWebLanguage) %></td>
        				<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_TRAETMENT_TB", sWebLanguage, false, "", "") %></td> 
						<td class="admin"><%=getTran(request,"web", "traetment.other", sWebLanguage)%></td>
			            <td class="admin2"  ><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_TRAETMENT_OTHER", 30) %></td>
			 </tr>
			  <tr>
			           <td class='admin'><%=getTran(request,"web","handicap",sWebLanguage) %></td>
        				<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_TRAETMENT_HANDICAP", sWebLanguage, false, "", "") %></td> 
			           <td class='admin'><%=getTran(request,"web","date.sortie",sWebLanguage) %></td>
        				<td class='admin2'><%=ScreenHelper.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_DATE_SORTIE", sWebLanguage, sCONTEXTPATH) %></td> 
			 </tr>
			 <tr>
			           <td class='admin'><%=getTran(request,"web","observation",sWebLanguage) %></td>
			           <td class='admin2' colspan="4" ><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_REGISTRY_DISPENTATION_TRAETMENT_VIH_OBSERVATION", 40, 2)%></td> 
			           
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