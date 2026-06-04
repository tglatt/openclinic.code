<%@page import="org.apache.http.client.*"%>
<%@page import="org.apache.http.impl.client.*"%>
<%@page import="org.apache.http.*"%>
<%@page import="org.apache.http.util.*"%>
<%@page import="org.apache.http.client.methods.*"%>
<%@page import="com.fasterxml.jackson.databind.ObjectMapper"%>
<%@page import="javax.json.*"%>
<%@page import="be.openclinic.openimis.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	SH.syslog("--- REQUEST ---");

	OpenIMIS openIMIS = new OpenIMIS("https://gambiatest.bluesquare.org/api/api_fhir_r4/","TestOCGA","Banjul2022");

	HttpClient client = HttpClients.createDefault();
	String sURL = SH.cs("OpenIMIS_FHIR_BaseURL", "https://gambiatest.bluesquare.org/api/api_fhir_r4/Practitioner/385C7A41-AF3C-4E01-806B-5CC97B15F600");
	SH.syslog("- URL = "+sURL);
	HttpGet req = new HttpGet(sURL);
   	req.setHeader("accept", "application/json");
   	req.setHeader("Authorization", "Bearer "+openIMIS.getToken());
    HttpResponse resp = client.execute(req);
    HttpEntity entity = resp.getEntity();
    String s = EntityUtils.toString(entity);
    System.out.println(s);
    JsonReader jr = Json.createReader(new java.io.StringReader(s));
    JsonObject jo = jr.readObject();
	SH.syslog("--- RESPONSE ---");
	ObjectMapper mapper = new ObjectMapper();
	String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(jo);
	System.out.println(json);

%>