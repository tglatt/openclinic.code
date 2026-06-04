<%@page import="org.apache.commons.io.FileUtils"%>
<%@page import="java.text.DecimalFormat"%>
<%@page import="be.openclinic.system.SystemInfo"%>
<%@include file="/includes/helper.jsp"%>
<%@page import="be.mxs.common.util.system.*"%>
<%= sCSSNORMAL %>
<%= sJSPROTOTYPE %>
<%
	if(request.getParameter("submitButton")!=null && SH.c(request.getParameter("accesskey")).length()>0){
		session.removeAttribute("accesskey");
		if(SH.cs("backupuser."+request.getParameter("accesskey"),"").length()>0){
			session.setAttribute("accesskey",request.getParameter("accesskey"));
		}
	}
	else if(request.getParameter("logoffButton")!=null){
		session.removeAttribute("accesskey");
	}
	String accesskey = SH.c((String)session.getAttribute("accesskey"));
	String site = SH.p(request,"site");
	String sBackupFolder = (SH.cs("backupFolder","/tmp/")+"/").replaceAll("//", "/");
	if(accesskey.length()==0){
%>
		<form name='transactionForm' method='post'>
			<br/><br/><br/><br/><br/><br/><center><img width='150px' src='<%=sCONTEXTPATH%>/_img/openclinic_logo.jpg'/></center><br/>
			<center>Access key: <input type='text' style='text-security:disc; -webkit-text-security:disc;' class='text' name='accesskey' value=''/> <input type='submit' name='submitButton' value='Login'/></center>
		</form>
<%		
	}
	else {
		String[] sFolders = SH.cs("backupuser."+accesskey,"").split(",");
		SortedMap sortedFolders = new TreeMap();
		for(int n=0;n<sFolders.length;n++){
			if(sFolders[n].split(":").length>1){
				sortedFolders.put(sFolders[n].split(":")[1],sFolders[n].split(":")[0]);
			}
			else{
				sortedFolders.put(sFolders[n].split(":")[0],sFolders[n].split(":")[0]);
			}
		}		
		String spaceUsed="";
		String spaceAvailable="";
		if(SH.cs("spaceusedFile","").length()>0){
			try{
				String s = FileUtils.readFileToString(new File(SH.cs("spaceusedFile",""))).split("\n")[1];
				while(s.contains("  ")){
					s=s.replaceAll("  "," ");
				}
				s=s.replaceAll(" ", ";");
				spaceUsed=" [used: <b style='font-size: 12px'>"+s.split(";")[2].trim()+"</b>]";
				spaceAvailable=" [available: <b style='font-size: 12px'>"+s.split(";")[3].trim()+"</b>]";
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		%>
		<form name='transactionForm' method='post'>
			<br/>
			<center><img width='150px' src='<%=sCONTEXTPATH%>/_img/openclinic_logo.jpg'/></center><br/>
			<center>
					Disk space: <b style='font-size: 12px'><%=spaceAvailable%> <%=spaceUsed %> 
					<input type='submit' name='logoffButton' value='<%=getTranNoLink("web","logoff","en") %>'/>
			</center><br/>
			<table width='100%'>
				<tr class='admin'>
					<td>
						Backup repository:&nbsp;&nbsp;&nbsp;
						<select class='text' name='site' id='site' onchange='loadfiles()'>
							<%
								Iterator iFolders = sortedFolders.keySet().iterator();
								while(iFolders.hasNext()){
									String folderName=(String)iFolders.next();
									String folder=(String)sortedFolders.get(folderName);
									out.println("<option value='"+folder+"'>"+folderName+"</option>");
								}
							%>
						</select>
					</td>
				</tr>
			</table>
			<div id='filelist' name='filelist'/>
		</form>
		<%
	}
%>
<script>
	function loadfiles(){
	    var url = '<c:url value="/backup/loadfiles.jsp"/>'+
	              '?folder=<%=sBackupFolder%>'+document.getElementById("site").value+
	              '&ts='+new Date().getTime()+
	              '&project='+document.getElementById("site").value;
	    new Ajax.Request(url,{
	      parameters: "",
	      onSuccess: function(resp){
	        document.getElementById("filelist").innerHTML = resp.responseText;
	      }
	    });
	  }
	
	loadfiles();
</script>