<%@page import="be.mxs.common.model.vo.healthrecord.util.*,be.mxs.common.model.vo.healthrecord.*"%>
<%@page import="java.io.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	BufferedReader br = new BufferedReader(new FileReader("/tmp/accueil.csv"));
    String line;
    br.readLine();
    while ((line = br.readLine()) != null) {
        String[] values = line.split(";");
        //Check if patient already exists
        AdminPerson person = AdminPerson.get(values[2]);
        if(!person.isNotEmpty()){
        	Connection conn= SH.getAdminConnection();
        	PreparedStatement ps = conn.prepareStatement("insert into admin(personid,lastname) values(?,?)");
        	ps.setString(1,values[2]);
        	ps.setString(2,values[4].split(",")[0]);
        	ps.execute();
        	ps.close();
        	conn.close();
        	person = AdminPerson.get(values[2]);
           	person.lastname = values[4].split(",")[0];
           	if(values[4].split(",").length>1){
               	person.firstname = values[4].split(",")[1];
           	}
           	try{
           		person.dateOfBirth="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date(new java.util.Date().getTime()-Integer.parseInt(values[5])*SH.getTimeYear()));
           	}
           	catch(Exception e){
           		continue;
           	}
           	person.gender=values[6];
           	person.comment5=values[11];
           	person.language="FR";
           	person.nativeCountry="BI";
           	AdminPrivateContact apc = person.getActivePrivate();
           	apc.businessfunction=values[7];
           	apc.sector=values[8];
           	apc.city=values[9];
           	apc.address=values[10];
           	if(person.privateContacts.size()==0){
           		person.privateContacts.add(apc);
           	}
           	person.store();
        }
        //Save the contact
        String service = "";
        String[] services={"CLIN.ADU","CLIN.VACC","HOSP.MA","CLIN.PF","CLIN.CPN","CLIN.CPON","CLIN.SSN","CLIN.CDV","PAR.LAB","CLIN.ADU","CLIN.CDV","PAR"};
		for(int n=12;n<24;n++){
			if(values.length<n+1){
				break;
			}
			if(values[n].equalsIgnoreCase("X")){
				service=services[n-12];
				break;
			}
		}
		
        java.util.Date date = SH.parseDate(values[1]);
       	if(date==null){
       		continue;
       	}
        Encounter encounter = null;
        Vector<Encounter> encounters = Encounter.selectEncounters("", "", SH.formatDate(date), SH.formatDate(new java.util.Date(date.getTime()+SH.getTimeDay())), "visit", "", "", "", person.personid, "");
        if(encounters.size()>0){
        	encounter=encounters.elementAt(0);
        }
        else{
        	encounter= new Encounter();
    		encounter.setBegin(date);
    		encounter.setEnd(SH.endOfDay(date));
    		encounter.setCreateDateTime(date);
    		encounter.setOrigin("");
    		encounter.setPatientUID(person.personid);
    		encounter.setServiceUID(service);
    		encounter.setSituation("1");
    		encounter.setType("visit");
    		encounter.setManagerUID("");
    		encounter.setUpdateUser("4");
    		encounter.setVersion(1);
    		encounter.store();
        }
        //Save the transaction
        if(MedwanQuery.getInstance().getTransactionsByTypeBetween(Integer.parseInt(person.personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSPLS_REGISTRY_RECEPTION", date, SH.endOfDay(date)).size()==0){
        	//Add the transaction
			TransactionVO transaction = new TransactionFactoryGeneral().createTransactionVO(MedwanQuery.getInstance().getUser("4"),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSPLS_REGISTRY_RECEPTION",false); 
			transaction.setCreationDate(new java.util.Date());
			transaction.setStatus(1);
			transaction.setTransactionId(MedwanQuery.getInstance().getOpenclinicCounter("TransactionID"));
			transaction.setServerId(MedwanQuery.getInstance().getConfigInt("serverId",1));
			transaction.setTransactionType("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSPLS_REGISTRY_RECEPTION");
			transaction.setUpdateTime(date);
			UserVO user = MedwanQuery.getInstance().getUser("4");
			transaction.setUser(user);
			transaction.setVersion(1);
			transaction.setItems(new Vector());
			String type="";
			for(int n=12;n<24;n++){
				if(values.length<n+1){
					break;
				}
				if(values[n].equalsIgnoreCase("X")){
					type+=(n-11)+";";
				}
			}
			ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENCOUNTERTYPE",type,date,itemContextVO));
			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PATIENTTYPE",values[3].equalsIgnoreCase("nouveau cas")?"1":"0",date,itemContextVO));
			if(encounter!=null){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID",encounter.getUid(),date,itemContextVO));
			}

			MedwanQuery.getInstance().updateTransaction(Integer.parseInt(person.personid),transaction);
        }
    }
%>