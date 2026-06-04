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
import be.openclinic.common.ObjectReference;
import be.openclinic.finance.Prestation;
import be.openclinic.system.SH;

public class GraphQLMedicalService extends GraphQL{
	String id;
	String uuid;
	String code;
	String name;
	String type;
	double price=0;
	String careType;
	int frequency;
	int patientCategory;
	String level;
	Date validityFrom;
	Date validityTo;
	String userid="4";
	
	public String getUserid() {
		return userid;
	}
	public void setUserid(String userid) {
		this.userid = userid;
	}
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
	public String getCode() {
		return code;
	}
	public void setCode(String code) {
		this.code = code;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public double getPrice() {
		return price;
	}
	public void setPrice(double price) {
		this.price = price;
	}
	public String getCareType() {
		return careType;
	}
	public void setCareType(String careType) {
		this.careType = careType;
	}
	public int getFrequency() {
		return frequency;
	}
	public void setFrequency(int frequency) {
		this.frequency = frequency;
	}
	public int getPatientCategory() {
		return patientCategory;
	}
	public void setPatientCategory(int patientCategory) {
		this.patientCategory = patientCategory;
	}
	public String getLevel() {
		return level;
	}
	public void setLevel(String level) {
		this.level = level;
	}
	public Date getValidityFrom() {
		return validityFrom;
	}
	public void setValidityFrom(Date validityFrom) {
		this.validityFrom = validityFrom;
	}
	public Date getValidityTo() {
		return validityTo;
	}
	public void setValidityTo(Date validityTo) {
		this.validityTo = validityTo;
	}
	
	public GraphQLMedicalService(JsonObject jo) {
		id=getJsonString(jo,"id");
		uuid=getJsonString(jo,"uuid");
		code=getJsonString(jo,"code");
		name=getJsonString(jo,"name");
		type=getJsonString(jo,"type");
		try {
			price = Double.parseDouble(getJsonString(jo,"price"));
		}
		catch(Exception e) {
			e.printStackTrace();
		};
		careType=getJsonString(jo,"careType");
		frequency=getJsonInt(jo,"frequency");
		patientCategory=getJsonInt(jo,"patientCategory");
		level=getJsonString(jo,"level");
		validityFrom=getJsonDateTime(jo,"validityFrom");
		validityTo=getJsonDateTime(jo,"validityTo");
	}

	public Prestation getPrestation() {
		Prestation prestation = new Prestation();
		prestation.setNomenclature(code);
		prestation.setCode(code);
		prestation.setDescription(name);
		prestation.setType(type);
		prestation.setPrice(price);
		prestation.setUpdateUser(userid);
		prestation.setReferenceObject(new ObjectReference(type,""));
		prestation.setInvoiceGroup(careType);
		prestation.setPrestationClass("act");
		prestation.setInactive(0);
		if(validityFrom!=null && validityFrom.after(new Date())) prestation.setInactive(1);
		if(validityTo!=null && validityTo.after(new Date())) prestation.setInactive(1);
		return prestation;
	}
	
	public void savePrestation() {
		Prestation prestation = getPrestation();
		Prestation dbPrestation = Prestation.getByCode(prestation.getCode());
		if(dbPrestation.hasValidUid()) {
			prestation.setUid(dbPrestation.getUid());
		}
		prestation.store();
	}

	public static Vector<GraphQLMedicalService> get(String uuid, String code, String name, String type){
		int offset=0;
		Vector<GraphQLMedicalService> items = new Vector<GraphQLMedicalService>();
		try {
			while(true) {
				JsonArray ja = getJsonArray(uuid, code, name, type, offset);
				for(int n=0;n<ja.size();n++) {
					JsonObject medicalService = ja.getJsonObject(n).getJsonObject("node");
					items.add(new GraphQLMedicalService(medicalService));
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
	
	public static JsonArray getJsonArray(String uuid, String code, String name, String type, int offset) throws ClientProtocolException, IOException {
		OpenIMIS oi = new OpenIMIS(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/api_fhir_r4",SH.cs("OpenIMISBaseLogin", "TestOCGA"),SH.cs("OpenIMISBasePassword", ""));
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/graphql");
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+oi.getToken());
		StringBuffer sb = new StringBuffer();
		sb.append("{\"query\":\"{medicalServices(offset: "+offset);
		String criteria = "";
		if(SH.c(uuid).length()>0) {
			criteria+=", uuid: \\\""+uuid+"\\\"";
		}
		if(SH.c(code).length()>0) {
			criteria+=", code: \\\""+code+"\\\"";
		}
		if(SH.c(name).length()>0) {
			criteria+=", name_Icontains: \\\""+name+"\\\"";
		}
		if(SH.c(type).length()>0) {
			criteria+=", type: \\\""+type+"\\\"";
		}
		if(criteria.length()>0) {
			sb.append(criteria);
		}
		sb.append("){edges{node{id uuid code name type price careType frequency patientCategory level validityFrom validityTo}}}}\",\"variables\":null}");
		StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(sb.toString()));
	   	req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    JsonObject jo = jr.readObject();
	    return jo.getJsonObject("data").getJsonObject("medicalServices").getJsonArray("edges");
	}

}
