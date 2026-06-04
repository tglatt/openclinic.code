<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<table>
<tr><td>
<%
	File backupFile = new File(SH.cs("backupFile","/mnt/nas/db.tar"));
	if(backupFile.exists()){
		%>
		<h1><%= getTran(request,"web","backupfile",sWebLanguage)%>: <%=backupFile.getAbsolutePath() %></h1><br/>
		<li><%= getTran(request,"web","filesize",sWebLanguage)%>: <b><%=new DecimalFormat("#,##0").format(backupFile.length()/1024) %> KB</b>
		<li><%=getTran(request,"web","lastmodified",sWebLanguage) %>: <b><%=SH.formatDate(new java.util.Date(backupFile.lastModified()),"yyyy/MM/dd HH:mm:ss") %></b> 
		<%		
	}
	else{
		out.println("<h1>"+getTran(request,"web","backupfile",sWebLanguage)+" "+backupFile+" "+getTran(request,"web","doesnotexist",sWebLanguage)+"</h1>");
	}
%>
</td></tr>
<tr><td><br/><input onclick='download()' class='button' type='button' name='downloadButton' value='<%=getTranNoLink("web","download",sWebLanguage)%>'/></td></tr>
</table>

<script>
	function download(){
		window.open('<%=sCONTEXTPATH%>/system/downloadBackupFile.jsp');
	}
</script>
