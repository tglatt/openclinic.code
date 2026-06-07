<%@page import="be.mxs.common.util.db.MedwanQuery"%>
<%@page import="java.util.*"%>
<%@page import="be.mxs.common.model.vo.healthrecord.TransactionVO"%>
<%@page import="net.admin.AdminPerson"%>
<%@page import="org.json.XML"%>
<%@page import="be.mayele.MayeleAPI"%>
<%@page import="org.dom4j.*"%>
<%
	// ************** A modifier selon le service ******************//
	//Récupérer les paramètres utiles
	String personid = request.getParameter("personid");
	String format = request.getParameter("format");
	//Exécuter la logique, ex. retourner une représentation XML du patient
	String message="<record personid='"+personid+"'>";
	int healthrecordid =
			MedwanQuery.getInstance().getHealthRecordIdFromPersonId(Integer.parseInt(personid));
	Vector<TransactionVO> transactions =
				TransactionVO.getTransactionsForHealthrecordId(healthrecordid);
	Iterator<TransactionVO> itransactions = transactions.iterator();
	while(itransactions.hasNext()){
		TransactionVO transaction = itransactions.next();
		message += transaction.toXml();
	}
	message+="</record>";
	
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