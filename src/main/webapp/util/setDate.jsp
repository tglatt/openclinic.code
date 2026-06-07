<%@include file="/includes/helper.jsp"%>
<%=sCSSNORMAL %>
<%=sJSPROTOTYPE %>
<html>
	<body>
		<form name='transactionForm' method='post'>
			<%if(new java.util.Date().before(new SimpleDateFormat("dd/MM/yyyy").parse(be.openclinic.system.SH.cs("minimumSystemDate","01/01/2021")))){ %>
			<h2><%=getTranNoLink("web","wrongdate","fr") %></h2>
			<%} %>
			<br/>
			<table width='100%'>
				<tr>
					<td class='admin' width='30%'>
						<%=getTranNoLink("web","date","fr") %>:&nbsp;
					</td>
					<td width='70%' class='admin2'>
						<input class=text' type='date' name='date' id='date' value='<%=new SimpleDateFormat("yyyy-dd-MM").format(new java.util.Date()) %>' size='10'/>
					</td>
				</tr>
				<tr>
					<td width='30%' class='admin'>
						<%=getTranNoLink("web","hour","fr") %>:&nbsp;
					</td>
					<td width='70%' class='admin2'>
						<select class='text' name='hour' id='hour'>
						<%
							for(int n=0;n<24;n++){
								out.println("<option "+(new SimpleDateFormat("HH").format(new java.util.Date()).equalsIgnoreCase(SH.padLeft(n+"", "0", 2))?"selected":"")+">"+SH.padLeft(n+"", "0", 2)+"</option>");
							}
						%>
						</select> :
						<select class='text' name='minutes' id='minutes'>
						<%
							for(int n=0;n<60;n++){
								out.println("<option "+(new SimpleDateFormat("mm").format(new java.util.Date()).equalsIgnoreCase(SH.padLeft(n+"", "0", 2))?"selected":"")+">"+SH.padLeft(n+"", "0", 2)+"</option>");
							}
						%>
						</select>
					</td>
				</tr>
				<tr>
					<td colspan='2'>
						<br/><input class='button' type='button' onclick='setDate();' name='setDateButton' value='<%=getTran(request,"web","update","fr") %>'/>
						<br/><br/><div id='ajaxloader' style='display:none'><img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/></div>
					</td>
				</tr>
			</table>
		</form>
		
		<script>
			function setDate(){
			     var params = "date="+document.getElementById('date').value+
                 "&hour="+document.getElementById('hour').value+
                 "&minutes="+document.getElementById('minutes').value;
			     var url = '<c:url value="/system/setDate.jsp"/>?ts='+new Date().getTime();
			     new Ajax.Request(url,{
			       method: "POST",
			       parameters: params,
			       onSuccess: function(resp){
  					 	document.getElementById('ajaxloader').style.display='';
			         	checkDate();
			       }
			     });
			}
			
			function checkDate(){
			     var url = '<c:url value="/system/checkDate.jsp"/>?ts='+new Date().getTime();
			     new Ajax.Request(url,{
			       method: "POST",
			       parameters: "",
			       onSuccess: function(resp){
			    	   if(resp.responseText.indexOf('<OK>')>-1){
				         	window.parent.location.href='<%=sCONTEXTPATH%>/login.jsp';
			    	   }
			    	   else{
			    		   window.setTimeout("checkDate();",5000);
			    	   }
			       }
			     });
			}
			window.parent.parent.scrollTo(0,0);
		</script>
	</body>
</html>
