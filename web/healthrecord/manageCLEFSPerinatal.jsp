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
	String accessright="clefs.perinatal";
%>
<%=checkPermission(accessright,"select",activeUser)%>
<%!
	private String writeDiag(int n,int rows,HttpServletRequest request,Object transaction,String sWebLanguage){
		return "<td class='admin2' id='cb.diag."+n+"' style='border: 1px solid;text-align: center' rowspan='"+rows+"'><b>"+getTran(request,"web","clefs.perinatal.diag"+n,sWebLanguage)+"</b><br/>"+SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_DIAG"+n, "onchange='checkSymptoms()'")+"<i>"+getTran(request,"web","accepteddiagnosis",sWebLanguage)+"</i></td>";
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
    
    <table width="100%" cellspacing="1" cellpadding='0'>
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
        	<td width='25%' valign='top'>
        		<table width='100%' cellspacing='0' cellpadding='2'>
        			<tr class='admin'>
        				<td colspan='2'><%=getTran(request,"web","generalsymptoms",sWebLanguage) %></td>
        			</tr>
        			<% for(int n=1;n<12;n++){ %>
	        			<tr>	
							<td class='admin2' width='1px' id='cb.symgen.<%=n%>'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMGEN"+n, "onchange='checkSymptoms()'") %></td>
							<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symgen"+n,sWebLanguage) %></td>
	        			</tr>
        			<% } %>
        			<tr><td colspan='2'><img width='100%' src='<%=sCONTEXTPATH%>/_img/clefs_perinatal.png'></td></tr>
        		</table>
        	</td>
        	<td width='75%' valign='top'>
        		<table width='100%' cellspacing='0' cellpadding='2'>
        			<tr class='admin'>
        				<td width='66%' colspan='2'><%=getTran(request,"web","specificsymptoms",sWebLanguage) %></td>
        				<td ><center><%=getTran(request,"web","diagnosis",sWebLanguage) %></center></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.1' width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC1", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec1",sWebLanguage) %></td>
						<%=writeDiag(1,2, request, transaction, sWebLanguage) %>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.2' width='1px' style='border-bottom: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC2", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-bottom: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspec2",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.3' width='1px' style='border-top: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC3", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-top: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspec3",sWebLanguage) %></td>
						<%=writeDiag(2,6, request, transaction, sWebLanguage) %>
        			</tr>
        			<tr>
						<td class='admin2'  id='cb.symspec.4'width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC4", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec4",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2'  id='cb.symspec.5'width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC5", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec5",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2'  id='cb.symspec.6'width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC6", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec6",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2'  id='cb.symspec.7'width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC7", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec7",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2'  id='cb.symspec.8'width='1px' style='border-bottom: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC8", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-bottom: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspec8",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.9' width='1px' style='border-top: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC9", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-top: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspe9",sWebLanguage) %></td>
						<%=writeDiag(3,4, request, transaction, sWebLanguage) %>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.10' width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC10", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec10",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.11' width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC11", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec11",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.12' width='1px' style='border-bottom: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC12", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-bottom: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspec12",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.13' width='1px' style='border-top: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC13", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-top: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspec13",sWebLanguage) %></td>
						<%=writeDiag(4,2, request, transaction, sWebLanguage) %>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.14' width='1px' style='border-bottom: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC14", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-bottom: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspec14",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.15' width='1px' style='border-top: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC15", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-top: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspec15",sWebLanguage) %></td>
						<%=writeDiag(5,7, request, transaction, sWebLanguage) %>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.16' width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC16", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec16",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.17' width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC17", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec17",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.18' width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC18", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec18",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.19' width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC19", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec19",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.20' width='1px'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC20", "onchange='checkSymptoms()'") %></td>
						<td class='admin2'><%=getTran(request,"web","clefs.perinatal.symspec20",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' id='cb.symspec.21' width='1px' style='border-bottom: 1px solid'><%=SH.writeDefaultCheckBox((TransactionVO)transaction, request, "medwan.common.true", "ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC21", "onchange='checkSymptoms()'") %></td>
						<td class='admin2' style='border-bottom: 1px solid'><%=getTran(request,"web","clefs.perinatal.symspec21",sWebLanguage) %></td>
        			</tr>
        			<tr>
						<td class='admin2' colspan='2' style='border-top: 1px solid'>&nbsp;</td>
						<%=writeDiag(6,1, request, transaction, sWebLanguage) %>
        			</tr>
        		</table>
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
	function checkSymptoms(){
		for(n=1;n<12;n++){
			document.getElementById('cb.symgen.'+n).style.backgroundColor='';
		}
		for(n=1;n<22;n++){
			document.getElementById('cb.symspec.'+n).style.backgroundColor='';
		}
		for(n=1;n<7;n++){
			document.getElementById('cb.diag.'+n).className='admin2';
		}
		if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN1').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN2').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN3').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN4').checked){
			document.getElementById('cb.symspec.1').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.2').style.backgroundColor='#4975A7';
		}
		if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN1').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN2').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN3').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN4').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN5').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN6').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN7').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN8').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN9').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN10').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN11').checked){
			document.getElementById('cb.symspec.3').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.4').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.5').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.6').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.7').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.8').style.backgroundColor='#4975A7';
		}
		if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN1').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN3').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN4').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN5').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN6').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN7').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN8').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN9').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN10').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN11').checked){
			document.getElementById('cb.symspec.9').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.10').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.11').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.12').style.backgroundColor='#4975A7';
		}
		if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN11').checked){
			document.getElementById('cb.symspec.15').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.16').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.17').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.18').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.19').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.20').style.backgroundColor='#4975A7';
			document.getElementById('cb.symspec.21').style.backgroundColor='#4975A7';
		}
		if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC1').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC2').checked){
			document.getElementById('cb.symgen.1').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.2').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.3').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.4').style.backgroundColor='#4975A7';
		}
		if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC3').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC4').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC5').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC6').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC7').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC8').checked){
			document.getElementById('cb.symgen.1').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.2').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.3').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.4').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.5').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.6').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.7').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.8').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.9').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.10').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.11').style.backgroundColor='#4975A7';
		}
		if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC9').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC10').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC11').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC12').checked){
			document.getElementById('cb.symgen.1').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.3').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.4').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.5').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.6').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.7').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.8').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.9').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.10').style.backgroundColor='#4975A7';
			document.getElementById('cb.symgen.11').style.backgroundColor='#4975A7';
		}
		if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC15').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC16').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC17').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC18').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC19').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC20').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC21').checked){
			document.getElementById('cb.symgen.11').style.backgroundColor='#4975A7';
		}
		if(document.getElementById("ITEM_TYPE_CLEFS_PERINATAL_DIAG1").checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC1').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC2').checked){
			document.getElementById('cb.diag.1').className='adminselected';
		}
		if(document.getElementById("ITEM_TYPE_CLEFS_PERINATAL_DIAG2").checked || (document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC3').checked && (document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC4').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC6').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC7').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN4').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN9').checked))){
			document.getElementById('cb.diag.2').className='adminselected';
		}
		if(document.getElementById("ITEM_TYPE_CLEFS_PERINATAL_DIAG3").checked || checkDepression()){
			document.getElementById('cb.diag.3').className='adminselected';
		}
		if(document.getElementById("ITEM_TYPE_CLEFS_PERINATAL_DIAG4").checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC13').checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC14').checked){
			document.getElementById('cb.diag.4').className='adminselected';
		}
		if(document.getElementById("ITEM_TYPE_CLEFS_PERINATAL_DIAG5").checked || checkPsychosis()){
			document.getElementById('cb.diag.5').className='adminselected';
		}
		if(document.getElementById("ITEM_TYPE_CLEFS_PERINATAL_DIAG6").checked || document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN11').checked){
			document.getElementById('cb.diag.6').className='adminselected';
		}
	}

  function checkDepression(){
	  nSigns=0;
	  signs="7;4;2;1;11;8".split(";");
	  for(n=0;n<signs.length;n++){
		  if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN'+signs[n]) && document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMGEN'+signs[n]).checked){
			  nSigns++;
		  }
	  }
	  signs="9;12;10;11".split(";");
	  for(n=0;n<signs.length;n++){
		  if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC'+signs[n]) && document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC'+signs[n]).checked){
			  nSigns++;
		  }
	  }
	  return nSigns>=2;
  }
  function checkPsychosis(){
	  nSigns=0;
	  signs="15;16;17".split(";");
	  for(n=0;n<signs.length;n++){
		  if(document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC'+signs[n]) && document.getElementById('ITEM_TYPE_CLEFS_PERINATAL_SYMSPEC'+signs[n]).checked){
			  nSigns++;
		  }
	  }
	  return nSigns>=1;
  }
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
  checkSymptoms();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        