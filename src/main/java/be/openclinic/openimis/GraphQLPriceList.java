package be.openclinic.openimis;

import java.io.IOException;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import be.mxs.common.util.system.HTMLEntities;
import be.openclinic.system.SH;

public class GraphQLPriceList {
	public static String getJsonObject(String chfId) throws ClientProtocolException, IOException {
		OpenIMIS oi = new OpenIMIS(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+SH.cs("OpenIMISFHIRContext","/api/api_fhir_r4"),SH.cs("OpenIMISBaseLogin", "TestOCGA"),SH.cs("OpenIMISBasePassword", "Banjul2022"));
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+SH.cs("OpenIMISGraphQLContext","/api/graphql"));
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+oi.getToken());
		StringBuffer sb = new StringBuffer();
		sb.append("{\"query\":\"{healthFacilities(code: \\\""+chfId+"\\\") {edges{node {code name servicesPricelist {name details { edges { node { service { code name }}}}} itemsPricelist { name details { edges { node { item { code name}}}}}}}}}\",\"variables\":null}");
		StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(sb.toString()));
	   	req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	    return s;
	}

}
