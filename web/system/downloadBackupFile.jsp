<%@page import="java.io.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	File backupFile = new File(SH.cs("backupFile","/mnt/nas/db.tar"));
	response.setContentType("application/octet-stream; charset=windows-1252");
	response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinic_Backup"+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".bkp\"");
	ServletOutputStream os = response.getOutputStream();
	BufferedReader br = new BufferedReader(new FileReader(backupFile));
	while(br.ready()){
		os.write(br.read());
	}
	os.flush();
	os.close();
%>