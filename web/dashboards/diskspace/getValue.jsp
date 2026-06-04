<%@page import="be.openclinic.system.SystemInfo"%>
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
	diskspace: <%=SystemInfo.getSystemDiskSpace()/factor %>,
}