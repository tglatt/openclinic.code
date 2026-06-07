<%@include file="/includes/validateUser.jsp"%>
<%@page import="javax.json.*,
				org.apache.http.*,
				org.apache.http.util.*,
				org.apache.http.entity.*,
				org.apache.http.client.*,
				org.apache.http.impl.client.*,
				org.apache.http.client.methods.*"%>
<%
	HttpClient client = HttpClients.createDefault();
	HttpPost req = new HttpPost("http://localhost/openclinic/api/getUser.jsp?userid=4");

    
    HttpResponse resp = client.execute(req);
    HttpEntity entity = resp.getEntity();
    String s = EntityUtils.toString(entity);
    JsonReader jr = Json.createReader(new java.io.StringReader(s));
    JsonObject jo = jr.readObject();
    System.out.println(jo.toString());
%>