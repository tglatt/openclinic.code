<%@page import="be.openclinic.finance.Insurance"%>
<%@page import="be.openclinic.finance.Insurar"%>
<%@page import="be.mxs.common.model.vo.healthrecord.util.*,be.mxs.common.model.vo.healthrecord.*"%>
<%@page import="java.io.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	String getValue(String[] values,int n){
		if(values.length>n){
			return values[n];
		}
		return "";
	}
%>

<%
	BufferedReader br = new BufferedReader(new FileReader("/tmp/enfants.csv"));
    String line;
    br.readLine();
    while((line = br.readLine()) != null) {
        String[] values = line.split(";");
        //Check if patient already exists
        java.util.Date date = SH.parseDate(getValue(values,1));
       	if(date==null){
       		continue;
       	}
        AdminPerson person = AdminPerson.get(values[2]);
        if(!person.isNotEmpty()){
        	Connection conn= SH.getAdminConnection();
        	PreparedStatement ps = conn.prepareStatement("insert into admin(personid,lastname) values(?,?)");
        	ps.setString(1,getValue(values,2));
        	ps.setString(2,getValue(values,3).split(",")[0]);
        	ps.execute();
        	ps.close();
        	conn.close();
        	
        	person.lastname = getValue(values,3).split(",")[0];
        	if(getValue(values,3).split(",").length>1){
            	person.firstname = getValue(values,3).split(",")[1];
        	}
        	try{
        		int months=0;
        		if(getValue(values,4).contains("m")){
        			months=Integer.parseInt(getValue(values,4).replaceAll("m", ""));
        		}
        		else{
        			months=Integer.parseInt(getValue(values,4))*12;
        		}
        		person.dateOfBirth="01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(date.getTime()-months*30*SH.getTimeDay()));
        	}
        	catch(Exception e){
        		continue;
        	}
        	
        	person.gender=getValue(values,6);
        	person.language="FR";
        	person.nativeCountry="BI";
        	person.setID("natreg",getValue(values,45));
        	person.adminextends.put("parentsidcard", getValue(values,46));
        	person.store();
        	SH.syslog("personid="+person.personid);
        }
        //Save the transaction
        if(MedwanQuery.getInstance().getTransactionsByTypeBetween(Integer.parseInt(person.personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSPLS_REGISTRY_CARE_CHILDREN", date, SH.endOfDay(date)).size()==0){
        	//Add the transaction
			TransactionVO transaction = new TransactionFactoryGeneral().createTransactionVO(MedwanQuery.getInstance().getUser("4"),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSPLS_REGISTRY_CARE_CHILDREN",false); 
			transaction.setCreationDate(new java.util.Date());
			transaction.setStatus(1);
			transaction.setTransactionId(MedwanQuery.getInstance().getOpenclinicCounter("TransactionID"));
			transaction.setServerId(MedwanQuery.getInstance().getConfigInt("serverId",1));
			transaction.setTransactionType("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MSPLS_REGISTRY_CARE_CHILDREN");
			transaction.setUpdateTime(date);
			UserVO user = MedwanQuery.getInstance().getUser("4");
			transaction.setUser(user);
			transaction.setVersion(1);
			transaction.setItems(new Vector());
			String situation="",s="";
			if(getValue(values,7).length()>0){
				situation="1";
				s="1";
			}
			else if(getValue(values,8).length()>0){
				situation="5";
				s="1";
			}
			else if(getValue(values,9).length()>0){
				situation="6";
				s="1";
			}
			else if(getValue(values,10).length()>0){
				situation="2";
				s="1";
			}
			else if(getValue(values,11).length()>0){
				situation="3";
				s="1";
			}
			else if(getValue(values,12).length()>0){
				situation="4";
				s="1";
			}
			else{
				s="0";
			}
	        //Save the contact
	        Encounter encounter = null;
	        Vector<Encounter> encounters = Encounter.selectEncounters("", "", SH.formatDate(date), SH.formatDate(new java.util.Date(date.getTime()+SH.getTimeDay())), "visit", "", "CLIN.ADU", "", person.personid, "");
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
	    		encounter.setServiceUID("CLIN.ENF");
	    		encounter.setSituation(situation);
	    		encounter.setType("visit");
	    		encounter.setManagerUID("");
	    		encounter.setUpdateUser("4");
	    		encounter.setVersion(1);
				if(getValue(values,43).contains("Ambulatoire")){
					encounter.setOutcome("better");
				}
				else if(getValue(values,43).contains("Contre-")){
					encounter.setOutcome("contrareference");
				}			
	    		encounter.store();
	        }
	        ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEWCASE",s,date,itemContextVO));
			if(getValue(values,14).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COUNTERREFERENCE","1",date,itemContextVO));
			}
			if(getValue(values,15).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT",getValue(values,15),date,itemContextVO));
			}
			if(getValue(values,16).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT",getValue(values,16),date,itemContextVO));
			}
			if(getValue(values,17).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DANGERSIGNS","1",date,itemContextVO));
			}
			s="";
			if(getValue(values,18).length()>0){
				s+="1;";
			}			
			if(getValue(values,19).length()>0){
				s+="2;";
			}			
			if(getValue(values,20).length()>0){
				s+="3;";
			}			
			if(getValue(values,21).length()>0){
				s+="4;";
			}			
			if(getValue(values,22).length()>0){
				s+="5;";
			}			
			if(getValue(values,23).length()>0){
				s+="6;";
			}			
			if(getValue(values,24).length()>0){
				s+="7;";
			}			
			if(getValue(values,25).length()>0){
				s+="8;";
			}			
			if(getValue(values,26).length()>0){
				s+="9;";
			}			
			if(s.length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CLINICALEXAMINATION",s,date,itemContextVO));
			}
			if(getValue(values,27).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERSYMPTOMS",getValue(values,27),date,itemContextVO));
			}
			if(getValue(values,28).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATIONSOK","1",date,itemContextVO));
			}
			if(getValue(values,28).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VITAMINAOK","1",date,itemContextVO));
			}
			if(getValue(values,29).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NEWCONSULTATIONINAMONTH","1",date,itemContextVO));
			}
			s = SH.getLabelId("mspls.labresult", getValue(values,30), "fr");
			if(s.length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SCREENINGINAMONTH",s,date,itemContextVO));
			}
			if(getValue(values,31).length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHERPATHOLOGIES",getValue(values,31),date,itemContextVO));
			}
			if(getValue(values,33).contains("Test rapide: -")){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_RAPIDTEST","1",date,itemContextVO));
			}
			else if(getValue(values,33).contains("Test rapide: +")){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_RAPIDTEST","2",date,itemContextVO));
			}
			if(getValue(values,33).contains("VIH/SIDA: -")){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_HIV","1",date,itemContextVO));
			}
			else if(getValue(values,33).contains("VIH/SIDA: +")){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_HIV","2",date,itemContextVO));
			}
			if(getValue(values,34).length()>1){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_DIAGNOSIS1",getValue(values,34).split(",")[0],date,itemContextVO));
			}
			s="Traitement: "+getValue(values,35)+"\nUnités: "+getValue(values,36)+"\nDosage: "+getValue(values,37)+"\nDurée en jours: "+getValue(values,38)+"\nLivré: "+getValue(values,39);
			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBSERVATIONS",s,date,itemContextVO));
			s = SH.getLabelId("yesno", getValue(values,40), "fr");
			if(s.length()>0){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NUTRITIONINFORMATION",s,date,itemContextVO));
			}
			s="";
			Vector<Insurar> v = Insurar.getInsurarsByName(getValue(values,42));
			for(int i=0;i<v.size();i++){
				Insurar insurar = v.elementAt(i);
				Vector<Insurance> insurances = Insurance.selectInsurances(person.personid, "");
				for(int n=0;n<insurances.size();n++){
					Insurance insurance = insurances.elementAt(n);
					if(insurance.getInsurarUid().equals(insurar.getUid())){
						s=insurance.getInsurarUid();
						break;
					}
				}
			}
			if(s.length()==0 && v.size()>0){
				Insurar insurar = v.elementAt(0);
				Insurance insurance = new Insurance();
				insurance.setCreateDateTime(date);
				insurance.setDefaultInsurance(1);
				insurance.setInsurarUid(insurar.getUid());
				insurance.setInsuranceCategoryLetter("A");
				insurance.setType(insurar.getType());
				insurance.setPatientUID(person.personid);
				insurance.setStart(date);
				insurance.setUpdateUser("4");
				insurance.setVersion(1);
				insurance.store();
			}
			if(encounter!=null){
				itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
				transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
						"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID",encounter.getUid(),date,itemContextVO));
			}

			MedwanQuery.getInstance().updateTransaction(Integer.parseInt(person.personid),transaction);
        }
      }
%>
+