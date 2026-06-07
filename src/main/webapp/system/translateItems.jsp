<%@page import="be.openclinic.system.TransactionItem"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<form name='transactionForm' method='post'>
<%
	String transactionType = SH.p(request,"transactiontype");
	if(request.getParameter("submitButton")!=null){
		Enumeration<String> params = request.getParameterNames();
		while(params.hasMoreElements()){
			String name = params.nextElement();
			if(name.startsWith("itemType.")){
				String itemType = name.substring(9);
				String itemLabel = SH.c(request.getParameter(name));
				if(!itemLabel.equalsIgnoreCase(itemType) && !itemLabel.equalsIgnoreCase(getTranNoLink("web.occup",itemType,sWebLanguage))){
					MedwanQuery.getInstance().storeLabelWithDelete("web.occup", itemType, sWebLanguage, itemLabel, Integer.parseInt(activeUser.userid));
				}
			}
		}
		MedwanQuery.getInstance().reloadLabels();
	}
%>
	<input type='hidden' name='transactiontype' value='<%=transactionType%>'/>
	<table width='100%'>
		<tr class='admin'>
			<td width='30%'><%=getTran(request,"web","id",sWebLanguage) %></td>
			<td><%=getTran(request,"web","label",sWebLanguage)+" ("+sWebLanguage.toUpperCase()+")"%></td>
		</tr>
<%
	Vector<TransactionItem> items = TransactionItem.selectByTransactionTypeId(transactionType);
	for(int n=0;n<items.size();n++){
		TransactionItem item = items.elementAt(n);
		out.println("<tr>");
		out.println("<td>"+item.getItemTypeId()+"</td>");
		out.println("<td><input type='text' class='text' size='100' name='itemType."+item.getItemTypeId()+"' value='"+getTranNoLink("web.occup",item.getItemTypeId(),sWebLanguage)+"'/></td>");
		out.println("</tr>");
	}
%>
	</table>
	<input type='submit' name='submitButton' value='<%=getTranNoLink("web","save",sWebLanguage) %>'/>
</form>