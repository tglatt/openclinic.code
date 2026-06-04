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
<%!
 
    private class TransactionID {
        public int transactionid = 0;
        public int serverid = 0;
    }

	private String getLastLabresult(TransactionVO transaction,String loinc,String personid){
		String s="&nbsp;&nbsp;";
		String sDateMin=SH.formatDate(new java.util.Date(transaction.getUpdateTime().getTime()-SH.getTimeDay()*7));
		String sDateMax=SH.formatDate(new java.util.Date(transaction.getUpdateTime().getTime()+SH.getTimeDay()));
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
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <% TransactionVO tran = (TransactionVO)transaction; %>
    <table class="list" width="100%" cellspacing="1" cellpadding='0'>
	     <tr class='admin'><td colspan='4'><%=getTran(request,"web","referral",sWebLanguage) %></td></tr>
	     <tr>
        	<td class='admin'><%=getTran(request,"web","patientorigin",sWebLanguage) %></td>
        	<td class='admin2' colspan='3'>
        		<%=SH.writeDefaultRadioButtons(tran, request, "gfmalaria.origin", "ITEM_TYPE_ORIGIN", sWebLanguage, false, "onchange='checkFields()'", "") %>
        	</td>
        </tr>
        <tr id='referralsection' style='display: none'>
        	<td colspan='4'>
        		<table width='100%'>
        			<tr>
        				<td class='admin' nowrap><%=getTran(request,"web","referraldatetime",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2'>
        					<%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_REFERRALDATETIME", sWebLanguage, sCONTEXTPATH) %>
						</td>
        				<td class='admin' nowrap><%=getTran(request,"web","referraldocument",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2'>
        					<%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_REFERRALDOCUMENT", sWebLanguage, false, "", "") %>
						</td>
        			</tr>
        			<tr>
        				<td class='admin' nowrap><%=getTran(request,"web","referringfacility",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2'>
        					<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_REFERRINGFACILITY", 40) %>
						</td>
        				<td class='admin' nowrap><%=getTran(request,"web","meansoftransport",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2'>
        					<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_MEANSOFTRANSPORT", "gfmalaria.transport", sWebLanguage, "onchange='checkFields()'") %>
        					<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MEANSOFTRANSPORT_OTHER", 20) %>
						</td>
        			</tr>
        			<tr>
        				<td class='admin' nowrap><%=getTran(request,"web","referrantqualification",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2'>
        					<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_REFERRANTQUALIFICATION", "gfmalaria.qualification", sWebLanguage,"") %>
						</td>
        				<td class='admin' nowrap><%=getTran(request,"web","receiverqualification",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2'>
        					<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_RECEIVERQUALIFICATION", "gfmalaria.qualification", sWebLanguage,"") %>
						</td>
        			</tr>
        			<tr>
        				<td class='admin' nowrap><%=getTran(request,"web","pretransfertreatment",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2'>
        					<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_PRETRANSFERTREATMENT", "gfmalaria.pretransfertreatment", sWebLanguage,"") %>
        					<span id='pretransferposology'><%=getTran(request,"web","posology",sWebLanguage)%>: <%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_PRETRANSFERPOSOLOGY", 20) %></span>
						</td>
        				<td class='admin' nowrap><%=getTran(request,"web","malariapicode",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2'>
        					<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MALARIYAPI_REFERRALCODE", 20) %>
						</td>
        			</tr>
        			<tr>
        				<td class='admin' nowrap><%=getTran(request,"web","reasonsforreferral",sWebLanguage) %>&nbsp;</td>
        				<td class='admin2' colspan='3'>
        					<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.severitysigns", "ITEM_TYPE_REFERRALSEVERITYSIGNS", sWebLanguage, false, "onchange='checkFields()'") %>
        					<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_REFERRALSEVERITYSIGNS_OTHER", 20) %>
        				</td>
        			</tr>
        			<tr>
        				<td class='admin'><%=getTran(request,"web","reasonsforreferralother",sWebLanguage) %></td>
        				<td class='admin2' colspan='3'>
        					<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.othersigns", "ITEM_TYPE_REFERRALOTHERSIGNS", sWebLanguage, false, "onchange='checkFields()'") %>
        					<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_REFERRALOTHERSIGNS_OTHER", 20) %>
        				</td>
        			</tr>
        			<tr>
        				<td class='admin'><%=getTran(request,"web","testsperformed",sWebLanguage) %></td>
        				<td class='admin2' colspan='3'>
        					<%=getTran(request,"web","rapidtest",sWebLanguage) %>: <%=SH.writeDefaultRadioButtons(tran, request, "posneg", "ITEM_TYPE_REF_RAPIDTEST", sWebLanguage, false, "", "") %>
        					&nbsp;&nbsp;|&nbsp;&nbsp;
        					<%=getTran(request,"web","thiksmear",sWebLanguage) %>: <%=SH.writeDefaultRadioButtons(tran, request, "posneg", "ITEM_TYPE_REF_THICKSMEAR", sWebLanguage, false, "", "") %>
        				</td>
        			</tr>
        		</table>
        	</td>
        </tr>
	    <tr class='admin'><td colspan='4'><%=getTran(request,"web","signsandsymptoms",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin' nowrap><%=getTran(request,"web","severitysigns",sWebLanguage) %>&nbsp;</td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.severitysigns", "ITEM_TYPE_SEVERITYSIGNS", sWebLanguage, false, "onchange='checkFields()'") %>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_SEVERITYSIGNS_OTHER", 20) %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","othersigns",sWebLanguage) %></td>
			<td class='admin2'>
				<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.othersigns2", "ITEM_TYPE_OTHERSIGNS", sWebLanguage, false, "onchange='checkFields()'") %>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_OTHERSIGNS_OTHER", 20) %>
			</td>
	       <%if(activePatient.gender.equalsIgnoreCase("f") && activePatient.getAge()>=12 && activePatient.getAge()<=60){ %>
	        	<td class='admin'><%=getTran(request,"web","pregnantwomen",sWebLanguage) %></td>
	        	<td class='admin2'>
	        		<%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_PREGNANTWOMEN", sWebLanguage, false, "onchange='checkFields()'", "") %>
	        	</td>
	     <%}else{ %>
	     		<td class='admin2' colspan='2'/>
	     <%} %>
		</tr>
	    <tr class='admin'><td colspan='4'><%=getTran(request,"web","antecedents",sWebLanguage) %></td></tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","medicalhistory",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.medicalhistory", "ITEM_TYPE_MEDICALHISTORY", sWebLanguage, false, "onchange='checkFields()'") %>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_MEDICALHISTORY_OTHER", 20) %>
			</td>
		</tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","prevention",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.prevention", "ITEM_TYPE_PREVENTION", sWebLanguage, false, "onchange='checkFields()'") %>
			</td>
		</tr>
	    <tr class='admin'><td colspan='4'><%=getTran(request,"web","physicalexamination",sWebLanguage) %></td></tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","neurological",sWebLanguage) %></td>
			<td class='admin2' colspan='2'>
				<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.neurologic", "ITEM_TYPE_NEUROLOGIC", sWebLanguage, false, "") %>
			</td>
			<td class='admin2'>
				Glasgow: <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_GLASGOW", sWebLanguage, "", 3, 15)%>
				Blantyre: <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_BLANTYRE", sWebLanguage, "", 0, 5)%>
				AVPU: <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_AVPU","avpu", sWebLanguage, "")%>
			</td>
		</tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","respiratory",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.respiratory", "ITEM_TYPE_RESPIRATORY", sWebLanguage, false, "onchange='checkFields()'") %>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_RESPIRATORY_OTHER", 20) %>
			</td>
		</tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","cutaneomucous",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.skin", "ITEM_TYPE_SKIN", sWebLanguage, false, "") %>
			</td>
		</tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","digestif",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultCheckBoxes(tran, request, "gfmalaria.digestive", "ITEM_TYPE_DIGESTIVE", sWebLanguage, false, "onchange='checkFields()'") %>
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_DIGESTIVE_OTHER", 20) %>
			</td>
		</tr>
	    <tr id='obstetricssection'>
			<td class='admin' nowrap><%=getTran(request,"web","obstetrical",sWebLanguage) %></td>
			<td class='admin2' colspan='3'>
				<table width='100%'>
					<tr>
						<td width='18%'><%=getTran(request,"web","hu",sWebLanguage) %>: <%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_UTERUSHEIGHT", 5, 0, 30, sWebLanguage) %> cm</td>
						<td width='18%'><%=getTran(request,"web","fetalmovements",sWebLanguage) %>: <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_FETALMOVEMENTS", "yesno", sWebLanguage, "") %></td>
						<td width='18%'><%=getTran(request,"web","fetalhartsounds",sWebLanguage) %>: <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_FETALHEARTSOUNDS", "fetalheartsounds", sWebLanguage, "") %></td>
						<td width='18%'><%=getTran(request,"web","presentation",sWebLanguage) %>: <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_FETALPRESENTATION", "fetalpresentation", sWebLanguage, "") %></td>
						<td><%=getTran(request,"web","pelvis",sWebLanguage) %>: <%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_PELVIS", "gfmalaria.pelvis", sWebLanguage, "onchange='checkFields()'") %> <%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_PELVIS_OTHER", 20) %></td>
					</tr>
				</table>
			</td>
		</tr>
	    <tr class='admin'>
	    	<td colspan='3'><%=getTran(request,"web","labresults",sWebLanguage) %></td>
	    	<td ><img onclick='showMalariyaPiBarcode()' height='16px' src='<%=sCONTEXTPATH%>/_img/themes/default/malariyapi2.png'></td>
	    </tr>
	    <tr>
	    	<td class='admin2' colspan='4'>
	    		<table width='100%'>
	    			<tr>
	    				<td width='14%'><%=getTran(request,"gfmalaria","tr",sWebLanguage) %>: <b><%=getLastLabresult(tran, "70569-9",activePatient.personid) %></b></td>
	    				<td width='14%'><%=getTran(request,"gfmalaria","ge",sWebLanguage) %>: <b><%=getLastLabresult(tran, "32700-7",activePatient.personid)+" "+getLastLabresult(tran, "637-9",activePatient.personid) %></b></td>
	    				<td width='14%'><%=getTran(request,"gfmalaria","hb",sWebLanguage) %>: <b><%=getLastLabresult(tran, "718-7",activePatient.personid) %></b> g/dl</td>
	    				<td width='14%'><%=getTran(request,"gfmalaria","gr",sWebLanguage) %>: <b><%=getLastLabresult(tran, "789-8",activePatient.personid) %></b> x10^12</td>
	    				<td width='14%'><%=getTran(request,"gfmalaria","gb",sWebLanguage) %>: <b><%=getLastLabresult(tran, "26464-8",activePatient.personid) %></b> x10^9</td>
	    				<td width='14%'><%=getTran(request,"gfmalaria","urea",sWebLanguage) %>: <b><%=getLastLabresult(tran, "3091-6",activePatient.personid) %></b> mg/dl</td>
	    				<td><%=getTran(request,"gfmalaria","creat",sWebLanguage) %>: <b><%=getLastLabresult(tran, "1988-5",activePatient.personid) %></b> mg/dl</td>
	    			</tr>
	    		</table>
	    	</td>
	    </tr>
	    <tr class='admin'><td colspan='4'><%=getTran(request,"web","diagnosis",sWebLanguage) %></td></tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","presumeddiagnosis",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<%=SH.writeDefaultRadioButtons(tran, request, "gfmalaria.presumeddiagnosis", "ITEM_TYPE_PRESUMEDDIAGNOSIS", sWebLanguage, false, "onchange='checkFields()'", "") %>
			</td>
			<td class='admin' nowrap><%=getTran(request,"web","aiassistant",sWebLanguage) %><span id='openaiwait'/></td>
			<td class='admin2'>
				<a href='javascript:malariaprobability()'/><%=getTran(request,"web","malariaprobability",sWebLanguage) %></a>
				&nbsp;&nbsp;&nbsp;<a href='javascript:differentialDiagnosis()'/><%=getTran(request,"web","differentialdiagnosis",sWebLanguage) %></a>
			</td>
		</tr>
	    <tr class='admin'><td colspan='4'><%=getTran(request,"web","malariatreatment",sWebLanguage) %></td></tr>
	    <tr'>
			<td id='simpletreatment1' class='admin' nowrap><%=getTran(request,"web","uncomplicatedmalaria",sWebLanguage) %>&nbsp;</td>
			<td id='simpletreatment2' class='admin2' colspan='3'>
				<%=getTran(request,"gfmalaria","artemeterlumifantrine",sWebLanguage) %>:
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TREATMENT_UNCOMPLICATED", "gfmalaria.treatment.uncomplicated", sWebLanguage, "") %>
				&nbsp;&nbsp;&nbsp;<%=getTran(request,"web","other",sWebLanguage) %>:
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TREATMENT_UNCOMPLICATED_OTHER", 20) %>
			</td>
		</tr>
	    <tr>
			<td id='severetreatment1' class='admin' nowrap><%=getTran(request,"web","severemalaria",sWebLanguage) %>&nbsp;</td>
			<td id='severetreatment2' class='admin2'>
				<%=getTran(request,"gfmalaria","injectableartesunate",sWebLanguage) %>:
				<%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_TREATMENT_ARTESUNATE", sWebLanguage, false, "", "") %>
				&nbsp;|&nbsp;<%=getTran(request,"web","dose",sWebLanguage) %>:
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TREATMENT_ARTESUNATE_DOSE", 20) %>
			</td>
			<td id='severetreatment3' class='admin2' colspan='2'>
				<%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "notification.malariatreatment3", "ITEM_TYPE_NOTIFICATION_MALARIATREATMENT2", sWebLanguage, false, "", "") %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","firstdose",sWebLanguage) %>&nbsp;</td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_FIRSTDOSE", sWebLanguage, sCONTEXTPATH) %>
			</td>
		</tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","hypoglycemia",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<%=getTran(request,"web","glucose",sWebLanguage) %>:
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TREATMENT_GLUCOSE", "gfmalaria.treatment.glocose", sWebLanguage, "") %>
				&nbsp;|&nbsp;<%=getTran(request,"web","quantity",sWebLanguage) %>:
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TREATMENT_GLUCOSE", sWebLanguage, "", 1, 10) %>
				&nbsp;|&nbsp;<%=getTran(request,"web","begin",sWebLanguage) %>:
        		<%=SH.writeDefaultTimeInput(session, tran, "ITEM_TYPE_GLUCOSEBEGIN", sWebLanguage, sCONTEXTPATH) %>
				&nbsp;|&nbsp;<%=getTran(request,"web","end",sWebLanguage) %>:
        		<%=SH.writeDefaultTimeInput(session, tran, "ITEM_TYPE_GLUCOSEEND", sWebLanguage, sCONTEXTPATH) %>
			</td>
			<td class='admin' nowrap><%=getTran(request,"gfmalaria","anemia",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<%=SH.writeDefaultCheckBox(tran, request, "yesno", "ITEM_TYPE_SEVEREANEMIA", sWebLanguage, "") %>
				<%=getTran(request,"web","severe",sWebLanguage) %>
			</td>
		</tr>
		<tr>
			<td class='admin' nowrap><%=getTran(request,"web","bloodtransfusion",sWebLanguage) %>&nbsp;</td>
			<td class='admin2' colspan='3'>
				<%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_TREATMENT_BLOODTRANSFUSION", sWebLanguage, false, "", "") %>
				<br/><%=getTran(request,"web","quantity",sWebLanguage) %>:
				<%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_TREATMENT_BLOODTRANSFUSIONQUANTITY", 8, 0, 10000, sWebLanguage) %> ml |
				<%=getTran(request,"web","hour",sWebLanguage) %>:
				<%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_TREATMENT_BLOODTRANSFUSIONTIME", sWebLanguage, sCONTEXTPATH)%>
			</td>
		</tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"gfmalaria","dehydration",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<%=getTran(request,"web","ringerlactate",sWebLanguage) %>:
				<%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_TREATMENT_RINGERLACTATE", sWebLanguage, false, "", "") %>
				<br/><%=getTran(request,"web","quantity",sWebLanguage) %>:
				<%=SH.writeDefaultNumericInput(session, tran, "ITEM_TYPE_TREATMENT_RINGERLACTATEQUANTITY", 8, 0, 10000, sWebLanguage) %> ml |
				<%=getTran(request,"web","hour",sWebLanguage) %>:
				<%=SH.writeDefaultDateTimeInput(session, tran, "ITEM_TYPE_TREATMENT_RINGERLACTATETIME", sWebLanguage, sCONTEXTPATH)%>
			</td>
			<td class='admin' nowrap><%=getTran(request,"web","convulsions",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<%=SH.writeDefaultSelect(request, tran, "ITEM_TYPE_TREATMENT_CONVULSIONS", "gfmalara.treatment.convulsions", sWebLanguage, "") %>
				&nbsp;|&nbsp;<%=getTran(request,"web","dose",sWebLanguage) %>:
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TREATMENT_CONVULSIONS_DOSE", 20) %>
			</td>
		</tr>
	    <tr>
			<td class='admin' nowrap><%=getTran(request,"web","fever",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<%=getTran(request,"web","antipyretic",sWebLanguage) %>:
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TREATMENT_ANTIPYRETIC", 20) %>
				&nbsp;|&nbsp;<%=getTran(request,"web","dose",sWebLanguage) %>:
				<%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_TREATMENT_ANTIPYRETIC_DOSE", 20) %>
			</td>
			<td class='admin' nowrap><%=getTran(request,"web","respiratorydistress",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<%=getTran(request,"web","oxygentherapy",sWebLanguage) %>:
				<%=SH.writeDefaultRadioButtons(tran, request, "yesno", "ITEM_TYPE_TREATMENT_OCYGEN", sWebLanguage, false, "", "") %>
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
    <%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_NOTIFICATION_MALARIA") %>
    <%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_NOTIFICATION_PREGNANTWOMEN") %>
    <%=SH.writeDefaultHiddenInput(tran, "ITEM_TYPE_NOTIFICATION_MALARIATREATMENT") %>

<script>  
function checkFields(){
	  if(document.getElementById("ITEM_TYPE_PRESUMEDDIAGNOSIS.1").checked){
		  document.getElementById("simpletreatment1").style.textDecoration='';
		  document.getElementById("simpletreatment2").style.textDecoration='';
		  document.getElementById("severetreatment1").style.textDecoration='line-through';
		  document.getElementById("severetreatment2").style.textDecoration='line-through';
		  document.getElementById("severetreatment3").style.textDecoration='line-through';
	  }
	  else if(document.getElementById("ITEM_TYPE_PRESUMEDDIAGNOSIS.2").checked){
		  document.getElementById("simpletreatment1").style.textDecoration='line-through';
		  document.getElementById("simpletreatment2").style.textDecoration='line-through';
		  document.getElementById("severetreatment1").style.textDecoration='';
		  document.getElementById("severetreatment2").style.textDecoration='';
		  document.getElementById("severetreatment3").style.textDecoration='';
	  }
	  else{
		  document.getElementById("simpletreatment1").style.textDecoration='';
		  document.getElementById("simpletreatment2").style.textDecoration='';
		  document.getElementById("severetreatment1").style.textDecoration='';
		  document.getElementById("severetreatment2").style.textDecoration='';
		  document.getElementById("severetreatment3").style.textDecoration='';
	  }
	  if("2;3;4;5;".indexOf(document.getElementById("ITEM_TYPE_ORIGIN").value)>-1){
		  document.getElementById("referralsection").style.display=''; 
		  if(document.getElementById("ITEM_TYPE_MEANSOFTRANSPORT").value=='6'){
			  document.getElementById("ITEM_TYPE_MEANSOFTRANSPORT_OTHER").style.display='';
		  }
		  else{
			  document.getElementById("ITEM_TYPE_MEANSOFTRANSPORT_OTHER").value='';
			  document.getElementById("ITEM_TYPE_MEANSOFTRANSPORT_OTHER").style.display='none';
		  }
		  if(document.getElementById("ITEM_TYPE_REFERRALOTHERSIGNS.2").checked){
			  document.getElementById("ITEM_TYPE_REFERRALOTHERSIGNS_OTHER").style.display='';
		  }
		  else{
			  document.getElementById("ITEM_TYPE_REFERRALOTHERSIGNS_OTHER").value='';
			  document.getElementById("ITEM_TYPE_REFERRALOTHERSIGNS_OTHER").style.display='none';
		  }
		  if(document.getElementById("ITEM_TYPE_REFERRALSEVERITYSIGNS.14").checked){
			  document.getElementById("ITEM_TYPE_REFERRALSEVERITYSIGNS_OTHER").style.display='';
		  }
		  else{
			  document.getElementById("ITEM_TYPE_REFERRALSEVERITYSIGNS_OTHER").value='';
			  document.getElementById("ITEM_TYPE_REFERRALSEVERITYSIGNS_OTHER").style.display='none';
		  }
	  }
	  else{
		  document.getElementById("referralsection").style.display='none'; 
	  }
	  if(document.getElementById("ITEM_TYPE_SEVERITYSIGNS.14").checked){
		  document.getElementById("ITEM_TYPE_SEVERITYSIGNS_OTHER").style.display='';
	  }
	  else{
		  document.getElementById("ITEM_TYPE_SEVERITYSIGNS_OTHER").value='';
		  document.getElementById("ITEM_TYPE_SEVERITYSIGNS_OTHER").style.display='none';
	  }
	  if(document.getElementById("ITEM_TYPE_OTHERSIGNS.6").checked){
		  document.getElementById("ITEM_TYPE_OTHERSIGNS_OTHER").style.display='';
	  }
	  else{
		  document.getElementById("ITEM_TYPE_OTHERSIGNS_OTHER").value='';
		  document.getElementById("ITEM_TYPE_OTHERSIGNS_OTHER").style.display='none';
	  }
	  if(document.getElementById("ITEM_TYPE_MEDICALHISTORY.5").checked){
		  document.getElementById("ITEM_TYPE_MEDICALHISTORY_OTHER").style.display='';
	  }
	  else{
		  document.getElementById("ITEM_TYPE_MEDICALHISTORY_OTHER").value='';
		  document.getElementById("ITEM_TYPE_MEDICALHISTORY_OTHER").style.display='none';
	  }
	  if(document.getElementById("ITEM_TYPE_DIGESTIVE.7").checked){
		  document.getElementById("ITEM_TYPE_DIGESTIVE_OTHER").style.display='';
	  }
	  else{
		  document.getElementById("ITEM_TYPE_DIGESTIVE_OTHER").value='';
		  document.getElementById("ITEM_TYPE_DIGESTIVE_OTHER").style.display='none';
	  }
	  if(document.getElementById("ITEM_TYPE_RESPIRATORY.5").checked){
		  document.getElementById("ITEM_TYPE_RESPIRATORY_OTHER").value='';
		  document.getElementById("ITEM_TYPE_RESPIRATORY_OTHER").style.display='';
	  }
	  else{
		  document.getElementById("ITEM_TYPE_RESPIRATORY_OTHER").style.display='none';
	  }
	  if(document.getElementById("ITEM_TYPE_PREGNANTWOMEN.1")){
		  if(document.getElementById("ITEM_TYPE_PREGNANTWOMEN.1").checked){
			  document.getElementById("obstetricssection").style.display='';
			  if(document.getElementById("ITEM_TYPE_PELVIS").value=='4'){
				  document.getElementById("ITEM_TYPE_PELVIS_OTHER").style.display='';
			  }
			  else{
				  document.getElementById("ITEM_TYPE_PELVIS_OTHER").value='';
				  document.getElementById("ITEM_TYPE_PELVIS_OTHER").style.display='none';
			  }
		  }
		  else{
			  document.getElementById("obstetricssection").style.display='none';
		  }
	  }
	  if(document.getElementById("temperature").value*1>=38){
		  document.getElementById("ITEM_TYPE_OTHERSIGNS.1").checked=true;
	  }
	  else if(document.getElementById("temperature").value*1>=30){
		  document.getElementById("ITEM_TYPE_OTHERSIGNS.1").checked=false;
	  }
	  if(document.getElementById("patienttype2").value.length>0){
		  document.getElementById("ITEM_TYPE_PREGNANTWOMEN.1").checked=true;
	  }
	  if(document.getElementById("functional.signs.ids")){
		  var keywords=document.getElementById("functional.signs.ids").value+";"+document.getElementById("inspection.ids").value+";"+document.getElementById("palpation.ids").value+";"+document.getElementById("auscultation.ids").value;
		  if(keywords.includes("ikirezi2.functional.signs.general$3")){
			  document.getElementById("ITEM_TYPE_SEVERITYSIGNS.01").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.neuro$22.10")){
			  document.getElementById("ITEM_TYPE_SEVERITYSIGNS.02").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.neuro$11.148") || keywords.includes("ikirezi2.functional.signs.neuro$4") || keywords.includes("ikirezi2.functional.signs.neuro$7") || keywords.includes("ikirezi2.functional.signs.neuro$3")){
			  document.getElementById("ITEM_TYPE_SEVERITYSIGNS.03").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.pneumo$5.164")){
			  document.getElementById("ITEM_TYPE_SEVERITYSIGNS.04").checked=true;
		  }
		  if(keywords.includes("ikirezi2.inspection.dermato$14.34")){
			  document.getElementById("ITEM_TYPE_SEVERITYSIGNS.06").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.uro$2.31")){
			  document.getElementById("ITEM_TYPE_SEVERITYSIGNS.07").checked=true;
		  }
		  if(keywords.includes("ikirezi2.inspection.dermato$1.46")){
			  document.getElementById("ITEM_TYPE_SEVERITYSIGNS.08").checked=true;
			  document.getElementById("ITEM_TYPE_SKIN.1").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.uro$5") || keywords.includes("ikirezi2.functional.signs.uro$14.85")){
			  document.getElementById("ITEM_TYPE_SEVERITYSIGNS.09").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.general$1.169")){
			  document.getElementById("ITEM_TYPE_OTHERSIGNS.1").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.neuro$1.513")){
			  document.getElementById("ITEM_TYPE_OTHERSIGNS.2").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.gastro$21.63")){
			  document.getElementById("ITEM_TYPE_OTHERSIGNS.5").checked=true;
		  }
		  if(keywords.includes("ikirezi2.palpation.neuro$1.47")){
			  document.getElementById("ITEM_TYPE_NEUROLOGIC.3").checked=true;
		  }
		  if(keywords.includes("ikirezi2.auscultation.pneumo$4.80")){
			  document.getElementById("ITEM_TYPE_RESPIRATORY.1").checked=true;
		  }
		  if(keywords.includes("ikirezi2.auscultation.pneumo$5.80")){
			  document.getElementById("ITEM_TYPE_RESPIRATORY.2").checked=true;
		  }
		  if(keywords.includes("ikirezi2.auscultation.pneumo$a1.88")){
			  document.getElementById("ITEM_TYPE_RESPIRATORY.3").checked=true;
		  }
		  if(keywords.includes("ikirezi2.inspection.dermato$16.11")){
			  document.getElementById("ITEM_TYPE_SKIN.2").checked=true;
		  }
		  if(keywords.includes("ikirezi2.inspection.dermato$a5")){
			  document.getElementById("ITEM_TYPE_SKIN.3").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.gastro$25.152") || keywords.includes("ikirezi2.inspection.gastro$8.152")){
			  document.getElementById("ITEM_TYPE_DIGESTIVE.1").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.palpation.gastro$14.50")){
			  document.getElementById("ITEM_TYPE_DIGESTIVE.2").checked=true;
		  }
		  if(keywords.includes("ikirezi2.palpation.gastro$5.33")){
			  document.getElementById("ITEM_TYPE_DIGESTIVE.3").checked=true;
		  }
		  if(keywords.includes("ikirezi2.auscultation.gastro$1.452")){
			  document.getElementById("ITEM_TYPE_DIGESTIVE.5").checked=true;
		  }
		  if(keywords.includes("ikirezi2.auscultation.gastro$1.452")){
			  document.getElementById("ITEM_TYPE_DIGESTIVE.5").checked=true;
		  }
		  if(keywords.includes("ikirezi2.functional.signs.gastro$8.13")){
			  document.getElementById("ITEM_TYPE_DIGESTIVE.8").checked=true;
		  }
	  }
	}

	function showMalariyaPiBarcode(){
	  	var params = serializeForm(transactionForm);
	  	var url = '<c:url value="/util/makeMalariyaPiBarcode.jsp"/>?encounteruid='+document.getElementById("encounteruid").value;
	  	new Ajax.Request(url,{
		      parameters: params,
		      onSuccess: function(resp){
	              var barcode = eval("("+resp.responseText+")");
		    	  Modalbox.show("<div><table width='100%'><tr><td><img src='"+barcode.data+"'/></td><td><img height='50px' src='<%=sCONTEXTPATH%>/_img/themes/default/malariyapi.png'/><br/><br/><font style='font-size:14px'>[<%=activePatient.personid%>] <%=activePatient.getFullName()%><br/><%=activePatient.gender+" "+activePatient.dateOfBirth%>&nbsp;&nbsp;-&nbsp;&nbsp;<%=SH.cs("malariyapi.serverid","")%>."+document.getElementById("encounteruid").value+"</font></td></tr></table></div>",{title:"<%=getTranNoLink("web","scanbarcodewithmalariyapi",sWebLanguage)%>",width:400,height:170});
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
	
	checkFields();
	document.getElementById("ITEM_TYPE_MALARIYAPI_REFERRALCODE").style="background-color: lightyellow";
</script>
    