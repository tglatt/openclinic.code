<%@page import="ca.uhn.hl7v2.model.v251.datatype.SAD"%>
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
	String accessright="mspls.registry.sta";
%>
<%=checkPermission(accessright,"select",activeUser)%>


<%!
	private String writerow(HttpServletRequest request,TransactionVO transaction,String language, int n, String label){
		String 	s="<tr>";
				s+="	<td class='admin' colspan='2'>";
				s+="		<table width='100%' cellspacing='0' cellpadding='0'>";
				s+="			<tr>";
				s+="				<td class='admin' width='80%'>"+n+". "+getTran(request,"web",label,language)+"</td>";
				s+="				<td class='admin' width='*'>";
				s+="					"+ScreenHelper.writeDefaultCheckBoxes((TransactionVO)transaction, request, "yesonly", "cb"+n, language, false, "onchange='loadrows()'");	
				s+="				</td>";
				s+="			</tr>";
				s+=" 		</table>";
				s+=" 	</td>";
				s+=" 	<td style='background-color:#DEEAFF;padding: 0px' id='td"+n+"' colspan='2'/>";
				s+="</tr>";
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
    <!--  
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	-->
 
    <table class="list" width="100%" cellspacing="1" cellpadding='0'>
        <%-- DATE --%>
		<tr>
        	<td class='admin2' colspan='2'>
        		<b><%=getTran(request,"web","bodysize",sWebLanguage) %>:</b> 
        		<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BODY_SIZE", 5, 0, 300, sWebLanguage) %> cm
        	</td>
        	<td class='admin2' colspan='2'>
        		<b><%=getTran(request,"web","target_weight",sWebLanguage) %>:</b> 
        		<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_TARGET_WEIGHT", 5, 0, 300, sWebLanguage) %> kg
        	</td>
        	<td class='admin2' colspan='2'>
        		<b><%=getTran(request,"web","pb_tobereached",sWebLanguage) %>:</b> 
        		<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_PB_TOBEREACHED", 5, 0, 300, sWebLanguage) %> mm
        	</td>
		</tr>
		<tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin' colspan='1'><b><%=getTran(request,"web","weight",sWebLanguage) %></b> </td>
        	<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_WEIGHT", 5, 0, 300, sWebLanguage) %> kg</td>
        	 <td class="admin"><b><%=getTran(request,"web", "edema", sWebLanguage)%></b> </td>
              <td class="admin2">  <%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_STA2_EDEMA", "mspls.sta.oedeme", sWebLanguage, "") %>
             </td>
             <td class='admin' colspan='1'><b><%=getTran(request,"web","pb",sWebLanguage) %>:</b></td> 
        	<td class='admin2'><%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_PB", 5, 0, 300, sWebLanguage) %> mm
        	</td>
		</tr>
		<tr>
			<td class='admin' colspan='1'><b><%=getTran(request,"web","diarrhea",sWebLanguage) %>:</b> </td>
        	<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_DIARRHEA", 5, 0, 300, sWebLanguage) %>jrs</td>
             <td class='admin' colspan='1'><b><%=getTran(request,"web","vomiting",sWebLanguage) %>:</b></td> 
        	<td class='admin2' colspan='1'><%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_VOMITING", 5, 0, 300, sWebLanguage) %> jrs</td>
        	<td class='admin' colspan='1'><b><%=getTran(request,"web","fever",sWebLanguage) %>:</b> </td>
        	<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_FEVER", 5, 0, 300, sWebLanguage) %> jrs</td>
		</tr>
		<tr>
			<td class='admin' colspan='1'><b><%=getTran(request,"web","cough",sWebLanguage) %>:</b> 
        	<td class="admin2">	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_COUGH", 5, 0, 300, sWebLanguage) %>jrs</td>
            <td class="admin"><b><%=getTran(request,"web", "conjunctivitis", sWebLanguage)%>:</b> </td>
             <td class="admin2">   <%=ScreenHelper.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_CONJUNCTIVITIS", "mspls.sta.conjoctivite", sWebLanguage, "") %></td>
        	<td class='admin' colspan='1'>	<b><%=getTran(request,"web","breathing",sWebLanguage) %>:</b> </td>
        	<td class="admin2">	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_BREATHING", 5, 0, 300, sWebLanguage) %> /min</td>
		</tr>
		<tr>
			<td class='admin' colspan='1'><b><%=getTran(request,"web","temperature",sWebLanguage) %>:</b> 
			<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_TEMPERATURE", 5, 0, 300, sWebLanguage) %>�C  </td>
             <td class='admin' colspan='1'><b><%=getTran(request,"web","malariaresult",sWebLanguage) %>:</b> </td>
              <td class='admin2' colspan='1'>  <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "resultpalu", "ITEM_TYPE_MALARIARESULT", sWebLanguage, false, "", "") %><p></td>
              <td class='admin' colspan='1'><b><%=getTran(request,"web","appetitetest",sWebLanguage) %>:</b> </td>
             <td class='admin2' colspan='1'>   <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "testappetit", "ITEM_TYPE_APPETITETEST", sWebLanguage, false, "", "") %><p></td>
		</tr>
		<tr>
			<td class='admin' colspan='1'><b><%=getTran(request,"web","test",sWebLanguage) %>:</b> </td>
             <td class='admin2' colspan='1'>   <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "test", "ITEM_TYPE_TEST", sWebLanguage, false, "", "") %><p></td>
             <td class='admin' colspan='1'><b><%=getTran(request,"web","accompanying_choice",sWebLanguage) %>:</b> </td>
             <td class='admin2' colspan='1'>   <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "choix", "ITEM_TYPE_ACCOMPANYINGCHOICE", sWebLanguage, false, "", "") %><p></td>
             <td class='admin' colspan='1'><b><%=getTran(request,"web","atpe_out",sWebLanguage) %>:</b> </td>
        	<td class='admin2' colspan='1'><%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ATPEOUT", 5, 0, 300, sWebLanguage) %></td>
		</tr>
		<tr>
            <td class='admin' colspan='1'><b><%=getTran(request,"web","atpegiven",sWebLanguage) %>:</b></td> 
        	<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ATPEGIVEN", 5, 0, 300, sWebLanguage) %></td>
        	<td class='admin' colspan='1'><b><%=getTran(request,"web","failure",sWebLanguage) %>:</b></td> 
        	<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_FAILURE", 5, 0, 300, sWebLanguage) %></td>
        	<td class='admin' colspan='1'><b><%=getTran(request,"web","vad_needed",sWebLanguage) %>:</b></td> 
             <td class='admin2' colspan='1'>   <%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "yesno", "ITEM_TYPE_VAD_NEEDED", sWebLanguage, false, "", "") %><p></td>
		</tr>
		<tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","drug",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin'><b><%=getTran(request,"web","amoxiciline",sWebLanguage) %>:</b></td> 
        	<td class='admin2'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_AMOXI_DOSAGE", 5, 0, 300, sWebLanguage) %></td>
        	<td class='admin' colspan='1'><b><%=getTran(request,"web","vitamineA",sWebLanguage) %>:</b> </td>
        	<td class='admin2'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_VITAMINEA", 5, 0, 300, sWebLanguage) %></td>
        	<td class='admin' colspan='1'><b><%=getTran(request,"web","antimalaria",sWebLanguage) %>:</b> </td>
        	<td class='admin2'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ANTIMALARIA", 5, 0, 300, sWebLanguage) %></td>
		</tr>
		<tr>
			<td class='admin' colspan='1'><b><%=getTran(request,"web","antihelmi",sWebLanguage) %>:</b></td> 
        	<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_ANTIHELMI", 5, 0, 300, sWebLanguage) %></td>
        	<td class='admin' colspan='1'><b><%=getTran(request,"web","vaccinationrougeole",sWebLanguage) %>:</b></td> 
        	<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_VACCINATIONROUGEOLE", 5, 0, 300, sWebLanguage) %></td>
        	<td class='admin' colspan='1'><b><%=getTran(request,"web","other",sWebLanguage) %>:</b></td> 
        	<td class='admin2' colspan='1'>	<%=ScreenHelper.writeDefaultNumericInput(session, (TransactionVO)transaction, "ITEM_TYPE_OTHER", 5, 0, 300, sWebLanguage) %></td>
		</tr>
		<tr class='admin'><td colspan='6' align="center"><%=getTran(request,"web","SPECIFIC_TREATMENT",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin' colspan='1'><b><%=getTran(request,"web","observation",sWebLanguage) %>:</b></td> 
        	<td class='admin2' colspan='1'>	<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_OBSERVATION", 40, 2) %></td>
        	<td class='admin' colspan='1'><b><%=getTran(request,"web","traitement",sWebLanguage) %>:</b> </td>
        	<td class='admin2' colspan='3'>	<%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_TRAITMENT", 40, 2) %></td>
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



<script>
  function searchEncounter(){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=encounteruid&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  
  function searchUser(managerUidField,managerNameField){
	  openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no&FindServiceID=<%=MedwanQuery.getInstance().getConfigString("CCBRTEyeRegistryService")%>",650,600);
    document.getElementById(diagnosisUserName).focus();
  }


</script>
  