<%@include file="/includes/validateUser.jsp"%>
<%=sJSPROTOTYPE %>
<%
	String activatedDashboards=";";
	if(request.getParameter("submitButton")!=null){
		Enumeration ePars = request.getParameterNames();
		while(ePars.hasMoreElements()){
			String parameter = (String)ePars.nextElement();
			if(parameter.startsWith("cb.")){
				activatedDashboards+=parameter.split("\\.")[1]+";";
			}
		}
		MedwanQuery.getInstance().setConfigString("activatedDashboards", activatedDashboards);
	}
%>

<form name='transactionform' method='post'>
	<table width='100%'>
		<tr class='admin'><td colspan='4'><%=getTran(request,"web","congiguredashboards",sWebLanguage) %></td></tr>
	<%
		String sDoc = SH.cs("templateSource","")+"dashboards.xml";
		SAXReader reader = new SAXReader(false);
		Document document = reader.read(new URL(sDoc));
		Element root = document.getRootElement();
		Iterator elements = root.elementIterator("group");
		while (elements.hasNext()){
		    Element group = (Element) elements.next();
		    out.println("<tr class='admin'><td colspan='4'>"+getTran(request,"dashboardgroup",group.attributeValue("labelid"),sWebLanguage)+"</td></tr>");
		    Iterator dashboards = group.elementIterator("dashboard");
		    while(dashboards.hasNext()){
		    	Element dashboard = (Element) dashboards.next();
			    out.println("<tr><td class='admin' width='1%'><input type='checkbox' "+(SH.cs("activatedDashboards","").contains(";"+dashboard.attributeValue("id")+";")?"checked":"")+" class='text' name='cb."+dashboard.attributeValue("id")+"'></td><td class='admin2' width='1%' nowrap><b>["+dashboard.attributeValue("id")+"]</b></td><td class='admin2'><b>"+getTran(request,"dashboard",dashboard.attributeValue("labelid"),sWebLanguage)+"</b></td><td width='66%' class='admin2' id='dashboard."+dashboard.attributeValue("id")+"''><img height='24px' title='"+getTranNoLink("web","preview",sWebLanguage)+"' style='vertical-align: middle' onclick='showDashboard(\""+dashboard.attributeValue("file")+"\")' src='"+sCONTEXTPATH+"/_img/icons/icon_eye2.png'/>&nbsp;&nbsp;"+getTran(request,"dashboardinfo",dashboard.attributeValue("id"),sWebLanguage)+"</td></tr>");
		    }
		}
	%>
	</table>
	<input type='submit' class='button' name='submitButton' value='<%=getTranNoLink("web","save",sWebLanguage) %>'/>
</form>

<script>
	function showDashboard(file){
		openPopup(file,200,200);
	}
</script>