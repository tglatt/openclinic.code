package be.openclinic.openimis;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

public class GraphQLInsuree extends GraphQL {
	String id;
	String uuid;
	String chfId;
	String legacyId;
	Date validityFrom;
	Date validityTo;
	String lastName;
	String otherNames;
	String gender;
	Date dob;
	String region="";
	String lga;
	String district;
	String village;
	String country;
	boolean head;
	String marital;
	String phone;
	String email;
	String profession;
	Vector<GraphQLInsureePolicy> insureePolicies = new Vector<GraphQLInsureePolicy>();

	public String getRegion() {
		return region;
	}
	public void setRegion(String region) {
		this.region = region;
	}
	public String getLga() {
		return lga;
	}
	public void setLga(String lga) {
		this.lga = lga;
	}
	public String getDistrict() {
		return district;
	}
	public void setDistrict(String district) {
		this.district = district;
	}
	public String getVillage() {
		return village;
	}
	public void setVillage(String village) {
		this.village = village;
	}
	public String getCountry() {
		return country;
	}
	public void setCountry(String country) {
		this.country = country;
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
	public String getChfId() {
		return chfId;
	}
	public void setChfId(String chfId) {
		this.chfId = chfId;
	}
	public String getLegacyId() {
		return legacyId;
	}
	public void setLegacyId(String legacyId) {
		this.legacyId = legacyId;
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
	public String getLastName() {
		return lastName;
	}
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	public String getOtherNames() {
		return otherNames;
	}
	public void setOtherNames(String otherNames) {
		this.otherNames = otherNames;
	}
	public String getGender() {
		return gender;
	}
	public void setGender(String gender) {
		this.gender = gender;
	}
	public Date getDob() {
		return dob;
	}
	public void setDob(Date dob) {
		this.dob = dob;
	}
	public boolean isHead() {
		return head;
	}
	public void setHead(boolean head) {
		this.head = head;
	}
	public String getMarital() {
		return marital;
	}
	public void setMarital(String marital) {
		this.marital = marital;
	}
	public String getPhone() {
		return phone;
	}
	public void setPhone(String phone) {
		this.phone = phone;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	public String getProfession() {
		return profession;
	}
	public void setProfession(String profession) {
		this.profession = profession;
	}
	public Vector<GraphQLInsureePolicy> getInsureePolicies() {
		return insureePolicies;
	}
	public void setInsureePolicies(Vector<GraphQLInsureePolicy> insureePolicies) {
		this.insureePolicies = insureePolicies;
	}
	
	public GraphQLInsuree(JsonObject jo) {
		id=getJsonString(jo,"id");
		uuid=getJsonString(jo,"uuid");
		chfId=getJsonString(jo,"chfId");
		legacyId=getJsonString(jo,"legacyId");
		validityFrom=getJsonDateTime(jo,"validityFrom");
		validityTo=getJsonDateTime(jo,"validityTo");
		lastName=getJsonString(jo,"lastName");
		otherNames=getJsonString(jo,"otherNames");
		if(!jo.isNull("gender")) {
			gender=getJsonString(jo.getJsonObject("gender"),"code");
		}
		dob=getJsonDate(jo,"dob");
		if(!jo.isNull("family") && !jo.getJsonObject("family").isNull("location")) {
			JsonObject joTemp = jo.getJsonObject("family").getJsonObject("location");
			if(!joTemp.isNull("name")) {
				village=getJsonString(joTemp,"name").toUpperCase();
				if(!joTemp.isNull("parent") && !joTemp.getJsonObject("parent").isNull("name")){
					district=getJsonString(joTemp.getJsonObject("parent"),"name").toUpperCase();
					if(!joTemp.getJsonObject("parent").isNull("parent") && !joTemp.getJsonObject("parent").getJsonObject("parent").isNull("name")){
						lga=getJsonString(joTemp.getJsonObject("parent").getJsonObject("parent"),"name").toUpperCase();
						if(SH.cs("setup.country", "gm").equalsIgnoreCase("gm")) {
							Connection conn = SH.getAdminConnection();
							try {
								PreparedStatement ps = conn.prepareStatement("select * from gambiazipcodes where district=? and city=?");
								ps.setString(1, district);
								ps.setString(2, village);
								ResultSet rs = ps.executeQuery();
								if(rs.next()) {
									region=rs.getString("province");
									lga=rs.getString("sector");
								}
								rs.close();
								ps.close();
								conn.close();
							} catch (SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
					}
				}
			}
		}
		head=getJsonBoolean(jo,"head");
		marital=getJsonString(jo,"marital");
		phone=getJsonString(jo,"phone");
		email=getJsonString(jo,"email");
		if(!jo.isNull("profession")) {
			profession=getJsonString(jo.getJsonObject("profession"),"profession");
		}
		JsonArray pols = jo.getJsonObject("insureePolicies").getJsonArray("edges");
		for(int n=0;n<pols.size();n++) {
			JsonObject policy = pols.getJsonObject(n).getJsonObject("node").getJsonObject("policy");
			GraphQLInsureePolicy insureePolicy = new GraphQLInsureePolicy(policy);
			getInsureePolicies().add(insureePolicy);
		}
	}
	public static GraphQLInsuree get(String chfId){
		JsonObject insuree = null;
		if(isOpenIMISReachable()) {
			try {
				insuree = getJsonObject(chfId).getJsonObject("node");
				SH.syslog(insuree.toString());
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		if(insuree==null) {
			return null;
		}
		return new GraphQLInsuree(insuree);
	}
	
	public GraphQLInsureePolicy getPolicy(String uuid) {
		for(int n=0;n<getInsureePolicies().size();n++) {
			GraphQLInsureePolicy p = getInsureePolicies().elementAt(n);
			if(p.getUuid().equalsIgnoreCase(uuid)) {
				return p;
			}
		}
		return new GraphQLInsureePolicy();
	}

	public static Vector<GraphQLInsuree> get(String uuid, String lastName, String otherNames, String chfId){
		int offset=0;
		Vector<GraphQLInsuree> items = new Vector<GraphQLInsuree>();
		if(isOpenIMISReachable()) {
			SH.syslog(1.1);
			try {
				while(true) {
					JsonArray ja = getJsonArray(uuid, lastName, otherNames, chfId, offset);
					for(int n=0;n<ja.size();n++) {
						JsonObject insuree = ja.getJsonObject(n).getJsonObject("node");
						items.add(new GraphQLInsuree(insuree));
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
		}
		return items;
	}

	public static JsonArray getJsonArray(String uuid, String lastName, String otherNames, String chfId, int offset) throws ClientProtocolException, IOException {
		OpenIMIS oi = new OpenIMIS(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/api_fhir_r4",SH.cs("OpenIMISBaseLogin", "TestOCGA"),SH.cs("OpenIMISBasePassword", "Banjul2022"));
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/graphql");
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+oi.getToken());
		StringBuffer sb = new StringBuffer();
		sb.append("{\"query\":\"{insurees(offset: "+offset);
		String criteria = "";
		if(SH.c(uuid).length()>0) {
			criteria+=", uuid: \\\""+uuid+"\\\"";
		}
		if(SH.c(lastName).length()>0) {
			criteria+=", lastName_Icontains: \\\""+lastName+"\\\"";
		}
		if(SH.c(otherNames).length()>0) {
			criteria+=", otherNames_Icontains: \\\""+otherNames+"\\\"";
		}
		if(SH.c(chfId).length()>0) {
			criteria+=", chfId: \\\""+chfId+"\\\"";
		}
		if(criteria.length()>0) {
			sb.append(criteria);
		}
		sb.append("){edges{node{validityFrom validityTo legacyId id uuid chfId lastName otherNames gender{code gender} dob head marital phone email profession{profession} insureePolicies{edges{node{policy{id uuid status stage startDate expiryDate product{code name} officer{code lastName otherNames}}}}}}}}}\",\"variables\":null}");
		StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(sb.toString()));
	   	req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    JsonObject jo = jr.readObject();
	    return jo.getJsonObject("data").getJsonObject("insurees").getJsonArray("edges");
	}

	public static JsonObject getJsonObject(String chfId) throws ClientProtocolException, IOException {
		OpenIMIS oi = new OpenIMIS(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+SH.cs("OpenIMISFHIRContext","/api/api_fhir_r4"),SH.cs("OpenIMISBaseLogin", "TestOCGA"),SH.cs("OpenIMISBasePassword", "Banjul2022"));
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+SH.cs("OpenIMISGraphQLContext","/api/graphql"));
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+oi.getToken());
		StringBuffer sb = new StringBuffer();
		sb.append("{\"query\":\"{insurees(chfId: \\\""+chfId+"\\\")");
		sb.append("{edges{node{validityFrom validityTo legacyId id uuid chfId lastName otherNames gender{code gender} dob family{location{code name uuid parent{code name uuid parent{code name uuid parent{code name uuid}}}}} head marital phone email profession{profession} insureePolicies{edges{node{policy{id uuid status stage startDate expiryDate product{code name} officer{code lastName otherNames}}}}}}}}}\",\"variables\":null}");
		StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(sb.toString()));
	   	req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	    SH.syslog(s);
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    JsonObject jo = jr.readObject();
	    if(jo.getJsonObject("data").getJsonObject("insurees").getJsonArray("edges").size()>0) {
	    	return jo.getJsonObject("data").getJsonObject("insurees").getJsonArray("edges").getJsonObject(0);
	    }
	    return null;
	}

}
