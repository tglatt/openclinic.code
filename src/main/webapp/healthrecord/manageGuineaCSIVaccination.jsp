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
	String accessright="mshp.csi.vaccination";
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
    
    String getLastVaccination(String personid, String antigen, String sLanguage){
    	String s="";
    	ItemVO item = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSHP_CSI_VACCINATION","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_"+antigen);
    	if(item!=null){
    		s=getTranNoLink("gn.vaccin."+antigen,item.getValue(),sLanguage);
    	}
    	item = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSHP_CSI_VACCINATION","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_"+antigen+"_DATE");
    	if(item!=null){
    		s+=" - "+item.getValue();
    	}
    	return s;
    }
    
    String getLastVaccinationDate(String personid, String antigen){
    	String s="";
    	ItemVO item = MedwanQuery.getInstance().getLastItemVO(Integer.parseInt(personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSHP_CSI_VACCINATION","be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_"+antigen+"_DATE");
    	SH.syslog(antigen);
    	if(item!=null){
    		SH.syslog("yes");
    		s=item.getValue();
    	}
    	return s;
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
        <% TransactionVO tran = (TransactionVO)transaction; %>
        <!-- 
        	******************************************
        	* Code goes here 						 *
        	******************************************
        -->
        <tr>
        	<td class='admin' width='1%' nowrap><%=getTran(request,"web","milda",sWebLanguage) %>&nbsp;</td>
        	<td class='admin2' colspan='3'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_MILDA", sWebLanguage, "") %></td>
        </tr>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","vaccinationchildren",sWebLanguage) %>&nbsp;<img id='img_children' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/<%=activePatient.getAge()<=5?"minus":"plus"%>.png' onclick='if(this.src.indexOf("plus.png")>-1){this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png";document.getElementById("children").style.display="";}else{this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png";document.getElementById("children").style.display="none";}'></td></tr>
        <tr id='children' style='display: <%=activePatient.getAge()<=5?"":"none"%>'>
        	<td colspan='4'>
        		<table width='100%'>
        			<tr class='admin'>
        				<td><%=getTran(request,"web","antigene",sWebLanguage) %></td>
        				<td><%=getTran(request,"vaccin","last",sWebLanguage) %></td>
						<td>#</td>
        				<td><%=getTran(request,"web","date",sWebLanguage) %></td>
        				<td><%=getTran(request,"web","batch",sWebLanguage) %></td>
        				<td><%=getTran(request,"web","expires",sWebLanguage) %></td>
        				<td><%=getTran(request,"web","location",sWebLanguage) %></td>
        				<td><%=getTran(request,"web","mapi",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<% String vaccin = "BCG"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccinationDate(activePatient.personid, vaccin) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_"+vaccin, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10)+" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "")%></td>
        			</tr>
        			<tr>
        				<% vaccin = "Hep-B"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccinationDate(activePatient.personid, vaccin) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_"+vaccin, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10)+" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "") %></td>
        			</tr>
        			<tr>
        				<% vaccin = "Polio"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccination(activePatient.personid, vaccin,sWebLanguage) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultSelectUnsorted(request, tran, "ITEM_TYPE_"+vaccin, "gn.vaccin."+vaccin, sWebLanguage, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10)+" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "") %></td>
        			</tr>
        			<tr>
        				<% vaccin = "DTC"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccination(activePatient.personid, vaccin,sWebLanguage) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultSelectUnsorted(request, tran, "ITEM_TYPE_"+vaccin, "gn.vaccin."+vaccin, sWebLanguage, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10)+" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "") %></td>
        			</tr>
        			<tr>
        				<% vaccin = "PCV13"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccination(activePatient.personid, vaccin,sWebLanguage) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultSelectUnsorted(request, tran, "ITEM_TYPE_"+vaccin, "gn.vaccin."+vaccin, sWebLanguage, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10) +" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "")%></td>
        			</tr>
        			<tr>
        				<% vaccin = "ROTA"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccination(activePatient.personid, vaccin,sWebLanguage) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultSelectUnsorted(request, tran, "ITEM_TYPE_"+vaccin, "gn.vaccin."+vaccin, sWebLanguage, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10)+" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "") %></td>
        			</tr>
        			<tr>
        				<% vaccin = "VAP"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccination(activePatient.personid, vaccin,sWebLanguage) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultSelectUnsorted(request, tran, "ITEM_TYPE_"+vaccin, "gn.vaccin."+vaccin, sWebLanguage, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10) +" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "")%></td>
        			</tr>
        			<tr>
        				<% vaccin = "VAR"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccination(activePatient.personid, vaccin,sWebLanguage) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultSelectUnsorted(request, tran, "ITEM_TYPE_"+vaccin, "gn.vaccin."+vaccin, sWebLanguage, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10) +" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "")%></td>
        			</tr>
        			<tr>
        				<% vaccin = "VAA"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccinationDate(activePatient.personid, vaccin) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_"+vaccin, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10)+" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "") %></td>
        			</tr>
        			<tr>
        				<% vaccin = "MenA"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccinationDate(activePatient.personid, vaccin) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultCheckBox(tran, request, "1", "ITEM_TYPE_"+vaccin, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10)+" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "") %></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <%if(activePatient.gender.equalsIgnoreCase("f")){ %>
        <tr class='admin'><td colspan='4'><%=getTran(request,"web","vaccinationwomen",sWebLanguage) %>&nbsp;<img id='img_women' height='16px' style='vertical-align: middle' src='<%=sCONTEXTPATH%>/_img/icons/mobile/<%=activePatient.gender.equalsIgnoreCase("f") && activePatient.getAge()>5?"minus":"plus"%>.png' onclick='if(this.src.indexOf("plus.png")>-1){this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/minus.png";document.getElementById("women").style.display="";}else{this.src="<%=sCONTEXTPATH%>/_img/icons/mobile/plus.png";document.getElementById("women").style.display="none";}'></td></tr>
        <tr id='women' style='display: <%=activePatient.gender.equalsIgnoreCase("f") && activePatient.getAge()>5?"":"none"%>'>
        	<td colspan='4'>
        		<table width='100%'>
        			<tr class='admin'>
        				<td><%=getTran(request,"web","antigene",sWebLanguage) %></td>
        				<td><%=getTran(request,"vaccin","last",sWebLanguage) %></td>
						<td>#</td>
        				<td><%=getTran(request,"web","date",sWebLanguage) %></td>
        				<td><%=getTran(request,"web","batch",sWebLanguage) %></td>
        				<td><%=getTran(request,"web","expires",sWebLanguage) %></td>
        				<td><%=getTran(request,"web","location",sWebLanguage) %></td>
        				<td><%=getTran(request,"web","mapi",sWebLanguage) %></td>
        			</tr>
        			<tr>
        				<% vaccin = "DT"; %>
        				<td class='admin' nowrap><%=getTran(request,"vaccin",vaccin,sWebLanguage) %>&nbsp;</td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccination(activePatient.personid, vaccin,sWebLanguage) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultSelectUnsorted(request, tran, "ITEM_TYPE_"+vaccin, "gn.vaccin."+vaccin, sWebLanguage, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10)+" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "") %></td>
        			</tr>
        			<tr>
        				<% vaccin = "HPV"; %>
        				<td class='admin' nowrap><%=vaccin %></td>
	       				<td class='admin2' width='1%' nowrap><i><%=getLastVaccination(activePatient.personid, vaccin,sWebLanguage) %></i>&nbsp;</td>
	       				<td class='admin2'><%=SH.writeDefaultSelectUnsorted(request, tran, "ITEM_TYPE_"+vaccin, "gn.vaccin."+vaccin, sWebLanguage, "") %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_DATE", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_BATCH", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultDateInput(session, tran, "ITEM_TYPE_"+vaccin+"_EXPIRES", sWebLanguage, sCONTEXTPATH) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_LOCATION", 10) %></td>
	       				<td class='admin2'><%=SH.writeDefaultTextInput(session, tran, "ITEM_TYPE_"+vaccin+"_MAPI", 10) +" "+SH.writeDefaultSelect(request, tran, "ITEM_TYPE_"+vaccin+"_MAPISEVERE", "mapi.severity", sWebLanguage, "")%></td>
        			</tr>
        		</table>
        	</td>
        </tr>
        <%} %>
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
	var oldWeight=document.getElementById("ITEM_TYPE_WEIGHT").value.trim();
	var oldHeight=document.getElementById("ITEM_TYPE_HEIGHT").value.trim();
	
	function calculateWeightOverHeight(){
		  if(document.getElementById("ITEM_TYPE_WEIGHT").value.trim()=="" || document.getElementById("ITEM_TYPE_HEIGHT").value.trim()==""){
			  document.getElementById("ITEM_TYPE_WEIGHTOVERHEIGHT").value="";
		  }
		  else{
			  document.getElementById("ITEM_TYPE_WEIGHTOVERHEIGHT").value=(document.getElementById("ITEM_TYPE_WEIGHT").value/document.getElementById("ITEM_TYPE_HEIGHT").value).toFixed(2);
			  checkWeightForHeight(document.getElementById("ITEM_TYPE_HEIGHT").value,document.getElementById("ITEM_TYPE_WEIGHT").value,"ITEM_TYPE_WEIGHTOVERHEIGHTZ","ITEM_TYPE_WEIGHTFORAGEZ","ITEM_TYPE_LENGTHFORAGEZ");
		  }
		  if(document.getElementById("ITEM_TYPE_WEIGHT").value*1>0 && document.getElementById("ITEM_TYPE_HEIGHT").value*1>0){
			  if(document.getElementById("ITEM_TYPE_WEIGHT").value!=oldWeight || document.getElementById("ITEM_TYPE_HEIGHT").value!=oldHeight){
				  drawGraphs();
				  oldWeight=document.getElementById("ITEM_TYPE_WEIGHT").value;
				  oldHeight=document.getElementById("ITEM_TYPE_HEIGHT").value;
			  }
		  }
	}

	function checkWeightForHeight(height,weight,fieldid,fieldid2,fieldid3){
		var today = new Date();
 	    var url= '<c:url value="/ikirezi/getWeightForHeight.jsp"/>?height='+height+'&weight='+weight+'&age=<%=new Double((((TransactionVO)transaction).getUpdateTime().getTime()-SH.parseDate(activePatient.dateOfBirth).getTime())/SH.getTimeDay()).intValue() %>&gender=<%=activePatient.gender%>&ts='+today;
	      new Ajax.Request(url,{
	          method: "POST",
	          postBody: "",
	          onSuccess: function(resp){
	              var label = eval('('+resp.responseText+')');
	    		  if(label.zindex>-999){
    				  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.2").checked=false;
	    			  if(label.zindex<-3){
	    				  document.getElementById(fieldid).className="darkredtext";
	    				  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.2").checked=true;
	    			  }
	    			  else if(label.zindex<-2){
	    				  document.getElementById(fieldid).className="orangetext";
	    			  }
	    			  else if(label.zindex<-1){
	    				  document.getElementById(fieldid).className="yellowtext";
	    			  }
	    			  else if(label.zindex>2){
	    				  document.getElementById(fieldid).className="orangetext";
	    			  }
	    			  else if(label.zindex>1){
	    				  document.getElementById(fieldid).className="yellowtext";
	    			  }
	    			  else{
	    				  document.getElementById(fieldid).className="text";
	    			  }
	    			  document.getElementById(fieldid).value=(label.zindex*1).toFixed(2);
	    		  }
	    		  else{
	    			  document.getElementById(fieldid).value="";
				  	  document.getElementById(fieldid).className="text";
	    		  }
	    		  if(label.zindexWFA>-999){
    				  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.3").checked=false;
	    			  if(label.zindexWFA<-3){
	    				  document.getElementById(fieldid2).className="darkredtext";
	    				  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.3").checked=true;
	    			  }
	    			  else if(label.zindexWFA<-2){
	    				  document.getElementById(fieldid2).className="orangetext";
	    				  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.3").checked=true;
	    			  }
	    			  else if(label.zindexWFA<-1){
	    				  document.getElementById(fieldid2).className="yellowtext";
	    			  }
	    			  else if(label.zindexWFA>2){
	    				  document.getElementById(fieldid2).className="orangetext";
	    			  }
	    			  else if(label.zindexWFA>1){
	    				  document.getElementById(fieldid2).className="yellowtext";
	    			  }
	    			  else{
	    				  document.getElementById(fieldid2).className="text";
	    			  }
	    			  document.getElementById(fieldid2).value=(label.zindexWFA*1).toFixed(2);
	    		  }
	    		  else{
	    			  document.getElementById(fieldid2).value="";
				  	  document.getElementById(fieldid2).className="text";
	    		  }
	    		  if(label.zindexLFA>-999){
    				  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.4").checked=false;
	    			  if(label.zindexLFA<-3){
	    				  document.getElementById(fieldid3).className="darkredtext";
	    				  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.4").checked=true;
	    			  }
	    			  else if(label.zindexLFA<-2){
	    				  document.getElementById(fieldid3).className="orangetext";
	    				  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.4").checked=true;
	    			  }
	    			  else if(label.zindexLFA<-1){
	    				  document.getElementById(fieldid3).className="yellowtext";
	    			  }
	    			  else if(label.zindexLFA>2){
	    				  document.getElementById(fieldid3).className="orangetext";
	    			  }
	    			  else if(label.zindexLFA>1){
	    				  document.getElementById(fieldid3).className="yellowtext";
	    			  }
	    			  else{
	    				  document.getElementById(fieldid3).className="text";
	    			  }
	    			  document.getElementById(fieldid3).value=(label.zindexLFA*1).toFixed(2);
	    		  }
	    		  else{
	    			  document.getElementById(fieldid3).value="";
				  	  document.getElementById(fieldid3).className="text";
	    		  }
	    		  if(document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.2").checked==false && document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.3").checked==false && document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.4").checked==false){
	    			  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.1").checked=true;
	    		  }
	    		  else{
	    			  document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.1").checked=false;
	    		  }
				  updateMultiCheckbox(document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.1"),"ITEM_TYPE_NUTRITIONSTATUS","1")
				  updateMultiCheckbox(document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.2"),"ITEM_TYPE_NUTRITIONSTATUS","2")
				  updateMultiCheckbox(document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.3"),"ITEM_TYPE_NUTRITIONSTATUS","3")
				  updateMultiCheckbox(document.getElementById("ITEM_TYPE_NUTRITIONSTATUS.4"),"ITEM_TYPE_NUTRITIONSTATUS","4")

	          },
	          onFailure: function(){
	          }
	      }
		  );
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
  calculateWeightOverHeight();
</script>
    
<%=writeJSButtons("transactionForm","saveButton")%>        