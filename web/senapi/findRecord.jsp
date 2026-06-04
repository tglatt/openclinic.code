<%@page import="be.openclinic.system.SH"%>
<%@page import="java.util.Iterator"%>
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
	String url="http://localhost/openclinic/senapi/REST_record.jsp";
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
	}
	else{
		Document xmlResponse = DocumentHelper.parseText(sResponse);
		Element record = xmlResponse.getRootElement();
		Iterator<Element> transactions = record.elementIterator("Transaction");
		while(transactions.hasNext()){
			Element transaction = transactions.next();
			Element header = transaction.element("Header");
			if(header!=null){
				String transactiontype = header.elementText("TransactionType");
				String date = header.elementText("UpdateTime");
				out.println(date+": "+SH.getTran(request,"web.occup",transactiontype,"fr")+"<br/>");
			}
		}
	}
	// ************** Fin ******************//
%>