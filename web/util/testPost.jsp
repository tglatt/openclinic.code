<%@page import="com.fasterxml.jackson.databind.node.*"%>
<%@page import="org.apache.http.client.*"%>
<%@page import="org.apache.http.impl.client.*"%>
<%@page import="org.apache.http.*"%>
<%@page import="org.apache.http.entity.*"%>
<%@page import="org.apache.http.util.*"%>
<%@page import="org.apache.http.client.methods.*"%>
<%@page import="com.fasterxml.jackson.databind.ObjectMapper"%>
<%@page import="javax.json.*"%>
<%@page import="be.openclinic.openimis.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	SH.syslog("--- REQUEST ---");
	OpenIMIS openIMIS = new OpenIMIS("https://gambiatest.bluesquare.org/api/api_fhir_r4/","TestOCGA","Banjul2022");
	HttpClient client = HttpClients.createDefault();
	String sURL="https://gambiatest.bluesquare.org/api/api_fhir_r4/Claim/";
	SH.syslog("- URL = "+sURL);
	HttpPost req = new HttpPost(sURL);
   	req.setHeader("Content-Type", "application/json");
   	req.setHeader("accept", "application/json");
   	String token = openIMIS.getToken();
   	SH.syslog(" - Token = "+token);
   	req.setHeader("Authorization", "Bearer "+token);
   	JsonNodeFactory factory = JsonNodeFactory.instance;
   	ObjectNode claim = factory.objectNode();
   	claim.put("resourceType", "Claim");
   	claim.put("id",new java.util.Date().getTime()+"");
   	claim.put("created", "2023-10-18");
   	claim.put("status", "active");
   	claim.put("use", "exploratory");
   	//**************************
   	//Patient
   	//**************************
   	ObjectNode patient = JsonNodeFactory.instance.objectNode();
   	patient.put("type","Patient");
   	patient.put("identifier",OpenIMIS.getOpenIMISIdentifierCode("010203040506"));
   	claim.put("patient", patient);
   	//**************************
   	//Provider
   	//**************************
   	ObjectNode provider = JsonNodeFactory.instance.objectNode();
   	provider.put("type","Organization");
   	provider.put("identifier",OpenIMIS.getOpenIMISIdentifierCode("WR1-0001"));
   	claim.put("provider", provider);
   	//**************************
	//Diagnosis
   	//**************************
   	ObjectMapper mapper = new ObjectMapper();
   	ArrayNode diagnosis = mapper.createArrayNode();
  	ObjectNode diag = JsonNodeFactory.instance.objectNode();
   	diag.put("sequence",1);
   	diag.put("diagnosisCodeableConcept",OpenIMIS.getDirectIdentifierCode("https://openimis.github.io/openimis_fhir_r4_ig/CodeSystem/diagnosis-ICD10-level1","G44"));
   	diagnosis.add(diag);
   	claim.put("diagnosis",diagnosis);
   	//**************************
	//Billable period
   	//**************************
   	ObjectNode billablePeriod = JsonNodeFactory.instance.objectNode();
   	billablePeriod.put("start","2023-10-18");
   	billablePeriod.put("end","2023-10-18");
    claim.put("billablePeriod",billablePeriod);
   	//**************************
	//Enterer
   	//**************************
   	ObjectNode enterer = JsonNodeFactory.instance.objectNode();
   	enterer.put("type","Practitioner");
   	enterer.put("identifier",OpenIMIS.getOpenIMISIdentifierCode("TestOCGA"));
   	claim.put("enterer", enterer);
   	//**************************
	//Type
   	//**************************
   	ObjectNode type = JsonNodeFactory.instance.objectNode();
	claim.put("type",OpenIMIS.getDirectIdentifierCode("https://openimis.github.io/openimis_fhir_r4_ig/CodeSystem/claim-visit-type","O"));
   	//**************************
	//Identifier
   	//**************************
   	ArrayNode identifierArray = mapper.createArrayNode();
   	identifierArray.add(OpenIMIS.getOpenIMISIdentifierCode("1.77600"));
   	claim.put("identifier",identifierArray);
   	//**************************
	//Items
   	//**************************
   	ArrayNode itemArray = mapper.createArrayNode();
   	ObjectNode item = JsonNodeFactory.instance.objectNode();
   	item.put("sequence",1);
   	ObjectNode itemCategory = JsonNodeFactory.instance.objectNode();
   	itemCategory.put("text","item");
   	item.put("category",itemCategory);
   	ObjectNode itemProductOrService = JsonNodeFactory.instance.objectNode();
   	itemProductOrService.put("text","ALLE02");
   	item.put("productOrService",itemProductOrService);
   	ObjectNode quantity = JsonNodeFactory.instance.objectNode();
   	quantity.put("value",1);
   	item.put("quantity",quantity);
   	ObjectNode unitPrice = JsonNodeFactory.instance.objectNode();
   	unitPrice.put("value",100.5);
   	unitPrice.put("currency","EUR");
   	item.put("unitPrice",unitPrice);
   	ArrayNode extensionArray = mapper.createArrayNode();
   	ObjectNode extension = JsonNodeFactory.instance.objectNode();
   	ObjectNode valueReference = JsonNodeFactory.instance.objectNode();
   	valueReference.put("type","Medication");
   	ObjectNode itemIdentifier2 = JsonNodeFactory.instance.objectNode();
   	ObjectNode itemIdentifierType2 = JsonNodeFactory.instance.objectNode();
   	ArrayNode itemIdentifierTypeCoding2 = mapper.createArrayNode();
   	itemIdentifierType2.put("coding",itemIdentifierTypeCoding2);
   	ObjectNode itemIdentifierTypeCode2 = JsonNodeFactory.instance.objectNode();
   	itemIdentifierTypeCode2.put("system","https://openimis.github.io/openimis_fhir_r4_ig/CodeSystem/openimis-identifiers");
   	itemIdentifierTypeCode2.put("code","code");
   	itemIdentifier2.put("value","ALLE02");
   	itemIdentifierTypeCoding2.add(itemIdentifierTypeCode2);
   	itemIdentifier2.put("type",itemIdentifierType2);
   	valueReference.put("identifier",itemIdentifier2);
   	extension.put("valueReference",valueReference);
   	extensionArray.add(extension);
   	item.put("extension",extensionArray);
   	itemArray.add(item);
   	
   	claim.put("item",itemArray);
   	

   	//**************************
	//Total
   	//**************************
   	ObjectNode total = JsonNodeFactory.instance.objectNode();
   	total.put("value",100.50);
   	total.put("currency","EUR");
    claim.put("total",total);

	mapper = new ObjectMapper();
	String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(claim);
	System.out.println(json);
	SH.syslog("");

   	String aut = claim.toString();
   	SH.syslog(" - Payload = "+aut);
    StringEntity reqEntity = new StringEntity(aut.replaceAll("'","\""));
    req.setEntity(reqEntity);
    
    HttpResponse resp = client.execute(req);
    HttpEntity entity = resp.getEntity();
    String s = EntityUtils.toString(entity);
	SH.syslog("");
	SH.syslog("");
    System.out.println(s);
    JsonReader jr = Json.createReader(new java.io.StringReader(s));
    JsonObject jo = jr.readObject();
	SH.syslog("--- RESPONSE ---");
	mapper = new ObjectMapper();
	json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(jo);
	System.out.println(json);
%>