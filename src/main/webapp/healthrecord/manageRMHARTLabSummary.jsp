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
	String accessright="default.accessright";
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
            <td class="admin" width="<%=sTDAdminWidth%>" colspan="8">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran(request,"Web.Occup","medwan.common.date",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","partnername",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_PARTNER", 20) %></td>
        	<td class='admin'><%=getTran(request,"web","donorname",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DONORNAME", 20) %></td>
        	<td class='admin'><%=getTran(request,"web","incubator",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_INCUBATOR", 10) %></td>
        	<td class='admin'><%=getTran(request,"web","color",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_COLOR", 10) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","semen",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction,"ITEM_TYPE_ARTLAB_SEMEN", "artlab.semen", sWebLanguage, "") %></td>
        	<td class='admin'><%=getTran(request,"web","donor",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction,"ITEM_TYPE_ARTLAB_DONOR", "yesno", sWebLanguage, "") %></td>
        	<td class='admin2' colspan='4'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "artlab.ivf", "ITEM_TYPE_ART_IVF", sWebLanguage, false, "", "") %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","volume",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VOLUME", 10) %>ml</td>
        	<td class='admin'><%=getTran(request,"art","concentration",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_CONCENTRATION", 10) %>x10^6/ml</td>
        	<td class='admin'><%=getTran(request,"artlab","motility",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_MOTILITY", 10) %>%</td>
        	<td class='admin'><%=getTran(request,"art","pr",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_PR", 10) %>%</td>
        </tr>
        <tr class='admin'>
        	<td colspan='8'><%=getTran(request,"art","retrieval",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","datetime",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_RETRIEVAL_DATE", sWebLanguage, sCONTEXTPATH) %>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_RETRIEVAL_HOUR", sWebLanguage, "", 0, 23) %>:<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_RETRIEVAL_MINUTE", sWebLanguage, "", 0, 59) %>
        	</td>
        	<td class='admin'><%=getTran(request,"web","md",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_MD", 20) %></td>
        	<td class='admin'><%=getTran(request,"web","embryologist",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_EMBRYOLOGIST", 20) %></td>
        	<td class='admin'><%=getTran(request,"web","accession",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_ACCESSION", 10) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","totaloocytesretrieved",sWebLanguage) %></td>
        	<td class='admin2' colspan='3'>
        		<b>L:</b> <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_TOTALOOCYTES_L", 5) %>
        		<b>R:</b> <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_TOTALOOCYTES_R", 5) %>
        		<b>T:</b> <%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_TOTALOOCYTES_T", 5) %>
        	</td>
        	<td class='admin'><%=getTran(request,"web","endtime",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_RETRIEVAL_ENDHOUR", sWebLanguage, "", 0, 23) %>:<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_RETRIEVAL_ENDMINUTE", sWebLanguage, "", 0, 59) %>
        	</td>
        	<td class='admin'>E2</td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_E2", 10) %></td>
        </tr>
        <tr class='admin'>
        	<td colspan='8'><%=getTran(request,"art","cryopreservation",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","totalvitrified",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_TOTALVITRIFIED", 10) %></td>
        	<td class='admin'><%=getTran(request,"art","location",sWebLanguage) %></td>
        	<td class='admin2' nowrap>
        		<b><%=getTran(request,"artlab","tank",sWebLanguage) %>:</b><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_TANK", sWebLanguage, "", 1, 10) %>
        		<b><%=getTran(request,"artlab","can",sWebLanguage) %>:</b><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_CAN", sWebLanguage, "", 1, 20) %>
        	</td>
        	<td class='admin' colspan='2'><%=getTran(request,"art","canelabel",sWebLanguage) %></td>
        	<td class='admin2' colspan='2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_CANELABEL", 20) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","day2.3",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY2OR3", 5) %></td>
        	<td class='admin'><%=getTran(request,"art","blast",sWebLanguage) %></td>
        	<td class='admin2'>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_BLAST", sWebLanguage, "", 5, 6)%>
        	</td>
        	<td class='admin' colspan='2'><%=getTran(request,"art","database",sWebLanguage) %></td>
        	<td class='admin2' colspan='2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DATABASE", 20) %></td>
        </tr>
        <tr class='admin'>
        	<td colspan='8'><%=getTran(request,"art","transfer",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","datetime",sWebLanguage) %></td>
        	<td class='admin2' nowrap>
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_TRANSFER_DATE", sWebLanguage, sCONTEXTPATH) %>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TRANSFER_HOUR", sWebLanguage, "", 0, 23) %>:<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_TRANSFER_MINUTE", sWebLanguage, "", 0, 59) %>
        	</td>
        	<td class='admin'><%=getTran(request,"web","md",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_TRANSFERMD", 20) %></td>
        	<td class='admin'><%=getTran(request,"web","embryologist",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_TRANSFEREMBRYOLOGIST", 20) %></td>
        	<td class='admin'><%=getTran(request,"web","difficulty",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DIFFICULTY", 20) %></td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"web","catheter",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_CATHETER", 20) %></td>
        	<td class='admin'><%=getTran(request,"art","numberet",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_ET", sWebLanguage, "", 0, 3) %></td>
        	<td class='admin'><%=getTran(request,"web","blood",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction,"ITEM_TYPE_ARTLAB_BLOOD", "yesno", sWebLanguage, "") %></td>
        	<td class='admin'><%=getTran(request,"web","mucus",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultSelect(request, (TransactionVO)transaction,"ITEM_TYPE_ARTLAB_MUCUS", "yesno", sWebLanguage, "") %></td>
        </tr>
        <tr class='admin'>
        	<td colspan='8'><%=getTran(request,"art","patientidverification",sWebLanguage) %></td>
        </tr>
        <tr>
        	<td colspan='8'>
        		<table width='100%'>
        			<tr>
			        	<td class='admin'><%=getTran(request,"web","retrieval",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_RETRIEVAL", 5) %></td>
			        	<td class='admin'><%=getTran(request,"art","fert",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_FERT", 5) %></td>
			        	<td class='admin'><%=getTran(request,"web","stripping",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_STRIPPING", 5) %></td>
			        	<td class='admin'><%=getTran(request,"web","insemicsi",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_INSEMICSI", 5) %></td>
			        	<td class='admin'><%=getTran(request,"web","day3",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_DAY3", 5) %></td>
					<tr>
			        <tr>
			        	<td class='admin'><%=getTran(request,"art","ah",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_AH", 5) %></td>
			        	<td class='admin'><%=getTran(request,"web","transfer",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_TRANSFER", 5) %></td>
			        	<td class='admin'><%=getTran(request,"web","day5",sWebLanguage) %></td>
			        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_DAY5", 5) %></td>
			        	<td class='admin'><%=getTran(request,"web","day6",sWebLanguage) %></td>
			        	<td class='admin2' colspan='3'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_VERIFICATION_DAY6", 5) %></td>
			        </tr>
				</table>
	        </td>
        </tr>
        <tr><td colspan='8'><hr/></td></tr>
        <tr>
        	<td colspan='8'>
        		<table width='100%'>
        			<tr class='admin'>
			        	<td><%=getTran(request,"art","oocyte.embryo",sWebLanguage) %></td>
			        	<td><%=getTran(request,"web","date",sWebLanguage) %></td>
			        	<td><%=getTran(request,"web","embryologist",sWebLanguage) %></td>
			        	<%
			        		for(int n=1;n<16;n++){
			        			out.println("<td><center>"+n+"</center></td>");
			        		}
			        	%>
        			</tr>
        			<tr>
			        	<td class='admin'><%=getTran(request,"art","maturitystage",sWebLanguage) %></td>
			        	<td class='admin' nowrap><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_MATURITYSTAGE_DATE", sWebLanguage, sCONTEXTPATH) %></td>
			        	<td class='admin'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_MATURUTYSTAGE_EMBRYOLOGIST", 10) %></td>
			        	<%
			        		for(int n=1;n<16;n++){
			        			out.println("<td class='admin2'>"+SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_MATURUTYSTAGE_"+n, 3)+"</td>");
			        		}
			        	%>
        			</tr>
        			<tr>
			        	<td class='admin'><%=SH.writeDefaultCheckBoxes((TransactionVO)transaction, request, "artlab.ivf", "ITEM_TYPE_ARTLAB_IVF", sWebLanguage, false) %></td>
			        	<td class='admin' nowrap><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_IVF_DATE", sWebLanguage, sCONTEXTPATH) %></td>
			        	<td class='admin'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_IVF_EMBRYOLOGIST", 10) %></td>
			        	<%
			        		for(int n=1;n<16;n++){
			        			out.println("<td class='admin2'>"+SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_IVF_"+n, 3)+"</td>");
			        		}
			        	%>
        			</tr>
        			<tr>
			        	<td class='admin'><%=getTran(request,"art","pnstatus",sWebLanguage) %></td>
			        	<td class='admin' nowrap><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_PNSTATUS_DATE", sWebLanguage, sCONTEXTPATH) %></td>
			        	<td class='admin'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_PNSTATUS_EMBRYOLOGIST", 10) %></td>
			        	<%
			        		for(int n=1;n<16;n++){
			        			out.println("<td class='admin2'>"+SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_PNSTATUS_"+n, 3)+"</td>");
			        		}
			        	%>
        			</tr>
        			<tr>
			        	<td class='admin'><%=SH.writeDefaultRadioButtons((TransactionVO)transaction, request, "artlab.day23", "ITEM_TYPE_ARTLAB_DAY23", sWebLanguage, false,"","") %></td>
			        	<td class='admin' nowrap><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY23_DATE", sWebLanguage, sCONTEXTPATH) %></td>
			        	<td class='admin'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY23_EMBRYOLOGIST", 10) %></td>
			        	<%
			        		for(int n=1;n<16;n++){
			        			out.println("<td class='admin2'>"+SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY23_"+n, 3)+"</td>");
			        		}
			        	%>
        			</tr>
        			<tr>
			        	<td class='admin'><%=getTran(request,"art","day5",sWebLanguage) %></td>
			        	<td class='admin' nowrap><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY5_DATE", sWebLanguage, sCONTEXTPATH) %></td>
			        	<td class='admin'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY5_EMBRYOLOGIST", 10) %></td>
			        	<%
			        		for(int n=1;n<16;n++){
			        			out.println("<td class='admin2'>"+SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY5_"+n, 3)+"</td>");
			        		}
			        	%>
        			</tr>
        			<tr>
			        	<td class='admin'><%=getTran(request,"art","day6",sWebLanguage) %></td>
			        	<td class='admin' nowrap><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY6_DATE", sWebLanguage, sCONTEXTPATH) %></td>
			        	<td class='admin'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY6_EMBRYOLOGIST", 10) %></td>
			        	<%
			        		for(int n=1;n<16;n++){
			        			out.println("<td class='admin2'>"+SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_DAY6_"+n, 3)+"</td>");
			        		}
			        	%>
        			</tr>
        			<tr>
			        	<td class='admin'><%=getTran(request,"art","finaldisposition",sWebLanguage) %></td>
			        	<td class='admin' nowrap><%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_FINAL_DATE", sWebLanguage, sCONTEXTPATH) %></td>
			        	<td class='admin'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_FINAL_EMBRYOLOGIST", 10) %></td>
			        	<%
			        		for(int n=1;n<16;n++){
			        			out.println("<td class='admin2'><center>"+SH.writeDefaultSelect(request, (TransactionVO)transaction,"ITEM_TYPE_ARTLAB_FINAL_"+n, "art.tvd", sWebLanguage, "")+"</center></td>");
			        		}
			        	%>
        			</tr>
        		</table>
        	</td>
        </tr>
        <tr>
        	<td class='admin'><%=getTran(request,"art","comments",sWebLanguage) %></td>
        	<td class='admin2' colspan='3'><%=SH.writeDefaultTextArea(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_FINAL_COMMENTS", 60, 2) %></td>
        	<td class='admin'><%=getTran(request,"art","reviewedby",sWebLanguage) %></td>
        	<td class='admin2'><%=SH.writeDefaultTextInput(session, (TransactionVO)transaction, "ITEM_TYPE_ARTLAB_REVIEWEDBY", 20) %></td>
        	<td class='admin'><%=getTran(request,"art","datetime",sWebLanguage) %></td>
        	<td class='admin2' nowrap>
        		<%=SH.writeDefaultDateInput(session, (TransactionVO)transaction, "ITEM_TYPE_REVIEWED_DATE", sWebLanguage, sCONTEXTPATH) %>
        		<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_REVIEWED_HOUR", sWebLanguage, "", 0, 23) %>:<%=SH.writeDefaultSelect(request, (TransactionVO)transaction, "ITEM_TYPE_REVIEWED_MINUTE", sWebLanguage, "", 0, 59) %>
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