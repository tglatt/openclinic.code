package be.openclinic.openimis;

import java.io.IOException;
import java.util.Date;
import java.util.Vector;

import javax.json.Json;
import javax.json.JsonArray;
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

public class GraphQLInsureePolicy extends GraphQL {
	String id;
	String uuid;
	int status;
	String stage;
	Date startDate;
	Date expiryDate;
	String productCode;
	String productName;
	String officerCode;
	String officerLastName;
	String officerOtherNames;
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getUuid() {
		return uuid;
	}
	public void setUuid(String uuid) {
		this.uuid = uuid;
	}
	public int getStatus() {
		return status;
	}
	public void setStatus(int status) {
		this.status = status;
	}
	public String getStage() {
		return stage;
	}
	public void setStage(String stage) {
		this.stage = stage;
	}
	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}
	public Date getExpiryDate() {
		return expiryDate;
	}
	public void setExpiryDate(Date expiryDate) {
		this.expiryDate = expiryDate;
	}
	public String getProductCode() {
		return productCode;
	}
	public void setProductCode(String productCode) {
		this.productCode = productCode;
	}
	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}
	public String getOfficerCode() {
		return officerCode;
	}
	public void setOfficerCode(String officerCode) {
		this.officerCode = officerCode;
	}
	public String getOfficerLastName() {
		return officerLastName;
	}
	public void setOfficerLastName(String officerLastName) {
		this.officerLastName = officerLastName;
	}
	public String getOfficerOtherNames() {
		return officerOtherNames;
	}
	public void setOfficerOtherNames(String officerOtherNames) {
		this.officerOtherNames = officerOtherNames;
	}
	
	public GraphQLInsureePolicy() {
		
	}
	
	public GraphQLInsureePolicy(JsonObject jo) {
		id=getJsonString(jo,"id");
		uuid=getJsonString(jo,"uuid");
		status=getJsonInt(jo,"status");
		stage=getJsonString(jo,"stage");
		startDate=getJsonDate(jo, "startDate");
		expiryDate=getJsonDate(jo, "expiryDate");
		if(!jo.isNull("product")){
			productCode=getJsonString(jo.getJsonObject("product"),"code");
			productName=getJsonString(jo.getJsonObject("product"),"name");
		}
		if(!jo.isNull("officer")){
			officerCode=getJsonString(jo.getJsonObject("officer"),"code");
			officerLastName=getJsonString(jo.getJsonObject("officer"),"lastName");
			officerOtherNames=getJsonString(jo.getJsonObject("officer"),"otherNames");
		}
	}

	public static Vector<GraphQLInsureePolicy> get(String uuid){
		int offset=0;
		Vector<GraphQLInsureePolicy> items = new Vector<GraphQLInsureePolicy>();
		try {
			while(true) {
				JsonArray ja = getJsonArray(uuid, offset);
				for(int n=0;n<ja.size();n++) {
					JsonObject policy = ja.getJsonObject(n).getJsonObject("node");
					items.add(new GraphQLInsureePolicy(policy));
				}
				if(ja.size()<100) {
					break;
				}
				offset+=100;
			}
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return items;
	}

	public static JsonArray getJsonArray(String uuid, int offset) throws ClientProtocolException, IOException {
		OpenIMIS oi = new OpenIMIS(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/api_fhir_r4",SH.cs("OpenIMISBaseLogin", "TestOCGA"),SH.cs("OpenIMISBasePassword", "Banjul2022"));
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/graphql");
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+oi.getToken());
		StringBuffer sb = new StringBuffer();
		sb.append("{\"query\":\"{insureePolicies(offset: "+offset);
		String criteria = "";
		if(SH.c(uuid).length()>0) {
			criteria+=", uuid: \\\""+uuid+"\\\"";
		}
		if(criteria.length()>0) {
			sb.append(criteria);
		}
		sb.append("){edges{node{policy{id uuid status stage startDate expiryDate product{code name} officer{code lastName otherNames}}}}}\",\"variables\":null}");
		StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(sb.toString()));
	   	req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    JsonObject jo = jr.readObject();
	    return jo.getJsonObject("data").getJsonObject("insureePolicies").getJsonArray("edges");
	}

}
