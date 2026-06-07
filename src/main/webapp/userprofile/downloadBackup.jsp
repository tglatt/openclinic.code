<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'><td><%=getTran(request,"web.userProfile","download.backup",sWebLanguage) %></td></tr>
		<%
			File file = new File(SH.cs("backupFile","/tmp/db.tar"));
			if(!file.exists()){
				%>
					<tr><td class='admin2'><%=SH.getTran(request,"web","file",sWebLanguage)+" <b>"+ SH.cs("backupFile","/tmp/db.tar")+"</b> "+SH.getTran("web","does.not.exist",sWebLanguage)%></td></tr>
				<%
			}
			else{
				%>
				<tr>
					<td class="admin2">
						<b>
							<%=SH.cs("backupFile","/tmp/db.tar") %> 
							(<%=new DecimalFormat("#,###").format(file.length()) %> <%=getTran(request,"web","bytes",sWebLanguage) %> - <%=SH.formatDate(new java.util.Date(file.lastModified()),"dd/MM/yyyy HH:mm:ss") %>)
						</b>
						<input type='button' class='button' value='<%=getTranNoLink("web","download",sWebLanguage) %>' onclick='downloadFile()'/>
					</td>
				</tr>
				<%
			}
		%>
	</table>
</form>

<script>
	function downloadFile(){
		window.open("<%=sCONTEXTPATH+"/userprofile/"%>getDownloadFile.jsp");
	}
</script>