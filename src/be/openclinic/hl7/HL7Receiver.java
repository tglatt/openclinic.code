package be.openclinic.hl7;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Vector;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryGeneral;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;
import be.openclinic.medical.Labo;
import be.openclinic.medical.RequestedLabAnalysis;
import be.openclinic.system.SH;
import ca.uhn.hl7v2.AcknowledgmentCode;
import ca.uhn.hl7v2.DefaultHapiContext;
import ca.uhn.hl7v2.HL7Exception;
import ca.uhn.hl7v2.HapiContext;
import ca.uhn.hl7v2.model.Message;
import ca.uhn.hl7v2.model.Varies;
import ca.uhn.hl7v2.model.v251.group.ORU_R01_OBSERVATION;
import ca.uhn.hl7v2.model.v251.group.ORU_R01_ORDER_OBSERVATION;
import ca.uhn.hl7v2.model.v251.group.ORU_R01_PATIENT_RESULT;
import ca.uhn.hl7v2.model.v251.group.OUL_R22_ORDER;
import ca.uhn.hl7v2.model.v251.group.OUL_R22_RESULT;
import ca.uhn.hl7v2.model.v251.group.OUL_R22_SPECIMEN;
import ca.uhn.hl7v2.model.v251.message.ACK;
import ca.uhn.hl7v2.model.v251.message.ORU_R01;
import ca.uhn.hl7v2.model.v251.message.OUL_R22;
import ca.uhn.hl7v2.model.v251.segment.MSH;
import ca.uhn.hl7v2.model.v251.segment.OBR;
import ca.uhn.hl7v2.model.v251.segment.OBX;
import ca.uhn.hl7v2.model.v251.segment.PID;
import ca.uhn.hl7v2.parser.CanonicalModelClassFactory;
import ca.uhn.hl7v2.parser.GenericModelClassFactory;
import ca.uhn.hl7v2.parser.Parser;
import ca.uhn.hl7v2.parser.PipeParser;
import ca.uhn.hl7v2.protocol.ReceivingApplication;
import ca.uhn.hl7v2.protocol.ReceivingApplicationException;
import ca.uhn.hl7v2.util.Terser;

public class HL7Receiver implements ReceivingApplication {
	@Override
	public boolean canProcess(Message message) {
	    return true;
	}
	
	@Override
 	public Message processMessage(Message message, Map<String, Object> theMetadata) throws ReceivingApplicationException, HL7Exception {
        String sError="";
        HapiContext context = new DefaultHapiContext();
        CanonicalModelClassFactory mcf = new CanonicalModelClassFactory("2.5.1");
        context.setModelClassFactory(mcf);			
 		String encodedMessage = context.getPipeParser().encode(message);
 		System.out.println("Received message:");
 		System.out.println("*******************************************************************");
 		System.out.println(encodedMessage.replaceAll("\r","\r\n"));
 		System.out.println("*******************************************************************");
        //Process the message
        Terser terser = new Terser(message);
        String messageType=terser.get("/.MSH-9-1");
        String messageSubType=terser.get("/.MSH-9-2");
        SH.syslog("message type = "+messageType+"^"+messageSubType);
        SH.syslog("storing received message in OC_HL7IN log");
        HL7Server.storeReceivedMessage(messageType+"_"+messageSubType, message);
        
        if(messageType.equalsIgnoreCase("OML") && messageSubType.equalsIgnoreCase("O21")) {
        	/*
        	 * Process a lab order message
        	 * Only relevant when OpenClinic GA is being used as the LIMS
        	 */
        	HL7Server.setReceivedMessageProcessed(message);
        }
        else if(messageType.equalsIgnoreCase("ORU") && messageSubType.equalsIgnoreCase("R01")) {
        	/*
        	 * Process a lab results message
        	 * We process LOINC codes and Internal Labanalyzer codes
        	 */
        	SH.syslog("Received ORU-R01 message");
        	ORU_R01 labresults = (ORU_R01)message;
        	/****************************
        	 * MSH
        	 ****************************/
        	MSH msh = labresults.getMSH();
        	SH.syslog("Successfully parsed message ID "+msh.getMsh10_MessageControlID());
        	java.util.Date resultdate = msh.getDateTimeOfMessage().getTime().getValueAsCalendar().getTime();
        	SH.syslog("Date="+resultdate);
        	String applicationName=HL7Server.checkString(msh.getSendingApplication().getComponent(0).encode());
        	String application=HL7Server.checkString(msh.getSendingApplication().getUniversalID().encode());
        	if(application.length()==0) {
        		application=applicationName;
        	}
        	SH.syslog("Sending application="+applicationName+" - "+application);
        	String facility=HL7Server.checkString(msh.getSendingFacility().encode());
        	SH.syslog("Sending facility="+facility);
        	List<ORU_R01_PATIENT_RESULT> patientResults = labresults.getPATIENT_RESULTAll();
        	SH.syslog("Found "+patientResults.size()+" patient results");
        	Iterator<ORU_R01_PATIENT_RESULT> iPatientResults = patientResults.iterator();
        	while(iPatientResults.hasNext()) {
            	/****************************
            	 * PID
            	 ****************************/
        		ORU_R01_PATIENT_RESULT patientResult = iPatientResults.next();
        		PID pid = patientResult.getPATIENT().getPID();
        		String personid="";
        		String[] idFieldMappings = SH.cs("s5.hl7.personidfield","").split(",");
        		for(int n=0;n<idFieldMappings.length;n++) {
        			if(idFieldMappings[n].split("=").length>1) {
		        		if(idFieldMappings[n].split("=")[0].equalsIgnoreCase(application) && idFieldMappings[n].split("=")[1].equalsIgnoreCase("3")) {
		        			//LabXpert
		        			personid = pid.getPid3_PatientIdentifierList(0).getComponents()[0].encode();
		            		SH.syslog("PID (3):"+personid);
		        		}
		        		else if(idFieldMappings[n].split("=")[0].equalsIgnoreCase(application) && idFieldMappings[n].split("=")[1].equalsIgnoreCase("4")) {
		        			personid = pid.getPid4_AlternatePatientIDPID(0).getComponents()[0].encode();
		            		SH.syslog("PID (4):"+personid);
		        		}
		        		else if(idFieldMappings[n].split("=")[0].equalsIgnoreCase(application) && idFieldMappings[n].split("=")[1].equalsIgnoreCase("2")) {
		        			//MindRay CL-900i HL7 1.0
		        			personid = pid.getPid2_PatientID().getComponents()[0].encode();
		            		SH.syslog("PID (2):"+personid);
		        		}
        			}
        		}
        		if(personid.length()==0) {
        			personid = pid.getPid3_PatientIdentifierList(0).getComponents()[0].encode();
            		SH.syslog("PID (3):"+personid);
            		if(SH.c(personid).length()==0) { 
            			personid = pid.getPid4_AlternatePatientIDPID(0).encode();
                		SH.syslog("PID (4):"+personid);
                		if(SH.c(personid).length()==0) { 
                			personid = pid.getPid2_PatientID().getComponents()[0].encode();
                    		SH.syslog("PID (2):"+personid);
                		}
            		}
        		}
        		SH.syslog("personid = "+personid);
        		String specimenid="",barcodeid="";
            	/****************************
            	 * OBR
            	 ****************************/
        		OBR obr = patientResult.getORDER_OBSERVATION().getOBR();
        		String[] specimenFieldMappings = SH.cs("s5.hl7.specimenfield","labxpert=3,DF5x=3,cl900i=2").split(",");
        		boolean bFoundSpecimenField = false;
        		for(int n=0;n<specimenFieldMappings.length;n++) {
        			if(specimenFieldMappings[n].split("=").length>1) {
	        			if(specimenFieldMappings[n].split("=")[0].equalsIgnoreCase(application) && obr.getField(Integer.parseInt(specimenFieldMappings[n].split("=")[1])).length>0) {
	        				bFoundSpecimenField=true;;
		        			barcodeid=obr.getField(Integer.parseInt(specimenFieldMappings[n].split("=")[1]))[0].encode();
		            		if(SH.c(barcodeid).length()>0) {
		                		SH.syslog("barcode ID = "+SH.padLeft(barcodeid,"0",10));
		    	        		specimenid = Labo.getLabSpecimenId(SH.padLeft(barcodeid,"0",10));
		            		}
		        		}
        			}
        		}
        		if(!bFoundSpecimenField && obr.getField(2).length>0) {
        			barcodeid=obr.getField(2)[0].encode();
            		if(SH.c(barcodeid).length()>0) {
                		SH.syslog("barcode ID = "+SH.padLeft(barcodeid,"0",10));
    	        		specimenid = Labo.getLabSpecimenId(SH.padLeft(barcodeid,"0",10));
            		}
        		}
        		SH.syslog("specimenid = "+specimenid);
        		String serverid=null,transactionid=null;
    			TransactionVO transaction = null;
        		if(SH.c(specimenid).split("\\.").length>1) {
	        		serverid = specimenid.split("\\.")[0];
	        		transactionid = specimenid.split("\\.")[1];
	    			try {
						int personid2=HL7Server.getTransactionPersonId(Integer.parseInt(serverid), Integer.parseInt(transactionid));
	    				if(personid2==-1) {
							SH.syslog("OUL^R22 Error: no matching lab order for personid/barcode/specimenid = "+personid+"/"+barcodeid+"/"+specimenid);
							continue;
						}
		        		else {
		    				transaction = TransactionVO.get(serverid+"."+transactionid);
		        			personid=personid2+"";
		                    String id=terser.get("/.MSH-10");
		        			HL7Server.storeReceivedMessageTransactionId(id, Integer.parseInt(transactionid));
		        			SH.syslog("Valid personid found: "+personid2+" ["+MedwanQuery.getInstance().getPerson(personid).getFullName()+"]");
		        		}
					} catch (NumberFormatException | SQLException e1) {
						e1.printStackTrace();
					}
        		}
        		if(SH.c(personid).length()==0) { 
            		SH.syslog("Unidentified patient, quit processing: "+pid.encode());
        			continue;
        		}
    			if(transaction==null) {
					//Check if a labrequest not older than x days exists. I yes, use it, if not create one
					transaction = MedwanQuery.getInstance().getLastTransactionsByTypeAfter(Integer.parseInt(personid), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST", new java.util.Date(resultdate.getTime()-SH.ci("s5.xml.kenza.maxdelay", 48)*SH.getTimeHour()));
    			}
    			if(transaction==null) {
        			//Create a new Lab Order transaction
        			transaction = new TransactionFactoryGeneral().createTransactionVO(MedwanQuery.getInstance().getUser(SH.cs("defaultLabUser","4")),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST",false); 
        			transaction.setCreationDate(new java.util.Date());
        			transaction.setHealthrecordId(MedwanQuery.getInstance().getHealthRecordIdFromPersonIdWithCreate(Integer.parseInt(personid)));
        			transaction.setStatus(1);
        			transaction.setTransactionId(MedwanQuery.getInstance().getOpenclinicCounter("TransactionID"));
        			transaction.setServerId(SH.ci("serverId",1));
        			transaction.setTransactionType("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST");
        			transaction.setUpdateTime(new java.util.Date());
        			UserVO user = MedwanQuery.getInstance().getUser(SH.cs("s5.hl7.defaultuser",SH.cs("defaultLabUser","4")));
        			if(user==null){
        				MedwanQuery.getInstance().getUser("4");
        			}
        			transaction.setUser(user);
        			transaction.setVersion(1);
        			transaction.setItems(new Vector<ItemVO>());
        			Encounter encounter = Encounter.getActiveEncounter(personid);
        			if(encounter!=null) {
        				transaction.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
            					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID",encounter.getUid(),new java.util.Date(),null));
        				transaction.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
            					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT",encounter.getServiceUID(),new java.util.Date(),null));
        			}
    				transaction.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
        					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_REMARK",application+"/"+facility,new java.util.Date(),null));
    				transaction.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
        					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_URGENCY","routine",new java.util.Date(),null));
    				transaction.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
        					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_INTERNALPRESCRIBER",user.getUserId()+"",new java.util.Date(),null));
    				transaction.getItems().add(new ItemVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
        					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_HOUR",SH.formatDate(resultdate,"HH:mm"),new java.util.Date(),null));
        			transaction.store();
        			SH.syslog("stored transaction "+transaction.getUid());
    			}
    			else {
        			SH.syslog("update transaction "+transaction.getUid());
    			}
            	List<ORU_R01_ORDER_OBSERVATION> orderObservations = patientResult.getORDER_OBSERVATIONAll();
            	SH.syslog("found "+orderObservations.size()+" orderObservations");
            	Iterator<ORU_R01_ORDER_OBSERVATION> iOrderObservations = orderObservations.iterator();
            	while(iOrderObservations.hasNext()) {
            		SH.syslog("order_Observation");
            		ORU_R01_ORDER_OBSERVATION orderObservation = iOrderObservations.next();
            		SH.syslog("specimen source: "+orderObservation.getOBR().getSpecimenSource().getSpecimenSourceNameOrCode().encode());
            		List<ORU_R01_OBSERVATION> observations = orderObservation.getOBSERVATIONAll();
            		SH.syslog("found "+observations.size()+" observations");
            		if(observations.size()>0) {
	                	Iterator<ORU_R01_OBSERVATION> iObservations = observations.iterator();
	        			java.util.Date datetime = resultdate;
	                	while(iObservations.hasNext()) {
	                		SH.syslog("observation");
	                		ORU_R01_OBSERVATION observation = iObservations.next();
	                    	/****************************
	                    	 * OBX
	                    	 ****************************/
	        				OBX obx = observation.getOBX();
	            			String analysercode = HL7Server.checkString(obx.getObservationIdentifier().getCe1_Identifier().encode());
	            			if(analysercode.length()==0) {
		            			analysercode = HL7Server.checkString(obx.getObservationIdentifier().getCe4_AlternateIdentifier().encode());
	            			}
	            			if(analysercode.length()==0) { //MindRay CL-900i HL7 1.0
		            			analysercode = HL7Server.checkString(obx.getObx4_ObservationSubID().encode());
	            			}
	            			if(analysercode.length()==0) {
		                		SH.syslog("\tno analyser code provided, skipping");
		                		continue;
	            			}
	            			SH.syslog("\tchecking analyser code "+analysercode);
	            			String labcode="";
	            			try {
								if(HL7Server.getConfigString("labanalysercodemapping","loinc").equalsIgnoreCase("loinc")) {
									SH.syslog("\tchecking mapping for "+applicationName+"."+analysercode);
									labcode = HL7Server.getLabCodeByMedidocCode(applicationName+"."+analysercode);
								}
								else {
									labcode = HL7Server.getLabCodeByAnalyserCode(applicationName+"."+analysercode);
								}
								if(labcode.length()==0) {
									SH.syslog("\tchecking mapping for ["+analysercode+"]");
									if(HL7Server.getConfigString("labanalysercodemapping","loinc").equalsIgnoreCase("loinc")) {
										labcode = HL7Server.getLabCodeByMedidocCode(analysercode);
									}
									else {
										labcode = HL7Server.getLabCodeByAnalyserCode(analysercode);
									}
								}
								if(labcode.length()==0) {
									if(HL7Server.getConfigInt("labanalysercodemappingallowmismatches",0)==1) {
										labcode= HL7Server.getLabCode(labcode);
									}
								}
								if(labcode.length()==0) {
									SH.syslog("\tORU^R01 Error: invalid analysercode: "+analysercode);
									continue;
								}
				        		else {
				        			SH.syslog("\tvalid labcode: "+labcode);
				        		}
							} catch (SQLException e) {
								e.printStackTrace();
							}
	            			String value = HL7Server.checkString(obx.getObservationValue(0).encode());
	            			SH.syslog("\tvalue="+value);
	            			String unit = HL7Server.checkString(obx.getUnits().encode());
	            			SH.syslog("\tunits="+unit);
	            			String abnormal = HL7Server.checkString(obx.getAbnormalFlags(0).getValue());
	            			SH.syslog("\tabnormal="+abnormal);
	            			if(!obx.getDateTimeOfTheObservation().isEmpty()){
	            				datetime=new java.util.Date(obx.getDateTimeOfTheObservation().getTime().getValueAsCalendar().getTimeInMillis());
	            			}
	            			SH.syslog("\tdatetime="+datetime);
	                		
	            			//Remove the observation from the transaction if it already exists
	                		RequestedLabAnalysis.delete(transaction.getServerId(), transaction.getTransactionId(), labcode);
	                		//Store the observation
	        				RequestedLabAnalysis analysis = new RequestedLabAnalysis();
	        				analysis.setAnalysisCode(labcode);
	        				analysis.setPatientId(personid);
	        				analysis.setRequestDate(new java.sql.Date(new java.util.Date().getTime()));
	        				analysis.setRequestUserId(SH.cs("s5.hl7.defaultuser",SH.cs("defaultLabTechnicianId","4")));
	        				analysis.setServerId(transaction.getServerId()+"");
	        				analysis.setTransactionId(transaction.getTransactionId()+"");
	        				analysis.setUpdatetime(new java.sql.Date(new java.util.Date().getTime()));
	        				analysis.setObjectid(-1);
	        				analysis.setResultValue(value);
	        				analysis.setResultModifier(abnormal);
	        				analysis.setFinalvalidationdatetime(new java.sql.Date(new java.util.Date().getTime()));
	        				analysis.store();
	        				SH.syslog("\tanalysis stored");
							try {
								HL7Server.updateRequestedLabanalysis(transaction.getServerId(), transaction.getTransactionId(), labcode, "finalvalidationdatetime", new java.sql.Date(new java.util.Date().getTime()));
								HL7Server.updateRequestedLabanalysis(transaction.getServerId(), transaction.getTransactionId(), labcode, "finalvalidator", SH.cs("defaultLabTechnicianId","4"));
								SH.syslog("\tstored finalvalidationdatetime: "+new java.sql.Date(new java.util.Date().getTime()));
							} catch (NumberFormatException | SQLException e1) {
								// TODO Auto-generated catch block
								e1.printStackTrace();
							}

	                	}
            		}
            	}
        	}
        	HL7Server.setReceivedMessageProcessed(message);
        }
        else if(messageType.equalsIgnoreCase("OUL") && messageSubType.equalsIgnoreCase("R22")) {
        	/*
        	 * Process a lab results message
        	 * We process LOINC codes and Internal Labanalyzer codes
        	 */
        	OUL_R22 labresults = (OUL_R22)message;
        	String personid = labresults.getPATIENT().getPID().getPid3_PatientIdentifierList(0).getIDNumber().getValue();
        	List specimens = labresults.getSPECIMENAll();
        	SH.syslog("total number of specimen: "+specimens.size());
        	Iterator iSpecimens = specimens.iterator();
        	while(iSpecimens.hasNext()) {
        		OUL_R22_SPECIMEN specimen = (OUL_R22_SPECIMEN)iSpecimens.next();
        		String barcodeid = HL7Server.checkString(specimen.getSPM().getSpecimenID().getPlacerAssignedIdentifier().getEi1_EntityIdentifier().getValue());
        		SH.syslog("****************************************");
        		SH.syslog("barcode ID: "+barcodeid);
        		String specimenid= Labo.getLabSpecimenId(barcodeid);
        		if(specimenid==null) {
        			SH.syslog("OUL^R22 Error: no matching specimenid for barcodeid: "+barcodeid);
        			continue;
        		}
        		else {
        			SH.syslog("valid specimen ID: "+specimenid+" (Lab order ID = "+specimenid.split("\\.")[0]+"."+specimenid.split("\\.")[1]+")");
        		}
        		String serverid = specimenid.split("\\.")[0];
        		String transactionid = specimenid.split("\\.")[1];
        		try {
                    String id=terser.get("/.MSH-10");
                    SH.syslog("setting transactionId = ["+transactionid+"] for message ["+id+"] in OC_HL7IN");
        			HL7Server.storeReceivedMessageTransactionId(id, Integer.parseInt(transactionid));
        			SH.syslog("transactionId stored");
        		}
        		catch(Exception e) {
        			e.printStackTrace();
        		}
    			try {
					int personid2=HL7Server.getTransactionPersonId(Integer.parseInt(serverid), Integer.parseInt(transactionid));
    				if(personid2==-1) {
						SH.syslog("OUL^R22 Error: no matching personid for specimenid = "+personid+"/"+specimenid);
						continue;
					}
	        		else {
	        			personid=personid2+"";
	        			SH.syslog("valid personid: "+personid+" ["+MedwanQuery.getInstance().getPerson(personid).getFullName()+"]");
	        		}
				} catch (NumberFormatException | SQLException e1) {
					e1.printStackTrace();
				}
        		List orders = specimen.getORDERAll();
        		Iterator iOrders = orders.iterator();
        		while(iOrders.hasNext()) {
        			OUL_R22_ORDER order = (OUL_R22_ORDER)iOrders.next();
        			List results = order.getRESULTAll();
        			Iterator iResults = results.iterator();
        			while(iResults.hasNext()) {
        				OUL_R22_RESULT result = (OUL_R22_RESULT)iResults.next();
        				SH.syslog("observation result");
        				OBX obx = result.getOBX();
            			String analysercode = HL7Server.checkString(obx.getObservationIdentifier().getCe1_Identifier().getValue());
            			String labcode="";
            			try {
							if(HL7Server.getConfigString("labanalysercodemapping","loinc").equalsIgnoreCase("loinc")) {
								labcode = HL7Server.getLabCodeByMedidocCode(analysercode);
							}
							else {
								labcode = HL7Server.getLabCodeByAnalyserCode(analysercode);
							}
							if(labcode.length()==0) {
								if(HL7Server.getConfigInt("labanalysercodemappingallowmismatches",0)==1) {
									labcode= HL7Server.getLabCode(labcode);
								}
							}
							if(labcode.length()==0) {
								SH.syslog("\tOUL^R22 Error: invalid analysercode: "+analysercode);
								continue;
							}
			        		else {
			        			SH.syslog("\tvalid labcode: "+labcode);
			        		}
						} catch (SQLException e) {
							e.printStackTrace();
						}
            			String value = HL7Server.checkString(obx.getObservationValue(0).encode());
            			String unit = HL7Server.checkString(obx.getUnits().encode());
            			String abnormal = HL7Server.checkString(obx.getAbnormalFlags(0).getValue());
            			String analyser = HL7Server.checkString(obx.getEquipmentInstanceIdentifier()[0].getEi1_EntityIdentifier()+"");
            			SH.syslog("\tanalayser ID = "+analyser);
            			try {
							if(!HL7Server.existsRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode)) {
								SH.syslog("\tOUL^R22 Error: no matching lab analysis order for personid/specimenid/labcode = "+personid+"/"+barcodeid+"/"+labcode);
			        			if(HL7Server.getConfigInt("autocreateHL7results", 0)==1) {
			        				SH.syslog("\tcreating new analysis order: "+personid+"/"+barcodeid+"/"+labcode);
			        				RequestedLabAnalysis analysis = new RequestedLabAnalysis();
			        				analysis.setAnalysisCode(labcode);
			        				analysis.setPatientId(personid);
			        				analysis.setRequestDate(new java.sql.Date(new java.util.Date().getTime()));
			        				analysis.setComment("###"+analyser);
			        				analysis.setRequestUserId(HL7Server.getConfigString("defaultLabTechnicianId","4"));
			        				analysis.setServerId(serverid);
			        				analysis.setTransactionId(transactionid);
			        				analysis.setUpdatetime(new java.sql.Date(new java.util.Date().getTime()));
			        				analysis.setObjectid(-1);
			        		    	java.sql.Connection conn =SH.getOpenClinicConnection();
			        				analysis.store(false, conn);
			        				conn.close();
			        			}
			        			else {
			        				continue;
			        			}
							}
			        		else {
			        			SH.syslog("\tvalid lab analysis order: "+personid+"/"+barcodeid+"/"+labcode);
			        		}
						} catch (NumberFormatException | SQLException e) {
							e.printStackTrace();
						}
						//Set the date/time of the result
						java.util.Date resultDate = new java.util.Date();
						try {
							resultDate=new java.util.Date(obx.getDateTimeOfTheObservation().getTime().getValueAsCalendar().getTimeInMillis());
						}
						catch(Exception ed) {
							try {
								resultDate=new java.util.Date(obx.getDateTimeOfTheAnalysis().getTime().getValueAsCalendar().getTimeInMillis());
							}
							catch(Exception ed2) {
								ed.printStackTrace();
							}
						}
						try {
							HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultDate", resultDate);
							SH.syslog("\tstored resultDate: "+resultDate);
						} catch (NumberFormatException | SQLException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
						//Set the analyser
						try {
							HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "Comment", "###"+analyser);
							SH.syslog("\tstored analyser: "+analyser);
						} catch (NumberFormatException | SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						//Set the value of the result
						String resultType = HL7Server.checkString(obx.getValueType().getValue());
						if(resultType.equalsIgnoreCase("NM")) {
							try {
								HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultValue", value);
								SH.syslog("\tstored resultValue: "+value);
							} catch (NumberFormatException | SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
							String references = HL7Server.checkString(obx.getReferencesRange().getValue());
							if(references.split(" - ").length==2) {
								try {
									HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultrefmin", references.split(" - ")[0]);
									SH.syslog("\tstored resultrefmin: "+references.split(" - ")[0]);
								} catch (NumberFormatException | SQLException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
								try {
									HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultrefmax", references.split(" - ")[1]);
									SH.syslog("\tstored resultrefmax: "+references.split(" - ")[1]);
								} catch (NumberFormatException | SQLException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
							}
							else if(HL7Server.checkString(references).length()>0){
								try {
									HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultrefmin", references);
									HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultrefmax", "");
									SH.syslog("\tstored resultrefmin: "+references);
								} catch (NumberFormatException | SQLException e) {
									// TODO Auto-generated catch block
									e.printStackTrace();
								}
							}
						}
						else {
							String resultValue="";
							for (Varies varies : obx.getObservationValue()) {
								if(resultValue.length()>0) {
									resultValue+=", ";
								}
								resultValue+=varies.encode();
							}
							try {
								HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultValue", resultValue);
								SH.syslog("\tstored resultvalue: "+resultValue);
							} catch (NumberFormatException | SQLException e) {
								// TODO Auto-generated catch block
								e.printStackTrace();
							}
						}
						try {
							HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "technicalvalidationdatetime", resultDate);
							SH.syslog("\tstored technicalvalidationdatetime: "+resultDate);
						} catch (NumberFormatException | SQLException e1) {
							// TODO Auto-generated catch block
							e1.printStackTrace();
						}
						try {
							HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "technicalvalidator", HL7Server.getConfigInt("defaultLabTechnicianId",4));
							SH.syslog("\tstored technicalvalidator: "+HL7Server.getConfigInt("defaultLabTechnicianId",4));
						} catch (SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						try {
							if(resultType.equalsIgnoreCase("NM") && HL7Server.checkString(abnormal).length()>0 && HL7Server.getConfigString("abnormalModifiersExtended", "*+*++*+++*-*--*---*h*hh*hhh*l*ll*lll*n*").contains("*"+abnormal+"*")) {
								HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultmodifier",abnormal);
								SH.syslog("\tstored resultmodifier: "+abnormal);
							}
							else if(abnormal.length()>0 && HL7Server.getConfigString("abnormalflagcodemapping","none").equalsIgnoreCase("ams")) {
	            				try {
	            					int iAbnormal = Integer.parseInt(abnormal) % 10;
	            					abnormal="";
	            					if(iAbnormal==0) {
	            						abnormal="n";
	            					}
	            					else if(iAbnormal==1) {
	            						abnormal="!";
	            					}
	            					else if(iAbnormal==2) {
	            						abnormal="!!";
	            					}
	            					else if(iAbnormal==3) {
	            						abnormal="!!!";
	            					}
	            					if(abnormal.length()>0) {
	    								HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultmodifier",abnormal);
	    								SH.syslog("\tstored resultmodifier: "+abnormal);
	            					}
	            				}
	            				catch (Exception e) {
	            					e.printStackTrace();
								}
	            			}
							else {
								if(resultType.equalsIgnoreCase("NM")){
									if(HL7Server.checkString(abnormal).length()>0) {
										SH.syslog("\tinvalid resultmodifier: "+abnormal);
									}
									else {
										SH.syslog("\tmissing resultmodifier");
									}
			        		    	java.sql.Connection conn =SH.getOpenClinicConnection();
			        		    	try {
					        			RequestedLabAnalysis analysis = RequestedLabAnalysis.get(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode,conn);
					        			analysis.calculateModifier(true,conn);
					        			SH.syslog("\tcalculated resultmodifier: "+analysis.getUnverifiedResultModifier());
			        		    	}
			        		    	catch(Exception q) {
			        		    		q.printStackTrace();
			        		    	}
				        			conn.close();
								}
								else {
									HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultmodifier","");
								}
							}
						} catch (NumberFormatException | SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
						try {
							HL7Server.updateRequestedLabanalysis(Integer.parseInt(serverid), Integer.parseInt(transactionid), labcode, "resultunit",unit);
							SH.syslog("\tstored resultunit: "+unit);
						} catch (NumberFormatException | SQLException e) {
							// TODO Auto-generated catch block
							e.printStackTrace();
						}
        			}
        		}
        	}
        	HL7Server.setReceivedMessageProcessed(message);
        }
        else if(messageType.equalsIgnoreCase("ACK")) {
        	SH.syslog("Received ACK");
        	ACK ack = (ACK)message;
	    	if("*AA*CA*".contains(ack.getMSA().getAcknowledgmentCode().getValue().toUpperCase())) {
        		try {
					HL7Server.setTransactionACK(ack.getMSA().getMessageControlID().getValue(), ack.getMSH().getDateTimeOfMessage().getTime().getValueAsCalendar().getTime());
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
        	}
        	else {
        		Parser p = context.getPipeParser();
        		String error = p.encode(ack);
        		try {
					HL7Server.setTransactionError(ack.getMSA().getMessageControlID().getValue(), error);
				} catch (SQLException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
        	}
        	HL7Server.setReceivedMessageProcessed(message);
        }
        else {
        	//TODO: Any other message type
        	HL7Server.setReceivedMessageProcessed(message);
        }
        // Now generate a simple acknowledgment message and return it
        try {
            context.close();
            if(sError.length()==0) {
        		Message ack = message.generateACK();
        		terser = new Terser(ack);
        		terser.set("MSH-9-2", null);
        		terser.set("MSH-9-3", null);
        		SH.syslog("returning ACK:");
         		System.out.println(ack.encode().replaceAll("\r", "\r\n"));
            	return ack;
        	}
        	else {
        		Message ack = message.generateACK(AcknowledgmentCode.AE, new HL7Exception(sError));
        		terser = new Terser(ack);
        		terser.set("MSH-9-2", null);
        		terser.set("MSH-9-3", null);
         		System.out.println(ack.encode().replaceAll("\r", "\r\n"));
        		return ack;
        	}
        } catch (IOException e) {
            throw new HL7Exception(e);
        }
    }
}
