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
	String accessright="cnts.supervision";
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
    </table>
    <table width="100%" class="list" cellspacing="1">
	    <tr>
	        <td class="admin"><%=getTran(request,"Web.Occup","bloodgiftreference",sWebLanguage)%></td>
	        <td class="admin2">
	            <select class="text" id="cntsobjectid" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_OBJECTID" property="itemId"/>]>.value">
	                <option/>
	                <%
		    	        ItemVO item = ((TransactionVO)transaction).getItem(sPREFIX+"ITEM_TYPE_LAB_OBJECTID");
		    	        String sObjectId = "-1";
		    	        if(item!=null) sObjectId = item.getValue();
	                	//Find all existing bloodgifts with expirydate in the future
	                	Vector bloodgifts = MedwanQuery.getInstance().getTransactionsByType(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNTS_BLOODGIFT");
	                	for(int n=0;n<bloodgifts.size();n++){
	                		TransactionVO bloodgift = (TransactionVO)bloodgifts.elementAt(n);
	                		String expirydate=bloodgift.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNTS_EXPIRYDATE");
	                		if(expirydate.length()==10){
	                			try{
	                				java.util.Date expdate = ScreenHelper.parseDate(expirydate);
	                				if(expdate.after(new java.util.Date())){
	                					out.println("<option value='"+bloodgift.getTransactionId()+"' "+(sObjectId.equalsIgnoreCase(bloodgift.getTransactionId()+"")?"selected":"")+">"+bloodgift.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CNTS_RECEPTIONDATE")+" (ID: "+bloodgift.getTransactionId()+")");
	                				}
	                			}
	                			catch(Exception e){}
	                		}
	                	}
	                %>
	            </select>
	        </td>
	    </tr>
	    <tr>
            <td class="admin"><%=getTran(request,"bloodgift","collectionunit",sWebLanguage)%></td>
            <td class="admin2">
            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CNTSBLOODGIFT_COLLECTIONUNIT","cnts.collectionunit", sWebLanguage, "",SH.c((String)session.getAttribute("defaultCNTSCollectionUnit"))) %>
            </td>
	    </tr>
    	<tr>
    		<td class='admin'><%=getTran(request,"bloodgift","duration",sWebLanguage) %></td>
    		<td class='admin2'>
				<table width='100%'>
					<tr>
						<td>
							<b><%=getTran(request,"web","begin",sWebLanguage) %></b>: 
							<select onclick='calculateDuration()' class='text' id='beginhour' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_BEGINHOUR" property="itemId"/>]>.value">
								<option/>
								<% 	
									String beginhour=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_BEGINHOUR");
									if(((TransactionVO)transaction).getTransactionId()<0){
										beginhour=new SimpleDateFormat("HH").format(new java.util.Date());
									}
									for(int n=0;n<24;n++){ %>
									<option value='<%=SH.padLeft(n+"", "0", 2) %>' <%=beginhour.equalsIgnoreCase(SH.padLeft(n+"", "0", 2))?"selected":"" %>><%=SH.padLeft(n+"", "0", 2) %>
								<%	} %>
							</select><b>:</b><select onclick='calculateDuration()' class='text' id='beginminutes' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_BEGINMINUTES" property="itemId"/>]>.value">
								<option/>
								<% 	
									String beginminutes=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_BEGINMINUTES");
									if(((TransactionVO)transaction).getTransactionId()<0){
										beginminutes=new SimpleDateFormat("mm").format(new java.util.Date());
									}
									for(int n=0;n<60;n++){ %>
									<option value='<%=SH.padLeft(n+"", "0", 2) %>' <%=beginminutes.equalsIgnoreCase(SH.padLeft(n+"", "0", 2))?"selected":"" %>><%=SH.padLeft(n+"", "0", 2) %>
								<%	} %>
							</select>
							&nbsp;&nbsp;&nbsp;
							<b><%=getTran(request,"web","end",sWebLanguage) %></b>: 
							<select onclick='calculateDuration()' class='text' id='endhour' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ENDHOUR" property="itemId"/>]>.value">
								<option/>
								<% 	
									String endhour=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ENDHOUR");
									for(int n=0;n<24;n++){ %>
									<option value='<%=SH.padLeft(n+"", "0", 2) %>' <%=endhour.equalsIgnoreCase(SH.padLeft(n+"", "0", 2))?"selected":"" %>><%=SH.padLeft(n+"", "0", 2) %>
								<%	} %>
							</select><b>:</b><select onclick='calculateDuration()' class='text' id='endminutes' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ENDMINUTES" property="itemId"/>]>.value">
								<option/>
								<% 	
									String endminutes=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_ENDMINUTES");
									for(int n=0;n<60;n++){ %>
									<option value='<%=SH.padLeft(n+"", "0", 2) %>' <%=endminutes.equalsIgnoreCase(SH.padLeft(n+"", "0", 2))?"selected":"" %>><%=SH.padLeft(n+"", "0", 2) %>
								<%	} %>
							</select>
							&nbsp;&nbsp;&nbsp;
							<b><%=getTran(request,"bloodgift","duration",sWebLanguage) %></b>: <span id='duration' style='font-size: 14px;font-weight: bolder'></span>
							<%=SH.writeDefaultHiddenInput((TransactionVO)transaction, "ITEM_TYPE_LAB_DURATION") %>
						</td>
					</tr>
				</table>
			</td>
    	</tr>
    	<tr>
    		<td class='admin'><%=getTran(request,"web","incidents",sWebLanguage) %></td>
    		<td class='admin2'>
				<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "cnts.incidents", "ITEM_TYPE_CNTSBLOODGIFT_INCIDENTS", sWebLanguage, true) %>
			</td>
    	</tr>
    	<tr>
    		<td class='admin'><%=getTran(request,"web","comment",sWebLanguage) %></td>
    		<td class='admin2'>
				<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_CNTSBLOODGIFT_SUPERVISIONCOMMENT", 80, 2) %>
			</td>
    	</tr>
        <tr class="admin">
            <td align="center" colspan="2"><a href="javascript:openPopup('medical/managePrescriptionsPopup.jsp&amp;skipEmpty=1',900,400,'medication');void(0);"><%=getTran(request,"Web.Occup","medwan.healthrecord.medication",sWebLanguage)%></a></td>
        </tr>
        <tr>
            <td id='activeprescriptions' colspan="2">
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
            <td align="center" colspan="2"><%=getTran(request,"curative","medication.paperprescriptions",sWebLanguage)%> (<%=ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime())%>)</td>
        </tr>
        <%
            Vector paperprescriptions = PaperPrescription.find(activePatient.personid,"",ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime()),ScreenHelper.stdDateFormat.format(((TransactionVO)transaction).getUpdateTime()),"","DESC");
            if(paperprescriptions.size()>0){
                out.print("<tr><td colspan='2'><table width='100%'>");
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
            <td colspan="2"><a href="javascript:openPopup('medical/managePrescriptionForm.jsp&amp;skipEmpty=1',650,430,'medication');void(0);"><%=getTran(request,"web","medicationpaperprescription",sWebLanguage)%></a></td>
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
  
  function calculateDuration(){
	  if(document.getElementById('endhour').value.length>0 && document.getElementById('endminutes').value.length>0 && document.getElementById('beginhour').value.length>0 && document.getElementById('beginminutes').value.length>0){
		  duration = document.getElementById('endhour').value*60+document.getElementById('endminutes').value*1-document.getElementById('beginhour').value*60-document.getElementById('beginminutes').value*1;
		  if(duration*1>0){
			  if(duration<60){
				  document.getElementById('duration').innerHTML=duration+"min";
			  }
			  else{
				  document.getElementById('duration').innerHTML=Math.floor(duration/60)+"h "+duration%60+"min";
			  }
			  document.getElementById("ITEM_TYPE_LAB_DURATION").value=duration*1;
		  }
		  else {
			  document.getElementById('duration').innerHTML="";
			  document.getElementById("ITEM_TYPE_LAB_DURATION").value="";
		  }
  	  }
	  else {
		  document.getElementById('duration').innerHTML="";
		  document.getElementById("ITEM_TYPE_LAB_DURATION").value="";
	  }
  }

  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO,activeUser,"document.transactionForm.submit();"));
    %>
  }
  
  calculateDuration();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        