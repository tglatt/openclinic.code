<%@page import="java.nio.file.*"%>
<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.medical.*,be.openclinic.hl7.*,ca.uhn.hl7v2.*,ca.uhn.hl7v2.parser.*,ca.uhn.hl7v2.util.*,ca.uhn.hl7v2.model.*,ca.uhn.hl7v2.model.v251.message.*,ca.uhn.hl7v2.model.v251.group.*" %>
<%
	String fileContent = "";
	try {
	    byte[] bytes = Files.readAllBytes(Paths.get("/tmp/hl7.msg"));
	    fileContent = new String (bytes);
	} catch (IOException e) {
	    //handle exception
	}
	SH.syslog(fileContent);
	HapiContext context = new DefaultHapiContext();
	Parser p = context.getPipeParser();
	Message message = p.parse(fileContent);
	Terser terser = new Terser(message);
	SH.syslog("before MSH-9: "+terser.get("MSH-9"));
	terser.set("MSH-9-2", null);
	terser.set("MSH-9-3", null);
	SH.syslog("after MSH-9: "+terser.get("MSH-9-2"));
	SH.syslog(message.encode().replace("\r","\r\n"));
	
%>