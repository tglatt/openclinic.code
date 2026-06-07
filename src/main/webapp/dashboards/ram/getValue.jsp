<%@include file="/includes/validateUser.jsp"%>
{
	usedram: <%=Runtime.getRuntime().totalMemory()-Runtime.getRuntime().freeMemory() %>,
	freeram: <%=Runtime.getRuntime().freeMemory() %>,
	reservedram: <%=Runtime.getRuntime().totalMemory() %>,
	maxram: <%=Runtime.getRuntime().maxMemory() %>
}