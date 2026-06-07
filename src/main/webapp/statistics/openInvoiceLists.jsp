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
    String sTitle = getTran(request,"web","statistics.openinvoicelists",sWebLanguage)+"&nbsp;&nbsp;&nbsp;<i>["+sStart+" - "+sEnd+"]</i>";
%>

<%=writeTableHeaderDirectText(sTitle,sWebLanguage," closeWindow()")%>
<div style="padding-top:5px;"/>
<%
	Enumeration<String> pars = request.getParameterNames();
	while(pars.hasMoreElements()){
		String name = pars.nextElement();
		if(name.startsWith("cb.")){
			if(request.getParameter("cancelButton")!=null){
				PatientInvoice invoice = PatientInvoice.get(name.substring(3));
				if(invoice!=null){
					Vector<Debet> debets = invoice.getDebets();
			        for (int i = 0; i < debets.size(); i++) {
	                    Debet debet = debets.elementAt(i);
                        debet.setAmount(0);
                        debet.setInsurarAmount(0);
                        debet.setCredited(1);
                        debet.store();
			        }
			        invoice.setStatus("canceled");
			        invoice.store();
				}
			}
			else if(request.getParameter("closeButton")!=null){
				PatientInvoice invoice = PatientInvoice.get(name.substring(3));
		        invoice.setStatus("closed");
		        invoice.store();
			}
		}
	}
%>

<form name='transactionForm', method='post'>
	<table width="100%" class="list" cellpadding="0" cellspacing="1">    
	<%
		if(activeUser.getAccessRight("bulkmodify.openinvoices.select")){
	%>
		<tr>
			<td colspan='4'>
				<a href='javascript:checkAll()'><%=getTran(request,"web","checkall",sWebLanguage) %></a>&nbsp;
				<a href='javascript:unCheckAll()'><%=getTran(request,"web","uncheckall",sWebLanguage) %></a>&nbsp;
				<a href='javascript:checkUnpaid()'><%=getTran(request,"web","checkUnpaid",sWebLanguage) %></a>&nbsp;
				<a href='javascript:checkPaid()'><%=getTran(request,"web","checkPaid",sWebLanguage) %></a>&nbsp;
				<br/><br/>
			</td>
			<td colspan='2' style='border:1px solid black; padding: 5px'>
				<font style='font-size:12px'><%=getTran(request,"web","selectedinvoices",sWebLanguage) %>:</font><br/><br/>
				<input type ='submit' class='text' name='cancelButton' value='<%=getTranNoLink("web","cancel",sWebLanguage) %>'/>
				<input type ='submit' class='text' name='closeButton' value='<%=getTranNoLink("web","close",sWebLanguage) %>'/>
			</td>
		</tr>
	<%
		}
		String activeuser = "";
	    int dossierCount = 0, invoiceCount = 0;
	
	    // list open invoices
		Vector invoices = PatientInvoice.searchInvoicesByStatusAndBalance(sStart,sEnd,"open","");
	    for(int n=0; n<invoices.size(); n++){
	    	PatientInvoice invoice = (PatientInvoice)invoices.elementAt(n);
	    	
	    	// other dossier
	    	if(!activeuser.equalsIgnoreCase(invoice.getUpdateUser())){
	    		activeuser = invoice.getUpdateUser();
	    		dossierCount++;
	    		
	    		out.print("<tr class='gray'>"+
	    		           "<td colspan='6'>"+activeuser+" - "+MedwanQuery.getInstance().getUserName(Integer.parseInt(activeuser))+"</td>"+
	    		          "</tr>");
	    		
	    		// header
	    		out.print("<tr>");
	    		 out.print("<td class='admin'>"+getTran(request,"web","ID",sWebLanguage)+"</td>");
	    		 out.print("<td class='admin'>"+getTran(request,"web","date",sWebLanguage)+"</td>");
	    		 out.print("<td class='admin'>"+getTran(request,"web","lastupdate",sWebLanguage)+"</td>");
	    		 out.print("<td class='admin'>"+getTran(request,"web","patient",sWebLanguage)+"</td>");
	    		 out.print("<td class='admin'>"+getTran(request,"web","amount",sWebLanguage)+"</td>");
	    		 out.print("<td class='admin'>"+getTran(request,"web","balance",sWebLanguage)+"</td>");
	    		out.print("</tr>");
	    	}
	    	
			out.print("<tr>");
			 out.print("<td class='admin2'>"+
		     (activeUser.getAccessRight("bulkmodify.openinvoices.select")?"<input type='checkbox' class='text' id='"+(invoice.getPatientAmount()>0 && new Double(invoice.getBalance()).intValue()==0?"A.":"B.")+ new Double(invoice.getBalance()-invoice.getPatientAmount()).intValue()+"."+invoice.getUid()+"' name='cb."+invoice.getUid()+"'>":"")+
			 "<a href='javascript:openinvoice(\""+invoice.getUid()+"\")'>"+invoice.getUid()+"</a></td>");
			 out.print("<td class='admin2'>"+ScreenHelper.formatDate(invoice.getDate())+"</td>");
			 out.print("<td class='admin2'>"+ScreenHelper.fullDateFormatSS.format(invoice.getUpdateDateTime())+"</td>");
			 out.print("<td class='admin2'>"+AdminPerson.getAdminPerson(invoice.getPatientUid()).getFullName()+"</td>");
			 out.print("<td class='admin2'>"+deci.format(invoice.getPatientAmount())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td>");
			 out.print("<td class='admin2'>"+deci.format(invoice.getBalance())+" "+MedwanQuery.getInstance().getConfigString("currency")+"</td>");
			out.print("</tr>");
			
			invoiceCount++;
	    }
	%>
	</table>
</form>

<%=getTran(request,"web","patients",sWebLanguage)%>: <%=dossierCount%><br>
<%=getTran(request,"web","invoices",sWebLanguage)%>: <%=invoiceCount%><br>

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
		openPopup('/financial/patientInvoiceEdit.jsp&showpatientname=1&FindPatientInvoiceUID='+uid);
	}
	
	function checkAll(){
		var els = document.all;
	    for(i=0; i<els.length; i++){
	        if(els[i].type=="checkbox"){
	          els[i].checked = true;
	        }
	      }
	}
	function checkUnpaid(){
		var els = document.all;
	    for(i=0; i<els.length; i++){
	        if(els[i].type=="checkbox" && els[i].id.indexOf("B.0.")==0){
	          els[i].checked = true;
	        }
	      }
	}
	function checkPaid(){
		var els = document.all;
	    for(i=0; i<els.length; i++){
	        if(els[i].type=="checkbox" && els[i].id.indexOf("A.")==0){
	          els[i].checked = true;
	        }
	      }
	}
	function unCheckAll(){
		var els = document.all;
	    for(i=0; i<els.length; i++){
	        if(els[i].type=="checkbox"){
	          els[i].checked = false;
	        }
	      }
	}
</script>
