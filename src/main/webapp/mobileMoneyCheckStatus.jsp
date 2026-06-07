<%@page import="javax.json.*,
				org.apache.http.*,
				org.apache.http.util.*,
				org.apache.http.entity.*,
				org.apache.http.client.*,
				org.apache.http.impl.client.*,
				org.apache.http.client.methods.*"%>
<%@include file="/includes/helper.jsp"%>
<%
	HttpClient client = HttpClients.createDefault();
	HttpGet req = new HttpGet("https://openclinic.hnrw.org/openclinic/mobileMoneyAPIStatus.jsp?invoice="+request.getParameter("invoice"));
	HttpResponse resp = client.execute(req);
   	HttpEntity body = resp.getEntity();
   	String sBody = EntityUtils.toString(body);
	JsonReader jr = Json.createReader(new java.io.StringReader(sBody));
	JsonObject jo = jr.readObject();
	System.out.println("Received: "+jo.toString());
%>
<%=jo.toString() %>
