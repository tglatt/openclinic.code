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
	String accessright="mspls.mccod";
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
            <td class="admin" width="<%=sTDAdminWidth%>" colspan="6">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <% TransactionVO tran = (TransactionVO)transaction; %>
        
        <tr>
			<td class='admin' id="dateofdeath">
				<%=getTran(request,"web","death_date",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2' colspan="5">
				<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DEATH_DATE", sWebLanguage, sCONTEXTPATH) %>
			</td>
       	</tr>
       	
        <tr class='admin'><td align="center" colspan="6"><%=getTran(request,"web","medicaldata",sWebLanguage)%>&nbsp;</td></tr>
        
        <tr class='admin'>
        	<td >
				<%=getTran(request,"web","death_reason",sWebLanguage)%>&nbsp;
			</td>
			<td >
				&nbsp;
			</td>
			<td >
				<%=getTran(request,"web","deathprocess_start",sWebLanguage)%>&nbsp;
			</td>
			<td colspan="3">
				<%=getTran(request,"web","event_duration",sWebLanguage)%>&nbsp;
			</td>
		</tr>
		
		<tr>
			<td class='admin'>
				<%=getTran(request,"web","direct_death_reason",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2' >
				
				<table>
				 <tr >
				 	<td><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_DIRECT_DEATH_REASON", 15, 2) %> </td>
				 	<td><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_DIRECT_DEATH_REASON_LABEL", 40, 2) %> </td>
			        <td align="center">
			        <a href="javascript:openPopup('healthrecord/deathFindICD11.jsp&ts=<%=getTs()%>&returnField=ITEM_TYPE_DIRECT_DEATH_REASON',700,400);void(0);"><%=getTran(request,"openclinic.chuk","diagnostic.icd11Code",sWebLanguage)%></a>
			        </td>
			       </tr>
				</table>
			</td>
			
			<td class='admin2' id="directcauseofdeath">
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DIRECT_DEATH_REASON_START", sWebLanguage, sCONTEXTPATH) %>
        	</td>
        	<td class='admin2' colspan="3" id="directcauseofdeath_duration" >
        		<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_DIRECT_DEATH_REASON_DURATION", 5)%>
        	</td>
			<%-- METTRE UN CHAMP CALCULANT LA DUREE --%>
		</tr>
		<tr>
			<td class='admin'>
				<%=getTran(request,"web","event3_death_reason",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
				
				
				<table>
				 <tr >
				 	<td>
				 	<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_EVENT_3_DEATH_REASON", 15, 1) %> </td>
				 		<td>
				 	<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_EVENT_3_DEATH_REASON_LABEL", 40, 1) %> </td>
			        <td align="center">
			        <a href="javascript:openPopup('healthrecord/deathFindICD11.jsp&ts=<%=getTs()%>&returnField=ITEM_TYPE_EVENT_3_DEATH_REASON',700,400);void(0);"><%=getTran(request,"openclinic.chuk","diagnostic.icd11Code",sWebLanguage)%></a>
			        </td>
			       </tr>
				</table>
			</td>
			<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DEATHPROCESS_3_START", sWebLanguage, sCONTEXTPATH) %>
        	</td>
        	<td class='admin2' colspan="3">
        		<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_DEATHPROCESS_3_DURATION", 5)%>
        	</td>
			<%-- METTRE UN CHAMP CALCULANT LA DUREE --%>
		</tr>
		<tr>
			<td class='admin'>
				<%=getTran(request,"web","event2_death_reason",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
				
				<table>
				 <tr >
				 	<td><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_EVENT_2_DEATH_REASON", 15, 2) %> </td>
				 	<td><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_EVENT_2_DEATH_REASON_LABEL", 40, 2) %> </td>
			        <td align="center">
			        <a href="javascript:openPopup('healthrecord/deathFindICD11.jsp&ts=<%=getTs()%>&returnField=ITEM_TYPE_EVENT_2_DEATH_REASON',700,400);void(0);"><%=getTran(request,"openclinic.chuk","diagnostic.icd11Code",sWebLanguage)%></a>
			        </td>
			       </tr>
				</table>
			</td>
			<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DEATHPROCESS_2_START", sWebLanguage, sCONTEXTPATH) %>
        	</td>
        	<td class='admin2' colspan="3">
        		<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_DEATHPROCESS_2_DURATION", 5)%>
        	</td>
			<%-- METTRE UN CHAMP CALCULANT LA DUREE --%>
		</tr>
		<tr>
			<td class='admin'>
				<%=getTran(request,"web","event1_death_reason",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
				
				<table>
				 <tr >
				 	<td><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_EVENT_1_DEATH_REASON", 15, 2) %> </td>
				 	<td><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_EVENT_1_DEATH_REASON_LABEL", 40, 2) %> </td>
			        <td align="center">
			        <a href="javascript:openPopup('healthrecord/deathFindICD11.jsp&ts=<%=getTs()%>&returnField=ITEM_TYPE_EVENT_1_DEATH_REASON',700,400);void(0);"><%=getTran(request,"openclinic.chuk","diagnostic.icd11Code",sWebLanguage)%></a>
			        </td>
			       </tr>
				</table>
			</td>
			<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DEATHPROCESS_1_START", sWebLanguage, sCONTEXTPATH) %>
        	</td>
        	<td class='admin2' colspan="3">
        		<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_DEATHPROCESS_1_DURATION", 5)%>
        	</td>
			<%-- METTRE UN CHAMP CALCULANT LA DUREE --%>
		</tr>
		<tr>
			<td class='admin'>
				<%=getTran(request,"web","otherevents_death_reason",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
				
				
				
				<table>
				 <tr >
				 	<td><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_OTHEREVENTS_DEATH_REASON", 15, 2) %> </td>
				 	<td><%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_OTHEREVENTS_DEATH_REASON_LABEL", 40, 2) %> </td>
			        <td align="center">
			        <a href="javascript:openPopup('healthrecord/deathFindICD11.jsp&ts=<%=getTs()%>&returnField=ITEM_TYPE_OTHEREVENTS_DEATH_REASON',700,400);void(0);"><%=getTran(request,"openclinic.chuk","diagnostic.icd11Code",sWebLanguage)%></a>
			        </td>
			       </tr>
				</table>
			</td>
			<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_OTHEREVENTS_DEATH_REASON_START", sWebLanguage, sCONTEXTPATH) %>
        	</td>
        	<td class='admin2' colspan="3">
        		<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_OTHEREVENTS_DEATH_REASON_DURATION", 5)%>
        	</td>
			<%-- METTRE UN CHAMP CALCULANT LA DUREE --%>
		</tr>

       <tr class='admin'><td align="center" colspan="6"><%=getTran(request,"web","othermedicaldata",sWebLanguage)%>&nbsp;</td></tr>
		<tr>
        	<td class='admin' >
        		<%=getTran(request,"web","surgerywuthin4lastweeks",sWebLanguage) %>
        	</td>
        	<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons(tran, request, "yesnounknown", "ITEM_TYPE_SURGERY_WITHIN_4LASTWEEKS", sWebLanguage, false, "", "") %><p>
        	</td>
        	<td class='admin'>
				<%=getTran(request,"web","surgery_date",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2' colspan="3">
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DATESURGERY", sWebLanguage, sCONTEXTPATH) %>
        	</td>
        </tr>
        <tr>
	        <td class='admin'>
					<%=getTran(request,"web","surgeryreason",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2' >
					<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_REASONSURGERY", 40, 2) %>
			</td>
	        <td class='admin'>
				<%=getTran(request,"web","autopsy_request",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons(tran, request, "yesnoindet", "ITEM_TYPE_REQUESTAUTOPSY", sWebLanguage, false, "", "") %><p>
        	</td>
        </tr>
        <tr>
        	<td class='admin'>
				<%=getTran(request,"web","autopsy_results",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2' colspan="5">
        		<%=SH.writeDefaultRadioButtons(tran, request, "autopsy.results", "ITEM_TYPE_RESULTAUTOPSY", sWebLanguage, false, "", "") %><p>
        	</td>
        </tr>
			<td class='admin'>
				<%=getTran(request,"web","death_circumstances",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2' colspan="5">
				<%= SH.writeDefaultCheckBoxes(tran, request, "death.circumstances", "ITEM_TYPE_DEATH_CIRCUMSTANCES", sWebLanguage, true) %>
			</td>
		</tr>
		<tr>
	        <td class='admin'>
					<%=getTran(request,"web","external_causeofdeath",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
        		Date Traumatisme: <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_DATE_EXTERNAL_CAUSEOFDEATH", sWebLanguage, sCONTEXTPATH) %>
        	</td>
			<td class='admin2' colspan="5">
					Description Cause externe<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_EXTERNAL_CAUSEOFDEATH", 40, 2) %>
			</td>
		</tr>
		
		<tr>
			<td class='admin'>
				<%=getTran(request,"web","external_causeofdeath_location",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2' colspan="5">
				<%= SH.writeDefaultCheckBoxes(tran, request, "external_causeofdeath_location", "ITEM_TYPE_EXTERNAL_CAUSEOFDEATH_LOCATION", sWebLanguage, false) %>
				<br/>Autre endroit: <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_OTHER_EXTERNAL_CAUSEOFDEATH_LOCATION", 40, 2) %>
			</td>
		</tr>
		
		<tr class='admin'><td align="center" colspan="6"><%=getTran(request,"web","featal_infant_death",sWebLanguage)%>&nbsp;</td></tr>
		<tr>
			<td class='admin'>
				<%=getTran(request,"web","multiple_pregnancy",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
	       		<%=SH.writeDefaultRadioButtons(tran, request, "yesnoindet", "ITEM_TYPE_MULTIPLE_PREGNANCY", sWebLanguage, false, "", "") %><p>
	       	</td>
	       	<td class='admin'>
				<%=getTran(request,"web","stilldeath",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2' colspan="5">
	       		<%=SH.writeDefaultRadioButtons(tran, request, "yesnoindet", "ITEM_TYPE_STILLDEATH", sWebLanguage, false, "", "") %><p>
	       	</td>
       	</tr>
       	<tr>
       		<td class='admin'>
				<%=getTran(request,"web","stilldeathbefore24",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
				<table>
					<tr>
						<td class='admin'><%= getTran(request,"web","number_oflifehours",sWebLanguage) %></td>
			        	<td class='admin2'>
			        		<%= SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_NUMBEROFHOURSOFLIFE", 5, sWebLanguage) %><b>h</b>
			        	</td>
			        	<td class='admin'><%= getTran(request,"web","birth_weight",sWebLanguage) %></td>
						<td class='admin2'>
        					<%= SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_BIRTHWEIGHT", 5, sWebLanguage) %><b>g</b>
        				</td>
					</tr>
					<tr>
						<td class='admin'><%= getTran(request,"web","pregnancy_age_in_weeks",sWebLanguage) %></td>
			        	<td class='admin2'>
			        		<%= SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_PREGNANCY_AGE_INWEEKS", 5, sWebLanguage) %>
			        	</td>
			        	<td class='admin'><%= getTran(request,"web","mother_age",sWebLanguage) %></td>
			        	<td class='admin2'>
			        		<%= SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_MOTHER_AGE", 5, sWebLanguage) %> 
			        	</td>
					</tr>
				</table>
			
			</td>
			<td class='admin'>
					<%=getTran(request,"web","perinatal_death",sWebLanguage)%>&nbsp;
			</td>
				<td class='admin2' colspan="3">
					<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_PERINATAL_DEATH", 40, 2) %>
			</td>
       	</tr>	
       	<tr>
       		<td class='admin'>
				<%=getTran(request,"web","womendeath",sWebLanguage)%>&nbsp;
			</td>
			<td class='admin2'>
				<table>
					<tr>
						<td class='admin'><%= getTran(request,"web","pregnant",sWebLanguage) %></td>
			        	<td class='admin2' >
			        		<%=SH.writeDefaultRadioButtons(tran, request, "yesnoindet", "ITEM_TYPE_DEAD_WOMEN_PREGNANT", sWebLanguage, false, "", "") %>
			        	</td>
			        	
					</tr>
					
				</table>
			</td>
			<td class='admin'><%= getTran(request,"web","pregnancytime",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
        		<%= SH.writeDefaultCheckBoxes(tran, request, "mccod.pregnancytime", "ITEM_TYPE_PREGNANCY_TIME", sWebLanguage, true) %>
        	</td>
			
       	</tr>	
        <tr>
			<td class='admin'><%= getTran(request,"web","pregnancy_causeofdeath",sWebLanguage) %></td>
			<td class='admin2' colspan='5'>
			    <%=SH.writeDefaultRadioButtons(tran, request, "yesnoindet", "ITEM_TYPE_PREGNANCY_CAUSE_OFDEATH", sWebLanguage, false, "", "") %>
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
  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  if( document.getElementById('encounteruid').value=="" <%=request.getParameter("nobuttons")==null?"":" && 1==0"%>){
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