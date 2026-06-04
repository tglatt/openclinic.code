<%@page import="be.mxs.common.util.db.MedwanQuery"%>
<%@page import="java.util.*"%>
<%@page import="net.admin.*"%>
<%@page import="org.json.XML"%>
<%@page import="be.mayele.MayeleAPI"%>
<%@page import="org.dom4j.*"%>
<%@include file="/senapi/api.jsp"%>
<%
	//Authentifier utilisateur
	String message = "<error id='401'>Unauthorized access</error>";
	String format = request.getParameter("format");

	if(isAuthorized(request,"mpi.api.select")){
		// ************** A modifier selon le service ******************//
		//Récupérer le body de la requête
		String body = getBody(request);
		//Récupérer les paramètres utiles
		String personid = request.getParameter("personid");
		String lastname = request.getParameter("lastname");
		String firstname = request.getParameter("firstname");
		String dateofbirth = request.getParameter("dateofbirth");
		message = "<persons>";
		//Exécuter la logique, ex. retourner une représentation XML de chaque patient trouvé
		List<AdminPerson> patients = AdminPerson.getAllPatients("", "", "", lastname, firstname, dateofbirth, personid, "");
		Iterator<AdminPerson> ipatients = patients.iterator();
		while(ipatients.hasNext()){
			AdminPerson patient = ipatients.next();
			message += patient.toXml();
		}
		message += "</persons>";
		// ************** Fin ******************//
	}

	//Formater le résultat de la logique
	if(format!=null && format.equalsIgnoreCase("xmlhtml")){
		message = MayeleAPI.XML2HTML(message);
		//Renvoyer le résultat formaté dans la réponse
		response.addHeader("Content-Type", "text/html");
	}
	else if(format!=null && format.equalsIgnoreCase("json")){
		//Renvoyer le résultat formaté dans la réponse
		message = XML.toJSONObject(message).toString(4);
		response.addHeader("Content-Type", "application/json");
	}
	else{
		//Renvoyer le résultat formaté dans la réponse
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