<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sVarCode=SH.p(request,"VarCode");
	String sVarCode2=SH.p(request,"VarCode2");
%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='2'><%=getTran(request,"web","findnupscode",sWebLanguage) %></td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"web","category",sWebLanguage) %></td>
		<td class='admin'>
			<select class='text' name='category' id='category'>
				<option/>
				<%
					Connection conn = SH.getOpenClinicConnection();
					PreparedStatement ps = conn.prepareStatement("select distinct section from nupsref");
					ResultSet rs = ps.executeQuery();
					while(rs.next()){
						String section=SH.c(rs.getString("section"));
						if(section.length()>0){
							out.println("<option>"+section+"</option>");
						}
					}
					rs.close();
					ps.close();
					conn.close();
				%>
			</select>
		</td>
	</tr>
	<tr>
		<td class='admin'><%=getTran(request,"web","keyword",sWebLanguage) %></td>
		<td class='admin'>
			<input type='text' class='text' size='40' name='keyword' id='keyword' onKeyDown='checkKeyDown(event);'/>
			<input type='button' class='button' name='searchButton' value='<%=getTranNoLink("web","search",sWebLanguage) %>' onclick='getNUPSCodes()'/>
		</td>
	</tr>
</table>
<div id='nupscodes'/>

<script>
	function checkKeyDown(evt){
		evt = evt || window.event;
		var kcode = evt.keyCode || evt.which;
		if(kcode && kcode==13){
		  getNUPSCodes();
		  return true;
		} 
		else{
		  return false;
		}
	}

	function getNUPSCodes(){
	   document.getElementById('nupscodes').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
	   var today = new Date();
	   var section=document.getElementById('category').value;
	   var keyword=document.getElementById('keyword').value;
	   var params = 'section=' + section+"&keyword="+keyword;
	   var url= '<c:url value="/_common/search/searchByAjax/searchNUPSShow.jsp"/>?ts=' + today;
	   new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               $('nupscodes').innerHTML=resp.responseText;
	           }
	       }
	   );  
	}
	
	function selectNUPS(code){
		<%if(sVarCode.length()>0){%>
		if(window.opener.<%=sVarCode%>){
			window.opener.<%=sVarCode%>.value=code;
		}
		<%}%>
		<%if(sVarCode2.length()>0){%>
		if(window.opener.document.getElementById('<%=sVarCode2%>')){
			window.opener.document.getElementById('<%=sVarCode2%>').value=code;
		}
		<%}%>
		if(window.opener.getNomenclatureLabel){
			window.opener.getNomenclatureLabel();
		}
		window.close();
	}
</script>