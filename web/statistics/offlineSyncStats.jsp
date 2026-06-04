<%@page import="be.openclinic.finance.*,
                be.mxs.common.util.system.*"%>
<%@include file="/includes/validateUser.jsp"%>
<table>
	<tr class='admin'>
		<td><%=getTran(request,"web","server",sWebLanguage) %></td>
		<td><%=getTran(request,"web","lastsync",sWebLanguage) %></td>
	</tr>
<%
	if(SH.p(request,"delete").length()>0){
		Pointer.deletePointers("offlinesync."+SH.p(request,"delete"));
	}
	Vector<String> syncs = Pointer.getPointersLike("offlinesync.");
	for(int n=0;n<syncs.size();n++){
		String key=syncs.elementAt(n).split(";")[0];
		String value=syncs.elementAt(n).split(";")[1];
		out.println("<tr>");
		java.util.Date d = SH.parseDate(value,"yyyyMMddHHmmss");
		if(new java.util.Date().getTime()-d.getTime()<SH.getTimeDay()*3){
			out.println("<td class='admin'>"+key.split("\\.")[1]+"</td>");
			out.println("<td class='admingreen'>"+SH.formatDate(d,"dd/MM/yyyy HH:mm:ss")+"</td>");
		}
		else{ 
		out.println("<td class='admin'><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' onclick='deleteServer(\""+key.split("\\.")[1]+"\")'/> "+key.split("\\.")[1]+"</td>");
			out.println("<td class='adminred'><font style='color: white;font-weight: bolder'>"+SH.formatDate(d,"dd/MM/yyyy HH:mm:ss")+"</font></td>");
		}
		out.println("</tr>");
	}
%>
</table>

