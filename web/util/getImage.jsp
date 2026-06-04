<%@page import="java.io.FileInputStream"%>
<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String SCANDIR_BASE = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_basePath","/var/tomcat/webapps/openclinic/scan");
    String SCANDIR_TO   = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo","to");
    String uid=SH.p(request,"uid");
    FileInputStream fis = new FileInputStream(SCANDIR_BASE+"/"+SCANDIR_TO+"/"+uid);
    byte[] buffer = new byte[4096];
    int bytesRead;
    response.setContentType("image/png");
    ServletOutputStream os = response.getOutputStream();
    while ((bytesRead = fis.read(buffer)) != -1) {
        os.write(buffer, 0, bytesRead);
    }
    os.flush();
    os.close();
%>