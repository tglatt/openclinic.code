<%@page import="ocdhis2.*,java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	if(checkString(request.getParameter("serviceuid")).length()>0){
		session.setAttribute("activeservice", request.getParameter("serviceuid"));
	}
	String sServiceUid = checkString((String)session.getAttribute("activeservice"));
	if(sServiceUid.length()==0){   	
		sServiceUid=activeUser.getParameter("defaultserviceid");
	}
%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'><%=getTran(request,"web","dhis2report",sWebLanguage) %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","service",sWebLanguage) %></td>
            <td class="admin2" nowrap>
                <input type="hidden" name="serviceuid" id="serviceuid" value="<%=sServiceUid%>">
                <input onblur="if(document.getElementById('serviceuid').value.length==0){this.value='';}" class="text" type="text" name="servicename" id="servicename" size="50" value="<%=getTranNoLink("service",sServiceUid,sWebLanguage) %>" >
                <img src="<c:url value="/_img/icons/icon_search.png"/>" class="link" alt="<%=getTran(null,"Web","select",sWebLanguage)%>" onclick="searchService('serviceuid','servicename');">
	            <img src="<c:url value="/_img/icons/icon_delete.png"/>" class="link" alt="<%=getTran(null,"Web","delete",sWebLanguage)%>" onclick="document.getElementById('serviceuid').value='';document.getElementById('servicename').value='';document.getElementById('servicename').focus();">
				<div id="autocomplete_service" class="autocomple"></div>
            </td>                        
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","year",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='year' id='year' class='text' onchange='validateOutput("year",this.value);'>
					<option/>
					<%
						int y=Integer.parseInt(SH.formatDate(new java.util.Date(),"yyyy"));
						for(int count=0;count<10;count++){
							out.println("<option value='"+(y-count)+"'>"+(y-count)+"</option>");
						}
					%>
				</select>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","trimester",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='quarter' id='quarter' class='text' onchange='validateOutput("quarter",this.value);'>
					<option/>
				<%
					int year = Integer.parseInt(SH.formatDate(new java.util.Date(),"yyyy"));
					int quarter=3;
					java.util.Date refdate = SH.parseDate("01/10/"+year);
					if(!refdate.before(new java.util.Date())){
						refdate = SH.parseDate("01/07/"+year);
					}
					if(!refdate.before(new java.util.Date())){
						refdate = SH.parseDate("01/04/"+year);
					}
					if(!refdate.before(new java.util.Date())){
						refdate = SH.parseDate("01/01/"+year);
					}
					int count=0;
					while(count<10){
						out.println("<option value='"+year+"Q"+quarter+"'>"+year+"Q"+quarter+"</option>");
						if(quarter==1){
							quarter=4;
							year--;
						}
						else{
							quarter--;
						}
						count++;
					}
				%>
				</select>
			</select>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","month",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='period' id='period' class='text' onchange='validateOutput("month",this.value);'>
					<option/>
					<%
						long day = 24*3600*1000;
						long month=30*day;
						java.util.Date activeMonth = new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("15/MM/yyyy").format(new java.util.Date()));
						for(int n=0;n<61;n++){
							java.util.Date dPeriod=new java.util.Date(activeMonth.getTime()-n*month);
							out.println("<option value='"+new SimpleDateFormat("yyyyMM").format(dPeriod)+"' "+(n==1?"selected":"")+">"+new SimpleDateFormat("yyyyMM").format(dPeriod)+"</option>");
						}
					%>
				</select> 
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","period",sWebLanguage) %></td>
			<td class='admin2'>
				<%=ScreenHelper.writeDateField("begin", "transactionForm", "", true, false, sWebLanguage, sCONTEXTPATH,"validateOutput('begin',this.value);","oninput='validateOutput(\"begin\",this.value);'") %> <%=getTran(request,"web","to",sWebLanguage) %> <%=ScreenHelper.writeDateField("end", "transactionForm", "", true, false, sWebLanguage, sCONTEXTPATH,"validateOutput('end',this.value);","oninput='validateOutput(\"end\",this.value);'") %>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","format",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='format' id='format' class='text' onchange='validateOutput();'>
					<option value='html' id='output_html'>HTML</option>
					<option value='dhis2server' id='output_dhis2server'><%=getTranNoLink("web","dhis2server",sWebLanguage) %></option>
					<option value='dhis2serverdelete' id='output_dhis2serverdelete'><%=getTranNoLink("web","dhis2serverdelete",sWebLanguage) %></option>
				</select>
				&nbsp;&nbsp;<%=getTran(request,"web","frequency",sWebLanguage) %>: <b><span id='output_period'></span></b>
			</td>
		</tr>
	</table>
	<input type='button' class='button' name='execute' value='<%=getTranNoLink("web","execute",sWebLanguage) %>' onclick='executeReport()'/>
	<p/>
	<a href="javascript:checkAll();"><%=getTran(request,"web","selectall",sWebLanguage) %></a>&nbsp;&nbsp;&nbsp;<a href="javascript:unCheckAll();"><%=getTran(request,"web","deselectall",sWebLanguage) %></a>
	<table width='100%'>
		<%
			String dhis2document=MedwanQuery.getInstance().getConfigString("templateDirectory","/var/tomcat/webapps/openclinic/_common_xml")+"/"+MedwanQuery.getInstance().getConfigString("dhis2document","dhis2.bi.xml");
	        SAXReader reader = new SAXReader(false);
	        Document document;
	        HashSet uids = new HashSet();
			try {
				document = reader.read(new File(dhis2document));
				Element root = document.getRootElement();
				Iterator i = root.elementIterator("dataset");
				while(i.hasNext()){
					Element dataset = (Element)i.next();
					if(!uids.contains(dataset.attributeValue("uid"))){
						String sWarning="";
						if(SH.c(dataset.attributeValue("dhis2serverprefix")).length()>0){
							sWarning = " <img style='vertical-align: middle' src='"+sCONTEXTPATH+"/_img/icons/icon_info.gif' title='"+getTranNoLink("web","destination",sWebLanguage)+": "+SH.cs(dataset.attributeValue("dhis2serverprefix")+"dhis2_server_uri","https://dhis.snis.bi")+"'/>";
						}
						out.println("<tr><td class='admin'><input type='checkbox' name='uid."+dataset.attributeValue("uid")+"' id='"+SH.c(dataset.attributeValue("period"),"monthly")+"."+dataset.attributeValue("uid")+"'/> <font id='font."+dataset.attributeValue("uid")+"' "+(checkString(dataset.attributeValue("color")).length()>0?"color='"+dataset.attributeValue("color")+"'":"")+">"+ScreenHelper.checkString(dataset.attributeValue("label"))+"</font>"+sWarning+"</td></tr>");
						uids.add(dataset.attributeValue("uid"));
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		%>
	</table>
</form>

<script>
	function checkAll(){
		  var elements = document.all;
		  for(n=0;n<elements.length;n++){
			  var element=elements[n];
			  if(element.name && element.name.startsWith("uid.") && !element.checked){
				  element.checked=true;
			  }
		  }
	}
	
	function unCheckAll(){
		  var elements = document.all;
		  for(n=0;n<elements.length;n++){
			  var element=elements[n];
			  if(element.name && element.name.startsWith("uid.") && element.checked){
				  element.checked=false;
			  }
		  }
	}
	
	function executeReport(){
		  var uids="";
		  var elements = document.all;
		  for(n=0;n<elements.length;n++){
			  var element=elements[n];
			  if(element.name && element.name.startsWith("uid.") && element.checked){
				  uids+=element.name.replace("uid.","")+";";
			  }
		  }
		  if(uids.length==0){
			  alert('<%=getTranNoLink("web","check.atleast.one.dataset",sWebLanguage)%>');
		  }
		  else{
		      var URL="/statistics/generateDHIS2Report.jsp&uids="+uids+"&organisationlevel="+document.getElementById("serviceuid").value+"&period="+document.getElementById("period").value+"&format="+document.getElementById("format").value+"&begin="+document.getElementById("begin").value+"&end="+document.getElementById("end").value+"&quarter="+document.getElementById("quarter").value+"&year="+document.getElementById("year").value;
			  openPopup(URL,1024,600,"OpenClinic-DHIS2");
		  }
	}
	
	new Ajax.Autocompleter('servicename','autocomplete_service','assets/findService.jsp',{
	  	minChars:1,
	  	method:'post',
	  	afterUpdateElement: afterAutoCompleteService,
	  	callback: composeCallbackURLService
	});

	function afterAutoCompleteService(field,item){
	  	var regex = new RegExp('[-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.]*-idcache','i');
	  	var nomimage = regex.exec(item.innerHTML);
	  	var id = nomimage[0].replace('-idcache','');
	  	document.getElementById("serviceuid").value = id;
	  	document.getElementById("servicename").value=item.innerHTML.split("$")[1];
	}
	
	function composeCallbackURLService(field,item){
	  	document.getElementById('serviceuid').value
	  	var url = "";
	  	if(field.id=="servicename"){
			url = "text="+field.value;
	  	}
	  	return url;
	}

	function searchService(serviceUidField,serviceNameField){
	  	openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
	  	document.getElementById(serviceNameField).focus();
	}
	
	function validateOutput(type,value){
		if(type=='year' && value==''){
			document.getElementById('begin').value='';
			document.getElementById('end').value='';
			document.getElementById('quarter').value='';
			document.getElementById('period').selectedIndex=2;
		}
		else if(type=='year'){
			document.getElementById('begin').value='';
			document.getElementById('end').value='';
			document.getElementById('quarter').value='';
			document.getElementById('period').value='';
		}
		else if(type=='quarter' && value==''){
			document.getElementById('begin').value='';
			document.getElementById('end').value='';
			document.getElementById('year').value='';
			document.getElementById('period').selectedIndex=2;
		}
		else if(type=='quarter'){
			document.getElementById('period').value='';
			document.getElementById('begin').value='';
			document.getElementById('year').value='';
			document.getElementById('end').value='';
		}
		else if(type=='month' && value==''){
			
		}
		else if(type=='month'){
			document.getElementById('quarter').value='';
			document.getElementById('year').value='';
			document.getElementById('begin').value='';
			document.getElementById('end').value='';
		}
		else if(type=='begin' && value==''){
			document.getElementById('begin').value='';
			document.getElementById('end').value='';
			document.getElementById('year').value='';
			document.getElementById('period').selectedIndex=2;
		}
		else if(type=='begin'){
			document.getElementById('quarter').value='';
			document.getElementById('period').value='';
			document.getElementById('year').value='';
		}
		else if(type=='end' && value==''){
		}
		else if(type=='end' && document.getElementById('begin').value==''){
			document.getElementById('end').value='';
		}
		else if(type=='end'){
			document.getElementById('year').value='';
			document.getElementById('quarter').value='';
			document.getElementById('period').value='';
		}
		if(document.getElementById('end').value.length>0){
			document.getElementById('output_html').selected=true;
			document.getElementById('output_dhis2server').disabled=true;
			document.getElementById('output_dhis2serverdelete').disabled=true;
			document.getElementById('output_period').innerHTML='<%=getTranNoLink("web","undefined",sWebLanguage)%>';
			//Enable all datasets
			var inputs = document.getElementsByTagName('input');
			for(n=0;n<inputs.length;n++){
				if(inputs[n].name.startsWith('hiddenuid')){
					inputs[n].name=inputs[n].name.replace('hiddenuid','uid');
					inputs[n].disabled=false;
					document.getElementById(inputs[n].name.replace('uid','font')).style.textDecoration='';
				}
			}
		}
		else{
			document.getElementById('output_dhis2server').disabled=false;
			document.getElementById('output_dhis2serverdelete').disabled=false;
			if(document.getElementById('begin').value.length>0){
				document.getElementById('output_period').innerHTML='<%=getTranNoLink("web","daily",sWebLanguage)%>';
				var inputs = document.getElementsByTagName('input');
				for(n=0;n<inputs.length;n++){
					if(inputs[n].name.startsWith('uid') || inputs[n].name.startsWith('hiddenuid')){
						if(document.getElementById('format').value=='html' || inputs[n].id.startsWith('daily')){
							if(inputs[n].name.startsWith('hiddenuid')){
								inputs[n].name=inputs[n].name.replace('hiddenuid','uid');
								inputs[n].disabled=false;
								document.getElementById(inputs[n].name.replace('uid','font')).style.textDecoration='';
							}
						}
						else if(inputs[n].name.startsWith('uid')){
							inputs[n].name=inputs[n].name.replace('uid','hiddenuid');
							inputs[n].disabled=true;
							document.getElementById(inputs[n].name.replace('hiddenuid','font')).style.textDecoration='line-through';
						}
					}
				}
			}
			else if(document.getElementById('quarter').value.length>0){
				document.getElementById('output_period').innerHTML='<%=getTranNoLink("web","quarterly",sWebLanguage)%>';
				var inputs = document.getElementsByTagName('input');
				for(n=0;n<inputs.length;n++){
					if(inputs[n].name.startsWith('uid') || inputs[n].name.startsWith('hiddenuid')){
						if(document.getElementById('format').value=='html' || inputs[n].id.startsWith('quarterly')){
							if(inputs[n].name.startsWith('hiddenuid')){
								inputs[n].name=inputs[n].name.replace('hiddenuid','uid');
								inputs[n].disabled=false;
								document.getElementById(inputs[n].name.replace('uid','font')).style.textDecoration='';
							}
						}
						else if(inputs[n].name.startsWith('uid')){
							inputs[n].name=inputs[n].name.replace('uid','hiddenuid');
							inputs[n].disabled=true;
							document.getElementById(inputs[n].name.replace('hiddenuid','font')).style.textDecoration='line-through';
						}
					}
				}
			}
			else if(document.getElementById('year').value.length>0){
				document.getElementById('output_period').innerHTML='<%=getTranNoLink("web","yearly",sWebLanguage)%>';
				var inputs = document.getElementsByTagName('input');
				for(n=0;n<inputs.length;n++){
					if(inputs[n].name.startsWith('uid') || inputs[n].name.startsWith('hiddenuid')){
						if(document.getElementById('format').value=='html' || inputs[n].id.startsWith('yearly')){
							if(inputs[n].name.startsWith('hiddenuid')){
								inputs[n].name=inputs[n].name.replace('hiddenuid','uid');
								inputs[n].disabled=false;
								document.getElementById(inputs[n].name.replace('uid','font')).style.textDecoration='';
							}
						}
						else if(inputs[n].name.startsWith('uid')){
							inputs[n].name=inputs[n].name.replace('uid','hiddenuid');
							inputs[n].disabled=true;
							document.getElementById(inputs[n].name.replace('hiddenuid','font')).style.textDecoration='line-through';
						}
					}
				}
			}
			else{
				document.getElementById('output_period').innerHTML='<%=getTranNoLink("web","monthly",sWebLanguage)%>';
				var inputs = document.getElementsByTagName('input');
				for(n=0;n<inputs.length;n++){
					if(inputs[n].name.startsWith('uid') || inputs[n].name.startsWith('hiddenuid')){
						if(document.getElementById('format').value=='html' || inputs[n].id.startsWith('monthly')){
							if(inputs[n].name.startsWith('hiddenuid')){
								inputs[n].name=inputs[n].name.replace('hiddenuid','uid');
								inputs[n].disabled=false;
								document.getElementById(inputs[n].name.replace('uid','font')).style.textDecoration='';
							}
						}
						else if(inputs[n].name.startsWith('uid')){
							inputs[n].name=inputs[n].name.replace('uid','hiddenuid');
							inputs[n].disabled=true;
							document.getElementById(inputs[n].name.replace('hiddenuid','font')).style.textDecoration='line-through';
						}
					}
				}
			}
		}
	}
	
	validateOutput("month","");
</script>