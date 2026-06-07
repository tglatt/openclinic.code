<%@page import="net.admin.Service"%>
<%
	String servicecode=SH.c(request.getParameter("servicecode"));
	if(servicecode.length()>0 && Service.getService(servicecode)!=null){
		out.println("<EXISTS>");
	}
%>