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
	String accessright="occup.rmhartsemenpreparation";
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
        <tr>
        	<td class='admin'><%=getTran(request,"art","sample",sWebLanguage) %></td>
        	<td class='admin2' colspan='2'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "art.sample", "ITEM_TYPE_ART_SAMPLE", sWebLanguage, false, "", "") %>
        	</td>
        	<td class='admin2' colspan='3'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "art.sip", "ITEM_TYPE_ART_SIP", sWebLanguage, false, "", "") %>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","namewomen",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_WOMENNAME", 20) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","idwomen",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_IDWOMEN", 10) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","physicianname",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_PHYSICIAN", 20) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","timeejaculate",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_TIMEEJACULATE", sWebLanguage, sCONTEXTPATH) %>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TIMEEJACULATE_HOUR", sWebLanguage, "", 0, 23) %>:<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TIMEEJACULATE_MINUTE", sWebLanguage, "", 0, 59) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","timesamplereceived",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_TIMESAMPLE", sWebLanguage, sCONTEXTPATH) %>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TIMESAMPLE_HOUR", sWebLanguage, "", 0, 23) %>:<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TIMESAMPLE_MINUTE", sWebLanguage, "", 0, 59) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","timeanalysis",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_TIMEANALYSIS", sWebLanguage, sCONTEXTPATH) %>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TIMEANALYSIS_HOUR", sWebLanguage, "", 0, 23) %>:<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TIMEANALYSIS_MINUTE", sWebLanguage, "", 0, 59) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","method",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_METHOD", "art.method", sWebLanguage, "") %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","daysofabstinence",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_DAYSOFABSTINENCE", 5) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","portionlost",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_ART_PORTIONLOST", sWebLanguage, false, "", "") %>
        	</td>
        </tr>
        <tr class='admin'>
        	<td colspan='6'><%=getTran(request,"art","samplecharacteristics",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","volume",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_VOLUME", 10) %>ml
        	</td>
        	<td class='admin2'><i style='color: green'>&gt;=1.5ml</i></td>
        	<td class='admin'><%=getTran(request,"art","concentration",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_CONCENTRATION", 10) %>ml
        	</td>
        	<td class='admin2'><i style='color: green'>&gt;=15M/ml</i></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","color",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_COLOR", 10) %>
        	</td>
        	<td class='admin2'><i style='color: green'><%=getTran(request,"art","whitetogray",sWebLanguage) %></i></td>
        	<td class='admin'><%=getTran(request,"art","totalsperm",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_TOTALSPERM", 10) %>ml
        	</td>
        	<td class='admin2'><i style='color: green'>&gt;=39M/ml</i></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","roundcells",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_ROUNDCELLS", 10) %>/hpf
        	</td>
        	<td class='admin2'><i style='color: green'>&lt;5/hpf</i></td>
        	<td class='admin'><%=getTran(request,"art","percentmotile",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_PERCENTMOTILE", 10) %>%
        	</td>
        	<td class='admin2'><i style='color: green'>&gt;=40%</i></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","viscosity",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_VISCISITY", 10) %>
        	</td>
        	<td class='admin2'><i style='color: green'>&lt;2</i></td>
        	<td class='admin'><%=getTran(request,"art","progressive",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_PROGRESSIVE", 10) %>%
        	</td>
        	<td class='admin2'><i style='color: green'>&gt;=32%</i></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","debris",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "art.debis", "ITEM_TYPE_ART_DEBRIS", sWebLanguage, false, "", "") %>
        	</td>
        	<td class='admin2'><i style='color: green'><%=getTran(request,"art.debis","1",sWebLanguage) %></i></td>
        	<td class='admin'><%=getTran(request,"art","totalprsperm",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_TOTALPRSPERM", 10) %>
        	</td>
        	<td class='admin2'><i style='color: green'>&gt;=12.5M</i></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","agglutination",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_ART_AGGLUTINATION", sWebLanguage, false, "", "") %>
        	</td>
        	<td class='admin2'><i style='color: green'><%=getTran(request,"yesno","0",sWebLanguage) %></i></td>
        	<td class='admin2' colspan='3'/>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","crystals",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_ART_CRYSTALS", sWebLanguage, false, "", "") %>
        	</td>
        	<td class='admin2'><i style='color: green'><%=getTran(request,"yesno","0",sWebLanguage) %></i></td>
        	<td class='admin2' colspan='3'/>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","liquefaction",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "art.liquefaction", "ITEM_TYPE_ART_LIQUEFACTION", sWebLanguage, false, "", "") %>
        	</td>
        	<td class='admin2'><i style='color: green'><%=getTran(request,"art.liquefaction","2",sWebLanguage) %></i></td>
        	<td class='admin2' colspan='3'/>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","gel",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_ART_GEL", sWebLanguage, false, "", "") %>
        	</td>
        	<td class='admin2'><i style='color: green'm><%=getTran(request,"yesno","0",sWebLanguage) %></i></td>
        	<td class='admin2' colspan='3'/>
        </tr>
        <tr class='admin'>
        	<td colspan='6'><%=getTran(request,"art","processedspecimen",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin' rowspan='4'><%=getTran(request,"art","method",sWebLanguage) %></td>
        	<td class='admin'><%=getTran(request,"art","gradientseparation",sWebLanguage) %></td>
        	<td class='admin'><%=getTran(request,"art","productname",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_GRADSEP_PRODUCT", 20) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","batchnumber",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_GRADSEP_BATCH", 10) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","wash",sWebLanguage) %></td>
        	<td class='admin'><%=getTran(request,"art","productname",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_WASH_PRODUCT", 20) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","batchnumber",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_WASH_BATCH", 10) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin'>
        		<%=getTran(request,"art","other",sWebLanguage) %>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_OTHERMETHOD", 20) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","productname",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_OTHER_PRODUCT", 20) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","batchnumber",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_OTHER_BATCH", 10) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","finalmedia",sWebLanguage) %></td>
        	<td class='admin'><%=getTran(request,"art","productname",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_FINAL_PRODUCT", 20) %>
        	</td>
        	<td class='admin'><%=getTran(request,"art","batchnumber",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_FINAL_BATCH", 10) %>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","concentration",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_FINAL_CONCENTRATION", 10) %>/ml
        	</td>
        	<td class='admin'><%=getTran(request,"art","motility",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_FINAL_MOTILITY", 10) %>%
        	</td>
        	<td class='admin'><%=getTran(request,"art","totalprsperm",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_FINAL_TOTALPRSPERM", 10) %>/ml
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","finalinseminationvolume",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_FINAL_INSEMINATIONVOLUME", 10) %>ml
        	</td>
        	<td class='admin'><%=getTran(request,"art","totalsperm",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_FINAL_TOTALSPERM", 10) %>%
        	</td>
        	<td class='admin'><%=getTran(request,"art","technician",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ART_FINAL_TECHNICIAN", 20) %>
        	</td>
        </tr>
    </table>
    <table width="100%" class="list" cellspacing="1">
        <td class="admin2" style="vertical-align:top;">
            <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
        </td>
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