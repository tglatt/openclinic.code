<%@include file="/includes/validateUser.jsp"%>
<%@page import="javax.json.*,
				org.apache.http.*,
				org.apache.http.util.*,
				org.apache.http.entity.*,
				org.apache.http.client.*,
				org.apache.http.impl.client.*,
				org.apache.http.client.methods.*"
%>
<%
	HttpClient client = HttpClients.createDefault();
	HttpPost req = new HttpPost("http://localhost/openclinic/api/getUser.jsp?userid=4");
	String aut = Base64.getEncoder().encodeToString("4:overmeire".getBytes("utf-8" ));
	req.setHeader("Authorization", "Basic "+aut);
    HttpResponse resp = client.execute(req);
    HttpEntity entity = resp.getEntity();
    String s = EntityUtils.toString(entity);
    JsonReader jr = Json.createReader(new java.io.StringReader(s));
    JsonObject jo = jr.readObject();
    out.print(	"Code d'erreur: <b>"+jo.getString("error")+
    			"</b><br/>Nom de famille: <b>"+jo.getString("lastname")+
    			"</b><br/>Prénom: <b>"+jo.getString("firstname")+
    			"</b><br/>Naissance: <b>"+jo.getString("dateofbirth")+
    			"</b><br/>Sexe: <b>"+jo.getString("gender")+
    			"</b>"
    		);
	
%>