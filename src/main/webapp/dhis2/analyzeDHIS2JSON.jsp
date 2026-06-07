<%@page import="org.json.*"%>
<%@page import="org.hamcrest.core.IsSame"%>
<%@page import="ocdhis2.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	String datasetname = SH.c(request.getParameter("datasetname"));
	String organisationunitname = SH.c(request.getParameter("organisationunitname"));
	String updatefield = SH.c(request.getParameter("updatefield"));
	String serverid = SH.c(request.getParameter("serverid"));
%>
<%=sJSPROTOTYPE %>
<form name='transactionForm' method='post' action='<%=sCONTEXTPATH%>/<%=request.getRequestURI().contains("main.jsp")?"main":"popup" %>.jsp?Page=dhis2/analyzeDHIS2JSON.jsp'>
	<input type='hidden' name='PopupWidth' id='PopupWidth' value='<%=SH.c(request.getParameter("PopupWidth"))%>'/>
	<input type='hidden' name='PopupHeight' id='PopupHeight' value='<%=SH.c(request.getParameter("PopupHeight"))%>'/>
	<input type='hidden' name='updatefield' id='updatefield' value='<%=SH.c(request.getParameter("updatefield"))%>'/>
	<input type='hidden' name='objectType' id='objectType' value=''/>
	<input type='hidden' name='showchildren' id='showchildren' value=''/>
	<input type='hidden' name='showancestor' id='showancestor' value=''/>
	<input type='hidden' name='objectValue' id='objectValue' value=''/>
	<input type='hidden' name='nodatasets' id='nodatasets' value='<%=SH.p(request,"nodatasets","")%>'/>
	<input type='hidden' name='nostore' id='nostore' value='<%=SH.p(request,"nostore","")%>'/>
	<table width='100%'>
		<tr class='admin'><td colspan='3'><%=getTran(request,"web","analyzedhis2server",sWebLanguage) %></td></tr>
		<%if(SH.p(request,"nodatasets","").length()==0){ %>
			<tr>
				<td class='admin' nowrap  width='1%'><%=getTran(request,"web","getdatasets",sWebLanguage) %>&nbsp;</td>
				<td class='admin2'><input name='datasetname' class='text' type='text' value='<%=datasetname %>'%></td>
				<td class='admin2'><input type='submit' class='button' name='getDatasetsButton' value='<%=getTranNoLink("web","execute",sWebLanguage)%>'/></td>
			</tr>
		<%} %>
		<tr>
			<td class='admin' nowrap  width='1%'><%=getTran(request,"web","getorganisationunits",sWebLanguage) %>&nbsp;</td>
			<td class='admin2' width='1%'><input name='organisationunitname' id='organisationunitname' class='text' type='text' value='<%=organisationunitname %>'%></td>
			<td class='admin2'><input type='submit' class='button' name='getOrganisationunitsButton' id='getOrganisationunitsButton' value='<%=getTranNoLink("web","execute",sWebLanguage)%>'/></td>
		</tr>
	</table>
	<!-- Show the results -->
	<table width='100%'>
		<%
			DHIS2Server server = new DHIS2Server(serverid);
		if(request.getParameter("getOrganisationunitsButton")!=null || SH.c(request.getParameter("showchildren")).equalsIgnoreCase("1") || SH.c(request.getParameter("showancestor")).equalsIgnoreCase("1")){
			out.println("<tr class='admin'>");
			out.println("<td>"+getTran(request,"web","organisationunit",sWebLanguage)+"</td>");
			out.println("<td colspan='2'>orgUnitUid</td>");
			out.println("</tr>");
			try{
				String sUrl="/organisationUnits?paging=false&fields=id,name,ancestors&filter=name:ilike:"+organisationunitname+"&filter=id:ilike:"+organisationunitname+"&rootJunction=OR";
				if(SH.c(request.getParameter("showchildren")).equalsIgnoreCase("1")){
					sUrl="/organisationUnits/"+organisationunitname+"?paging=false&includeChildren=true&fields=id,name,ancestors";
				}
				JSONObject root = server.getJson(sUrl);
				JSONArray orgunits = root.getJSONArray("organisationUnits");
				SortedMap<String,JSONObject> sM = new TreeMap();
				boolean bEmpty=true;
				if(orgunits!=null){
					Iterator iOrgunits = orgunits.iterator();
					while(iOrgunits.hasNext()){
						JSONObject orgunit = (JSONObject)iOrgunits.next();
						sM.put(orgunit.getString("name"),orgunit);
					}
					Iterator<String> iSorts = sM.keySet().iterator();
					while(iSorts.hasNext()){
						JSONObject orgunit = sM.get(iSorts.next());
						if(!request.getParameter("showchildren").equalsIgnoreCase("1") && organisationunitname.length()>0 && !orgunit.getString("id").equals(organisationunitname) && !orgunit.getString("name").toLowerCase().contains(organisationunitname.toLowerCase())){
							continue;
						}
						else if(request.getParameter("showchildren").equalsIgnoreCase("1") && orgunit.getString("id").equals(organisationunitname)){
							continue;
						}
						bEmpty=false;
						String ancestor = "";
						JSONArray ancestors = orgunit.getJSONArray("ancestors");
						if(ancestors!=null){
							Iterator iAncestors = ancestors.iterator();
							while(iAncestors.hasNext()){
								ancestor = ((JSONObject)iAncestors.next()).getString("id");
							}
						}
						out.println("<tr>");
						out.println("<td class='admin'><b>"+orgunit.getString("name")+"</b></td>");
						out.println("<td class='admin2' width='1%' id='"+orgunit.getString("id")+"'>"+orgunit.getString("id")+"&nbsp;</td><td class='admin2'><input class='button' type='button' value='"+getTranNoLink("web","select",sWebLanguage)+"' onclick='selectOrgUnit(\""+orgunit.getString("id")+"\")'/><input class='button' type='button' value='"+getTranNoLink("web","descendants",sWebLanguage)+"' onclick='getDescendants(\""+orgunit.getString("id")+"\")'/>"+(ancestor.length()>0?"<input class='button' type='button' value='"+getTranNoLink("web","ancestor",sWebLanguage)+"' onclick='getAncestor(\""+ancestor+"\")'/>":"")+"</td>");
						out.println("</tr>");
					}
				}
				if(bEmpty && request.getParameter("showchildren").equalsIgnoreCase("1")){
					sUrl="/organisationUnits?paging=false&fields=id,name,ancestors&filter=name:ilike:"+organisationunitname+"&filter=id:ilike:"+organisationunitname+"&rootJunction=OR";
					root = server.getJson(sUrl);
					orgunits = root.getJSONArray("organisationUnits");
					if(orgunits!=null){
						Iterator iOrgunits = orgunits.iterator();
						while(iOrgunits.hasNext()){
							JSONObject orgunit = (JSONObject)iOrgunits.next();
							sM.put(orgunit.getString("name"),orgunit);
						}
						Iterator<String> iSorts = sM.keySet().iterator();
						while(iSorts.hasNext()){
							JSONObject orgunit = sM.get(iSorts.next());
							String ancestor = "";
							JSONArray ancestors = orgunit.getJSONArray("ancestors");
							if(ancestors!=null){
								Iterator iAncestors = ancestors.iterator();
								while(iAncestors.hasNext()){
									ancestor = ((JSONObject)iAncestors.next()).getString("id");
								}
							}
							out.println("<tr>");
							out.println("<td class='admin'><b>"+orgunit.getString("name")+"</b></td>");
							out.println("<td class='admin2' width='1%' id='"+orgunit.getString("id")+"'>"+orgunit.getString("id")+"&nbsp;</td><td class='admin2'><input class='button' type='button' value='"+getTranNoLink("web","select",sWebLanguage)+"' onclick='selectOrgUnit(\""+orgunit.getString("id")+"\")'/>"+(ancestor.length()>0?"<input class='button' type='button' value='"+getTranNoLink("web","ancestor",sWebLanguage)+"' onclick='getAncestor(\""+ancestor+"\")'/>":"")+"</td>");
							out.println("</tr>");
						}
					}
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		else if(request.getParameter("getDatasetsButton")!=null){
				out.println("<tr class='admin'>");
				out.println("<td colspan='3'>dataSets</td>");
				out.println("</tr>");
				try{
					JSONObject root = server.getJson("/dataSets?paging=false&fields=id,name");
					JSONArray datasets = root.getJSONArray("dataSets");
					if(datasets!=null){
						SortedMap<String,JSONObject> sM = new TreeMap();
						Iterator iDatasets = datasets.iterator();
						while(iDatasets.hasNext()){
							JSONObject dataset = (JSONObject)iDatasets.next();
							sM.put(dataset.getString("name"),dataset);
							System.out.println(dataset.getString("name"));
						}
						Iterator<String> iSorts = sM.keySet().iterator();
						while(iSorts.hasNext()){
							JSONObject dataset = sM.get(iSorts.next());
							if(datasetname.length()>0 && !dataset.getString("name").toLowerCase().contains(datasetname.toLowerCase())){
								continue;
							}
							out.println("<tr>");
							out.println("<td class='admin'><b>"+dataset.getString("name")+"</b></td>");
							out.println("<td class='admin2'><a href='javascript:getDataSet(\""+dataset.getString("id")+"\");'>"+dataset.getString("id")+"</a></td>");
							out.println("</tr>");
						}
					}
				}
				catch(Exception e){
					e.printStackTrace();
				}
			}
			else if(request.getParameter("objectType")!=null){
				if(request.getParameter("objectType").equalsIgnoreCase("dataset")){
					JSONObject root = server.getJson("/dataSets/"+request.getParameter("objectValue")+"?paging=false&fields=id,name,categoryCombo[id,name],dataSetElements[dataElement[categoryCombo[id,name],id,name]]");
					SH.syslog(root);
					out.println("<tr class='admin'>");
					out.println("<td>dataSet</td>");
					out.println("<td>"+root.getString("name")+"</td>");
					out.println("<td><a href='javascript:getDataSet(\""+root.getString("id")+"\");'>"+root.getString("id")+"</a></td>");
					out.println("</tr>");
					JSONObject categoryCombo = root.getJSONObject("categoryCombo");
					if(categoryCombo!=null){
						out.println("<tr>");
						out.println("<td class='admin'>categoryCombo</td>");
						out.println("<td class='admin2'><b>"+categoryCombo.getString("name")+"</b></td>");
						out.println("<td class='admin2'><a href='javascript:getCategoryCombo(\""+categoryCombo.getString("id")+"\");'>"+categoryCombo.getString("id")+"</a></td>");
						out.println("</tr>");
					}
					JSONArray dataSetElements = root.getJSONArray("dataSetElements");
					if(dataSetElements!=null){
						SortedMap<String,JSONObject> sM = new TreeMap();
						Iterator idataSetElements = dataSetElements.iterator();
						while(idataSetElements.hasNext()){
							JSONObject dataElement = ((JSONObject)idataSetElements.next()).getJSONObject("dataElement");
							sM.put(dataElement.getString("name"),dataElement);
						}
						Iterator<String> sI = sM.keySet().iterator();
						while(sI.hasNext()){
							JSONObject dataElement = sM.get(sI.next());
							out.println("<tr>");
							out.println("<td class='admin'>dataElement</td>");
							out.println("<td class='admin2'><b>"+dataElement.getString("name")+"</b></td>");
							out.println("<td class='admin2'>"+dataElement.getString("id")+"</td>");
							out.println("</tr>");
							categoryCombo = dataElement.getJSONObject("categoryCombo");
							if(categoryCombo!=null){
								out.println("<tr>");
								out.println("<td class='admin'></td>");
								out.println("<td class='admin2'><i>categoryCombo: "+categoryCombo.getString("name")+"</i></td>");
								out.println("<td class='admin2'><i><a href='javascript:getCategoryCombo(\""+categoryCombo.getString("id")+"\");'>"+categoryCombo.getString("id")+"</a></i></td>");
								out.println("</tr>");
							}
						}
					}
				}
				else if(request.getParameter("objectType").equalsIgnoreCase("categoryCombo")){
					JSONObject root = server.getJson("/categoryCombos/"+request.getParameter("objectValue")+"?paging=false&fields=id,name,categoryOptionCombos[id,name]");
					out.println("<tr class='admin'>");
					out.println("<td>categoryCombo</td>");
					out.println("<td>"+root.getString("name")+"</td>");
					out.println("<td><a href='javascript:getCategoryCombo(\""+root.getString("id")+"\");'>"+root.getString("id")+"</a></td>");
					out.println("</tr>");
					JSONArray categoryOptionCombos = root.getJSONArray("categoryOptionCombos");
					if(categoryOptionCombos!=null){
						SortedMap<String,JSONObject> sM = new TreeMap();
						Iterator iCategoryOptionCombo = categoryOptionCombos.iterator();
						while(iCategoryOptionCombo.hasNext()){
							JSONObject categoryOptionCombo = (JSONObject)iCategoryOptionCombo.next();
							sM.put(categoryOptionCombo.getString("name"),categoryOptionCombo);
						}
						Iterator<String> iS = sM.keySet().iterator();
						while(iS.hasNext()){
							JSONObject categoryOptionCombo = sM.get(iS.next());
							out.println("<tr>");
							out.println("<td class='admin'>categoryOptionCombo</td>");
							out.println("<td class='admin2'><b>"+categoryOptionCombo.getString("name")+"</b></td>");
							out.println("<td class='admin2'>"+categoryOptionCombo.getString("id")+"</td>");
							out.println("</tr>");
						}
					}
					out.println("<tr><td colspan='3'><center><br/><a href='javascript:history.back();'>"+getTran(request,"web","back",sWebLanguage)+"</center></td></tr>");
				}
			}
		%>
	</table>
</form>

<script>
	var oldid='-p';
	function getDataSet(id){
		document.getElementById('objectType').value='dataSet';
		document.getElementById('objectValue').value=id;
		transactionForm.submit();
	}
	function getCategoryCombo(id){
		document.getElementById('objectType').value='categoryCombo';
		document.getElementById('objectValue').value=id;
		transactionForm.submit();
	}
	function selectOrgUnit(id){
		if('<%=SH.p(request,"nostore","")%>'==''){
		    var url = '<c:url value="/dhis2/setOrganisationUnit.jsp"/>'+
		              '?uid='+id+
		              '&ts='+new Date().getTime();
		    new Ajax.Request(url,{
		      parameters: "",
		      onSuccess: function(resp){
		    	  setOrgUnit(id);
		    	  if(document.getElementById('updatefield').value.length>0 && window.opener.document.getElementById(document.getElementById('updatefield').value)){
		    		  window.opener.document.getElementById(document.getElementById('updatefield').value).value=id;
		    	  }
		    	  alert('<%=getTranNoLink("web","orgunitset",sWebLanguage)%>');
		      }
		    });
		}
		else{
	    	  if(document.getElementById('updatefield').value.length>0 && window.opener.document.getElementById(document.getElementById('updatefield').value)){
	    		  window.opener.document.getElementById(document.getElementById('updatefield').value).value=id;
	    		  window.close();
	    	  }
		}
	}
	function getDescendants(id){
		document.getElementById('organisationunitname').value=id;
		document.getElementById('showchildren').value="1";
		transactionForm.submit();
	}
	function getAncestor(id){
		document.getElementById('organisationunitname').value=id;
		document.getElementById('showancestor').value="1";
		transactionForm.submit();
	}
	function setOrgUnit(id){
  	  	if(document.getElementById(oldid)){
		  	document.getElementById(oldid).className='admin2';
		  	document.getElementById(oldid).style.fontWeight='normal';
	  	}
  	  	if(document.getElementById(id)){
		  	document.getElementById(id).className='admingreen';
		  	document.getElementById(id).style.fontWeight='bolder';
		  	oldid=id;
  	  	}
	}
	
	setOrgUnit('<%=SH.cs("dhis2_orgunit","-p")%>');
</script>