<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="org.json.JSONObject"%>
<%@page import="org.dom4j.*"%>
<%@page import="org.apache.commons.httpclient.*"%>
<%@page import="org.apache.commons.httpclient.methods.*"%>
<%@include file="/senapi/api.jsp"%>

<%
	//implémentation d'un client RESTR générique
	//création d'un client http
	HttpClient client = new HttpClient();

	// ************** A modifier selon le service voulu ******************//
	//création d'une méthode POST avec un URL et des paramètres
	String url="http://openclinic.hnrw.org/openclinic/senapi/REST_cancerRegistry.jsp";
	String uid="";
	
	Connection conn = SH.getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement(
							"select * from transactions where transactiontype=? and"+
							" ts>?");
	ps.setString(1,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSAS_UTERUSCANCER");
	ps.setTimestamp(2, new Timestamp(new java.util.Date().getTime()-SH.getTimeDay()*7));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		TransactionVO transaction = TransactionVO.get(rs.getInt("serverid"), 
																rs.getInt("transactionid"));
		if(!Pointer.getPointer("UTERUSCANCERREGISTRY."+
									transaction.getUid()).contains("code='200'")){
			PostMethod method = new PostMethod(url);
			
			//Ici on ajoute l'authentification
			addAuthorizationHeader(request, method);
			
			//Ici on ajoutera les paramètres
			//Chercher la Transaction régistre cancer de l'urérus suivante qui n'a pas encore
			// été envoyé

			String iva = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_IVA");
			String ivl = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_IVL");
			String mat_status = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MATRIMONIALSTATUS");
			String mat_regimen = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MATRIMONIALREGIMEN");
			String gestity = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_GESTITY");
			String parity = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARITY");
			String contraception = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRACEPTION");
			String duration = transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRACEPTIONDURATION");
			System.out.println("healthrecord="+transaction.getHealthrecordId());
			int age = transaction.getPatient().getAge();
			String date = SH.formatDate(transaction.getUpdateTime(),"yyyyMMddHHmmss");
			String patientid = SH.cs("registryServerId","1")+"."+transaction.getPatientUid();
			
			method.addParameter("patientid", patientid);
			method.addParameter("date", date);
			method.addParameter("iva", iva);
			method.addParameter("ivl", ivl);
			method.addParameter("age", age+"");
			method.addParameter("mat_status",mat_status);
			method.addParameter("mat_regimen", mat_regimen);
			method.addParameter("gestity", gestity);
			method.addParameter("parity", parity);
			method.addParameter("contraception", contraception);
			method.addParameter("duration", duration);
			uid=transaction.getUid();

			addParameter(request, method, "format", "xml");
			
			//Exécution de la méthode avec le client http
			client.executeMethod(method);
			
			//Récupérer la réponse reçue
			String sResponse = method.getResponseBodyAsString();
			
			// ************** A modifier selon la logique ******************//
			//Ici on traitera la réponse
			out.print(sResponse+" pour transaction "+uid+"<br/>");
			Pointer.storePointer("UTERUSCANCERREGISTRY."+uid, sResponse);
			// ************** Fin ******************//
		}		
	}
	rs.close();
	ps.close();
	conn.close();
	// ************** Fin ******************//
	
%>