<%@page import="ocdhis2.*,java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'><%=getTran(request,"web","dhis2report",sWebLanguage) %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","period",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='period' id='period' class='text' onchange='validateOutput();'>
					<%
						long day = 24*3600*1000;
						long month=30*day;
						java.util.Date activeMonth = new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("15/MM/yyyy").format(new java.util.Date()));
						for(int n=0;n<61;n++){
							java.util.Date dPeriod=new java.util.Date(activeMonth.getTime()-n*month);
							out.println("<option value='"+new SimpleDateFormat("yyyyMM").format(dPeriod)+"' "+(n==1?"selected":"")+">"+new SimpleDateFormat("yyyyMM").format(dPeriod)+"</option>");
						}
					%>
				</select> <%=getTran(request,"web","or",sWebLanguage) %>
				<%=ScreenHelper.writeDateField("begin", "transactionForm", "", true, false, sWebLanguage, sCONTEXTPATH, "validateOutput();","oninput='validateOutput();'") %> <%=getTran(request,"web","to",sWebLanguage) %> <%=ScreenHelper.writeDateField("end", "transactionForm", "", true, false, sWebLanguage, sCONTEXTPATH, "validateOutput();","oninput='validateOutput();'") %>
				&nbsp;&nbsp;<%=getTran(request,"web","frequency",sWebLanguage) %>: <b><span id='output_period'></span></b>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran(request,"web","format",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='format' id='format' class='text' onchange='validateOutput();'>
					<option value='html' id='output_html'>HTML</option>
					<option value='htmlfull' id='output_htmlfull'>HTML (<%=getTranNoLink("dhis2","showemptyfields",sWebLanguage) %>)</option>
					<option value='dhis2server' id='output_dhis2server'><%=getTranNoLink("web","dhis2server",sWebLanguage) %></option>
					<option value='dhis2serverdelete' id='output_dhis2serverdelete'><%=getTranNoLink("web","dhis2serverdelete",sWebLanguage) %></option>
				</select>
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
		      var URL="/statistics/generateDHIS2Report.jsp&uids="+uids+"&period="+document.getElementById("period").value+"&format="+document.getElementById("format").value+"&begin="+document.getElementById("begin").value+"&end="+document.getElementById("end").value;
			  openPopup(URL,1024,600,"OpenClinic-DHIS2");
		  }
	}
	
	function validateOutput(){
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
						if(document.getElementById('format').value=='html' || document.getElementById('format').value=='htmlfull' || inputs[n].id.startsWith('daily')){
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
						if(document.getElementById('format').value=='html' || document.getElementById('format').value=='htmlfull' || inputs[n].id.startsWith('monthly')){
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
		<%if(!activeUser.getAccessRightNoSA("dhis2sendtoserver.add")){%>
			document.getElementById('output_dhis2server').disabled=true;
			document.getElementById('output_dhis2serverdelete').disabled=true;
		<%}%>
	}
	
	validateOutput();
</script>