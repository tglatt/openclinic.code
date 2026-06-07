<%@include file="/senapi/api.jsp"%>

<%
	//implémentation d'un client RESTR générique
	//création d'un client http
	HttpClient client = new HttpClient();

	// ************** A modifier selon le service voulu ******************//
	//création d'une méthode POST avec un URL et des paramètres
	String url="http://localhost/openclinic/senapi/REST_getLastAdmission.jsp";
	PostMethod method = new PostMethod(url);

	//Ici on ajoute l'authentification
	addAuthorizationHeader(request, method);
	
	//Ajouter le paramètre personid 
	addParameter(request, method, "personid", "");
	String format = addParameter(request, method, "format", "");
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
	else{
		Document xmlResponse = DocumentHelper.parseText(sResponse);
		out.println(xmlResponse.getRootElement().attributeValue("code")+": "+
				xmlResponse.getRootElement().getText());
	}
	// ************** Fin ******************//

%>