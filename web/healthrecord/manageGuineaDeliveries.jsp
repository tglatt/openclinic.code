<%@page import="
                be.openclinic.system.Transaction
              " %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission(out,"mshp.delivery","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>" colspan="2">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)' onchange='calculateAge();'>
                <script>writeTranDate();</script>
            </td>
        </tr>
 <% TransactionVO tran = (TransactionVO)transaction; %>
        <tr>
        	<td width="100%" valign='top'>
	        	<table width='100%'>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","partogram.number",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_DELIVERIES_PARTOGRAMNUMBER", 10) %></td>
			            <td class='admin'><%=getTran(request,"web","arrivaldate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			                <%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_MSAS_DELIVERIES_ARRIVALDATE", sWebLanguage, sCONTEXTPATH) %>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","gestity",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_GESTITY", 5) %>
			            </td>
			            <td class='admin'><%=getTran(request,"web","parity",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_PARITY", 5) %>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","last.child.status",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_LASTCHILDSTATUS", "msas.lastchildstatus", sWebLanguage, "") %>
			            </td>
			            <td class='admin'><%=getTran(request,"web","presentation",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_PRESENTATION", "msas.presentation", sWebLanguage, "") %>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","deliverydate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			                <%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYDATE", sWebLanguage, sCONTEXTPATH) %>
			            </td>
			            <td class='admin'><%=getTran(request,"web","delivery.location",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYLOCATION", "gn.deliverylocation.hospital", sWebLanguage, "") %>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","weeksofpregnancy",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_WEEKS", 10, 1, 50, sWebLanguage) %></td>
			            <td class='admin' nowrap><%=getTran(request,"web","vaccinationcomplete",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_VACCINATIONCOMPLETE", sWebLanguage, false, "", "") %>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","namedeliverer",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
							<%= SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERERNAME", 30) %>
						</td>
			            <td class='admin'><%=getTran(request,"web","qualification",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_QUALIFICATION", "msas.qualification", sWebLanguage, "") %>
			                <%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_MSAS_DELIVERIES_PARTOGRAMME", "") %><%=getTran(request,"web","partogrammedone",sWebLanguage) %>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","uterotonicum",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes(tran, request, "uterotonicum", "ITEM_TYPE_MSAS_DELIVERIES_GATPA", sWebLanguage, false) %>
			            </td>
			            <td class="admin" rowspan='2'><%=getTran(request,"web", "complications", sWebLanguage)%></td>
			            <td class="admin2" width='35%' rowspan='2'>
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.delivery.directcomplications", "ITEM_TYPE_MSAS_DELIVERIES_DIRECTCOMPLICATIONS", sWebLanguage, false) %>
			            	<br/><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "msas.delivery.indirectcomplications", "ITEM_TYPE_MSAS_DELIVERIES_INDIRECTCOMPLICATIONS", sWebLanguage, false) %>
			                <br/>
           					 <%=getTran(request,"web", "other", sWebLanguage)%>: <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_DELIVERIES_COMPLICATIONS", 30, 1)%>
			                <br/>
           					 <%=getTran(request,"delivery", "treated", sWebLanguage)%>: <%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEMTYPE_COMPLICATIONS_TREATED", sWebLanguage, false, "", "")%>
           					 &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;<%=getTran(request,"web", "referred", sWebLanguage)%>: <%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEMTYPE_COMPLICATIONS_REFERRAL", sWebLanguage, false, "", "")%>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","status.mother",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_MOTHERSTATUS", "gn.motherstatus", sWebLanguage, "onchange='checkMotherStatus();'") %><br>
			                <span id='deceased'>
			                	<%=getTran(request,"web","auditdate",sWebLanguage) %>: <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_MOTHER_DEATH_AUDIT_DATE", sWebLanguage, sCONTEXTPATH) %><br/>
								<%=getTran(request,"web","causeofdeath",sWebLanguage) %>: <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_MOTHER_CAUSEOFDEATH", "gn.delivery.causeofdeath", sWebLanguage, "") %>			                	
			                </span>
			            </td>
					</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","ptme",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes(tran, request, "mspls.acc.ptme", "ITEM_TYPE_MSAS_DELIVERIES_PTME", sWebLanguage, false) %>
						</td>			            
	        		</tr>
	        		
	        		<tr>
						<td class='admin'><%=getTran(request,"web","breastfeedingcounseling",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_BREASTFEEDING_COUNSELING", sWebLanguage, false, "", "") %></td>
						<td class='admin'><%=getTran(request,"web","immediatecontraception",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_IMMEDIATECONTRACEPTION", sWebLanguage, false, "", "") %></td>
		           	</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","familyplanning",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan="3">
			            	<%=getTran(request,"web","counseling",sWebLanguage)%>
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_FPCOUNSELING", sWebLanguage, false, "", "")%>
			            	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=getTran(request,"web","method",sWebLanguage)%>
			            	<%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_FPMETHOD", 40) %>
			            </td>
	        		</tr>
	        		 
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","dischargedate",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			               	<%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_MSAS_DELIVERIES_DISCHARGEDATE", sWebLanguage, sCONTEXTPATH) %>
			            </td>
			            <td class="admin" ><%=getTran(request,"web","admissionduration",sWebLanguage)%></td>
           	 			<td class="admin2"><%=SH.writeDefaultNumericInput(session, tran,"ITEM_TYPE_MSAS_DELIVERIES_ADMISSIONDURATION" , 3, 1, 100,sWebLanguage , "", "")%></td>
           	 		</tr>
			        <tr>
			            <td class="admin"><%=getTran(request,"web", "consultation.observations", sWebLanguage)%></td>
			            <td colspan="3" class="admin2">
			                <%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_MSAS_DELIVERIES_OBSERVATIONS", 50, 2) %>
			            </td>
			        </tr>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child",sWebLanguage)%>&nbsp;</td>
	        		</tr>
	        		<tr>
			            <td class="admin"><%=getTran(request,"web","child.cried",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_CRIED", sWebLanguage, false, "", "")%>
			            </td>
			            <td class='admin'><%=getTran(request,"web","childstatus",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS", "gn.delivery.childstatus", sWebLanguage, "onchange='checkChildStatus();calculateBirths();'") %>
   			                <span id='deceasedchild'><%=getTran(request,"web","auditdate",sWebLanguage) %>: <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_CHILD_DEATH_AUDIT_DATE", sWebLanguage, sCONTEXTPATH) %></span>
			            </td>
	        		</tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","infectionrisk",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_INFECTIONRISK", sWebLanguage, false, "", "")%>
			            </td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2' >
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE", 10, 5, 50, sWebLanguage) %> cm
			            </td>
	        		</tr>
         		    <tr>
			            <td class='admin'><%=getTran(request,"web","deliverytype",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE", "msas.deliverytype.cs", sWebLanguage, "") %>
			                &nbsp;<%=getTran(request,"msas","comment",sWebLanguage) %>: 
			                <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_COMMENT", 20) %>
			            </td>
       		   			<td class='admin'><%=getTran(request,"web","newbornantibiotic",sWebLanguage)%>&nbsp;</td>
       			 		<td class="admin2"  ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNANTIBIOTIC", sWebLanguage, false, "", "") %></td>
			        </tr>
			        <tr>
       		   			<td class='admin'><%=getTran(request,"web","newbornrevived",sWebLanguage)%>&nbsp;</td>
					 	<td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "gn.reanimation","ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREVIVED", sWebLanguage, false, "", "") %></td>
       		   			<td class='admin'><%=getTran(request,"web","newbornreferral",sWebLanguage)%>&nbsp;</td>
	            		<td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request,"yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREFERRAL", sWebLanguage, false, "", "") %></td> 
			        </tr>
			        <tr>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.headcircumference",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEADCIRCUMFERENCE", 10, 10, 100, sWebLanguage) %> cm
			            </td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.thoraxcircumference",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_THORAXCIRCUMFERENCE", 10, 10, 200, sWebLanguage) %> cm
			            </td>
			        </tr>
	        		<tr>
			            <td class='admin'><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER", "msas.gender", sWebLanguage, "") %>
			            </td>
			            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_CHILDWEIGHT", 10, 0.1, 10, sWebLanguage) %></td>
	        		</tr>
	        				           
			           	<tr>
			           	<td class='admin'><%=getTran(request,"web","delivery.child.immediats",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.essentialcare", "ITEM_TYPE_MSAS_DELIVERIES_CARE_IMMEDIAT", sWebLanguage, false) %>
						</td>
			            <td class='admin'><%=getTran(request,"web","delivery.child.care",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.care", "ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED", sWebLanguage, false) %>
						</td>
									            
 		            </tr>
	        		<tr>
	        		 	<td class='admin'>APGAR A1&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_APGAR_A1", sWebLanguage, "", 0, 10) %></td>
						<td class='admin'>APGAR A5&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_APGAR_A5", sWebLanguage, "", 0, 10) %></td>
			        </tr>
	        		<tr>
	        		 	<td class='admin'><%=getTran(request,"web","kangoroomethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO", sWebLanguage, false, "", "") %></td>
						<td class='admin'><%=getTran(request,"web","newbornweightkangoroomethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_NEWBORN", sWebLanguage, false, "", "") %></td>
			        </tr>
	        		<tr>
	        		 	<td class='admin'><%=getTran(request,"web","complications",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes(tran, request, "gn.newborncomplications", "ITEM_TYPE_DELIVERY_NEWBORNCOMPLICATIONS", sWebLanguage, false)%>
			            	<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_DELIVERY_COMPLICATIONS_CHILD", 100, 1) %>
			            <br>
			            </td>
			        </tr>
	        		<%
	        			String sChild2Display="none",sChild3Display="none";
	        			Iterator items = ((TransactionVO)transaction).getItems().iterator();
	        			while(items.hasNext()){
	        				ItemVO item = (ItemVO)items.next();
	        				if(item.getType().endsWith("_2") && SH.c(item.getValue()).length()>0){
	        					sChild2Display="";
	        				}
	        				else if(item.getType().endsWith("_3") && SH.c(item.getValue()).length()>0){
	        					sChild3Display="";
	        				}
	        			}
	        		%>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child2",sWebLanguage)%>&nbsp;<img id='img_child2' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='if(this.src.indexOf("plus.png")>-1){this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png";document.getElementById("child2").style.display="";}else{this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png";document.getElementById("child2").style.display="none";}'>&nbsp;</td>
	        		</tr>
	        		<tbody id='child2' style='display: <%=sChild2Display%>'>
		        		<tr>
				            <td class="admin"><%=getTran(request,"web","child.cried",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_CRIED_2", sWebLanguage, false, "", "")%>
				            </td>
				            <td class='admin'><%=getTran(request,"web","childstatus",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2", "gn.delivery.childstatus", sWebLanguage, "onchange='checkChildStatus();calculateBirths();'") %>
	  			                <span id='deceasedchild2'><%=getTran(request,"web","auditdate",sWebLanguage) %>: <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_CHILD_DEATH_AUDIT_DATE_2", sWebLanguage, sCONTEXTPATH) %></span>
				            </td>
		        		</tr>
		        		<tr>
				            <td class='admin'><%=getTran(request,"web","infectionrisk",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_INFECTIONRISK_2", sWebLanguage, false, "", "")%>
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2' colspan='3'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE_2", 10, 5, 50, sWebLanguage) %> cm
				            </td>
		        		</tr>
		        		 	
			           <tr>
				            <td class='admin'><%=getTran(request,"web","deliverytype",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_2", "msas.deliverytype.cs", sWebLanguage, "") %>
				                &nbsp;<%=getTran(request,"msas","comment",sWebLanguage) %>: 
				                <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_COMMENT_2", 20) %>
				            </td>
			             
	        		   			<td class='admin'><%=getTran(request,"web","newbornantibiotic",sWebLanguage)%>&nbsp;</td>
	        			 		<td class="admin2"  ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNANTIBIOTIC_2", sWebLanguage, false, "", "") %></td>
	        		 				 		            
			           </tr>
			           <tr>
	        		   				<td class='admin'><%=getTran(request,"web","newbornrevived",sWebLanguage)%>&nbsp;</td>
							 		<td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "gn.reanimation","ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREVIVED_2", sWebLanguage, false, "", "") %></td>
	        		   			<td class='admin'><%=getTran(request,"web","newbornreferral",sWebLanguage)%>&nbsp;</td>
			            		<td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request,"yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREFERRAL_2", sWebLanguage, false, "", "") %></td> 
	        			            
			           </tr>
				        <tr>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.headcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEADCIRCUMFERENCE_2", 10, 10, 100, sWebLanguage) %> cm
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.thoraxcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_THORAXCIRCUMFERENCE_2", 10, 10, 200, sWebLanguage) %> cm
				            </td>
				        </tr>
		        		<tr>
				            <td class='admin'><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER_2", "msas.gender", sWebLanguage, "") %>
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_CHILDWEIGHT_2", 10, 0.1, 10, sWebLanguage) %></td>
		        		</tr>
		        		  	<tr>
			           	<td class='admin'><%=getTran(request,"web","careimmediats",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.essentialcare", "ITEM_TYPE_MSAS_DELIVERIES_CARE_IMMEDIAT_2", sWebLanguage, false) %>
						</td>
			            <td class='admin'><%=getTran(request,"web","careoffered",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.care", "ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED_2", sWebLanguage, false) %>
						</td>
									            
			           </tr>
	        		<tr>
	        		 	<td class='admin'>APGAR A1&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_APGAR_A1_2", sWebLanguage, "", 0, 10) %></td>
						<td class='admin'>APGAR A5&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_APGAR_A5_2", sWebLanguage, "", 0, 10) %></td>
			        </tr>
		        		<tr>
				           			            
				            <td class='admin'><%=getTran(request,"web","kangoroomethod",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_2", sWebLanguage, false, "", "") %></td>
		        		
							<td class='admin'><%=getTran(request,"web","newbornweightkangoroomethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_NEWBORN_2", sWebLanguage, false, "", "") %></td>
	        				            
			           	</tr>
	        		<tr>
	        		 	<td class='admin'><%=getTran(request,"web","complications",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes(tran, request, "gn.newborncomplications", "ITEM_TYPE_DELIVERY_NEWBORNCOMPLICATIONS_2", sWebLanguage, false)%>
			            	<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_DELIVERY_COMPLICATIONS_CHILD_2", 100, 1) %>
			            </td>
			        </tr>
				    </tbody>
	        		<tr class='admin'>
			            <td colspan='4'><%=getTran(request,"web","child3",sWebLanguage)%>&nbsp;<img id='img_child2' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png' onclick='if(this.src.indexOf("plus.png")>-1){this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png";document.getElementById("child3").style.display="";}else{this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png";document.getElementById("child3").style.display="none";}'>&nbsp;</td>
	        		</tr>
	        		<tbody id='child3' style='display: <%=sChild3Display%>'>
		        		<tr>
				            <td class="admin"><%=getTran(request,"web","child.cried",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_CRIED_3", sWebLanguage, false, "", "")%>
				            </td>
				            <td class='admin'><%=getTran(request,"web","childstatus",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				                <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3", "gn.delivery.childstatus", sWebLanguage, "onchange='checkChildStatus();calculateBirths();'") %>
	   			                <span id='deceasedchild3'><%=getTran(request,"web","auditdate",sWebLanguage) %>: <%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_CHILD_DEATH_AUDIT_DATE_3", sWebLanguage, sCONTEXTPATH) %></span>
				            </td>
		        		</tr>
		        		<tr>
				            <td class='admin'><%=getTran(request,"web","infectionrisk",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_INFECTIONRISK_3", sWebLanguage, false, "", "")%>
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.armcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2' colspan='3'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARM_CIRCUMFERENCE_3", 10, 5, 50, sWebLanguage) %> cm
				            </td>
		        		</tr>
		        		 	
			           
			           <tr>
				            <td class='admin'><%=getTran(request,"web","deliverytype",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_3", "msas.deliverytype.cs", sWebLanguage, "") %>
				                &nbsp;<%=getTran(request,"msas","comment",sWebLanguage) %>: 
				                <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_DELIVERYTYPE_COMMENT_3", 20) %>
				            </td>
			             
	        		   			<td class='admin'><%=getTran(request,"web","newbornantibiotic",sWebLanguage)%>&nbsp;</td>
	        			 		<td class="admin2"  ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNANTIBIOTIC_3", sWebLanguage, false, "", "") %></td>
	        		 				 		            
			           </tr>
			           <tr>
	        		   				<td class='admin'><%=getTran(request,"web","newbornrevived",sWebLanguage)%>&nbsp;</td>
							 		<td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "gn.reanimation","ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREVIVED_3", sWebLanguage, false, "", "") %></td>
	        		   			<td class='admin'><%=getTran(request,"web","newbornreferral",sWebLanguage)%>&nbsp;</td>
			            		<td class="admin2" ><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request,"yesno", "ITEM_TYPE_MSAS_DELIVERIES_NEWBORNREFERRAL_3", sWebLanguage, false, "", "") %></td> 
	        			            
			           </tr>
				        <tr>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.headcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_HEADCIRCUMFERENCE_3", 10, 10, 100, sWebLanguage) %> cm
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.thoraxcircumference",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'>
				            	<%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_THORAXCIRCUMFERENCE_3", 10, 10, 200, sWebLanguage) %> cm
				            </td>
				        </tr>
		        		<tr>
				            <td class='admin'><%=getTran(request,"web","gender",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2">
				            	<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_MSAS_DELIVERIES_CHILDGENDER_3", "msas.gender", sWebLanguage, "") %>
				            </td>
				            <td class='admin'><%=getTran(request,"Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
				            <td class='admin2'><%=SH.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BIOMETRY_CHILDWEIGHT_3", 10, 0.1, 10, sWebLanguage) %></td>
		        		</tr>
		        		 	<tr>
			           	<td class='admin'><%=getTran(request,"web","careimmediats",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.essentialcare", "ITEM_TYPE_MSAS_DELIVERIES_CARE_IMMEDIAT_3", sWebLanguage, false) %>
						</td>
			            <td class='admin'><%=getTran(request,"web","careoffered",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2">
			            	<%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "delivery.child.care", "ITEM_TYPE_MSAS_DELIVERIES_CARE_OFFERED_3", sWebLanguage, false) %>
						</td>
									            
			           </tr>
	        		<tr>
	        		 	<td class='admin'>APGAR A1&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_APGAR_A1_3", sWebLanguage, "", 0, 10) %></td>
						<td class='admin'>APGAR A5&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_APGAR_A5_3", sWebLanguage, "", 0, 10) %></td>
			        </tr>
		        		<tr>
				            			            
				            <td class='admin'><%=getTran(request,"web","kangoroomethod",sWebLanguage)%>&nbsp;</td>
				            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_3", sWebLanguage, false, "", "") %></td>
		        			
							<td class='admin'><%=getTran(request,"web","newbornweightkangoroomethod",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2"><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_MSAS_DELIVERIES_KANGOROO_NEWBORN_3", sWebLanguage, false, "", "") %></td>
	        				            
			           	</tr>
	        		<tr>
	        		 	<td class='admin'><%=getTran(request,"web","complications",sWebLanguage)%>&nbsp;</td>
			            <td class="admin2" colspan='3'>
			            	<%=SH.writeDefaultCheckBoxes(tran, request, "gn.newborncomplications", "ITEM_TYPE_DELIVERY_NEWBORNCOMPLICATIONS_3", sWebLanguage, false)%>
			            	<%=SH.writeDefaultTextArea(session, tran, "ITEM_TYPE_DELIVERY_COMPLICATIONS_CHILD_3", 40, 1) %>
			            </td>
			        </tr>
				    </tbody>
					<tr>
						<td valign="top" colspan="4">
					      	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
						</td>
					</tr>
	            </table>
	        </td>
        </tr>
    </table>
    <%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_DEADBORNS_FRESH") %>
    <%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_DEADBORNS_MACERTATED") %>
    <%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_LIVEBORNS") %>
    <%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_DECEASED") %>
    <%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_LOWWEIGHTS") %>
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"msas.registry.deliveries",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  function calculateBirths(){
	  liveborns=0;
	  deadfresh=0;
	  deadmacerated=0;
	  deceased=0;
	  lowweights=0;
	  if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3").value=='vbp'){
		  liveborns++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3").value=='mnf'){
		  deadfresh++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3").value=='mnm'){
		  deadmacerated++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3").value=='dcd' || document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3").value=='dcd2'){
		  deceased++;
	  }
	  if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2").value=='vbp'){
		  liveborns++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2").value=='mnf'){
		  deadfresh++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2").value=='mnm'){
		  deadmacerated++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2").value=='dcd' || document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2").value=='dcd2'){
		  deceased++;
	  }
	  if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS").value=='vbp'){
		  liveborns++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS").value=='mnf'){
		  deadfresh++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS").value=='mnm'){
		  deadmacerated++;
	  }
	  else if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS").value=='dcd' || document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS").value=='dcd2'){
		  deceased++;
	  }
	  if(document.getElementById("ITEM_TYPE_BIOMETRY_CHILDWEIGHT").value.length>0 && document.getElementById("ITEM_TYPE_BIOMETRY_CHILDWEIGHT").value.replace(",",".")*1<2.5){
		  lowweights++;
	  }
	  if(document.getElementById("ITEM_TYPE_BIOMETRY_CHILDWEIGHT_2").value.length>0 && document.getElementById("ITEM_TYPE_BIOMETRY_CHILDWEIGHT_2").value.replace(",",".")*1<2.5){
		  lowweights++;
	  }
	  if(document.getElementById("ITEM_TYPE_BIOMETRY_CHILDWEIGHT_3").value.length>0 && document.getElementById("ITEM_TYPE_BIOMETRY_CHILDWEIGHT_3").value.replace(",",".")*1<2.5){
		  lowweights++;
	  }
	  document.getElementById("ITEM_TYPE_DEADBORNS_FRESH").value=deadfresh;
	  document.getElementById("ITEM_TYPE_DEADBORNS_MACERTATED").value=deadmacerated;
	  document.getElementById("ITEM_TYPE_LIVEBORNS").value=liveborns;
	  document.getElementById("ITEM_TYPE_DECEASED").value=deceased;
	  document.getElementById("ITEM_TYPE_LOWWEIGHTS").value=lowweights;
  }

  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&Varcode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
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
  function checkMotherStatus(){
	  if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_MOTHERSTATUS").value>2){
		  document.getElementById("deceased").style.display='';
	  }
	  else{
		  document.getElementById("deceased").style.display='none';
	  }
  }
  
  function checkChildStatus(){
	  if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS").value=='dcd' || document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS").value=='dcd2'){
		  document.getElementById("deceasedchild").style.display='';
	  }
	  else{
		  document.getElementById("deceasedchild").style.display='none';
	  }
	  if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2").value=='dcd' || document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_2").value=='dcd2'){
		  document.getElementById("deceasedchild2").style.display='';
	  }
	  else{
		  document.getElementById("deceasedchild2").style.display='none';
	  }
	  if(document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3").value=='dcd' || document.getElementById("ITEM_TYPE_MSAS_DELIVERIES_CHILDSTATUS_3").value=='dcd2'){
		  document.getElementById("deceasedchild3").style.display='';
	  }
	  else{
		  document.getElementById("deceasedchild3").style.display='none';
	  }
  }
  
  function calculateDuration(){
    var arrivaldate = new Date();
    var d1 = document.getElementById('arrivaldate').value.split("/");
    if(d1.length == 3){
        // actual transaction date
        arrivaldate.setDate(d1[0]);
        arrivaldate.setMonth(d1[1] - 1);
        arrivaldate.setFullYear(d1[2]);
        var disdate = new Date();
        var d1 = document.getElementById('dischargedate').value.split("/");
        if(d1.length == 3){
        	disdate.setDate(d1[0]);
        	disdate.setMonth(d1[1] - 1);
        	disdate.setFullYear(d1[2]);
            //Calculate number of days elapsed between admission date and discharge date 
            var timeElapsed = disdate.getTime() - arrivaldate.getTime();
            timeElapsed = timeElapsed / (1000 * 3600 * 24);
    		if (!isNaN(timeElapsed) && timeElapsed >= 0) {
    			document.getElementById("admissionduration").innerHTML=timeElapsed;
    			document.getElementById("admduration").value=timeElapsed;
    		}
        }
    }
  }
  checkMotherStatus();
  checkChildStatus();
  calculateBirths();
  calculateDuration();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>