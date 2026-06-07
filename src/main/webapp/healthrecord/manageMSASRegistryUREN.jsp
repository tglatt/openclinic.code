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
<%
	String accessright="msas.registry.uren";
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
        <tr>
        	<td class='admin'><%=getTran(request,"web","masnumber",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MASNUMBER", 15) %></td>
        	<td class='admin'><%=getTran(request,"web","mothersname",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MOTHERSNAME", 50) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","admissiontype",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_ADMISSIONTYPE","msas.uren.admissiontype", sWebLanguage, "") %><BR/>
        		<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.uren.communityreferral", "ITEM_TYPE_MSAS_UREN_COMMUNITYREFERRAL", sWebLanguage, false) %>
        	</td>
        	<td class='admin'><%=getTran(request,"web","comingfrom",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_COMINGFROM", 50) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","peopleathome",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_PEOPLEATHOME", 2,1,40,sWebLanguage) %></td>
        	<td class='admin'><%=getTran(request,"web","twin",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_TWIN", sWebLanguage, false, "", "") %></td>
        </tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","anthropometry",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin2' colspan='4'><%writeVitalSigns(pageContext); %></td>
		</tr>	
        <tr>
        	<td class='admin'><%=getTran(request,"web","oedema",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.uren.oedema", "ITEM_TYPE_UREN_OEDEMA", sWebLanguage, false, "", "") %>
        		&nbsp;<%=getTran(request,"web","since",sWebLanguage) %> <%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_OEDEMA_SINCE", sWebLanguage, sCONTEXTPATH) %>
        	</td>
        	<td class='admin'<><%=getTran(request,"web","other",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_ANTHROPOMETRY_OTHER", 50, 1) %></td>
        </tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","clinicalhistory",sWebLanguage) %></td></tr>
        <tr>
        	<td colspan='4'>
        		<table width='100%'>
        			<tr>
			        	<td class='admin'><%=getTran(request,"web","oedema",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_DIARRHEA", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","vomiting",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_VOMITING", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","cough",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_COUGH", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","appetite",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.uren.appetite", "ITEM_TYPE_UREN_APPETITE", sWebLanguage, false, "", "") %></td>
        			</tr>
        			<tr>
			        	<td class='admin'><%=getTran(request,"web","stoolperday",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.ure.stool", "ITEM_TYPE_UREN_STOOLPERDAY", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","doesurinate",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_DOESURINATE", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","mothermilk",sWebLanguage) %></td>
			        	<td class='admin2' colspan='3'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_MOTHERMILK", sWebLanguage, false, "", "") %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
		<tr>
        	<td class='admin' colspan='2'><%=getTran(request,"web","problemsbyattendant",sWebLanguage) %></td>
        	<td class='admin2' colspan='2'><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_PROBLEMSBYATTENDANT", 50, 1) %></td>
		</tr>				
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","physicalexamination",sWebLanguage) %></td></tr>
        <tr>
        	<td colspan='4'>
        		<table width='100%'>
        			<tr>
			        	<td class='admin'><%=getTran(request,"web","eyes",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.uren.eyes", "ITEM_TYPE_UREN_EYES", sWebLanguage, false) %></td>
			        	<td class='admin'><%=getTran(request,"web","ears",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.uren.ears", "ITEM_TYPE_UREN_EARS", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","lymphnodes",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.uren.lymphnodes", "ITEM_TYPE_UREN_LYMPHNODES", sWebLanguage, false) %></td>
			        	<td class='admin'><%=getTran(request,"web","skin",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.uren.skin", "ITEM_TYPE_UREN_SKIN", sWebLanguage, false) %></td>
        			</tr>
        			<tr>
			        	<td class='admin'><%=getTran(request,"web","chestindrawing",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_CHESTINDRAWING", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","conjunctiva",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.uren.conjunctiva", "ITEM_TYPE_UREN_CONJUNCTIVA", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","dehydration",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.uren.dehydration", "ITEM_TYPE_UREN_DEHYDRATION", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","mouth",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.uren.mouth", "ITEM_TYPE_UREN_MOUTH", sWebLanguage, false) %></td>
        			</tr>
        			<tr>
			        	<td class='admin'><%=getTran(request,"msas","anemia",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_ANEMIA", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","skininfection",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_SKININFECTION", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","handicap",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_UREN_HANDICAP", sWebLanguage, false, "", "") %></td>
			        	<td class='admin'><%=getTran(request,"web","limbs",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "msas.uren.limbs", "ITEM_TYPE_UREN_LIMBS", sWebLanguage, false, "", "") %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","medicalprotocol",sWebLanguage) %></td></tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","vitamina",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_VITAMINADATE", sWebLanguage, sCONTEXTPATH) %>
        		&nbsp;<%=getTran(request,"web","dose",sWebLanguage) %>: <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_VITAMINADOSE", 15) %>
        	</td>
        	<td class='admin'><%=getTran(request,"web","mebendazole",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_MEBENDAZOLEDATE", sWebLanguage, sCONTEXTPATH) %>
        		&nbsp;<%=getTran(request,"web","dose",sWebLanguage) %>: <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_MEBENDAZOLEDOSE", 15) %>
        	</td>
        </tr>
		<tr>
	       	<td class='admin'><%=getTran(request,"web","amoxycillin",sWebLanguage) %></td>
	       	<td class='admin2'>
	       		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_AMOXYCYCILLINDATE", sWebLanguage, sCONTEXTPATH) %>
	       		&nbsp;<%=getTran(request,"web","dose",sWebLanguage) %>: <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_AMOXYCYCILLINDOSE", 15) %>
	       	</td>
	       	<td class='admin'><%=getTran(request,"web","mumpsvaccine",sWebLanguage) %></td>
	       	<td class='admin2'>
	       		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_MUMPSDATE", sWebLanguage, sCONTEXTPATH) %>
	       		&nbsp;<%=getTran(request,"web","dose",sWebLanguage) %>: <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_MUMPSDOSE", 15) %>
	       	</td>
		</tr>
		<tr>
	       	<td class='admin'><%=getTran(request,"msas","othertreatment",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_OTHERTREATMENT", 50, 1) %>
        	</td>
	       	<td class='admin'><%=getTran(request,"msas","atpebags",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_ATPEBAGS", 3,0,20,sWebLanguage) %></td>
		</tr>
		<tr>
	       	<td class='admin'><%=getTran(request,"msas","action",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_UREN_ACTION", 50, 1) %></td>
        	<td class='admin2' colspan='2'>
        		<%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "TEM_TYPE_MSAS_MALNUTRITION_SENTTOCOMMUNITYLEVEL", "") %><%=getTran(request,"web","senttocommunitylevel",sWebLanguage) %>
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