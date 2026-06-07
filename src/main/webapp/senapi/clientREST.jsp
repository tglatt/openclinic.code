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
	String url="http://localhost/openclinic/senapi/serviceREST.jsp";
	PostMethod method = new PostMethod(url);
	//Ajouter le paramètre key avec comme valeur le message fourni
	String msg = request.getParameter("message");
	if(msg==null) msg="Erreur: paramètre message pas fourni";
	method.addParameter("key",msg);
	//Ajouter le paramètre format pour définir le format de la réponse
	String format = request.getParameter("format");
	if(format==null) format="xml";
	method.addParameter("format",format);
	// ************** Fin ******************//
	
	//Exécution de la méthode avec le client http
	client.executeMethod(method);
	
	//Récupérer la réponse reçue
	String sResponse = method.getResponseBodyAsString();
	
	// ************** A modifier selon la logique ******************//
	//Affichage de la réponse après interprétation comme XML
	if(format.equalsIgnoreCase("xmlhtml")){
		out.print(sResponse);
	}
	else if(format.equalsIgnoreCase("json")){
		JSONObject json = new JSONObject(sResponse);
		out.println(json.getJSONObject("message").getString("key"));
	}
	else{
		Document xmlResponse = DocumentHelper.parseText(sResponse);
		out.println(xmlResponse.getRootElement().elementText("key"));
	}
	// ************** Fin ******************//
%>