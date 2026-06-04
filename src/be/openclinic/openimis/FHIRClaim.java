package be.openclinic.openimis;

import java.io.UnsupportedEncodingException;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Vector;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;

import be.openclinic.adt.Encounter;
import be.openclinic.finance.Debet;
import be.openclinic.finance.Insurance;
import be.openclinic.finance.PatientInvoice;
import be.openclinic.finance.Prestation;
import be.openclinic.medical.Diagnosis;
import be.openclinic.system.SH;
import net.admin.Service;
import net.admin.User;

public class FHIRClaim {
	public static JsonObject submit(String patientInvoiceUid, String status) { //use = claim|exploratory
		PatientInvoice invoice = PatientInvoice.get(patientInvoiceUid);
		try {
			if(invoice!=null) {
				//Compose Claim JsonObject
			   	JsonNodeFactory factory = JsonNodeFactory.instance;
			   	ObjectNode claim = factory.objectNode();
			   	claim.put("resourceType", "Claim");
			   	claim.put("id",SH.cs("OpenIMISProviderCode","")+"-"+invoice.getInvoiceNumber()+"");
			   	claim.put("created", SH.formatDate(new java.util.Date(),"yyyy-MM-dd"));
			   	claim.put("status", status);
			   	claim.put("use", "claim");
			   	//**************************
			   	//Patient
			   	//**************************
			   	ObjectNode patient = JsonNodeFactory.instance.objectNode();
			   	patient.put("type","Patient");
			   	Insurance openIMISInsurance=null;;
			   	Iterator insurances = invoice.getInsurances().iterator();
			   	while(insurances.hasNext()) {
			   		Insurance insurance = Insurance.get((String)insurances.next());
			   		if(insurance!=null && insurance.getInsurar()!=null && insurance.getInsurar().isOpenIMISConfigured()) {
			   			openIMISInsurance=insurance;
			   		}
			   	}
			   	patient.put("identifier",OpenIMIS.getOpenIMISIdentifierCode(invoice.getPatient().getID("natreg")));
			   	claim.put("patient", patient);
			   	//Provider
			   	//**************************
			   	ObjectNode provider = JsonNodeFactory.instance.objectNode();
			   	provider.put("type","Organization");
			   	provider.put("identifier",OpenIMIS.getOpenIMISIdentifierCode(SH.cs("OpenIMISProviderCode","")));
			   	claim.put("provider", provider);
			   	//**************************
				//Diagnosis
			   	//**************************
			   	ObjectMapper mapper = new ObjectMapper();
			   	ArrayNode diagnosis = mapper.createArrayNode();
			   	//First get all ICD10 diagnoses for the invoice encounters
			   	HashSet diagnoses = new HashSet();
			   	HashSet encounters = new HashSet();
			   	Vector debets = invoice.getDebets();
			   	if(SH.cs("OpenIMISForceDefaultDiagnosis", "").length()==0) {
				   	for(int n=0;n<debets.size();n++) {
				   		Debet debet = (Debet)debets.elementAt(n);
				   		if(!encounters.contains(debet.getEncounterUid())) {
				   			Vector diags = Diagnosis.selectDiagnoses("","",debet.getEncounterUid(),"","","","","","","","","icd10","");
				   			for(int i=0;i<diags.size();i++) {
				   				Diagnosis diag = (Diagnosis)diags.elementAt(i);
				   				String cd = diag.getCode();
				   				if(cd.length()>3) {
				   					cd=cd.substring(0,3);
				   				}
				   				diagnoses.add(cd);
				   			}
				   			encounters.add(debet.getEncounterUid());
				   		}
				   	}
			   	}
				else {
					diagnoses.add(SH.cs("OpenIMISForceDefaultDiagnosis", ""));
				}
			   	//Now we've got a list of 3 letter diagnosis codes
			   	int sequence=1;
			   	Iterator i =diagnoses.iterator();
			   	while(i.hasNext()) {
				  	ObjectNode diag = JsonNodeFactory.instance.objectNode();
				   	diag.put("sequence",sequence++);
				   	diag.put("diagnosisCodeableConcept",OpenIMIS.getDirectIdentifierCode("https://openimis.github.io/openimis_fhir_r4_ig/CodeSystem/diagnosis-ICD10-level1",(String)i.next()));
				   	diagnosis.add(diag);
			   	}
			   	claim.put("diagnosis",diagnosis);
			   	//**************************
				//Billable period
			   	//**************************
			   	ObjectNode billablePeriod = JsonNodeFactory.instance.objectNode();
			   	billablePeriod.put("start",SH.formatDate(invoice.getFirstDebetDate(),"yyyy-MM-dd"));
			   	billablePeriod.put("end",SH.formatDate(invoice.getLastDebetDate(),"yyyy-MM-dd"));
			    claim.put("billablePeriod",billablePeriod);
			   	//**************************
				//Enterer
			   	//**************************
			   	ObjectNode enterer = JsonNodeFactory.instance.objectNode();
			   	enterer.put("type","Practitioner");
			   	enterer.put("identifier",OpenIMIS.getOpenIMISIdentifierCode(User.get(Integer.parseInt(invoice.getUpdateUser())).getParameter("organisationid")));
			   	claim.put("enterer", enterer);
			   	//**************************
				//Type
			   	//**************************
			   	ObjectNode type = JsonNodeFactory.instance.objectNode();
			   	String visitType="O";
			   	Iterator services = invoice.getServices().iterator();
			   	while(services.hasNext()) {
			   		Service service = Service.getService((String)services.next());
			   		if(service!=null && service.getCode3().equalsIgnoreCase("E")) {
			   			visitType="E";
			   			break;
			   		}
			   	}
			   	Iterator iencounters = invoice.getEncounters().iterator();
			   	while(iencounters.hasNext()) {
			   		Encounter encounter = Encounter.get((String)iencounters.next());
			   		if(encounter!=null && SH.cs("OpenIMISReferralOrigins","healthcenter,hospital,otherhospital").toLowerCase().contains(encounter.getOrigin().toLowerCase())) {
			   			visitType="R";
			   			break;
			   		}
			   	}
				claim.put("type",OpenIMIS.getDirectIdentifierCode("https://openimis.github.io/openimis_fhir_r4_ig/CodeSystem/claim-visit-type",visitType));
			   	//**************************
				//Identifier
			   	//**************************
			   	ArrayNode identifierArray = mapper.createArrayNode();
			   	identifierArray.add(OpenIMIS.getOpenIMISIdentifierCode(SH.cs("OpenIMISProviderCode","")+"-"+invoice.getUid()));
			   	claim.put("identifier",identifierArray);
			   	//**************************
				//Items
			   	//**************************
			   	ArrayNode itemArray = mapper.createArrayNode();
			   	double totalPrice=0;
			   	for(int n=0;n<invoice.getDebets().size();n++) {
			   		Debet debet = (Debet)debets.elementAt(n);
			   		if(debet.getInsurance()!=null && debet.getInsurance().getInsurar()!=null && debet.getInsurance().getInsurar().isOpenIMISConfigured()) {
				   		Prestation prestation = debet.getPrestation();
				   	   	ObjectNode item = JsonNodeFactory.instance.objectNode();
				   	   	item.put("sequence",n+1);
				   	   	if(SH.cs("OpenIMISItemCodes","mlp").contains(prestation.getInvoicegroup().toLowerCase())) {
					   	   	ObjectNode itemCategory = JsonNodeFactory.instance.objectNode();
					   	   	itemCategory.put("text","item");
					   	   	item.put("category",itemCategory);
				   	   	}
				   	   	else {
					   	   	ObjectNode itemCategory = JsonNodeFactory.instance.objectNode();
					   	   	itemCategory.put("text","service");
					   	   	item.put("category",itemCategory);
				   	   	}
				   	   	ObjectNode itemProductOrService = JsonNodeFactory.instance.objectNode();
				   	   	itemProductOrService.put("text",prestation.getNomenclature());
				   	   	item.put("productOrService",itemProductOrService);
				   	   	ObjectNode quantity = JsonNodeFactory.instance.objectNode();
				   	   	quantity.put("value",debet.getQuantity());
				   	   	item.put("quantity",quantity);
				   	   	ObjectNode unitPrice = JsonNodeFactory.instance.objectNode();
				   	   	if(SH.cs("OpenIMISPriceToClaim", "insurer").equalsIgnoreCase("patient")) {
				   	   		unitPrice.put("value",debet.getAmount()/debet.getQuantity());
				   	   		totalPrice+=debet.getAmount();
				   	   	}
				   	   	else if(SH.cs("OpenIMISPriceToClaim", "insurer").equalsIgnoreCase("insurer")) {
				   	   		unitPrice.put("value",debet.getInsurarAmount()/debet.getQuantity());
				   	   		totalPrice+=debet.getInsurarAmount();
				   	   	}
				   	   	else if(SH.cs("OpenIMISPriceToClaim", "insurer").equalsIgnoreCase("total")) {
				   	   		unitPrice.put("value",debet.getTotalAmount()/debet.getQuantity());
				   	   		totalPrice+=debet.getTotalAmount();
				   	   	}
				   	   	unitPrice.put("currency",SH.cs("currency", "EUR"));
				   	   	item.put("unitPrice",unitPrice);
				   	   	ArrayNode extensionArray = mapper.createArrayNode();
				   	   	ObjectNode extension = JsonNodeFactory.instance.objectNode();
				   	   	ObjectNode valueReference = JsonNodeFactory.instance.objectNode();
				   	   	if(SH.cs("OpenIMISItemCodes","m").contains(prestation.getInvoicegroup().toLowerCase())) {
					   	   	valueReference.put("type","Medication");
				   	   	}
				   	   	else {
					   	   	valueReference.put("type","ActivityDefinition");
				   	   	}
				   	   	valueReference.put("identifier",OpenIMIS.getOpenIMISIdentifierCode(prestation.getCode()));
				   	   	extension.put("valueReference",valueReference);
				   	   	extensionArray.add(extension);
				   	   	item.put("extension",extensionArray);
				   	   	itemArray.add(item);
			   		}
			   	}
			   	claim.put("item",itemArray);
			   	//**************************
				//Total
			   	//**************************
			   	ObjectNode total = JsonNodeFactory.instance.objectNode();
			   	total.put("value",totalPrice);
		   	   	total.put("currency",SH.cs("currency", "EUR"));
			    claim.put("total",total);
			    
			    //Now submit the claim
				OpenIMIS openIMIS = new OpenIMIS(openIMISInsurance.getInsurar().getOpenIMIS_URL(),openIMISInsurance.getInsurar().getOpenIMIS_UserName(),openIMISInsurance.getInsurar().getOpenIMIS_Password());
				HttpClient client = HttpClients.createDefault();
				HttpPost req = new HttpPost(openIMISInsurance.getInsurar().getOpenIMIS_URL()+"/Claim/");
			   	req.setHeader("Content-Type", "application/json");
			   	req.setHeader("accept", "application/json");
			   	String token = openIMIS.getToken();
			   	req.setHeader("Authorization", "Bearer "+token);
	
				mapper = new ObjectMapper();
				String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(claim);
				System.out.println(json);

				StringEntity reqEntity = new StringEntity(claim.toString());
			    req.setEntity(reqEntity);
			    HttpResponse resp = client.execute(req);
			    HttpEntity entity = resp.getEntity();
			    String s = EntityUtils.toString(entity);
			    JsonReader jr = Json.createReader(new java.io.StringReader(s));
			    JsonObject jo = jr.readObject();
				return jo;
			}
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return null;
	}
	
}
