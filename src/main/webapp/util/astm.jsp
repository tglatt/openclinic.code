<%@page import="java.io.BufferedReader"%><%@include file="/includes/helper.jsp"%><%
	BufferedReader br = request.getReader();
	SH.syslog(request.getRequestURL());
    SH.syslog("----HEADER-----");
    Enumeration<String> headerNames = request.getHeaderNames();
    while (headerNames.hasMoreElements()) {
         String headerName = headerNames.nextElement();
         Enumeration<String> headers = request.getHeaders(headerName);
       while (headers.hasMoreElements()) {
              String headerValue = headers.nextElement();
              SH.syslog(headerName+":"+headerValue);
         }
    }
    SH.syslog("----PARAMETERS-----");
    Map<String, String[]> parameters = request.getParameterMap();
    for(String parameter : parameters.keySet()) {
            String[] values = parameters.get(parameter);
            for (int i=0; i < values.length;i++) {
            	SH.syslog(parameter+":"+values[i]);
            }
    }
    SH.syslog("----BODY-----");
    String line="";
        while((line = br.readLine()) != null) {
        	SH.syslog(line);
        }

%>OK
