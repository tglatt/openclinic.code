<%@page import="be.openclinic.medical.*"%>
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
	String accessright="occup.outpatientfile";
%>
<%=checkPermission(accessright,"select",activeUser)%>
<%!
	private String getLastLabresult(TransactionVO transaction,String loinc,String personid){
		String s="&nbsp;&nbsp;";
		String sDateMin=SH.formatDate(new java.util.Date(transaction.getUpdateTime().getTime()-SH.getTimeDay()*7));
		String sDateMax=SH.formatDate(SH.getTomorrow());
		Encounter encounter = transaction.getEncounter();
		if(encounter==null && transaction.isNew()){
			encounter = Encounter.getActiveEncounter(personid);
		}
		if(encounter!=null){
			sDateMin =SH.formatDate(encounter.getBegin());
			if(encounter.getEnd()!=null){
				sDateMax=SH.formatDate(encounter.getEnd());
			}
		}
		LabAnalysis analysis = LabAnalysis.getLabAnalysisByMedidocCode(loinc);
		if(analysis!=null){
			Vector<RequestedLabAnalysis> labs = RequestedLabAnalysis.find("", "", personid, analysis.getLabcode(), "", "", "", "", "", "", "", "", sDateMin, sDateMax, "", "DESC", false, "");
			for(int n=0;n<labs.size();n++){
				RequestedLabAnalysis anal = labs.elementAt(n);
				if(SH.c(anal.getResultValue()).length()>0){
					s=anal.getResultValue();
					n=labs.size();
				}
			}
		}
		return s;
	}

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
    <% SH.loadRecentItems((TransactionVO)transaction,activePatient); %>
    
    <table class="list" width="100%" cellspacing="1" cellpadding='0'>
        <%-- DATE --%>
        <tr>
            <td class="admin" width="10%" nowrap>
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>&nbsp;
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
				<!-- Add time section -->
                <%
                	java.util.Date date = ((TransactionVO)transaction).getUpdateTime();
                	if(date==null){
                		date=new java.util.Date();
                	}
                	String sTime=new SimpleDateFormat("HH:mm").format(date);
                %>
                <input type='text' class='text' size='5' maxLength='5' name='trantime' id='trantime' value='<%=sTime%>'/>
                <!-- End time section -->
            </td>
            <td class="admin2" colspan='2'>&nbsp;</td>
        </tr>
        <% TransactionVO tran = (TransactionVO)transaction; %>
    </table>
	<BR/>
	<%-- TABS --%>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(1)" id="td1" nowrap>&nbsp;<b><%=getTran(request,"web","consultation",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselectedred' style='display: none' width="1%" onclick="activateTab(2)" id="td2" nowrap>&nbsp;<b><%=getTran(request,"web","malaria",sWebLanguage)%></b>&nbsp;</td>
            <td width="*" class='tabs'></td>
        </tr>
    </table>
    <%-- HIDEABLE --%>
    
    <table id="contentpane" style="vertical-align:top;" width="100%" border="0" cellspacing="0">
        <tr id="tr1-view">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/manageRMHOutpatientFileInclude.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr2-view" style="display:none">
            <td>
            	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/manageMalariaAdmissionInclude.jsp"),pageContext);%>
            </td>
        </tr>
    </table>
	

	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,accessright,sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
    <%=ScreenHelper.contextFooter(request)%>
    
    <input type='hidden' name='activeDestinationIdField' id='activeDestinationIdField'/>
  	<input type='hidden' name='activeDestinationTextField' id='activeDestinationTextField'/>
  	<input type='hidden' name='activeLabeltype' id='activeLabeltype'/>
  	<input type='hidden' name='activeDivld' id='activeDivld'/>
    
</form>

<script>  
	function resizeContentPane(pane){
	  	if(document.getElementById("Juist").clientHeight>0){
		  	document.getElementById("contentpane").width=document.getElementById("Juist").clientWidth; 
	  	}
 	}

  function activateTab(iTab){
    if(document.getElementById('tr1-view')) document.getElementById('tr1-view').style.display = 'none';
    if(document.getElementById('tr2-view')) document.getElementById('tr2-view').style.display = 'none';
    if(document.getElementById('tr3-view')) document.getElementById('tr3-view').style.display = 'none';
    if(document.getElementById('tr4-view')) document.getElementById('tr4-view').style.display = 'none';
    if(document.getElementById('tr5-view')) document.getElementById('tr5-view').style.display = 'none';
    if(document.getElementById('tr6-view')) document.getElementById('tr6-view').style.display = 'none';
    if(document.getElementById('tr7-view')) document.getElementById('tr7-view').style.display = 'none';
    if(document.getElementById('tr8-view')) document.getElementById('tr8-view').style.display = 'none';
    if(document.getElementById('tr9-view')) document.getElementById('tr9-view').style.display = 'none';

    if(document.getElementById('td1')) document.getElementById('td1').className = "tabunselected";
    if(document.getElementById('td2')) document.getElementById('td2').className = "tabunselectedred";
    if(document.getElementById('td3')) document.getElementById('td3').className = "tabunselected";
    if(document.getElementById('td4')) document.getElementById('td4').className = "tabunselected";
    if(document.getElementById('td5')) document.getElementById('td5').className = "tabunselected";
    if(document.getElementById('td6')) document.getElementById('td6').className = "tabunselected";
    if(document.getElementById('td7')) document.getElementById('td7').className = "tabunselected";
    if(document.getElementById('td8')) document.getElementById('td8').className = "tabunselected";
    if(document.getElementById('td9')) document.getElementById('td9').className = "tabunselected";

    if (iTab==1){
      document.getElementById('tr1-view').style.display = '';
      document.getElementById('td1').className="tabselected";
      resizeContentPane();
    }
    else if (iTab==2){
        document.getElementById('tr2-view').style.display = '';
        document.getElementById('td2').className="tabselectedred";
        resizeContentPane();
        checkFields();
      }
    else if (iTab==3){
        document.getElementById('tr3-view').style.display = '';
        document.getElementById('td3').className="tabselected";
        resizeContentPane();
      }
    else if (iTab==4){
        document.getElementById('tr4-view').style.display = '';
        document.getElementById('td4').className="tabselected";
        resizeContentPane();
      }
    else if (iTab==5){
    	loadAssessment(true);
      }
    else if (iTab==6){
    	loadTests(true);
      }
    else if (iTab==7){
        document.getElementById('tr7-view').style.display = '';
        document.getElementById('td7').className="tabselected";
        resizeContentPane();
      }
    else if (iTab==8){
        document.getElementById('tr8-view').style.display = '';
        document.getElementById('td8').className="tabselected";
        resizeContentPane();
      }
    else if (iTab==9){
        document.getElementById('tr9-view').style.display = '';
        document.getElementById('td9').className="tabselected";
        resizeContentPane();
      }
    document.getElementById("Juist").scrollTop=0;;
  }

  function openEncounter(){
    openPopup("adt/editEncounter.jsp&ReloadParent=no&Popup=yes&EditEncounterUID=" + document.getElementById('encounteruid').value + "&ts=<%=getTs()%>",800);
  }
  function malariaCare(activate){
	  if(document.getElementById("ITEM_TYPE_MALARIA_CARE").value=='1;'){
		  document.getElementById("td2").style.display='';
		  if(activate){
			  activateTab(2);
		  }
	  }
	  else{
		  document.getElementById("td2").style.display='none';
	  }
  }
  <%-- SUBMIT FORM --%>
  function submitForm(){
	  if(<%=((TransactionVO)transaction).getServerId()%>==1 && document.getElementById('encounteruid').value=='' <%=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERRAL_SOURCESITE").length()==0 && request.getParameter("nobuttons")==null?"":" && 1==0"%>){
			alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
			searchEncounter();
	  }	
	  else {
    	<% if(SH.ci("enableOutpatientMalariaExtension",0)==1){%>
    		document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIA").value="";
    		if('<%=getLastLabresult(tran, "70569-9",activePatient.personid).replaceAll("&nbsp;","")%>'.length==0 && '<%=getLastLabresult(tran, "32700-7",activePatient.personid).replaceAll("&nbsp;","")%>'.length==0){
    			document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIA").value+="0;";
    		}
    		else{
    			if(document.getElementById("ITEM_TYPE_PRESUMEDDIAGNOSIS.1").checked){
        			document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIA").value+="1;";
    			}
    			else if(document.getElementById("ITEM_TYPE_PRESUMEDDIAGNOSIS.2").checked){
        			document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIA").value+="2;";
    			}
    		}
			if(document.getElementById("ITEM_TYPE_SEVEREANEMIA").checked){
    			document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIA").value+="3;";
			}
			
    		document.getElementById("ITEM_TYPE_NOTIFICATION_PREGNANTWOMEN").value="";
    		if(document.getElementById("ITEM_TYPE_PREGNANTWOMEN.0")){
				if(document.getElementById("ITEM_TYPE_PREGNANTWOMEN.0").checked){
	    			document.getElementById("ITEM_TYPE_NOTIFICATION_PREGNANTWOMEN").value="0;";
				}
				else if(document.getElementById("ITEM_TYPE_PREGNANTWOMEN.1").checked){
					if(document.getElementById("ITEM_TYPE_PREGNANCYDURATION").value*1<14){
		    			document.getElementById("ITEM_TYPE_NOTIFICATION_PREGNANTWOMEN").value="1;";
					}
					else{
		    			document.getElementById("ITEM_TYPE_NOTIFICATION_PREGNANTWOMEN").value="2;";
					}
				}
    		}			
    		document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIATREATMENT").value="";
    		if(document.getElementById("ITEM_TYPE_TREATMENT_UNCOMPLICATED").value=="1"){
    			document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIATREATMENT").value="1;";
    		}
    		else if(document.getElementById("ITEM_TYPE_TREATMENT_UNCOMPLICATED").value=="2"){
    			document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIATREATMENT").value="2;";
    		}
    		else if(document.getElementById("ITEM_TYPE_TREATMENT_UNCOMPLICATED").value=="3"){
    			document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIATREATMENT").value="3;";
    		}
    		else if(document.getElementById("ITEM_TYPE_TREATMENT_UNCOMPLICATED").value=="4"){
    			document.getElementById("ITEM_TYPE_NOTIFICATION_MALARIATREATMENT").value="4;";
    		}
    	<% } %>
	    transactionForm.saveButton.disabled = true;
	    document.getElementById('trandate').value+=' '+document.getElementById('trantime').value;
	    addIkireziBiometrics();
	    <%
	        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
	        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
	    %>
	  }
  }    

  function addIkireziBiometrics(){
	    var url = '<c:url value="/ikirezi/addBiometrics.jsp"/>'+
			    '?encounteruid='+document.getElementById('encounteruid').value+
			    '&temperature='+document.getElementById('temperature').value+
			    '&wfl='+document.getElementById('wflinfo').title+
			    '&wflval='+document.getElementById('WFL').value+
			    '&bmi='+document.getElementById('BMI').value+
	              '&ts='+new Date().getTime();
	    new Ajax.Request(url,{
	      parameters: "",
	      onSuccess: function(resp){
	    	  //Fine
	      }
	    });
	  }

  <%-- SELECT KEYWORDS --%>
  function selectKeywords(destinationidfield,destinationtextfield,labeltype,divid,element){	
	if(element){
		//document.getElementById("keywordstd").style="position: absolute;top: "+element.getBoundingClientRect().top;

	}
    var bShowKeywords=true;
	document.getElementById("activeDestinationIdField").value=destinationidfield;
	document.getElementById("activeDestinationTextField").value=destinationtextfield;
	document.getElementById("activeLabeltype").value=labeltype;
	document.getElementById("activeDivld").value=divid;
	
    document.getElementById("key1").width = "16";
    document.getElementById("key2").width = "16";
    document.getElementById("key3").width = "16";
    document.getElementById("key4").width = "16";
    document.getElementById("key6").width = "16";
    
    document.getElementById("title1").style.textDecoration = "none";
    document.getElementById("title2").style.textDecoration = "none";
    document.getElementById("title3").style.textDecoration = "none";
    document.getElementById("title4").style.textDecoration = "none";
    document.getElementById("title6").style.textDecoration = "none";
    
    if(labeltype=='ikirezi2.functional.signs'){
        document.getElementById("title1").style.textDecoration = "underline";
	  	document.getElementById('key1').width = '32';
	  	//document.getElementById('keywordstd').style = "vertical-align:top";
	}
    else if(labeltype=='ikirezi2.inspection'){
      document.getElementById("title2").style.textDecoration = "underline";
	  document.getElementById('key2').width = '32';
	  	//document.getElementById('keywordstd').style = "vertical-align:top";
	}
    else if(labeltype=='ikirezi2.palpation'){
      document.getElementById("title3").style.textDecoration = "underline";
	  document.getElementById('key3').width = '32';
	  	//document.getElementById('keywordstd').style = "vertical-align:top";
	}
    else if(labeltype=='ikirezi2.auscultation'){
      document.getElementById("title4").style.textDecoration = "underline";
	  document.getElementById('key4').width = '32';
	  	//document.getElementById('keywordstd').style = "vertical-align:top";
	}
    else if(labeltype=='reference'){
      document.getElementById("title6").style.textDecoration = "underline";
	  document.getElementById('key6').width = '32';
	  	//document.getElementById('keywordstd').style = "vertical-align:bottom";
	}
    else{
    	bShowKeywords=false;
    }
    
    if(bShowKeywords){
	    var params = "";
	    var today = new Date();
	    var url = '<c:url value="/healthrecord/ajax/getKeywords.jsp"/>'+
	              '?destinationidfield='+destinationidfield+
	              '&destinationtextfield='+destinationtextfield+
	              '&labeltype='+labeltype+
	              '&filetype=new'+
	              '&ts='+today;
	    new Ajax.Request(url,{
	      method: "POST",
	      parameters: params,
	      onSuccess: function(resp){
	        $(divid).innerHTML = resp.responseText;
	    	  if(resp.responseText.indexOf("<recheck/>")>-1){
	    		  window.setTimeout('storekeywordsubtype(document.getElementById("keywordsubtype").value);',200);
	    	  }
	    	  <%
	    	  	if(checkString((String)request.getSession().getAttribute("editmode")).equalsIgnoreCase("1")){%>
	            	myselect=document.getElementById('keywordsubtype');
	            	myselect.style='border:2px solid black; border-style: dotted';
	            	myselect.onclick=function(){window.open('<%=request.getRequestURI().replaceAll(request.getServletPath(),"")%>/popup.jsp?Page=system/manageTranslations.jsp&FindLabelType=keywordsubtypes.'+labeltype+'&find=1','popup','toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=500,menubar=no');return false;};
	    	  <%
	    	  	}
	    	  %>
	      },
	      onFailure: function(){
	        $(divid).innerHTML = "";
	      }
	    });
    }
    else{
        $(divid).innerHTML = "";
    }
  }

  function newkeyword(){
      openPopup("/healthrecord/ajax/newKeyword.jsp&ts=<%=getTs()%>&labeltype="+document.getElementById("activeLabeltype").value+"."+document.getElementById("keywordsubtype").value);
  }
  
  function deletekeyword(labeltype,labelid){
	if(confirm("<%=getTranNoLink("web","areyousure",sWebLanguage)%>")){
	    var params = "";
	    var today = new Date();
	    var url = '<c:url value="/healthrecord/ajax/deleteKeyword.jsp"/>'+
	              '?labeltype='+labeltype+'&labelid='+labelid;
	    new Ajax.Request(url,{
	      method: "POST",
	      parameters: params,
	      onSuccess: function(resp){
	    	  refreshKeywords();
	      },
	      onFailure: function(){
	      }
	    });
	}
  }
  
  function refreshKeywords(){
	  selectKeywords(document.getElementById("activeDestinationIdField").value,
			  document.getElementById("activeDestinationTextField").value,
			  document.getElementById("activeLabeltype").value,
			  document.getElementById("activeDivld").value);
  }
  
  <%-- ADD KEYWORD --%>
  function addKeyword(id,label,destinationidfield,destinationtextfield){
	while(document.getElementById(destinationtextfield).innerHTML.indexOf('&nbsp;')>-1){
		document.getElementById(destinationtextfield).innerHTML=document.getElementById(destinationtextfield).innerHTML.replace('&nbsp;','');
	}
	var ids = document.getElementById(destinationidfield).value;
	if((ids+";").indexOf(id+";")<=-1){
	  document.getElementById(destinationidfield).value = ids+";"+id;
	  
	  if(document.getElementById(destinationtextfield).innerHTML.length > 0){
		if(!document.getElementById(destinationtextfield).innerHTML.endsWith("| ")){
          document.getElementById(destinationtextfield).innerHTML+= " | ";
	    }
	  }
	  
	  document.getElementById(destinationtextfield).innerHTML+= "<span style='white-space: nowrap;'><a href='javascript:deleteKeyword(\""+destinationidfield+"\",\""+destinationtextfield+"\",\""+id+"\");'><img width='8' src='<c:url value="/_img/themes/default/erase.png"/>' class='link' style='vertical-align:-1px'/></a> <b>"+label+"</b></span> | ";
	}
  }

  function storekeywordsubtype(s){
    var params = "";
    var today = new Date();
    var url = '<c:url value="/healthrecord/ajax/storeKeywordSubtype.jsp"/>'+
              '?subtype='+s;
    new Ajax.Request(url,{
      method: "POST",
      parameters: params,
      onSuccess: function(resp){
    	  selectKeywords(document.getElementById("activeDestinationIdField").value,
    			  document.getElementById("activeDestinationTextField").value,
    			  document.getElementById("activeLabeltype").value,
    			  document.getElementById("activeDivld").value);
      },
      onFailure: function(){
      }
    });
  }

  <%-- DELETE KEYWORD --%>
  function deleteKeyword(destinationidfield,destinationtextfield,id){
	var newids = "";
	
	var ids = document.getElementById(destinationidfield).value.split(";");
	for(n=0; n<ids.length; n++){
	  if(ids[n].indexOf("$")>-1){
		if(id!=ids[n]){
		  newids+= ids[n]+";";
		}
	  }
	}
	
	document.getElementById(destinationidfield).value = newids;
	var newlabels = "";
	var labels = document.getElementById(destinationtextfield).innerHTML.split(" | ");
    for(n=0;n<labels.length;n++){
	  if(labels[n].trim().length>0 && labels[n].indexOf(id)<=-1){
	    newlabels+=labels[n]+" | ";
	  }
	}
    
	document.getElementById(destinationtextfield).innerHTML = newlabels;	
  }
  
  <%-- SET BP --%>
  function setBP(oObject,sbp,dbp){
    if(oObject.value.length>0){
      if(!isNumberLimited(oObject,40,300)){
        alertDialog("Web.Occup","out-of-bounds-value");
      }
      else if((sbp.length>0)&&(dbp.length>0)){
        isbp = document.getElementsByName(sbp)[0].value*1;
        idbp = document.getElementsByName(dbp)[0].value*1;
        if(idbp>isbp){
          alertDialog("Web.Occup","error.dbp_greather_than_sbp");
        }
      }
    }
  }

  <%-- SET HF --%> 
  function setHF(oObject){
    if(oObject.value.length>0){
      if(!isNumberLimited(oObject,30,300)){
        alertDialog("web.occup","out-of-bounds-value");
      }
    }
  }
  
  <%-- CALCULATE BMI --%>
  function calculateBMI(){
    var _BMI = 0;
    var heightInput = document.getElementById('height');
    var weightInput = document.getElementById('weight');

    if(heightInput.value > 0){
      _BMI = (weightInput.value * 10000) / (heightInput.value * heightInput.value);
      if (_BMI > 100 || _BMI < 5){
        document.getElementsByName('BMI')[0].value = "";
      }
      else {
        document.getElementsByName('BMI')[0].value = Math.round(_BMI*10)/10;
      }
      var wfl=(weightInput.value*1/heightInput.value*1);
      if(wfl>0){
    	  document.getElementById('WFL').value = wfl.toFixed(2);
    	  checkWeightForHeight(heightInput.value,weightInput.value);
      }
    }
  }

	function checkWeightForHeight(height,weight){
	      var today = new Date();
	      var url= '<c:url value="/ikirezi/getWeightForHeight.jsp"/>?height='+height+'&weight='+weight+'&gender=<%=activePatient.gender%>&ts='+today;
	      new Ajax.Request(url,{
	          method: "POST",
	          postBody: "",
	          onSuccess: function(resp){
	              var label = eval('('+resp.responseText+')');
	    		  if(label.zindex>-999){
	    			  if(label.zindex<-4){
	    				  document.getElementById("WFL").className="darkredtext";
	    				  document.getElementById("wflinfo").title="Z-index < -4: <%=getTranNoLink("web","severe.malnutrition",sWebLanguage).toUpperCase()%>";
	    				  document.getElementById("wflinfo").style.display='';
	    			  }
	    			  else if(label.zindex<-3){
	    				  document.getElementById("WFL").className="darkredtext";
	    				  document.getElementById("wflinfo").title="Z-index = "+(label.zindex*1).toFixed(2)+": <%=getTranNoLink("web","severe.malnutrition",sWebLanguage).toUpperCase()%>";
	    				  document.getElementById("wflinfo").style.display='';
	    			  }
	    			  else if(label.zindex<-2){
	    				  document.getElementById("WFL").className="orangetext";
	    				  document.getElementById("wflinfo").title="Z-index = "+(label.zindex*1).toFixed(2)+": <%=getTranNoLink("web","moderate.malnutrition",sWebLanguage).toUpperCase()%>";
	    				  document.getElementById("wflinfo").style.display='';
	    			  }
	    			  else if(label.zindex<-1){
	    				  document.getElementById("WFL").className="yellowtext";
	    				  document.getElementById("wflinfo").title="Z-index = "+(label.zindex*1).toFixed(2)+": <%=getTranNoLink("web","light.malnutrition",sWebLanguage).toUpperCase()%>";
	    				  document.getElementById("wflinfo").style.display='';
	    			  }
	    			  else if(label.zindex>2){
	    				  document.getElementById("WFL").className="orangetext";
	    				  document.getElementById("wflinfo").title="Z-index = "+(label.zindex*1).toFixed(2)+": <%=getTranNoLink("web","obesity",sWebLanguage).toUpperCase()%>";
	    				  document.getElementById("wflinfo").style.display='';
	    			  }
	    			  else if(label.zindex>1){
	    				  document.getElementById("WFL").className="yellowtext";
	    				  document.getElementById("wflinfo").title="Z-index = "+(label.zindex*1).toFixed(2)+": <%=getTranNoLink("web","light.obesity",sWebLanguage).toUpperCase()%>";
	    				  document.getElementById("wflinfo").style.display='';
	    			  }
	    			  else{
	    				  document.getElementById("WFL").className="text";
	    				  document.getElementById("wflinfo").style.display='none';
	    			  }
	    		  }
    			  else{
    				  document.getElementById("WFL").className="text";
    				  document.getElementById("wflinfo").style.display='none';
    			  }
	          },
	          onFailure: function(){
	          }
	      }
		  );
	  	}

	  function searchEncounter(){
	      openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&Varcode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
	  }
	  
	  calculateBMI();
	  if(<%=((TransactionVO)transaction).getServerId()%>==1 && document.getElementById('encounteruid').value=='' <%=((TransactionVO)transaction).getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERRAL_SOURCESITE").length()==0 && request.getParameter("nobuttons")==null?"":" && 1==0"%>){
			alertDialogDirectText('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
			searchEncounter();
	  }	
	  function triage(){
		  
	  }
	  function differentialDiagnosis(){
			document.getElementById("openaiwait").innerHTML="&nbsp;<img height='14px' src='<c:url value="/_img/icons/icon-search.gif"/>'/>";        
		  	var params = serializeForm(transactionForm);
		  	var url = '<c:url value="/ikirezi/checkMalariaDifferentialDiagnosis.jsp"/>';
		    new Ajax.Request(url,{
			      parameters: params,
			      onSuccess: function(resp){
			    	  document.getElementById("openaiwait").innerHTML="";
			    	  openPopup("<c:url value="ikirezi/showOpenAIResult.jsp"/>&attribute=malariaDifferentialDiagnosis",600,400);
			      }
			});
	  }
	  function malariaprobability(){
	  		document.getElementById("openaiwait").innerHTML="&nbsp;<img height='14px' src='<c:url value="/_img/icons/icon-search.gif"/>'/>";        
		  	var params = serializeForm(transactionForm);
		  	var url = '<c:url value="/ikirezi/checkMalariaProbability.jsp"/>';
		    new Ajax.Request(url,{
			      parameters: params,
			      onSuccess: function(resp){
			    	  document.getElementById("openaiwait").innerHTML="";
			    	  openPopup("<c:url value="ikirezi/showOpenAIResult.jsp"/>&attribute=malariaProbabilityAnalysis",600,400);
			      }
			});
	  }
	  function serializeForm(form){
		  var parameters="";
		  var elements = form.getElementsByTagName("*");
		  for(n=0;n<elements.length;n++){
			  if(elements[n].id.length>0 && elements[n].tagName.toLowerCase()=='input' && elements[n].type.toLowerCase()=='radio' && elements[n].checked){
			  	parameters+=elements[n].id+"=1&";
			  }
			  else if(elements[n].id.length>0 && elements[n].tagName.toLowerCase()=='input' && elements[n].type.toLowerCase()=='checkbox' && elements[n].checked){
				parameters+=elements[n].id+"=1&";
			  }
			  else if(elements[n].id.length>0 && elements[n].tagName.toLowerCase()=='input' && (elements[n].type.toLowerCase()=='text' || elements[n].type.toLowerCase()=='time') && elements[n].value.length>0){
				parameters+=elements[n].id+"="+elements[n].value+"&";
			  }
			  else if(elements[n].id.length>0 && elements[n].tagName.toLowerCase()=='select' && elements[n].value.length>0){
				parameters+=elements[n].id+"="+elements[n].value+"&";
			  }
		  }
		  return parameters;
	  }
	  activateTab(1);
	  malariaCare(false);
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        