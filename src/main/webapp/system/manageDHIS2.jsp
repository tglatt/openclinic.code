<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.openclinic.system.Config,java.util.Hashtable,java.util.Enumeration" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission(out,"system.management","select",activeUser)%>
<%!
	private String writeConfigRow(String labtype,String defaultValue){
		String sOut="<tr class='admin2'>";
		sOut+="<td valign='top'>"+labtype+"</td><td><textarea onKeyup='resizeTextarea(this,10);' class='text' cols='100', rows='1' name='config$"+labtype+"'>"+MedwanQuery.getInstance().getConfigString(labtype,defaultValue)+"</textarea></td></tr>";
		sOut+="<tr><td colspan='2'><hr/></td></tr>";
		return sOut;
	}
	private String writeConfigRowLink(String labtype,String defaultValue,String link){
		String sOut="<tr class='admin2'>";
		sOut+="<td valign='middle'>"+labtype+" <img style='vertical-align: middle' src='"+sCONTEXTPATH+"/_img/icons/icon_search.png' onclick='"+link+"'/></td><td><textarea onKeyup='resizeTextarea(this,10);' class='text' cols='100', rows='1' name='config$"+labtype+"'id='config$"+labtype+"'>"+MedwanQuery.getInstance().getConfigString(labtype,defaultValue)+"</textarea></td></tr>";
		sOut+="<tr><td colspan='2'><hr/></td></tr>";
		return sOut;
	}
	private String writeConfigRowPassword(String labtype,String defaultValue){
		String sOut="<tr class='admin2'>";
		sOut+="<td valign='top'>"+labtype+"</td><td><input autocomplete='one-time-code' class='text' size='100', rows='1' type='password' name='config$"+labtype+"' id='config$"+labtype+"' value='"+MedwanQuery.getInstance().getConfigString(labtype,defaultValue)+"'/></td></tr>";
		sOut+="<tr><td colspan='2'><hr/></td></tr>";
		return sOut;
	}
%>
<%
	String serverid=SH.p(request,"serverid");
	boolean updated=false;
	if(request.getParameter("save")!=null){
		//Save configuration
		Enumeration e = request.getParameterNames();
		while(e.hasMoreElements()){
			String sParName=(String)e.nextElement();
			if(sParName.split("\\$").length==2 && sParName.split("\\$")[0].equalsIgnoreCase("config")){
				MedwanQuery.getInstance().setConfigString(sParName.split("\\$")[1],checkString(request.getParameter(sParName)));
			}
		}
	}
%>
<form name="searchForm" method="post">
  <%=writeTableHeader("web.manage","manageDHIS2",sWebLanguage,"doBack();")%>
  <table width="100%" class="menu" cellspacing="0" cellpadding="1">
	<%
		HashSet servers = new HashSet();
		servers.add(";Default");
		String sDoc = SH.cs("templateSource","")+SH.cs("dhis2document","dhis2.bi.xml");
		SAXReader reader = new SAXReader(false);
		Document document = reader.read(new URL(sDoc));
		Element root = document.getRootElement();
		Iterator iServers = root.elementIterator("dataset");
		while(iServers.hasNext()){
			Element dataset = (Element)iServers.next();
			if(SH.c(dataset.attributeValue("dhis2serverprefix")).length()>0){
				servers.add(dataset.attributeValue("dhis2serverprefix")+";"+dataset.attributeValue("dhis2serverprefix"));
			}
		}
		if(servers.size()>1){
			out.println("<tr valign='middle'><td>Server</td><td valign='middle'>");
			Iterator i = servers.iterator();
			while(i.hasNext()){
				String server = (String)i.next();
				out.println("<input "+(serverid.equalsIgnoreCase(server.split(";")[0])?"checked":"")+" type='radio' class='text' name='serverid' value='"+server.split(";")[0].trim()+"' onclick='searchForm.submit()'/>"+server.split(";")[1]+" ");
			}
			out.println("</td></tr>");
			out.println("<tr><td colspan='2'><hr/></td></tr>");
		}
		
		out.println("<tr>");
		out.println("<td valign='middle'>enableDHIS2</td><td valign='middle'><input class='text' type='radio' "+(SH.cs("enableDHIS2","0").equalsIgnoreCase("0")?"checked":"")+" name='config$enableDHIS2' value='0'/>0 <input class='text' type='radio' "+(SH.cs("enableDHIS2","0").equalsIgnoreCase("1")?"checked":"")+" name='config$enableDHIS2' value='1'/>1</td></tr>");
		out.println("<tr><td colspan='2'><hr/></td></tr>");
		out.println(writeConfigRow(serverid+"dhis2_server_uri","https://play.dhis2.org/demo"));
		out.println(writeConfigRow(serverid+"dhis2_server_api","/api"));
		out.println(writeConfigRow(serverid+"dhis2_server_port","443"));
		out.println(writeConfigRow(serverid+"dhis2_server_username","demo"));
		out.println(writeConfigRowPassword(serverid+"dhis2_server_pwd","demo"));
		out.println(writeConfigRowLink(serverid+"dhis2_orgunit","","javascript:exploreDHIS2(\""+serverid.trim()+"\")"));
		out.println(writeConfigRow("dhis2_department_orgunits",""));
		out.println(writeConfigRow("dhis2document","dhis2.bi.xml"));
		out.println(writeConfigRow("dhis2_truststore","/temp/keystore"));
		out.println(writeConfigRowPassword("dhis2_truststore_pass","changeme"));
		out.println(writeConfigRow("sendFullDHIS2DataSets","0"));
	%>
  </table>
  <input type='submit' name='save' value='<%=getTranNoLink("web","save",sWebLanguage)%>'/>
</form>
	
<script>
	function exploreDHIS2(prefix){
		if(document.getElementById('config$'+prefix+'dhis2_orgunit').value.length>0){
			openPopup("dhis2/analyzeDHIS2JSON.jsp&serverid="+prefix+"&updatefield=config$"+prefix+"dhis2_orgunit&getOrganisationunitsButton=1&organisationunitname="+document.getElementById('config$'+prefix+'dhis2_orgunit').value+"&nodatasets=1",800,600);
		}
		else{
			openPopup("dhis2/analyzeDHIS2JSON.jsp&serverid="+prefix+"&updatefield=config$"+prefix+"dhis2_orgunit&nodatasets=1",800,600);
		}
	}
</script>