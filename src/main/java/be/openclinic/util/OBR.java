package be.openclinic.util;

import java.io.IOException;
import java.util.Base64;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.ParseException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

public class OBR {
	public static String getToken() throws ParseException, IOException {
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost("http://localhost/openclinic/api/obr/getToken.jsp");
		String aut = Base64.getEncoder().encodeToString("4:overmeire".getBytes("utf-8"));
		req.setHeader("Authorization", "Basic "+aut);
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	    System.out.println("status"+resp.getStatusLine());
	    System.out.println(s);
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    return jr.readObject().getString("token");
	}
}
