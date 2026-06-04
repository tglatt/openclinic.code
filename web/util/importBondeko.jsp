<%@page import="be.mxs.common.model.vo.healthrecord.util.*,be.mxs.common.model.vo.healthrecord.*"%>
<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%!
	String addValue(String label, String field, ResultSet rs, String consultation){
		try{
			if(SH.c(rs.getString(field)).length()>0){
				String nl=";";
				String lastline=(consultation+",").split("~")[(consultation+",").split("~").length-1];
				if(lastline.split(";").length>5){
					nl="~";
				}
				return label+";"+rs.getString(field).replaceAll(";",",")+nl;
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return "";
	}
%>
<%
	//First connect to SQL server
	Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
	Connection ms_conn = DriverManager.getConnection("jdbc:sqlserver://localhost:1433;databaseName=dmi;username=sa;password=cbmt");
	
	/*******************************
	* Now import patient records
	********************************/
	if(false){
		Connection conn = SH.getAdminConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
		ps = conn.prepareStatement("delete from admin where personid>0");
		ps.execute();
		ps.close();
		ps = conn.prepareStatement("truncate table adminhistory");
		ps.execute();
		ps.close();
		ps = conn.prepareStatement("delete from adminprivate where personid>0");
		ps.execute();
		ps.close();
		ps = conn.prepareStatement("delete from adminwork where personid>0");
		ps.execute();
		ps.close();
		ps = conn.prepareStatement("delete from adminextends where personid>0");
		ps.execute();
		ps.close();
		PreparedStatement ms_ps = ms_conn.prepareStatement("select * from patients");
		ResultSet ms_rs = ms_ps.executeQuery();
		int count=0;
		while(ms_rs.next()){
			if(count % 100 == 0){
				SH.syslog("Imported "+count+" patients");
			}
			count++;
			String immatnew=SH.c(ms_rs.getString("NumFiche"));
			String natreg=SH.c(ms_rs.getString("numidentité")).trim();
			String nom=(ms_rs.getString("Noms")+" "+SH.c(ms_rs.getString("Postnom"))).trim();
			String prenom=SH.c(ms_rs.getString("prénom")).trim();
			String sexe=SH.c(ms_rs.getString("sexe")).trim();
			java.util.Date naissance = ms_rs.getDate("Naissance");
			String etatCivil=SH.c(ms_rs.getString("etatcivil")).trim(); 				//todo
			String nationalite=SH.c(ms_rs.getString("nationalité")).trim();
			String avenue=SH.c(ms_rs.getString("avenue")).trim();
			String quartier=SH.c(ms_rs.getString("quartier")).trim();
			String commune=SH.c(ms_rs.getString("commune")).trim();
			String telephone=SH.c(ms_rs.getString("téléphone")).trim();
			String email=SH.c(ms_rs.getString("messagerie")).trim();
			java.util.Date start = ms_rs.getDate("premièrevisite");
			String history = SH.c(ms_rs.getString("antécédents")).trim();				//todo
			String zone=SH.c(ms_rs.getString("localisation")).trim();					//todo
			String allergie=SH.c(ms_rs.getString("allergie")).trim();					//todo
			String lieunaissance=SH.c(ms_rs.getString("LieuNaissance")).trim();
			//Initialize AdminPerson
			AdminPerson person = new AdminPerson();
			person.setID("immatnew", immatnew);
			person.setID("natreg", natreg);
			person.lastname=nom.toUpperCase();
			person.firstname=prenom.toUpperCase();
			person.gender=sexe.toLowerCase();
			person.language="fr";
			person.dateOfBirth=SH.formatDate(naissance);
			if(nationalite.toUpperCase().contains("RDC")){
				person.nativeCountry="CD";
			}
			person.begin=SH.formatDate(start);
			person.nativeTown=lieunaissance;
			person.comment=etatCivil+"~"+history+"~"+zone+"~"+allergie;
	
			AdminPrivateContact apc = new AdminPrivateContact();
			apc.address=commune+(commune.length()>0?" - ":"")+quartier+(quartier.length()>0?" - ":"")+avenue;
			apc.telephone=telephone;
			apc.email=email;
			person.privateContacts.add(apc);
			
			person.store();
	
		}
		ms_rs.close();
		ms_ps.close();
		conn.close();
	}
	
	if(false){
		Connection oconn = SH.getOpenclinicConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
		ps = oconn.prepareStatement("truncate table oc_encounters");
		ps.execute();
		ps.close();
		ps = oconn.prepareStatement("truncate table oc_encounters_history");
		ps.execute();
		ps.close();
		ps = oconn.prepareStatement("truncate table oc_encounter_services");
		ps.execute();
		ps.close();
		oconn.close();
		PreparedStatement ms_ps = ms_conn.prepareStatement("select * from VisitesMédicales");
		ResultSet ms_rs = ms_ps.executeQuery();
		int count=0;
		while(ms_rs.next()){
			if(count % 100 == 0){
				SH.syslog("Imported "+count+" encounters");
			}
			count++;
			String numvisite = SH.c(ms_rs.getString("NumVisite"));
			String numfiche = SH.c(ms_rs.getString("NumFiche"));
			java.util.Date start = new java.util.Date(ms_rs.getTimestamp("DateCréation").getTime()-new SimpleDateFormat("dd/MM/yyyy").parse("30/12/1899").getTime()+ms_rs.getTimestamp("HeureCréation").getTime());
			String typevisite = ms_rs.getString("TypeVisite");
			String typecas = SH.c(ms_rs.getString("Durée"));			//todo
			String auteur = SH.c(ms_rs.getString("AuteurCréation"));	//todo
			String sample = SH.c(ms_rs.getString("Echantillon"));		//todo
			String provenance = SH.c(ms_rs.getString("Provenance"));
			Connection conn = SH.getAdminConnection();
			ps = conn.prepareStatement("select * from admin where immatnew=?");
			ps.setString(1,numfiche);
			rs = ps.executeQuery();
			if(rs.next()){
				int personid = rs.getInt("personid");
				Encounter encounter = new Encounter();
				encounter.setPatientUID(personid+"");
				encounter.setCreateDateTime(start);
				if(typevisite.toLowerCase().startsWith("hosp")){
					encounter.setType("admission");
					encounter.setServiceUID("IMP.HOSP");
					PreparedStatement ms_ps2 = ms_conn.prepareStatement("select * from hospitalisation where numvisite=?");
					ms_ps2.setString(1,numvisite);
					ResultSet ms_rs2 = ms_ps2.executeQuery();
					if(ms_rs2.next()){
						encounter.setBegin(ms_rs2.getTimestamp("dateentrée"));
						encounter.setEnd(ms_rs2.getTimestamp("datesortie"));
					}
					else{
						encounter.setBegin(start);
						encounter.setEnd(new java.util.Date(start.getTime()+SH.getTimeDay()));
					}
					ms_rs2.close();
					ms_ps2.close();
				}
				else if(typevisite.toLowerCase().startsWith("ext")){
					encounter.setType("visit");
					encounter.setServiceUID("IMP.EXT");
					encounter.setBegin(start);
					encounter.setEnd(new java.util.Date(start.getTime()+SH.getTimeHour()));
				}
				else if(typevisite.toLowerCase().startsWith("amb")){
					encounter.setType("visit");
					encounter.setServiceUID("IMP.AMB");
					encounter.setBegin(start);
					encounter.setEnd(new java.util.Date(start.getTime()+SH.getTimeHour()));
				}
				if(provenance.equalsIgnoreCase("Référé Centre de Santé")){
					encounter.setOrigin("cds");
				}
				else if(provenance.equalsIgnoreCase("Référé Hôpital")){
					encounter.setOrigin("hospital");
				}
				else if(provenance.equalsIgnoreCase("Domicile")){
					encounter.setOrigin("residence");
				}
				else{
					encounter.setOrigin("other");
				}
				encounter.setEtiology(typecas+"~"+auteur+"~"+sample);
				encounter.setSituation(numvisite);
				encounter.store();
			}
			rs.close();
			ps.close();
			conn.close();
		}
		ms_rs.close();
		ms_ps.close();
	}
	if(true){
		Connection oconn = SH.getOpenclinicConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
		ps = oconn.prepareStatement("truncate table transactions");
		ps.execute();
		ps.close();
		ps = oconn.prepareStatement("truncate table items");
		ps.execute();
		ps.close();
		PreparedStatement ms_ps = ms_conn.prepareStatement("select * from VisitesMédicales");
		ResultSet ms_rs = ms_ps.executeQuery();
		int count=0;
		UserVO user = MedwanQuery.getInstance().getUser("4");
		while(ms_rs.next()){
			if(count % 100 == 0){
				SH.syslog("Imported acts for "+count+" visits");
			}
			count++;
			oconn.close();
			oconn = SH.getOpenclinicConnection();
			ps = oconn.prepareStatement("select * from oc_encounters where oc_encounter_situation=?");
			ps.setString(1,ms_rs.getString("NumVisite"));
			rs = ps.executeQuery();
			if(rs.next()){
				PreparedStatement ms_ps2 = ms_conn.prepareStatement("select * from Actes where numvisite=?");
				ms_ps2.setString(1,ms_rs.getString("NumVisite"));
				ResultSet ms_rs2 = ms_ps2.executeQuery();
				String content = "title;actes~";
				String consultation = "";
				String title = "Hospitalisation";
				if(SH.c(rs.getString("oc_encounter_type")).equalsIgnoreCase("visit")){
					title="Consultation";
				}
				String encounteruid = rs.getInt("oc_encounter_serverid")+"."+rs.getInt("oc_encounter_objectid");
				String personid = rs.getString("oc_encounter_patientuid");
				while(ms_rs2.next()){
					String numacte = SH.c(ms_rs2.getString("NumActe"));
					String numvisite = SH.c(ms_rs2.getString("NumVisite"));
					String acte = SH.c(ms_rs2.getString("acte"));
					String service = SH.c(ms_rs2.getString("service"));
					String typeconsultation = SH.c(ms_rs2.getString("typeconsultation"));
					String resultat = SH.c(ms_rs2.getString("résultat1"));
					content+="Acte;"+acte+";Résultat;"+resultat+";Service;"+service+";Type contact;"+typeconsultation+"~";
					PreparedStatement ms_ps3 = ms_conn.prepareStatement("select * from Consultations where numacte=?");
					ms_ps3.setString(1,numacte);
					ResultSet ms_rs3 = ms_ps3.executeQuery();
					while(ms_rs3.next()){
						consultation+= addValue("Température °C","Température",ms_rs3,consultation);
						consultation+= addValue("Poids en kg","Poids",ms_rs3,consultation);
						consultation+= addValue("Taille en cm","Taille",ms_rs3,consultation);
						consultation+= addValue("TA mmHg","TA",ms_rs3,consultation);
						consultation+= addValue("FC bpm","FC",ms_rs3,consultation);
						consultation+= addValue("FR /min","FR",ms_rs3,consultation);
						consultation+= addValue("SO","SO",ms_rs3,consultation);
						consultation+= addValue("PC","PC",ms_rs3,consultation);
						consultation+= addValue("PB cm","PB",ms_rs3,consultation);
						consultation+= addValue("Plaintes","Plaintes",ms_rs3,consultation);
						consultation+= addValue("Histoire","HistoireAffection",ms_rs3,consultation);
						consultation+= addValue("Compléments","Compléments",ms_rs3,consultation);
						consultation+= addValue("Etat général","EtatGénéral",ms_rs3,consultation);
						consultation+= addValue("Observation infirmière","ObservationInfirmière",ms_rs3,consultation);
						consultation+= addValue("Examen physique","ExamenPhysique",ms_rs3,consultation);
						consultation+= addValue("Diagnostic","DiagnosticsCertitude",ms_rs3,consultation);
						consultation+= addValue("PA","PA",ms_rs3,consultation);
						consultation+= addValue("PP","PP",ms_rs3,consultation);
						consultation+= addValue("Observations médecin","ObservationMédecin",ms_rs3,consultation);
						consultation+= addValue("Conclusion","conclusion",ms_rs3,consultation);
					}
					ms_rs3.close();
					ms_ps3.close();
				}
				if(content.length()>0 || consultation.length()>0){
					if(consultation.length()>0){
						content="title;Consultation~"+consultation+"~"+content;
					}
	    			TransactionVO transaction = new TransactionFactoryGeneral().createTransactionVO(MedwanQuery.getInstance().getUser("4"),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_IMPORT",false); 
	    			transaction.setCreationDate(rs.getTimestamp("oc_encounter_begindate"));
	    			transaction.setStatus(1);
	    			transaction.setTransactionId(MedwanQuery.getInstance().getOpenclinicCounter("TransactionID"));
	    			transaction.setServerId(MedwanQuery.getInstance().getConfigInt("serverId",1));
	    			transaction.setTransactionType("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_IMPORT");
					transaction.setUpdateTime(rs.getTimestamp("oc_encounter_begindate"));
	    			transaction.setUser(user);
	    			transaction.setVersion(1);
	    			transaction.setItems(new Vector());
	    			ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
	    			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
	    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID",encounteruid,new java.util.Date(),itemContextVO));
	    			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
	    			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
	    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTENT",content,new java.util.Date(),itemContextVO));
	    			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
	    			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
	    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TITLE",title,new java.util.Date(),itemContextVO));
					MedwanQuery.getInstance().updateTransaction(Integer.parseInt(personid),transaction);
				}
				ms_rs2.close();
				ms_ps2.close();
			}
			rs.close();
			ps.close();
		}
		ms_rs.close();
		ms_ps.close();
	}
	ms_conn.close();
%>