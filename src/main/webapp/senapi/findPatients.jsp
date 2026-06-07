<%@include file="/senapi/api.jsp"%>

<%
	//implémentation d'un client RESTR générique
	//création d'un client http
	HttpClient client = new HttpClient();

	// ************** A modifier selon le service voulu ******************//
	//création d'une méthode POST avec un URL et des paramètres
	String url="http://localhost/openclinic/senapi/REST_patients.jsp";
	PostMethod method = new PostMethod(url);
	//Ajouter le paramètre key avec comme valeur le message fourni
	addParameter(request, method, "personid", "");
	addParameter(request, method, "lastname", "");
	addParameter(request, method, "firstname", "");
	addParameter(request, method, "dateofbirth", "");
	// ************** Fin ******************//
	
	//Ajouter le paramètre format pour définir le format de la réponse
	String format=addParameter(request, method, "format", "xml");
	
	//Exécution de la méthode avec le client http
	
	//Récupérer la réponse reçue
	String sResponse = method.getResponseBodyAsString();
	
	//Affichage de la réponse après interprétation comme XML
	if(format.equalsIgnoreCase("xmlhtml")){
		out.print(sResponse);
	}
	// ************** A modifier selon la logique ******************//
	else if(format.equalsIgnoreCase("json")){
		System.out.println(sResponse);
		JSONObject json = new JSONObject(sResponse);
		if(json.has("error") && json.get("error") instanceof JSONObject){
			out.println(sResponse);
		}
		else if(json.get("persons") instanceof JSONObject){
			if(json.getJSONObject("persons").get("person") instanceof JSONArray){
				JSONArray array = json.getJSONObject("persons").getJSONArray("person");
				for(int n=0;n<array.length();n++){
					JSONObject person = array.getJSONObject(n);
					String lastname = person.getString("lastname");
					String firstname = person.getString("firstname");
					String dob = person.getString("dateofbirth");
					out.println("<b>"+lastname+", "+firstname+"</b> °"+dob+"<br/>");
				}
			}
			else if(json.getJSONObject("persons").get("person") instanceof JSONObject){
				JSONObject person = json.getJSONObject("persons").getJSONObject("person");
				String lastname = person.getString("lastname");
				String firstname = person.getString("firstname");
				String dob = person.getString("dateofbirth");
				out.println("<b>"+lastname+", "+firstname+"</b> °"+dob+"<br/>");
			}
		}
		else{
			out.println("Aucun patient trouvé");
		}
	}
	else{
		Document xmlResponse = DocumentHelper.parseText(sResponse);
		Element persons = xmlResponse.getRootElement();
		if(persons.getName().equalsIgnoreCase("error")){
			out.println(persons.attributeValue("id")+": "+persons.getText());
		}
		else{
			Iterator<Element> ipersons = persons.elementIterator("person");
			while(ipersons.hasNext()){
				Element person = ipersons.next();
				String lastname = person.elementText("lastname");
				String firstname = person.elementText("firstname");
				String dob = person.elementText("dateofbirth");
				out.println("<b>"+lastname+", "+firstname+"</b> °"+dob+"<br/>");
			}
		}		
	}
	// ************** Fin ******************//
%>