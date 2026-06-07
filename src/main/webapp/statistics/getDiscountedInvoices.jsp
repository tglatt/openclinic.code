<%@page import="be.openclinic.finance.*,
                java.util.Hashtable,
                java.util.Vector,
                java.util.Collections,
                java.text.DecimalFormat"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sStart = checkString(request.getParameter("start")),
           sEnd   = checkString(request.getParameter("end"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** statistics/openInvoiceLists.jsp *******************");
    	Debug.println("sStart : "+sStart);
    	Debug.println("sEnd   : "+sEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    DecimalFormat deci = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));
    String sTitle = getTran(request,"web","statistics.discountedinvoices",sWebLanguage)+"&nbsp;&nbsp;&nbsp;<i>["+sStart+" - "+sEnd+"]</i>";
%>

<%=writeTableHeaderDirectText(sTitle,sWebLanguage," closeWindow()")%>
<div style="padding-top:5px;"/>

<form name='transactionForm', method='post'>
	<table width="100%" class="list" cellpadding="0" cellspacing="1">    
		<tr class='admin'>
			<td><%=getTran(request, "web", "date", sWebLanguage)%></td>
			<td><%=getTran(request, "web", "invoice", sWebLanguage)%></td>
			<td><%=getTran(request, "web", "patientid", sWebLanguage)%></td>
			<td><%=getTran(request, "web", "patient", sWebLanguage)%></td>
			<td><%=getTran(request, "web", "discount", sWebLanguage)%></td>
			<td><%=getTran(request, "web", "comment", sWebLanguage)%></td>
		</tr>
		<%
			double total=0;
			Connection conn = SH.getOpenClinicConnection();
			String sql = "SELECT oc_patientcredit_updatetime,oc_patientcredit_invoiceuid,personid,lastname,firstname,oc_patientcredit_amount,oc_patientinvoice_insurarreference from"+
						 " oc_patientcredits, oc_patientinvoices, adminview WHERE"+
						 " personid=oc_patientinvoice_patientuid and"+
						 " oc_patientinvoice_objectid=REPLACE(oc_patientcredit_invoiceuid,'"+SH.getServerId()+".','') and"+
						 " oc_patientcredit_type='reduction' AND"+
						 " oc_patientcredit_updatetime>=? AND" +
						 " oc_patientcredit_updatetime<?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setDate(1,SH.getSQLDate(sStart));
			ps.setDate(2,SH.getSQLDate(sEnd));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				out.println("<tr>");
				out.println("<td class='admin'>"+SH.formatDate(rs.getDate("oc_patientcredit_updatetime"))+"</td>");
				out.println("<td class='admin2'><a href='javascript:openInvoice(\""+SH.c(rs.getString("oc_patientcredit_invoiceuid"))+"\")'><b>"+SH.c(rs.getString("oc_patientcredit_invoiceuid"))+"</b></a></td>");
				out.println("<td class='admin2'>"+SH.c(rs.getString("personid"))+"</td>");
				out.println("<td class='admin2'>"+SH.c(rs.getString("lastname")).toUpperCase()+", "+SH.capitalizeAllWords(rs.getString("firstname")).toUpperCase()+"</td>");
				out.println("<td class='admin2'>"+SH.formatPrice(rs.getDouble("oc_patientcredit_amount"))+"</td>");
				out.println("<td class='admin2'>"+SH.c(rs.getString("oc_patientinvoice_insurarreference"))+"</td>");
				out.println("</tr>");
				total+=rs.getDouble("oc_patientcredit_amount");
			}
			out.println("<tr><td colspan='3'/>");
			out.println("<td style='text-align: right'><b>"+getTran(request,"web","total",sWebLanguage)+":&nbsp;&nbsp;</b></td>");
			out.println("<td><b>"+SH.formatPrice(total)+"</b></td>");
			out.println("</td></tr>");
			rs.close();
			ps.close();
			conn.close();
			
		%>
	</table>
</form>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="closeWindow();">
<%=ScreenHelper.alignButtonsStop()%>

<script>  
  <%-- CLOSE WINDOW --%>
  function closeWindow(){
    window.opener = null;
    window.close();
  }
	function openinvoice(uid){
		openPopup('/financial/patientInvoiceEdit.jsp&showpatientname=1&nosave=1&FindPatientInvoiceUID='+uid);
	}
	function openInvoice(uid){
		openPopup('/financial/patientInvoiceEdit.jsp&showpatientname=1&nosave=1&FindPatientInvoiceUID='+uid);
	}
</script>
