<%@include file="/includes/helper.jsp"%>
<%@page import="org.dom4j.*"%>
<%!
	//Déclaration de méthodes propres à la page jsp
	
	void sendError(Element root, String errorCode,String errorMessage){
		Element error = root.addElement("error");
		error.setAttributeValue("id", errorCode);
		error.setText(errorMessage);
	}
%>
<%
	Document document = DocumentHelper.createDocument();
	Element root = document.addElement("message");
	// Retrouver le paramètre action pour savoir ce qu'il faut faire
	// Les valeurs possibles sont "find", "add" ou "update"
	String action = SH.c(request.getParameter("action"));
	System.out.println("-- "+new SimpleDateFormat("HH:mm:ss").format(new java.util.Date())+" ---------------------------------------------------------------------------");
	System.out.println("############ API CONNECT - Connection from "+request.getRemoteAddr()+" with action = "+action);

	if(action.equalsIgnoreCase("find")){
		//action = find. Récupérer les critères sur base desquels des patients
		// doivent être cherchés
		String sPersonid = SH.c(request.getParameter("personid"));
		String sLastname = SH.c(request.getParameter("lastname"));
		String sFirstname = SH.c(request.getParameter("firstname"));
		String sDateOfBirth = SH.c(request.getParameter("dateofbirth"));
		System.out.println("############ -- personid = "+sPersonid);
		System.out.println("############ -- lastname = "+sLastname);
		System.out.println("############ -- firstname = "+sFirstname);
		System.out.println("############ -- dateofbirth = "+sDateOfBirth);
		if((sPersonid+sLastname+sFirstname+sDateOfBirth).length()==0){
			sendError(root,"002","Aucun critère spécifié");
			System.out.println("############ -> No action provided");
		}
		else{
			List patients = AdminPerson.getAllPatients("", "", "", sLastname, sFirstname, sDateOfBirth, sPersonid, "");
			if(patients.size()==0){
				System.out.println("############ -> No matching patients found");
			}
			Iterator iPatients = patients.iterator();
			int nCount=0;
			while(iPatients.hasNext() && nCount++<100){
				AdminPerson patient = (AdminPerson)iPatients.next();
				System.out.println("############ -> Found patient #"+nCount+" "+patient.getFullName());
				patient = AdminPerson.get(patient.personid);
				//Créer un nouvel élément patient
				Element ePatient = root.addElement("patient");
				//Mettre le personid comme attribut de l'élément patient
				ePatient.setAttributeValue("personid", patient.personid);
				//Insérer les éléments lastname, firstname et dateofbirth dans l'élément patient
				ePatient.addElement("lastname").setText(patient.lastname);
				ePatient.addElement("firstname").setText(patient.firstname);
				ePatient.addElement("gender").setText(patient.gender);
				ePatient.addElement("dateofbirth").setText(patient.dateOfBirth);
				Element eLanguage=ePatient.addElement("language");
				eLanguage.setAttributeValue("code", patient.language);
				eLanguage.setText(getTranNoLink("web.language",patient.language,"en"));
				
				AdminPrivateContact apc = patient.getActivePrivate();
				//Insérer un élément address qui contient les coordonnées du patient
				Element eAddress = ePatient.addElement("address");
				eAddress.addElement("address").setText(apc.address);
				eAddress.addElement("city").setText(apc.city);
				eAddress.addElement("province").setText(apc.province);
				eAddress.addElement("telephone").setText(apc.telephone);
				eAddress.addElement("mobile").setText(apc.mobile);
				eAddress.addElement("email").setText(apc.email);
				Element eCountry=eAddress.addElement("country");
				eCountry.setAttributeValue("code", apc.country);
				eCountry.setText(getTranNoLink("country",apc.country,"en"));
			}
		}
	}
	else if(action.equalsIgnoreCase("add")){
		
	}
	else if(action.equalsIgnoreCase("update")){
		
	}
	else{
		sendError(root,"001","Action '"+action+"': action inconnue");
	}

	String sFileName="api.xml";
	response.setContentType("application/xml");
    response.setHeader("Content-Disposition", "inline; filename=\""+
    					sFileName+"\"");
    ServletOutputStream os = response.getOutputStream();
	byte[] b = document.asXML().getBytes("utf-8");
	for(int n=0;n<b.length;n++){
		os.write(b[n]);
	}
    os.flush();
	os.close();
%>