<%@page import="be.openclinic.system.SH"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.io.File"%>
<%@page import="java.io.FileReader"%>
<%@page import="java.io.BufferedReader"%>
<%
	File file = new File(SH.cs("backupFile","/tmp/db.tar"));
	BufferedReader reader = new BufferedReader(new FileReader(file));
	response.setContentType("application/octet-stream; charset=windows-1252");
	response.setHeader("Content-Disposition", "Attachment;Filename=\""+new SimpleDateFormat("yyyyMMddHHmmss").format(file.lastModified())+" - "+file.getName()+"\"");
	ServletOutputStream os = response.getOutputStream();
	while(reader.ready()){
	    os.write(reader.read());
	}
	os.flush();
	os.close();

%>