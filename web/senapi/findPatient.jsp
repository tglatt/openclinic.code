<%@page import="org.json.JSONObject"%>
<%@page import="org.dom4j.*"%>
<%@page import="org.apache.commons.httpclient.*"%>
<%@page import="org.apache.commons.httpclient.methods.*"%>
<%
	//implémentation d'un client RESTR générique
	//création d'un client http
	HttpClient client = new HttpClient();

	// ************** A modifier selon le service voulu ******************//
	//création d'une méthode POST avec un URL et des paramètres
	String url="http://localhost/openclinic/senapi/REST_patient.jsp";
	PostMethod method = new PostMethod(url);
	//Ajouter le paramètre key avec comme valeur le message fourni
	String personid = request.getParameter("personid");
	if(personid==null) personid="";
	method.addParameter("personid",personid);
	// ************** Fin ******************//

	//Ajouter le paramètre format pour définir le format de la réponse
	String format = request.getParameter("format");
	if(format==null) format="xml";
	method.addParameter("format",format);
	
	//Exécution de la méthode avec le client http
	client.executeMethod(method);
	
	//Récupérer la réponse reçue
	String sResponse = method.getResponseBodyAsString();
	
	//Affichage de la réponse après interprétation comme XML
	if(format.equalsIgnoreCase("xmlhtml")){
		out.print(sResponse);
	}
	// ************** A modifier selon la logique ******************//
	else if(format.equalsIgnoreCase("json")){
		JSONObject json = new JSONObject(sResponse);
		String lastname = json.getJSONObject("person").getString("lastname");
		String firstname = json.getJSONObject("person").getString("firstname");
		String dob = json.getJSONObject("person").getString("dateofbirth");
		out.println("<b>"+lastname+", "+firstname+"</b> °"+dob);
	}
	else{
		Document xmlResponse = DocumentHelper.parseText(sResponse);
		String lastname = xmlResponse.getRootElement().elementText("lastname");
		String firstname = xmlResponse.getRootElement().elementText("firstname");
		String dob = xmlResponse.getRootElement().elementText("dateofbirth");
		out.println("<b>"+lastname+", "+firstname+"</b> °"+dob);
	}
	// ************** Fin ******************//
%>