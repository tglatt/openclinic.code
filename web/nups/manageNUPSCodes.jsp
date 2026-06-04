<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sCSSNORMAL %>
<%=sJSPROTOTYPE %>
<%
	String keywords=SH.p(request,"e-keywords");
	String muid=SH.p(request,"e-muid");
	String csu=SH.p(request,"e-csu");
	String code=SH.p(request,"e-code");
	String extension=SH.p(request,"e-extension");
	String originalcode=SH.p(request,"e-originalcode");
	String domain=SH.p(request,"e-domain");
	String fr=SH.p(request,"e-fr");
	String en=SH.p(request,"e-en");
	String pt=SH.p(request,"e-pt");
	String es=SH.p(request,"e-es");
	String sectioncode=SH.p(request,"e-sectioncode");
	String parent=SH.p(request,"e-parent");
%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'><%=getTran(request,"nups","nups",sWebLanguage) %></td>
			<td colspan='4' style='text-align: right'>
				<img src='<%=sCONTEXTPATH %>/_img/flags/uk.png' style='vertical-align: middle' height='14px' title='English' onclick='setLanguage("en")'/>
				&nbsp;<img src='<%=sCONTEXTPATH %>/_img/flags/france.png' style='vertical-align: middle' height='14px' title='Français' onclick='setLanguage("fr")'/>
				<!-- 
				&nbsp;<img src='<%=sCONTEXTPATH %>/_img/flags/spain.png' style='vertical-align: middle' height='14px' titel='Español' onclick='setLanguage("es")'/>
				&nbsp;<img src='<%=sCONTEXTPATH %>/_img/flags/portugal.png' style='vertical-align: middle' height='14px' titel='Português' onclick='setLanguage("pt")'/>
				 -->
				&nbsp;<a href='javascript:downloadNUPS()'><%=getTran(request,"nups","downloadselection",sWebLanguage) %></a>
				&nbsp;<img title='Quitter' height='20px' style='vertical-align: middle' src='<%=sCONTEXTPATH %>/_img/icons/mobile/logout.png' onclick='logout();'/>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"nups","code",sWebLanguage) %></td>
			<td class='admin2'><input class='text' type='text' name='code' id='code' size='10' value='<%=code%>'/></td>
			<td class='admin'><%=getTran(request,"nups","suffix",sWebLanguage) %></td>
			<td class='admin2'><input class='text' type='text' name='extension' id='extension' size='10' value='<%=extension%>'/></td>
			<td class='admin'><%=getTran(request,"nups","sort",sWebLanguage) %>:</td>
			<td class='admin2'>
				<select name='sort' id='sort' class='text'>
					<option/>
					<option value='1'><%=getTranNoLink("nups","sortonnupscode",sWebLanguage) %></option>
					<option value='2'><%=getTranNoLink("nups","sortonlabel",sWebLanguage) %></option>
					<option value='3'><%=getTranNoLink("nups","sortonnupscodefromcode",sWebLanguage) %></option>
					<option value='4'><%=getTranNoLink("nups","sortonlabelfromkeyword",sWebLanguage) %></option>
				</select>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"nups","section",sWebLanguage)%></td>
			<td class='admin2'>
				<select class='text' name='section' id='section'>
					<option/>
					<%= SH.getNUPSSectionOptions(activeUser, sectioncode,sWebLanguage) %>
				</select>
			</td>
			<td class='admin'><%=getTran(request,"nups","keywords",sWebLanguage)%></td>
			<td class='admin2'>
				<input class='text' type='text' name='keywords' id='keywords' size='50' value='<%=keywords%>'/>
			</td>
			<td class='admin2' colspan='2' rowspan='3'>
				<center>
					<input class='button' type='button' name='searchButton' value='<%=getTranNoLink("web","clear",sWebLanguage)%>' onclick='emptyNUPS();'/>&nbsp;
					<input class='button' type='button' name='searchButton' value='<%=getTranNoLink("web","search",sWebLanguage)%>' onclick='searchNUPS();'/>&nbsp;
					<%if(activeUser.getAccessRight("nups.manage.add")){ %>
						<input class='button' type='button' name='newButton' value='<%=getTranNoLink("web","new",sWebLanguage)%>' onclick='newNUPS();'/>
					<%} %>
				</center>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"nups","originalcode",sWebLanguage)%></td>
			<td class='admin2'><input class='text' type='text' name='originalcode' id='originalcode' size='10' value='<%=originalcode%>'/></td>
			<td class='admin'><%=getTran(request,"nups","parentcode",sWebLanguage)%></td>
			<td class='admin2'>
				<input class='text' type='text' name='parent' id='parent' size='10' value='<%=parent%>' onkeyup='getNomenclatureLabel2();'/>
                    &nbsp;&nbsp;&nbsp;<span style='color: darkblue;font-style: italic;font-size: 11px' id='nomenclatureText2'/>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","levels",sWebLanguage)%></td>
			<td class='admin2'>
				<select name='level' id='level' class='text'>
					<option/>
				<%
					String[] levels=SH.cs("nups.levels","").split(";");
					for(int q=0;q<levels.length;q++){
						if(levels[q].length()>0){
							out.println("<option value='"+levels[q]+"'>"+levels[q]+"</option>");
						}
					}
				%>
				</select>
			</td>
			<td class='admin'><%=getTran(request,"web","groups",sWebLanguage)%></td>
			<td class='admin2'>
				<select name='group' id='group' class='text'>
					<option/>
				<%
					String[] groups=SH.cs("nups.groups","").split(";");
					for(int q=0;q<groups.length;q++){
						if(groups[q].length()>0){
							out.println("<option value='"+groups[q]+"'>"+groups[q]+"</option>");
						}
					}
				%>
				</select>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"nups","limitrecords",sWebLanguage)%></td>
			<td class='admin2'>
				<select name='limit' id='limit' class='text'>
					<option>1000</option>
					<option>2000</option>
					<option>5000</option>
					<option>10000</option>
					<option value='999999999'><%=getTranNoLink("web","unlimited",sWebLanguage)%></option>
				</select>
			</td>
			<td class='admin'><%=getTran(request,"nups","uhc",sWebLanguage)%></td>
			<td class='admin2'>
				<input class='text' type='checkbox' name='csu' id='csu'/>
			</td>
			<td class='admin2' colspan='2'>
				<center>
					<%if(activeUser.getAccessRight("nups.manage.add")){ %>
						<input class='button' type='button' name='levelButton' value='<%=getTranNoLink("web","levels",sWebLanguage)%>' onclick='searchNUPSCareLevels();'/>&nbsp;
						<input class='button' type='button' name='groupButton' value='<%=getTranNoLink("web","groups",sWebLanguage)%>' onclick='searchNUPSGroups();'/>&nbsp;
					<%} %>
				</center>
			</td>
		</tr>
	</table>
	<div id='nupsdata'/>
</form>

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

	function searchNUPS(){
		document.getElementById('nupsdata').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
		var today = new Date();
		var params = 'code=' + document.getElementById('code').value+
		'&extension='+document.getElementById('extension').value+
		'&sectioncode='+document.getElementById('section').value+
		'&keywords='+document.getElementById('keywords').value+
		'&parent='+document.getElementById('parent').value+
		'&limit='+document.getElementById('limit').value+
		'&level='+document.getElementById('level').value+
		'&group='+document.getElementById('group').value+
		'&csu='+document.getElementById('csu').checked+
		'&sort='+document.getElementById('sort').value+
		'&originalcode='+document.getElementById('originalcode').value
		;
	   var url= '<c:url value="/nups/ajax/searchNUPSCodes.jsp"/>?ts=' + today;
	   new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               $('nupsdata').innerHTML=resp.responseText;
	           }
	       }
	   );  
	}
	function searchNUPSCareLevels(){
		document.getElementById('nupsdata').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
		var today = new Date();
		var params = 'code=' + document.getElementById('code').value+
		'&extension='+document.getElementById('extension').value+
		'&sectioncode='+document.getElementById('section').value+
		'&keywords='+document.getElementById('keywords').value+
		'&parent='+document.getElementById('parent').value+
		'&level='+document.getElementById('level').value+
		'&group='+document.getElementById('group').value+
		'&limit='+document.getElementById('limit').value+
		'&csu='+document.getElementById('csu').checked+
		'&sort='+document.getElementById('sort').value+
		'&originalcode='+document.getElementById('originalcode').value
		;
	   var url= '<c:url value="/nups/ajax/searchNUPSCodeCareLevels.jsp"/>?ts=' + today;
	   new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               $('nupsdata').innerHTML=resp.responseText;
	           }
	       }
	   );  
	}
	function searchNUPSGroups(){
		document.getElementById('nupsdata').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
		var today = new Date();
		var params = 'code=' + document.getElementById('code').value+
		'&extension='+document.getElementById('extension').value+
		'&sectioncode='+document.getElementById('section').value+
		'&keywords='+document.getElementById('keywords').value+
		'&level='+document.getElementById('level').value+
		'&group='+document.getElementById('group').value+
		'&parent='+document.getElementById('parent').value+
		'&limit='+document.getElementById('limit').value+
		'&csu='+document.getElementById('csu').checked+
		'&sort='+document.getElementById('sort').value+
		'&originalcode='+document.getElementById('originalcode').value
		;
	   var url= '<c:url value="/nups/ajax/searchNUPSCodeGroups.jsp"/>?ts=' + today;
	   new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               $('nupsdata').innerHTML=resp.responseText;
	           }
	       }
	   );  
	}
	function registerLevel(id){
		var today = new Date();
		var active=0;
		if(document.getElementById(id).checked){
			active=1;
		}
		var params = 'nups=' + id.split(";")[1]+'&level=' + id.split(";")[2]+'&active='+active;
	    var url= '<c:url value="/nups/ajax/registerLevel.jsp"/>?ts=' + today;
	    new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               
	           },
	  		   onError: function(){
	  			   alert("error");
	  		   }
	       }
	    );  
	}
	function registerGroup(id){
		var today = new Date();
		var nups=id.split(";")[2];
		group1=document.getElementById('selgroup;0;'+nups).value;
		group2=document.getElementById('selgroup;1;'+nups).value;
		group3=document.getElementById('selgroup;2;'+nups).value;
		var params = 'nups=' + nups+'&group1='+group1+'&group2='+group2+'&group3='+group3;
	    var url= '<c:url value="/nups/ajax/registerGroup.jsp"/>?ts=' + today;
	    new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               
	           },
	  		   onError: function(){
	  			   alert("error");
	  		   }
	       }
	    );  
	}
	function downloadNUPS(){
	   var today = new Date();
	   var params = 'code=' + document.getElementById('code').value+
				'&extension='+document.getElementById('extension').value+
				'&sectioncode='+document.getElementById('section').value+
   				'&keywords='+document.getElementById('keywords').value+
   				'&level='+document.getElementById('level').value+
   				'&group='+document.getElementById('group').value+
   				'&parent='+document.getElementById('parent').value+
   				'&limit='+document.getElementById('limit').value+
   				'&csu='+document.getElementById('csu').checked+
   				'&originalcode='+document.getElementById('originalcode').value
	   				;
	   window.open('<c:url value="/nups/ajax/downloadNUPSCodes.jsp"/>?'+params);
	}
		
	function showNUPSChildren(code){
		emptyNUPS();
		document.getElementById('parent').value=code;
		searchNUPS();
		getNomenclatureLabel2();
	}
	
	function emptyNUPS(){
		document.getElementById('code').value='';
		document.getElementById('extension').value='';
		document.getElementById('section').value='';
		document.getElementById('keywords').value='';
		document.getElementById('originalcode').value='';
		document.getElementById('level').value='';
		document.getElementById('group').value='';
		document.getElementById('parent').value='';
		$('nomenclatureText2').innerHTML='';
		$('nupsdata').innerHTML='';
	}
	
	function showNUPSCode(code){
		emptyNUPS();
		document.getElementById('code').value=code;
		searchNUPS();
		getNomenclatureLabel2();
	}

	function editNUPS(code){
		   document.getElementById('nupsdata').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
		   var today = new Date();
		   var params = 'code=' + code;
		   var url= '<c:url value="/nups/ajax/editNUPSCode.jsp"/>?ts=' + today;
		   new Ajax.Request(url,{
		           method: "POST",
		           parameters: params,
		           onSuccess: function(resp){
		               $('nupsdata').innerHTML=resp.responseText;
		               getNomenclatureLabel();
		               editNUPSExtended(code);
		           }
		       }
		   );  
		}

	function editNUPSExtended(code){
		   document.getElementById('nupsdataextended').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
		   var today = new Date();
		   var params = 'code=' + code+'&sectioncode='+document.getElementById('e-sectioncode').value;
		   var url= '<c:url value="/nups/ajax/editNUPSCodeExtended.jsp"/>?ts=' + today;
		   new Ajax.Request(url,{
		           method: "POST",
		           parameters: params,
		           onSuccess: function(resp){
		               $('nupsdataextended').innerHTML=resp.responseText;
		           }
		       }
		   );  
		}

	function newNUPSExtended(){
		   document.getElementById('nupsdataextended').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
		   var today = new Date();
		   var params = 'sectioncode='+document.getElementById('e-sectioncode').value;
		   var url= '<c:url value="/nups/ajax/newNUPSCodeExtended.jsp"/>?ts=' + today;
		   new Ajax.Request(url,{
		           method: "POST",
		           parameters: params,
		           onSuccess: function(resp){
		               $('nupsdataextended').innerHTML=resp.responseText;
		           }
		       }
		   );  
		}

	function extendNUPS(code){
		   document.getElementById('nupsdata').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
		   var today = new Date();
		   var params = 'code=' + code;
		   var url= '<c:url value="/nups/ajax/extendNUPSCode.jsp"/>?ts=' + today;
		   new Ajax.Request(url,{
		           method: "POST",
		           parameters: params,
		           onSuccess: function(resp){
		               $('nupsdata').innerHTML=resp.responseText;
		               getNomenclatureLabel();
		               extendNUPSExtended(code);
		           }
		       }
		   );  
		}

	function extendNUPSExtended(code){
		   document.getElementById('nupsdataextended').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
		   var today = new Date();
		   var params = 'code=' + code+'&sectioncode='+document.getElementById('e-sectioncode').value;
		   var url= '<c:url value="/nups/ajax/extendNUPSCodeExtended.jsp"/>?ts=' + today;
		   new Ajax.Request(url,{
		           method: "POST",
		           parameters: params,
		           onSuccess: function(resp){
		               $('nupsdataextended').innerHTML=resp.responseText;
		           }
		       }
		   );  
		}

	function newNUPS(){
	   document.getElementById('nupsdata').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
	   var today = new Date();
	   var params = 'code=' + code;
	   var url= '<c:url value="/nups/ajax/newNUPSCode.jsp"/>?ts=' + today;
	   new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               $('nupsdata').innerHTML=resp.responseText;
	               newNUPSExtended();
	           }
	       }
	   );  
	}
	
	function logout(){
		if(window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>')){
			window.location.href='<%=sCONTEXTPATH%>/nupsLogin.jsp';
		}
	}

	function searchParentCode(){
	 <%if(SH.cs("prestationNomenclatureTable","nups").equalsIgnoreCase("nups")){%>
	     openPopupLocal("/_common/search/searchNUPS.jsp&PopupWidth=800&PopupHeight=500&ts=<%=getTs()%>&VarCode2=e-parent");
	 <%}%>
	    document.getElementById("e-parent").focus();
	}

	function openPopupLocal(page,width,height,title,parameters){
		var url = "<c:url value='/popup.jsp'/>?Page="+page;
		if(width!=undefined){
			url+= "&PopupWidth="+width;
		}
		else{
			width=1;
		}
		if(height!=undefined){
			url+= "&PopupHeight="+height;
		}
		else{
			height=1;
		}
	    if(title==undefined){
		  if(page.indexOf("&") < 0){
		    title = page.replace("/","_");
		    title = replaceAll(title,".","_");
		  }
		  else{
		    title = replaceAll(page.substring(1,page.indexOf("&")),"/","_");
		    title = replaceAll(title,".","_");
		  }
		}
		if(!parameters || parameters.length==0){
			parameters="toolbar=no,status=yes,scrollbars=yes,resizable=yes,width="+width+",height="+height+",menubar=no";
		}
		popup = window.open(url,title,parameters);
		if(width && height){
			popup.resizeTo(width,height);
		}
		popup.moveBy(2000,2000);
		return popup;
	}
	function replaceAll(s,s1,s2){
		while(s.indexOf(s1) > -1){
		  s = s.replace(s1,s2);
		}
		return s;
	}
	function getNomenclatureLabel(){
	    document.getElementById('nomenclatureText').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
	    var today = new Date();
	    var code=document.getElementById("e-parent").value;
	    var params = 'code=' + code;
	    var url= '<c:url value="/system/ajax/getNomenclatureText.jsp"/>?ts=' + today;
	    new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               var label = eval('('+resp.responseText+')');
	               $('nomenclatureText').innerHTML=label.text;
	           }
	       }
	    );  
	}
	
	function getNomenclatureLabel2(){
	    document.getElementById('nomenclatureText2').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
	    var today = new Date();
	    var code=document.getElementById("parent").value;
	    var params = 'code=' + code;
	    var url= '<c:url value="/system/ajax/getNomenclatureText.jsp"/>?ts=' + today;
	    new Ajax.Request(url,{
	           method: "POST",
	           parameters: params,
	           onSuccess: function(resp){
	               var label = eval('('+resp.responseText+')');
	               $('nomenclatureText2').innerHTML=label.text;
	           }
	       }
	    );  
	}
	
	function checkSaveNUPS(){
		if(document.getElementById('dosetlabels') && document.getElementById('dosetlabels').value==1){
			setNUPSLabels();
		}
		else{
			saveNUPS();
		}
	}
	
	function saveNUPS(){
		var today = new Date();
		var params = 'code=' + document.getElementById("e-code").value+
					 '&csu=' + document.getElementById("e-csu").checked+
					 '&extension=' + document.getElementById("e-extension").value+
					 '&originalcode=' + document.getElementById("e-originalcode").value+
					 '&domain=' + document.getElementById("e-domain").value+
					 '&fr=' + encodeURI(document.getElementById("e-fr").value)+
					 '&en=' + encodeURI(document.getElementById("e-en").value)+
					 '&es=' + encodeURI(document.getElementById("e-es").value)+
					 '&pt=' + encodeURI(document.getElementById("e-pt").value)+
					 '&section=' + document.getElementById("e-sectioncode").value+
					 '&parent=' + document.getElementById("e-parent").value;
		var url= '<c:url value="/nups/ajax/saveNUPSCode.jsp"/>?ts=' + today;
		new Ajax.Request(url,{
		        method: "POST",
		        parameters: params,
		        onSuccess: function(resp){
		            $('nupsdata').innerHTML=resp.responseText;
		            document.getElementById('nupsmessage').innerHTML ='';
		        }
		    }
		);  
	}
	function addDCI(){
		for(n=1;n<50;n++){
			if(!document.getElementById("dci"+n)){
				body=document.getElementById('dcitable').getElementsByTagName('tbody')[0];
				row=body.insertRow();
				cell=row.insertCell();
				cell.className="admin";
				cell.appendChild(document.createTextNode('DCI '+n));
				cell=row.insertCell();
				cell.className="admin2";
				input=document.createElement("input");
				input.type="text";
				input.name="dci"+n;
				input.id="dci"+n;
				input.size=50;
				input.className="text";
				cell.appendChild(input);
				cell=row.insertCell();
				cell.className="admin";
				cell.appendChild(document.createTextNode('Dose '+n));
				cell=row.insertCell();
				cell.className="admin2";
				input=document.createElement("input");
				input.type="text";
				input.name="dose"+n;
				input.id="dose"+n;
				input.size=10;
				input.className="text";
				cell.appendChild(input);
				break;
			}
		}
	}
	function setNUPSLabels(){
		if(document.getElementById("e-domain").value=='MED'){
			var today = new Date();
			var params = 'comment=' + document.getElementById("comment").value+
						 '&domain=' + document.getElementById("e-domain").value+
  				         '&presentation=' + document.getElementById('presentation').value+
						 '&code=' + document.getElementById("e-code").value;
			for(n=1;n<50;n++){
				if(document.getElementById("dci"+n) && document.getElementById("dci"+n).value.length>0){
					params+='&dci'+n+'=' + encodeURI(document.getElementById("dci"+n).value)+
					        '&dose'+n+'=' + encodeURI(document.getElementById("dose"+n).value);
				}
				else{
					break;
				}
			}
			if(document.getElementById("title-fr") && document.getElementById("title-fr").value.length>0){
				params+="&title-fr="+document.getElementById("title-fr").value;
			}
			if(document.getElementById("title-en") && document.getElementById("title-en").value.length>0){
				params+="&title-en="+document.getElementById("title-en").value;
			}
			if(document.getElementById("title-es") && document.getElementById("title-es").value.length>0){
				params+="&title-es="+document.getElementById("title-es").value;
			}
			if(document.getElementById("title-pt") && document.getElementById("title-pt").value.length>0){
				params+="&title-pt="+document.getElementById("title-pt").value;
			}
			var url= '<c:url value="/nups/ajax/setNUPSLabels.jsp"/>?ts=' + today;
			new Ajax.Request(url,{
			        method: "POST",
			        parameters: params,
			        onSuccess: function(resp){
			    	    document.getElementById('nupsmessage').innerHTML = "<img style='vertical-align: middle' height='12px' src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading";
						var label = eval('('+resp.responseText+')');
						$('e-fr').value=label.fr;
						$('e-en').value=label.en;
						$('e-es').value=label.es;
						$('e-pt').value=label.pt;
						window.setTimeout("saveNUPS();",500);
			        }
			    }
			);  
		}
		else{
			window.setTimeout("saveNUPS();",500);
		}
	}

	function deleteNUPS(){
		if(window.confirm('<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>')){
			var today = new Date();
			var params = 'code=' + document.getElementById("e-code").value+
						 '&extension=' + document.getElementById("e-extension").value;
			var url= '<c:url value="/nups/ajax/deleteNUPSCode.jsp"/>?ts=' + today;
			new Ajax.Request(url,{
			        method: "POST",
			        parameters: params,
			        onSuccess: function(resp){
			            $('nupsdata').innerHTML=resp.responseText;
			        }
			    }
			);  
		}
	}
	
	function setLanguage(language){
		var params = 'language=' + language;
		var url= '<c:url value="/nups/ajax/setLanguage.jsp"/>';
		new Ajax.Request(url,{
		   method: "POST",
		   parameters: params,
		   onSuccess: function(resp){
		       window.location.reload();
		   }
		}
		);  
	}

	  function dotranslate(targetlanguage,term,targetfield){
	      var today = new Date();
	      var url= '<c:url value="/system/getTranslation.jsp"/>?sourcelanguage=<%=sWebLanguage%>&targetlanguage='+targetlanguage+'&labelvalue='+term+'&ts='+today;
	      new Ajax.Request(url,{
	          method: "POST",
	          postBody: "",
	          onSuccess: function(resp){
	              var label = eval('('+resp.responseText+')');
	              document.getElementById(targetfield).value=label.translation.toUpperCase();
	          },
	          onFailure: function(){
	              alert("Error in function translate() => AJAX");
	          }
	      }
		  );
	  }
	  
	  function openPopup(url,width,height,title,parameters){
	    if(!parameters || parameters.length==0){
	    	parameters="toolbar=no,status=yes,scrollbars=yes,resizable=yes,width="+width+",height="+height+",menubar=no";
	    }
	    popup = window.open(url,title,parameters);
	    if(width && height){
	    	popup.resizeTo(width,height);
	    }
	    popup.moveTo((screen.width-width)/2,(screen.height-height)/2);
	    return popup;
	  }

	  function checkOriginalCode(){
		  var code=document.getElementById('e-originalcode').value;
		  if(code.indexOf('R-')>-1){
	    	  openPopup("https://mor.nlm.nih.gov/RxNav/search?searchBy=NameOrCode&searchTerm="+code.substring(2),800,600,"NUPSRef");
		  }
		  else if(code.indexOf('I-')>-1){
	    	  openPopup("https://www.icd10data.com/search?codebook=icd10pcs&s="+code.substring(2),800,600,"NUPSRef");
		  }
		  else if(code.indexOf('C-')>-1){
	    	  openPopup("https://www.google.com/search?q=cpt+"+code.substring(2),800,600,"NUPSRef");
		  }
		  else if(code.indexOf('H-')>-1){
	    	  openPopup("https://www.aapc.com/codes/hcpcs-codes/"+code.substring(2),800,600,"NUPSRef");
		  } 
		  else if(code.indexOf('U-')>-1){
	    	  openPopup("https://www.google.com/search?q=UB04+code+"+code.substring(2),800,600,"NUPSRef");
		  }
		  else if(code.indexOf('L-')>-1){
	    	  openPopup("https://loinc.org/search/?s="+code.substring(2),800,600,"NUPSRef");
		  }
	  }

</script>