<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
   	String sServiceUid = checkString((String)session.getAttribute("activeservice"));
   	if(sServiceUid.length()==0){   	
   		sServiceUid=activeUser.getParameter("defaultserviceid");
   	}
%>
<form name='SearchForm' method='post'>
	<table width='100%'>
		<tr class='admin'><td colspan='2'><%=getTran(request,"web","statistics.norms",sWebLanguage) %></td></tr>
		<tr>
			<td class='admin' width='1%' nowrap><%=getTran(request,"web","service",sWebLanguage) %>&nbsp;&nbsp;</td>
			<td class='admin2'>
	            <input type="hidden" name="serviceuid" id="serviceuid" value="<%=sServiceUid%>">
	            <input class="text" type="text" name="servicename" id="servicename" readonly size="60" value="<%=getTranNoLink("service",sServiceUid,sWebLanguage) %>" >
	            <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"Web","select",sWebLanguage)%>" onclick="searchService('serviceuid','servicename');">
				<% if(SH.cs("setup.country","bi").equalsIgnoreCase("mg")){%>
	            &nbsp;&nbsp;&nbsp;<input type='checkbox' checked name='csb' id='csb' onchange='setSelects()'/><%=getTran(request,"web","csb",sWebLanguage) %>
	            &nbsp;&nbsp;&nbsp;<input type='checkbox' checked name='chr' id='chr' onchange='setSelects()'/><%=getTran(request,"web","chr",sWebLanguage) %>
	            &nbsp;&nbsp;&nbsp;<input type='checkbox' checked name='chu' id='chu' onchange='setSelects()'/><%=getTran(request,"web","chu",sWebLanguage) %>
				<%}else{ %>
	            &nbsp;&nbsp;&nbsp;<input type='checkbox' checked name='cds' id='cds' onchange='setSelects()'/><%=getTran(request,"web","cds",sWebLanguage) %>
	            &nbsp;&nbsp;&nbsp;<input type='checkbox' checked name='com' id='com' onchange='setSelects()'/><%=getTran(request,"web","com",sWebLanguage) %>
	            &nbsp;&nbsp;&nbsp;<input type='checkbox' checked name='hd' id='hd' onchange='setSelects()'/><%=getTran(request,"web","hd",sWebLanguage) %>
				<%} %>
			</td>
		</tr>
		<tr>
			<td class='admin' width='1%' nowrap rowspan='2'><%=getTran(request,"web","norm",sWebLanguage) %>&nbsp;&nbsp;</td>
			<td class='admin2'>
				<select class='text' name='nomenclature' id='nomenclature'>
					<option value=''><%=getTranNoLink("web","all",sWebLanguage) %></option>
					<option value='gen@i'><%=getTranNoLink("web","infrastructure",sWebLanguage) %></option>
					<option value='gen@e'><%=getTranNoLink("web","equipment",sWebLanguage) %></option>
					<%
						Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
						PreparedStatement ps = conn.prepareStatement("select structure,nomenclature from oc_standards where quantity>0 order by structure,nomenclature");
						ResultSet rs = ps.executeQuery();
						while(rs.next()){
							out.println("<option value='"+rs.getString("structure")+"@"+rs.getString("nomenclature")+"'>"+rs.getString("structure").toUpperCase()+" - "+rs.getString("nomenclature").toUpperCase().split(";")[0]+" "+getTranNoLink("admin.nomenclature.asset",rs.getString("nomenclature").split(";")[0],sWebLanguage)+"</option>");
						}
						rs.close();
						ps.close();
						conn.close();
					%>
				</select>
				<input type='button' class='button' name='addNormButton' value='<%=getTranNoLink("web","add",sWebLanguage) %>' onclick='addnorm()'/>
				<input type='button' class='button' name='clearNormsButton' value='<%=getTranNoLink("web","clear",sWebLanguage) %>' onclick='clearNorms()'/>
			</td>
		</tr>
		<tr>
			<td class='admin2'><div id='selectednorms'></div></td>
		</tr>
		<tr>
			<td class='admin' width='1%' nowrap/>
			<td class='admin2' nowrap>
	            <input type='button' class='button' name='calculateNormsButton' value='<%=getTran(request,"web","calculate",sWebLanguage) %>' onclick='calculateNorms()'/>
				&nbsp;&nbsp;
				<input type='radio' name='format' value='csv' checked/>CSV/Excel
				<input type='radio' name='format' value='csv2' />CSV/Excel = PDF
				<input type='radio' name='format' value='pdf'/>PDF
				<span id='messagediv'></span>
			</td>
		</tr>
	</table>
</form>
<iframe id="hiddenframe" src="" style="display:none;"></iframe>
<script>
	var norms="";
	
	function searchService(serviceUidField,serviceNameField){
	  	openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
	  	document.getElementById(serviceNameField).focus();
    }
	function calculateNorms(){
		document.getElementById('messagediv').innerHTML='<img src="<c:url value="/_img/themes/default/ajax-loader.gif"/>"/>';
		var structures="";
		if(document.getElementById("cds") && document.getElementById("cds").checked){
			structures="cds;";
		}
		if(document.getElementById("hd") && document.getElementById("hd").checked){
			structures+="hd;";
		}
		if(document.getElementById("com") && document.getElementById("com").checked){
			structures+="com;";
		}
		if(document.getElementById("csb") && document.getElementById("csb").checked){
			structures+="csb;";
		}
		if(document.getElementById("chr") && document.getElementById("chr").checked){
			structures+="chr;";
		}
		if(document.getElementById("chu") && document.getElementById("chu").checked){
			structures+="chu;";
		}
		if(norms.length==0){
			addnorm();
		}
		var url="<c:url value="/assets/normsReport.jsp"/>?ts=<%=getTs()%>&format="+SearchForm.format.value+"&structures="+structures+"&serviceid="+document.getElementById("serviceuid").value+"&nomenclature="+norms;
		document.getElementById("hiddenframe").src=url;
		window.setTimeout("checkNorms()",500);
	}
	function checkNorms(){
	      var today = new Date();
	      var url= '<c:url value="/assets/checkNormsReport.jsp"/>?ts='+today;
	      new Ajax.Request(url,{
	          method: "POST",
	          postBody: "",
	          onSuccess: function(resp){
	              var label = resp.responseText;
	              if(label.indexOf("<OK>")>-1){
	            	  document.getElementById('messagediv').innerHTML='';	              
	              }
	              else {
	            	  window.setTimeout("checkNorms()",500);
	              }
	          },
	          onFailure: function(){
	          }
	      }
		  );
	}
	function loadNorms(){
	      var today = new Date();
	      var url= '<c:url value="/assets/loadNorms.jsp"/>?ts='+today+"&norms="+norms;
	      new Ajax.Request(url,{
	          method: "POST",
	          postBody: "",
	          onSuccess: function(resp){
	              document.getElementById('selectednorms').innerHTML=resp.responseText;
	          },
	          onFailure: function(){
	          }
	      }
		  );
	}
	function addnorm(){
		if(document.getElementById("nomenclature").value.length==0){
			norms="";
		}
		else if(document.getElementById("nomenclature").value.indexOf('gen@')<0){
			norms=norms.replace(document.getElementById("nomenclature").value+";","");
			norms+=document.getElementById("nomenclature").value+";";
		}
		else{
			if(document.getElementById("nomenclature").value.indexOf('gen@i')>=0){
				options = document.getElementById("nomenclature").options;
				for(n=0;n<options.length;n++){
					if(options[n].style.display=='' && options[n].value.toUpperCase().indexOf('@I')>=0 && options[n].value!='gen@i'){
						norms=norms.replace(options[n].value+";","");
						norms+=options[n].value+";";
					}
				}
			}
			if(document.getElementById("nomenclature").value.indexOf('gen@e')>=0){
				options = document.getElementById("nomenclature").options;
				for(n=0;n<options.length;n++){
					if(options[n].style.display=='' && options[n].value.toUpperCase().indexOf('@E')>=0 && options[n].value!='gen@e'){
						norms=norms.replace(options[n].value+";","");
						norms+=options[n].value+";";
					}
				}
			}
		}
		loadNorms();
	}
	function clearNorms(){
		norms="";
		document.getElementById('selectednorms').innerHTML="";
		document.getElementById("nomenclature").selectedIndex=0;
	}
	function setSelects(){
		options = document.getElementById("nomenclature").options;
		for(n=0;n<options.length;n++){
			if(options[n].value.toUpperCase().indexOf('CDS@')>=0 && !document.getElementById('cds').checked){
				options[n].style.display='none';
			}
			else if(options[n].value.toUpperCase().indexOf('CDS@')>=0){
				options[n].style.display='';
			}
			if(options[n].value.toUpperCase().indexOf('COM@')>=0 && !document.getElementById('com').checked){
				options[n].style.display='none';
			}
			else if(options[n].value.toUpperCase().indexOf('COM@')>=0){
				options[n].style.display='';
			}
			if(options[n].value.toUpperCase().indexOf('HD@')>=0 && !document.getElementById('hd').checked){
				options[n].style.display='none';
			}
			else if(options[n].value.toUpperCase().indexOf('HD@')>=0){
				options[n].style.display='';
			}
		}
	}
	setSelects();
</script>