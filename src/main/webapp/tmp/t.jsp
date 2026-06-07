<%@include file="/includes/validateUser.jsp"%>
<%
	User user = User.get(4);
	user.stop = "";
	user.saveToDB();
%>