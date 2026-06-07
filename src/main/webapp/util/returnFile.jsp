<%@page import="java.io.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	File returnFile = new File(SH.p(request,"filename"));
	response.setContentType("application/octet-stream; charset=windows-1252");
	response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicReport"+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".xlsx\"");
	ServletOutputStream os = response.getOutputStream();
	BufferedReader br = new BufferedReader(new FileReader(returnFile));
	while(br.ready()){
		os.write(br.read());
	}
	os.flush();
	os.close();
%>