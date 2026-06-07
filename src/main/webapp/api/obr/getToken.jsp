<%@page import="be.openclinic.system.SH"%>
<%@page import="javax.json.*,
				org.apache.http.*,
				org.apache.http.util.*,
				org.apache.http.entity.*,
				org.apache.http.client.*,
				org.apache.http.impl.client.*,
				org.apache.http.client.methods.*"%>
<%
	HttpClient client = HttpClients.createDefault();
	HttpPost req = new HttpPost("http://41.79.226.28:8345/ebms_api/login/");
    req.setHeader("Content-Type", "application/json");
    String aut = "{'username':'"+SH.cs("OBR_username","")+"','password':'"+SH.cs("OBR_password","")+"'}";
    StringEntity reqEntity = new StringEntity(aut.replaceAll("'","\""));
    req.setEntity(reqEntity);
    
    HttpResponse resp = client.execute(req);
    HttpEntity entity = resp.getEntity();
    JsonReader jr = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
    JsonObject jo = jr.readObject();
%>
{
	"token":"<%=jo.getJsonObject("result").getString("token") %>"
}