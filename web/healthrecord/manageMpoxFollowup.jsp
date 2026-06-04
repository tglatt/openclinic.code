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
	String accessright="mpox.followup";
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
        <% TransactionVO tran = (TransactionVO)transaction; %>))
        <tr class='admin'>
        	<td colspan='8'><%=getTran(request,"web","clinicalsignsandsymptoms",sWebLanguage) %></td>
        </tr>
		<tr>
        	<td class='admin' colspan='2' width='25%'>
        		<%=getTran(request,"web","begin",sWebLanguage) %>:
        		<%=SH.writeDefaultLastDateInput(request, tran, "ITEM_TYPE_MPOX_SYMPTOMSONSET", sWebLanguage, sCONTEXTPATH, "onchange='triage()'") %>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_FEVER", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"covid","fever",sWebLanguage) %>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_COUGH", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"covid","cough",sWebLanguage) %>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_MUSCLEPAIN", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","musclepain",sWebLanguage) %>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_RUNNINGNOSE", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"covid","runningnose",sWebLanguage) %>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_SORETHROAT", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","sorethroat",sWebLanguage) %>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_BACKACHE", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","backache",sWebLanguage) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin' colspan='2' rowspan='2'>
        		<span id='symptomsduration'></span>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_HEADACHE", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","headache",sWebLanguage) %>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_FATIGUE", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","fatigue",sWebLanguage) %>
        	</td>
        	<td class='admin2top'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_CHILLS", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","chills",sWebLanguage) %>
        	</td>
        	<td class='admin2top' colspan='2'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_SWOLLENLYMPHNODES", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","noduleslumphatiquesgonflees",sWebLanguage) %>
        	</td>
        	<td class='admin2top'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_ASTEHENIA", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","asthenia",sWebLanguage) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_GENITALSWELLING", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","genitalswelling",sWebLanguage) %>
        	</td>
        	<td class='admin2top' width='12.5%'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_GENITALPAIN", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","genitalpain",sWebLanguage) %>
        	</td>
        	<td class='admin2top'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_NAUSEA", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","vomitingnausea",sWebLanguage) %>
        	</td>
        	<td class='admin2top'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_CONJUNCTIVITIS", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","conjunctivitis",sWebLanguage) %>
        	</td>
        	<td class='admin2top'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_POLYADENOPATHY", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","polyadenopathy",sWebLanguage) %>
        	</td>
        	<td class='admin2top'>
        		<%=SH.writeDefaultLastCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_DIARRHEA", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"web","diarrhea",sWebLanguage) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin' colspan='2'><%=getTran(request,"web","todayscomplaints",sWebLanguage) %></td>
        	<td class='admin2' colspan='6'>
        		<%=SH.writeDefaultLastTextArea(request, tran, "ITEM_TYPE_MPOX_TODAYSCOMPLAINTS", 100, 1) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin' colspan='2'><%=getTran(request,"web","clinicalexamination",sWebLanguage) %></td>
        	<td class='admin2' colspan='6'>
        		<%=SH.writeDefaultLastTextArea(request, tran, "ITEM_TYPE_MPOX_CLINICALEXAMINATION", 100, 1) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin' colspan='2'><%=getTran(request,"web","otherobservations",sWebLanguage) %></td>
        	<td class='admin2' colspan='6'>
        		<%=SH.writeDefaultLastTextArea(request, tran, "ITEM_TYPE_MPOX_OBSERVATIONS", 100, 1) %>
        	</td>
        </tr>
		<tr><td class='admin2' colspan='8'><hr/></td></tr>
		<tr>
            <td class="admin" colspan='2'>
            	<%=getTran(request,"Web.Occup","rmh.vital.signs",sWebLanguage)%>&nbsp;
            </td>
			<td class='admin2' colspan='6'><% writeVitalSigns(pageContext); %></td>
		</tr>
        <tr class='admin'>
        	<td colspan='8'><%=getTran(request,"web","rash",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin' colspan='2'>
        		<%=getTran(request,"web","begin",sWebLanguage) %>:
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MPOX_RASHONSET", sWebLanguage, sCONTEXTPATH, "onchange='triage();' onfocus='triage();'") %>
        	</td>
        	<td class='admin'><%=getTran(request,"web","bodyparts",sWebLanguage) %></td>
        	<td class='admin2' colspan='5'>
        		<%=SH.writeDefaultCheckBoxes(tran, request, "mpox.rashlocations" , "ITEM_TYPE_MPOX_RASHLOCATIONS", sWebLanguage, false) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin' colspan='2'>
        		<span id='rashduration'></span>
        	</td>
        	<td class='admin'>
        		<%=getTran(request,"web","stages",sWebLanguage) %>
        		<img src='<%=sCONTEXTPATH %>/_img/icons/icon_info.gif' onclick="zoomlarge('<%=sCONTEXTPATH %>/_img/sormas/rash-<%=sWebLanguage %>.png')" onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","info",sWebLanguage) %>' style='vertical-align: middle'/>
        	</td>
        	<td class='admin2top' id='macula'>
        		<%=SH.writeDefaultCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_MACULA", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"mpox","macula",sWebLanguage) %>&nbsp;
        		<img src='<%=sCONTEXTPATH %>/_img/sormas/macula.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        		&nbsp;<img src='<%=sCONTEXTPATH %>/_img/sormas/macula2.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        	</td>
        	<td class='admin2top' id='papula'>
        		<%=SH.writeDefaultCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_PAPULA", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"mpox","papula",sWebLanguage) %>&nbsp;
        		<img src='<%=sCONTEXTPATH %>/_img/sormas/papula.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        		&nbsp;<img src='<%=sCONTEXTPATH %>/_img/sormas/papula2.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        	</td>
        	<td class='admin2top' id='vesicula'>
        		<%=SH.writeDefaultCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_VESICULA", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"mpox","vesicle",sWebLanguage) %>&nbsp;
        		<img src='<%=sCONTEXTPATH %>/_img/sormas/vesicula.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        		&nbsp;<img src='<%=sCONTEXTPATH %>/_img/sormas/vesicula2.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        	</td>
        	<td class='admin2top' id='pustula'>
        		<%=SH.writeDefaultCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_PUSTULA", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"mpox","pustule",sWebLanguage) %>&nbsp;
        		<img src='<%=sCONTEXTPATH %>/_img/sormas/pustula.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        		&nbsp;<img src='<%=sCONTEXTPATH %>/_img/sormas/pustula2.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        		&nbsp;<img src='<%=sCONTEXTPATH %>/_img/sormas/pustula3.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        	</td>
        	<td class='admin2top' id='scab'>
        		<%=SH.writeDefaultCheckBox(tran, request, "yesno", "ITEM_TYPE_MPOX_SCAB", sWebLanguage, "onchange='triage();'") %>
        		<%=getTran(request,"mpox","scab",sWebLanguage) %>&nbsp;
        		<img src='<%=sCONTEXTPATH %>/_img/sormas/scabs.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        		&nbsp;<img src='<%=sCONTEXTPATH %>/_img/sormas/scabs2.png' onclick='zoom(this.src)' onmouseover='this.style.cursor="hand"' title='<%=getTranNoLink("web","clicktoenlarge",sWebLanguage) %>' style='vertical-align: middle' height='16px'/>
        	</td>
        </tr>
        <tr class="admin">
            <td colspan="8"><%=getTran(request,"web","complications",sWebLanguage)%>&nbsp;</td>
        </tr>
        	<td class='admin2' colspan='5'>
        		<%=SH.writeDefaultCheckBoxes(tran, request, "mpox.complications", "ITEM_TYPE_MPOX_COMPLICATIONS", sWebLanguage, false) %>
        	</td>
        	<td class='admin'><%=getTran(request,"web","other",sWebLanguage) %></td>
        	<td class='admin2' colspan='2'>
        		<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MPOX_OTHERCOMPLICATIONS", 30, 1) %>
        	</td>
        <tr class="admin">
            <td colspan="8"><%=getTran(request,"web","treatment",sWebLanguage)%>&nbsp;</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"mpox","drugs",sWebLanguage) %></td>
        	<td class='admin2' colspan='3'>
        		<%=SH.writeDefaultCheckBoxes(tran, request, "mpox.drugs", "ITEM_TYPE_MPOX_DRUGS", sWebLanguage, false) %>
        	</td>
        	<td class='admin'><%=getTran(request,"mpox","care",sWebLanguage) %></td>
        	<td class='admin2' colspan='3'>
        		<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MPOX_CARE", 40, 2) %>
        	</td>
        </tr>
        <tr class="admin">
            <td colspan="8"><%=getTran(request,"web","vaccination",sWebLanguage)%>&nbsp;</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"mpox","newsmallpoxvaccination",sWebLanguage) %></td>
        	<td class='admin2' colspan='7'>
        		Dose 1:&nbsp;
        		<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MPOX_SMALLPOXVACCINE1", "mpox.vaccine", sWebLanguage, "onchange='triage()'") %>
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MPOX_SMALLPOXVACCINEDATE1", sWebLanguage, sCONTEXTPATH) %>
        		<br/>Dose 2:&nbsp;
        		<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MPOX_SMALLPOXVACCINE2", "mpox.vaccine", sWebLanguage, "onchange='triage()'") %>
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MPOX_SMALLPOXVACCINEDATE2", sWebLanguage, sCONTEXTPATH) %>
        		<br/>Dose 3:&nbsp;
        		<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MPOX_SMALLPOXVACCINE3", "mpox.vaccine", sWebLanguage, "onchange='triage()'") %>
        		<%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MPOX_SMALLPOXVACCINEDATE3", sWebLanguage, sCONTEXTPATH) %>
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
  function zoom(img){
      window.open("<%=sCONTEXTPATH%>/popupImage.jsp?file="+img,"Mpox","height=600,width=600,toolbar=no,status=no,scrollbars=no,resizable=no,menubar=no");
  }

  function zoomlarge(img){
      window.open("<%=sCONTEXTPATH%>/popupImage.jsp?file="+img,"Mpox","height=800,width=1024,toolbar=no,status=no,scrollbars=no,resizable=no,menubar=no");
  }
  
  function triage(){
	  var els = document.body.getElementsByTagName('input');
	  for(i=0;i<els.length;i++){
		  el=els[i];
		  if(document.getElementById('label-'+el.id)){
			  if(el.id && el.id.includes("-1") ){
				  if(el.checked){
					  document.getElementById('label-'+el.id).style.backgroundColor='red';
					  document.getElementById('label-'+el.id).style.color='white';
				  }
				  else {
					  document.getElementById('label-'+el.id).style.backgroundColor='#e4e4e4';
					  document.getElementById('label-'+el.id).style.color='black';
				  }
			  }
	  	  }
	  }
	  if(document.getElementById("ITEM_TYPE_MPOX_RASHONSET").value.length>0){
		  	var rashonset = makedate(document.getElementById("ITEM_TYPE_MPOX_RASHONSET").value);
		  	var trandate = makedate(document.getElementById("trandate").value);
	        var timeElapsed = trandate.getTime() - rashonset.getTime();
	        timeElapsed = timeElapsed / (1000 * 3600 * 24);
		  	document.getElementById('rashduration').innerHTML='<%=getTranNoLink("web","since",sWebLanguage)%> <font style="font-size: 14px">'+Math.floor(timeElapsed)+'</font> <%=getTranNoLink("web","days",sWebLanguage)%>';
	  }
	  if(document.getElementById("ITEM_TYPE_MPOX_SYMPTOMSONSET").value.length>0){
		  	var symptomsonset = makedate(document.getElementById("ITEM_TYPE_MPOX_SYMPTOMSONSET").value);
		  	var trandate = makedate(document.getElementById("trandate").value);
	        var timeElapsed = trandate.getTime() - symptomsonset.getTime();
	        timeElapsed = timeElapsed / (1000 * 3600 * 24);
		  	document.getElementById('symptomsduration').innerHTML='<%=getTranNoLink("web","since",sWebLanguage)%> <font style="font-size: 14px">'+Math.floor(timeElapsed)+'</font> <%=getTranNoLink("web","days",sWebLanguage)%>';
	  }
	  if(document.getElementById("[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE").value*1>=38){
		  document.getElementById("ITEM_TYPE_MPOX_FEVER").checked=true;
	  }
	  else if(document.getElementById("[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE").value*1>=30){
		  document.getElementById("ITEM_TYPE_MPOX_FEVER").checked=false;
	  }
	  if(document.getElementById("ITEM_TYPE_MPOX_MACULA").checked){
		  document.getElementById('macula').style.border='3px solid black';
	  }
	  else{
		  document.getElementById('macula').style.border='';
	  }
	  if(document.getElementById("ITEM_TYPE_MPOX_PAPULA").checked){
		  document.getElementById('papula').style.border='3px solid black';
	  }
	  else{
		  document.getElementById('papula').style.border='';
	  }
	  if(document.getElementById("ITEM_TYPE_MPOX_VESICULA").checked){
		  document.getElementById('vesicula').style.border='3px solid black';
	  }
	  else{
		  document.getElementById('vesicula').style.border='';
	  }
	  if(document.getElementById("ITEM_TYPE_MPOX_PUSTULA").checked){
		  document.getElementById('pustula').style.border='3px solid black';
	  }
	  else{
		  document.getElementById('pustula').style.border='';
	  }
	  if(document.getElementById("ITEM_TYPE_MPOX_SCAB").checked){
		  document.getElementById('scab').style.border='3px solid black';
	  }
	  else{
		  document.getElementById('scab').style.border='';
	  }
}

  function makedate(s){
	  var date = new Date();
	  var parts = s.split("/");
	  date.setDate(1);
	  date.setMonth(parts[1]-1);
	  date.setYear(parts[2]);
      var day=24*3600*1000;
      date.setTime(date.getTime()+(parts[0]-1)*day);
      return date;
  }

  triage();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        