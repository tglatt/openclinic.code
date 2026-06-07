<%@page import="javax.json.*,
				org.apache.http.*,
				org.apache.http.util.*,
				org.apache.http.entity.*,
				org.apache.http.client.*,
				org.apache.http.impl.client.*,
				org.apache.http.client.methods.*"%>

<%
	HttpClient client = HttpClients.createDefault();
	HttpPost req = new HttpPost("http://localhost/openclinic/api/obr/getToken.jsp");
	String aut = java.util.Base64.getEncoder().encodeToString("4:overmeire".getBytes("utf-8"));
	req.setHeader("Authorization", "Basic "+aut);
	HttpResponse resp = client.execute(req);
	HttpEntity entity = resp.getEntity();
	String s = EntityUtils.toString(entity);
	JsonReader jr = Json.createReader(new java.io.StringReader(s));
	String token = jr.readObject().getString("token");
%>
{
	"token":"<%=token %>"
}