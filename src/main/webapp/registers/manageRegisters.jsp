<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!
	//--- GET FIRST DAY PREVIOUS MONTH ------------------------------------------------------------
	public String getFirstDayPreviousMonth(){
	    // DATE
	    Calendar cal = Calendar.getInstance();
	    cal.setTime(new java.util.Date()); // now
	    cal.add(Calendar.MONTH,-1); // previous month
	    cal.set(Calendar.DAY_OF_MONTH,1); // first day

	    // HOUR
	    cal.set(Calendar.HOUR_OF_DAY,0);
	    cal.set(Calendar.MINUTE,0);
	    cal.set(Calendar.SECOND,0);
	    cal.set(Calendar.MILLISECOND,0);
	    
        return ScreenHelper.formatDate(cal.getTime());  
	}

	//--- GET LAST DAY PREVIOUS MONTH -------------------------------------------------------------
	public String getLastDayPreviousMonth(){
	    // DATE
	    Calendar cal = Calendar.getInstance();
	    cal.setTime(new java.util.Date()); // now
	    cal.add(Calendar.MONTH,-1); // previous month
	    cal.set(Calendar.DAY_OF_MONTH,cal.getActualMaximum(Calendar.DAY_OF_MONTH)); // last day
	
	    // HOUR
	    cal.set(Calendar.HOUR_OF_DAY,23);
	    cal.set(Calendar.MINUTE,59);
	    cal.set(Calendar.SECOND,59);
	    cal.set(Calendar.MILLISECOND,99);
	    	    
	    return ScreenHelper.formatDate(cal.getTime());    
	}
%>

<%
	String sBegindate = checkString(request.getParameter("begindate"));
	String sEnddate = checkString(request.getParameter("enddate"));
	if(sBegindate.length()==0){
		sBegindate=getFirstDayPreviousMonth();
	}
	if(sEnddate.length()==0){
		sEnddate=getLastDayPreviousMonth();
	}
%>

<form name="transactionForm" method="post">
	<table width="100%">
		<tr class='admin'>
			<td colspan="3"><%=getTran(request,"web","registers",sWebLanguage) %></td>
		</tr>
	<%
		Vector validRegisters = new Vector();
		//First we look for country-specific registers
	    String sDoc = MedwanQuery.getInstance().getConfigString("templateSource") + MedwanQuery.getInstance().getConfigString("registersfile","registers.xml");
	    SAXReader reader = new SAXReader(false);
	    Document document = reader.read(new URL(sDoc));
	    Iterator registers = document.getRootElement().elementIterator("register");
	    while(registers.hasNext()){
	    	Element register = (Element)registers.next();
	    	if(activeUser.getAccessRight(register.attributeValue("accessright")) && (checkString(register.attributeValue("country")).length()==0 || checkString(register.attributeValue("country")).equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("countrycode")))){
	    		//This register can be used
	    		if(register.attributeValue("title")!=null){
	    			validRegisters.add(register.attributeValue("id")+";"+register.attributeValue("title"));
	    		}
	    		else{
	    			validRegisters.add(register.attributeValue("id")+";"+register.attributeValue("transactiontype"));
	    		}
	    	}
	    }
	    if(validRegisters.size()>0){
	    	out.println("<tr><td class='admin' rowspan='2'>"+getTran(request,"web","selectregister",sWebLanguage));
	    	out.println("<select class='text' name='register' id='register'>");
			for(int n=0;n<validRegisters.size();n++){
				out.println("<option value='"+((String)validRegisters.elementAt(n)).split(";")[0]+"'>"+getTran(request,"web.occup",((String)validRegisters.elementAt(n)).split(";")[1],sWebLanguage)+"</option>");
			}
			out.println("</select></td>");
			out.println("<td class='admin'>"+getTran(request,"web","from",sWebLanguage)+"* "+ScreenHelper.writeDateField("begindate", "transactionForm", sBegindate, true, false, sWebLanguage, sCONTEXTPATH));
			out.println(" "+getTran(request,"web","to",sWebLanguage)+"* "+ScreenHelper.writeDateField("enddate", "transactionForm", sEnddate, true, false, sWebLanguage, sCONTEXTPATH)+"</td>");
			out.println("<td class='admin' rowspan='2'><input class='button' type='button' onclick='runreportcsv();' value='"+getTran(request,"web","csvreport",sWebLanguage)+"'/> <input class='button' type='button' onclick='runreportpdf();' value='"+getTran(request,"web","pdfreport",sWebLanguage)+"'/></td></tr>");
			out.println("<tr><td class='admin'>"+getTran(request,"web","service",sWebLanguage)+": <input type='hidden' name='serviceid' id='serviceid'/><input class='text' type='text' name='servicename' readonly size='36'/>");
			%>
	                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"web","select",sWebLanguage)%>" onclick="searchService('serviceid','servicename');">
	                <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"web","clear",sWebLanguage)%>" onclick="transactionForm.serviceid.value='';transactionForm.servicename.value='';">
			<%
			out.println("</td></tr>");
	    }
	%>
	</table>
</form>

<script>
	function runreportcsv(){
		if(document.getElementById('begindate').value.length==0 || document.getElementById('enddate').value.length==0){
			alert('<%=getTranNoLink("web","somedataismissing",sWebLanguage)%>');
		}
		else{
			window.open("<c:url value='/registers/runRegisterReportCsv.jsp'/>?ts=<%=getTs()%>&id="+document.getElementById("register").value+"&begindate="+document.getElementById("begindate").value+"&enddate="+document.getElementById("enddate").value+"&language=<%=sWebLanguage%>&serviceid="+document.getElementById("serviceid").value);
		}
	}
	function runreportpdf(){
		if(document.getElementById('begindate').value.length==0 || document.getElementById('enddate').value.length==0){
			alert('<%=getTranNoLink("web","somedataismissing",sWebLanguage)%>');
		}
		else{
		    window.open("<c:url value='/registers/runRegisterReportPdf.jsp'/>?ts=<%=getTs()%>&id="+document.getElementById("register").value+"&begindate="+document.getElementById("begindate").value+"&enddate="+document.getElementById("enddate").value+"&language=<%=sWebLanguage%>&serviceid="+document.getElementById("serviceid").value);
		}
	}
	function searchService(serviceUidField,serviceNameField,nocheck){
	   	openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
	   	document.getElementById(serviceNameField).focus();
	 }

</script>