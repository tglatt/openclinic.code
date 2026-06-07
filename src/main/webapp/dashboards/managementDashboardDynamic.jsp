<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<%
		String sDoc = SH.cs("templateSource","")+"dashboards.xml";
		SAXReader reader = new SAXReader(false);
		Document document = reader.read(new URL(sDoc));
		Element root = document.getRootElement();
		Iterator elements = root.elementIterator("group");
		int cell=0;
		while (elements.hasNext()){
		    Element group = (Element) elements.next();
		    Iterator dashboards = group.elementIterator("dashboard");
		    while(dashboards.hasNext()){
		    	Element dashboard = (Element) dashboards.next();
		    	if(SH.cs("activatedDashboards","").contains(";"+dashboard.attributeValue("id")+";")){
		    		if(cell==0){
		    			out.println("<tr>");
		    		}
		    		out.println("<td width='33%' height='200px' style='border-style: solid;border-width: 1px;border-color: blue;'>");
		    		SH.setIncludePage(customerInclude(dashboard.attributeValue("file")),pageContext);
					out.println("</td>");
		    		if(cell<2){
		    			cell++;
		    		}
		    		else{
		    			out.println("</tr>");
		    			cell=0;
		    		}
		    	}
		    }
		}
	%>
</table>
<center>
	<p><a href='javascript:configureDashboard();'><%=getTran(request,"web","congiguredashboards",sWebLanguage) %></a></p>
</center>

<script>
	function configureDashboard(){
		window.opener.location.href='<%=sCONTEXTPATH%>/main.do?Page=userprofile/manageDashboards.jsp';
		window.close();
	}
</script>