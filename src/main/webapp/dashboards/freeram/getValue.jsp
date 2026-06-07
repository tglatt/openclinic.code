<%@include file="/includes/validateUser.jsp"%>
<%
	String units = SH.p(request,"units");
	double factor=1024;
	if(units.equalsIgnoreCase("mb")){
		factor=1024*1024;
	}
	else if(units.equalsIgnoreCase("gb")){
		factor=1024*1024*1024;
	}
%>
{
	usedram: <%=(Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory())/factor %>,
	freeram: <%=Runtime.getRuntime().freeMemory()/factor %>,
	reservedram: <%=Runtime.getRuntime().totalMemory()/factor %>,
	maxram: <%=Runtime.getRuntime().maxMemory()/factor %>
}