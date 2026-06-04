package be.openclinic.openimis;

import java.text.SimpleDateFormat;
import java.util.Enumeration;
import java.util.Hashtable;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;

import be.openclinic.system.SH;

public class OpenIMIS {
	String url, username, password;
	
	public OpenIMIS(String url, String username, String password) {
		this.url=url;
		this.username=username;
		this.password=password;
		
	}
	
	public String getToken() {
		String token = null;
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(url+"/login/");
		   	req.setHeader("Content-Type", "application/json");
		   	req.setHeader("accept", "application/json");
		    String aut = "{'username':'"+username+"','password':'"+password+"'}";
		    StringEntity reqEntity = new StringEntity(aut.replaceAll("'","\""));
		    req.setEntity(reqEntity);
		    
		    HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    JsonObject jo = jr.readObject();
		    token = jo.getString("token");
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	   	return token;
	}
	
	public JsonObject getPatient(String uid) {
		Hashtable ht = new Hashtable();
		ht.put("identifier", uid);
		return getPatients(ht);
	}
	
	public JsonObject getPatients(Hashtable hParameters) {
		JsonObject jo = null;
		try {
			HttpClient client = HttpClients.createDefault();
			String sURL = url+"/Patient/";
			if(hParameters.size()>0) {
				sURL+="?";
				Enumeration<String> e = hParameters.keys();
				while(e.hasMoreElements()) {
					String key = e.nextElement();
					if(!sURL.endsWith("?")) {
						sURL+="&";
					}
					sURL+=key+"="+hParameters.get(key);
				}
			}
			HttpGet req = new HttpGet(sURL);
		   	req.setHeader("accept", "application/json");
		   	req.setHeader("Authorization", "Bearer "+getToken());
		    HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    jo = jr.readObject();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return jo;
	}
	
	public JsonObject getCoverage(String patientid) {
		JsonObject jo = null;
		try {
			HttpClient client = HttpClients.createDefault();
			HttpPost req = new HttpPost(url+"/CoverageEligibilityRequest/");
		   	req.setHeader("Content-Type", "application/json");
		   	req.setHeader("accept", "application/json");
		   	req.setHeader("Authorization", "Bearer "+getToken());
		    String aut = "{'resourceType':'CoverageEligibilityRequest','patient': {'reference':'Patient/"+patientid+"'},'status':'active','created':'"+new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date())+"','purpose':['discovery']}";
		    StringEntity reqEntity = new StringEntity(aut.replaceAll("'","\""));
		    req.setEntity(reqEntity);
		    HttpResponse resp = client.execute(req);
		    HttpEntity entity = resp.getEntity();
		    String s = EntityUtils.toString(entity);
		    JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    jo = jr.readObject();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return jo;
	}
	
	public static ObjectNode getOpenIMISIdentifierCode(String value) {
	   	ObjectNode identifier = JsonNodeFactory.instance.objectNode();
	   	ObjectNode identifierType = JsonNodeFactory.instance.objectNode();
	   	ArrayNode identifierTypeCoding = new ObjectMapper().createArrayNode();
	   	identifierType.put("coding",identifierTypeCoding);
	   	ObjectNode identifierTypeCode = JsonNodeFactory.instance.objectNode();
	   	identifierTypeCode.put("system","https://openimis.github.io/openimis_fhir_r4_ig/CodeSystem/openimis-identifiers");
	   	identifierTypeCode.put("code","Code");
	   	identifier.put("value",value);
	   	identifierTypeCoding.add(identifierTypeCode);
	   	identifier.put("type",identifierType);
	   	return identifier;
	}
	
	public static ObjectNode getIdentifierCode(String system, String value) {
	   	ObjectNode identifier = JsonNodeFactory.instance.objectNode();
	   	ObjectNode identifierType = JsonNodeFactory.instance.objectNode();
	   	ArrayNode identifierTypeCoding = new ObjectMapper().createArrayNode();
	   	identifierType.put("coding",identifierTypeCoding);
	   	ObjectNode identifierTypeCode = JsonNodeFactory.instance.objectNode();
	   	identifierTypeCode.put("system",system);
	   	identifierTypeCode.put("code","Code");
	   	identifier.put("value",value);
	   	identifierTypeCoding.add(identifierTypeCode);
	   	identifier.put("type",identifierType);
	   	return identifier;
	}
	
	public static ObjectNode getDirectIdentifierCode(String system, String code) {
	   	ObjectNode diagnosisCodeableConcept = JsonNodeFactory.instance.objectNode();
	   	ArrayNode codeArray = new ObjectMapper().createArrayNode();
	   	ObjectNode icd10 = JsonNodeFactory.instance.objectNode();
	   	icd10.put("system",system);
	   	icd10.put("code",code);
	   	codeArray.add(icd10);
	   	diagnosisCodeableConcept.put("coding",codeArray);
	   	return diagnosisCodeableConcept;
	}
	
}
