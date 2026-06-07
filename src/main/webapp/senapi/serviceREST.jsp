<%@page import="org.json.XML"%>
<%@page import="be.mayele.MayeleAPI"%>
<%@page import="org.dom4j.*"%>
<%
	// ************** A modifier selon le service ******************//
	//Récupérer les paramètres utiles
	String key = request.getParameter("key");
	String format = request.getParameter("format");
	//Exécuter la logique, ex. retourner le paramètre key avec
	//un message
	Document document = DocumentHelper.createDocument();
	Element root = document.addElement("message");
	root.addAttribute("text", "Clef fournie par le client");
	Element keyElement = root.addElement("key");
	keyElement.setText(key);
	String message = document.asXML();
	// ************** Fin ******************//

	//Formater le résultat de la logique
	if(format!=null && format.equalsIgnoreCase("xmlhtml")){
		message = MayeleAPI.XML2HTML(message);
		//Renvoyer le résultat formatté dans la réponse
		response.addHeader("Content-Type", "text/html");
	}
	else if(format!=null && format.equalsIgnoreCase("json")){
		//Renvoyer le résultat formatté dans la réponse
		message = XML.toJSONObject(message).toString(4);
		response.addHeader("Content-Type", "application/json");
	}
	else{
		//Renvoyer le résultat formatté dans la réponse
		response.addHeader("Content-Type", "application/xml");
	}
    
	ServletOutputStream os = response.getOutputStream();
	byte[] b = message.getBytes("utf-8");
	for(int n=0;n<b.length;n++){
		os.write(b[n]);
	}
    os.flush();
	os.close();
%>