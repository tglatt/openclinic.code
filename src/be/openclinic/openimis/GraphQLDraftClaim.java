package be.openclinic.openimis;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.util.Date;
import java.util.HashSet;
import java.util.UUID;
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

import com.sun.xml.internal.ws.protocol.soap.ClientMUTube;

import be.mxs.common.util.system.HTMLEntities;
import be.openclinic.finance.Debet;
import be.openclinic.finance.PatientInvoice;
import be.openclinic.finance.Prestation;
import be.openclinic.medical.Diagnosis;
import be.openclinic.system.SH;

public class GraphQLDraftClaim {
	String mutationId;
	String mutationLabel;
	String code;
	String insureeId;
	String claimAdminCode;
	Date dateFrom;
	String icdCode;
	String visitType;
	Vector<ClaimItem> services = new Vector<ClaimItem>();
	Vector<ClaimItem> items = new Vector<ClaimItem>();
	String internalId;
	ClaimValidationResult validationResult = new ClaimValidationResult();
	
	public ClaimValidationResult getValidationResult() {
		return validationResult;
	}

	public void setValidationResult(ClaimValidationResult validationResult) {
		this.validationResult = validationResult;
	}

	public static class ClaimItem{
		String code;
		double price;
		double quantity;
	}
	
	public static class ClaimValidationResult{
		public int status;
		public Vector<String> errors = new Vector<String>();
	}

	public String getMutationId() {
		return mutationId;
	}

	public void setMutationId(String mutationId) {
		this.mutationId = mutationId;
	}

	public String getMutationLabel() {
		return mutationLabel;
	}

	public void setMutationLabel(String mutationLabel) {
		this.mutationLabel = mutationLabel;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getInsureeId() {
		return insureeId;
	}

	public void setInsureeId(String insureeId) {
		this.insureeId = insureeId;
	}

	public String getClaimAdminCode() {
		return claimAdminCode;
	}

	public void setClaimAdminCode(String claimAdminCode) {
		this.claimAdminCode = claimAdminCode;
	}

	public Date getDateFrom() {
		return dateFrom;
	}

	public void setDateFrom(Date dateFrom) {
		this.dateFrom = dateFrom;
	}

	public String getIcdCode() {
		return icdCode;
	}

	public void setIcdCode(String icdCode) {
		this.icdCode = icdCode;
	}

	public String getVisitType() {
		return visitType;
	}

	public void setVisitType(String visitType) {
		this.visitType = visitType;
	}

	public Vector<ClaimItem> getServices() {
		return services;
	}

	public void setServices(Vector<ClaimItem> services) {
		this.services = services;
	}

	public Vector<ClaimItem> getItems() {
		return items;
	}

	public void setItems(Vector<ClaimItem> items) {
		this.items = items;
	}

	public String getInternalId() {
		return internalId;
	}

	public void setInternalId(String internalId) {
		this.internalId = internalId;
	}
	
	public GraphQLDraftClaim(String invoiceUid) {
		PatientInvoice invoice = PatientInvoice.get(invoiceUid);
		mutationId=UUID.randomUUID().toString();
		mutationLabel="Create draft claim - "+invoiceUid;
		code=invoiceUid;
		insureeId=invoice.getPatient().getID("natreg");
		claimAdminCode=SH.cs("OpenIMISClaimAdministratorCode", "");
		dateFrom = invoice.getDate();
	   	Vector debets = invoice.getDebets();
	   	HashSet diagnoses = new HashSet();
	   	HashSet encounters = new HashSet();
	   	icdCode="";
	   	if(SH.cs("OpenIMISForceDefaultDiagnosis", "").length()==0) {
		   	for(int n=0;n<debets.size();n++) {
		   		Debet debet = (Debet)debets.elementAt(n);
		   		if(!encounters.contains(debet.getEncounterUid()) && icdCode.split(";").length<5) {
		   			Vector diags = Diagnosis.selectDiagnoses("","",debet.getEncounterUid(),"","","","","","","","","icd10","");
		   			for(int i=0;i<diags.size();i++) {
		   				Diagnosis diag = (Diagnosis)diags.elementAt(i);
		   				String cd = diag.getCode();
		   				if(cd.length()>3) {
		   					cd=cd.substring(0,3);
		   				}
		   				if(icdCode.length()>0) {
		   					icdCode+=";";
		   				}
		   				icdCode += cd; 
		   				if(icdCode.split(";").length>=5) {
		   					break;
		   				}
		   			}
		   			encounters.add(debet.getEncounterUid());
		   		}
		   	}
	   	}
		else {
			icdCode=SH.cs("OpenIMISForceDefaultDiagnosis", "");
		}
		visitType = "O"; //E=Emergency, R=Referral, O=Other - to be added to Invoice!
	   	for(int n=0;n<invoice.getDebets().size();n++) {
	   		Debet debet = (Debet)debets.elementAt(n);
	   		Prestation prestation = debet.getPrestation();
	   		ClaimItem claimItem = new ClaimItem();
	   		claimItem.code=prestation.getNomenclature();
	   	   	if(SH.cs("OpenIMISPriceToClaim", "insurer").equalsIgnoreCase("patient")) {
	   	   		claimItem.price=debet.getAmount()/debet.getQuantity();
	   	   	}
	   	   	else if(SH.cs("OpenIMISPriceToClaim", "insurer").equalsIgnoreCase("insurer")) {
	   	   		claimItem.price=debet.getInsurarAmount()/debet.getQuantity();
	   	   	}
	   	   	else if(SH.cs("OpenIMISPriceToClaim", "insurer").equalsIgnoreCase("total")) {
	   	   		claimItem.price=debet.getTotalAmount()/debet.getQuantity();
	   	   	}
	   	   	claimItem.quantity=debet.getQuantity();
	   	   	if(SH.cs("OpenIMISItemCodes","mlp").contains(prestation.getInvoicegroup().toLowerCase())) {
	   	   		items.add(claimItem);
	   	   	}
	   	   	else {
	   	   		services.add(claimItem);
	   	   	}
	   	}
	   	validationResult = new ClaimValidationResult();
	}
	
	public JsonObject postClaim() throws ClientProtocolException, IOException {
		OpenIMIS oi = new OpenIMIS(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/api_fhir_r4",SH.cs("OpenIMISBaseLogin", "TestOCGA"),SH.cs("OpenIMISBasePassword", ""));
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/graphql");
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+oi.getToken());
		StringBuffer sb = new StringBuffer();
		sb.append("{\"query\": \"mutation {createDraftClaim(input: {");
		sb.append("clientMutationId: \\\""+mutationId+"\\\",");
		sb.append("clientMutationLabel: \\\""+mutationLabel+"\\\",");
		sb.append("code: \\\""+code+"\\\",");
		sb.append("insureeId: \\\""+insureeId+"\\\",");
		sb.append("claimAdminCode: \\\""+claimAdminCode+"\\\",");
		sb.append("dateFrom: \\\""+SH.formatDate(dateFrom,"yyyy-MM-dd")+"\\\",");
		sb.append("icdCode: \\\""+icdCode.split(";")[0]+"\\\",");
		for(int n=1;n<icdCode.split(";").length;n++) {
			sb.append("altIcdCode"+n+": \\\""+icdCode.split(";")[n]+"\\\",");
		}
		sb.append("visitType: \\\""+visitType+"\\\",");
		sb.append("services: [");
		for(int n=0;n<services.size();n++) {
			ClaimItem claimItem = services.elementAt(n);
			sb.append("{serviceCode: \\\""+claimItem.code+"\\\",");
			sb.append("priceAsked: \\\""+claimItem.price+"\\\",");
			sb.append("qtyProvided: \\\""+claimItem.quantity+"\\\"},");
		}
		sb.append("],");
		sb.append("items: [");
		for(int n=0;n<items.size();n++) {
			ClaimItem claimItem = items.elementAt(n);
			sb.append("{itemCode: \\\""+claimItem.code+"\\\",");
			sb.append("priceAsked: \\\""+claimItem.price+"\\\",");
			sb.append("qtyProvided: \\\""+claimItem.quantity+"\\\"},");
		}
		sb.append("]");
		sb.append("}) {clientMutationId internalId}}\",\"variables\":null}");
		StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(sb.toString()));
	   	req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    JsonObject jo = jr.readObject();
	    return jo.getJsonObject("data").getJsonObject("createDraftClaim");
	}
	
	public static JsonArray getValidation(String internalId) throws ClientProtocolException, IOException {
		OpenIMIS oi = new OpenIMIS(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/api_fhir_r4",SH.cs("OpenIMISBaseLogin", "TestOCGA"),SH.cs("OpenIMISBasePassword", ""));
		HttpClient client = HttpClients.createDefault();
		HttpPost req = new HttpPost(SH.cs("OpenIMISBaseURL", "https://gambiatest.bluesquare.org")+"/api/graphql");
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+oi.getToken());
		StringBuffer sb = new StringBuffer();
		sb.append("{\"query\": \"{mutationLogs(id: \\\""+internalId+"\\\"){edges{node{id status error clientMutationId clientMutationLabel clientMutationDetails requestDateTime}}}}\",\"variables\":null}");
		StringEntity reqEntity = new StringEntity(HTMLEntities.htmlentities(sb.toString()));
	   	req.setEntity(reqEntity);
	    HttpResponse resp = client.execute(req);
	    HttpEntity entity = resp.getEntity();
	    String s = EntityUtils.toString(entity);
	    JsonReader jr = Json.createReader(new java.io.StringReader(s));
	    JsonObject jo = jr.readObject();
	    return jo.getJsonObject("data").getJsonObject("mutationLogs").getJsonArray("edges");
	}
	
	public static ClaimValidationResult validateDraftClaim(String uid) throws ClientProtocolException, IOException {
		GraphQLDraftClaim claim = new GraphQLDraftClaim(uid);
		JsonObject jo = claim.postClaim();
		String internalId = jo.getString("internalId");
		JsonArray errors = getValidation(internalId);
		for(int n=0;n<errors.size();n++) {
			JsonObject error = errors.getJsonObject(n).getJsonObject("node");
			SH.syslog(error.toString());
			claim.getValidationResult().status=error.getInt("status");
			if(!error.isNull("error")) {
				InputStream is = new ByteArrayInputStream(error.getString("error").getBytes());
				JsonReader reader = Json.createReader(is);
				JsonArray messages = reader.readArray();
				for(int i=0;i<messages.size();i++) {
					JsonObject message = messages.getJsonObject(i);
					claim.getValidationResult().errors.add(message.getString("message"));
				}
			}
		}
		return claim.getValidationResult();
	}
}
;