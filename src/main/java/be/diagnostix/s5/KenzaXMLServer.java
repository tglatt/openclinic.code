package be.diagnostix.s5;

import java.io.File;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Vector;

import org.apache.commons.io.FileUtils;
import org.dcm4che2.data.Tag;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryGeneral;
import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;
import be.openclinic.archiving.ScannableFileFilter;
import be.openclinic.medical.RequestedLabAnalysis;
import be.openclinic.system.SH;

public class KenzaXMLServer implements Runnable {
	String pathin = null;
	Thread thread =null;
	
	public KenzaXMLServer(String pathin) {
		this.pathin=pathin;
	}
	
	@Override
	public void run() {
		while(true) {
			try {
				//Scan incoming directory and do stuff
				if(SH.ci("s5.xml.kenza.debug", 1)==1) {
					SH.syslog("Scanning Kenza XML path ["+pathin+"]");
				}
				File scanDir = new File(pathin);
		    	ScannableFileFilter fileFilter = new ScannableFileFilter(SH.cs("s5.xml.kenza.excludeextensions", ""));
		    	File[] scannableFiles = scanDir.listFiles(fileFilter); 
		    	if(scannableFiles!=null && scannableFiles.length > 0){
					if(SH.ci("s5.xml.kenza.debug", 1)==1) {
						SH.syslog("Found "+scannableFiles.length+" files");
					}
		    		for(int n=0;n<scannableFiles.length;n++) {
			    		File file = scannableFiles[n];
						if(file.getName().endsWith(SH.cs("s5.xml.kenza.includeextensions", ".xml"))) {
							readFile(file);
						}
			    	}
		    	}
		    	Thread.sleep(SH.cl("s5.xml.kenza.scaninterval", 10000));
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
	}
	
	public void start() {
		thread = new Thread(this);
		thread.start();
	}
	
	public void readFile(File file) {
		SH.syslog("Reading "+file.getAbsolutePath());
        SAXReader reader = new SAXReader(false);
        try {
	        Document document = reader.read(file);
	        Element root = document.getRootElement();
	        if(root.getName().equalsIgnoreCase("lab-result")) {
	        	//Patient header
	        	String device = root.attributeValue("device");
	        	java.util.Date date = SH.parseDate(root.elementText("date"),"yyyyMMddHHmmss");
	        	SH.syslog("date = "+date);
	        	String patientId = root.elementText("patient-id").trim();
	        	String patientName = root.elementText("patientname");
	        	String gender = root.elementText("species");
	        	String transactionId = "";
	        	if(gender.toLowerCase().startsWith("m")) {
	        		gender="m";
	        	}
	        	else {
	        		gender="f";
	        	}
	        	if(MedwanQuery.getInstance().getPerson(patientId)==null) {
	        		SH.syslog("No matching patient for Patient ID "+patientId);
	        		return;
	        	}
				SH.syslog("Found results file for "+patientName+" with ID "+patientId+" ["+MedwanQuery.getInstance().getPerson(patientId).getFullName()+"] on "+SH.formatDate(date,"dd/MM/yyyy HH:mm"));
				Element results = root.element("results");
				if(results!=null) {
					Iterator<Element> tests = results.elementIterator("param");
					while(tests.hasNext()) {
						Element test = tests.next();
						String code = test.elementText("name").trim();
						if(SH.cs("s5.xml.kenza.mappings", "").length()>0) {
							String[] mappings = SH.cs("s5.xml.kenza.mappings", "").split(",");
							for(int n=0;n<mappings.length;n++) {
								if(mappings[n].split("=").length>1 && code.equalsIgnoreCase(mappings[n].split("=")[0])) {
									code=mappings[n].split("=")[1];
								}
							}
						}
						SH.syslog("code="+code);
						String value = test.elementText("value").replaceAll(",", ".");
						String valuetext = test.elementText("valuetext");
						String unit = test.elementText("unit");
						String modifier = test.elementText("flag");
						String min = test.elementText("min");
						String max = test.elementText("max");
						boolean bUnsolicited = SH.ci("s5.xml.kenza.unsolicited", 0)==1;
						//Check if an open labrequest exists for the patient with this testcode and less than x days ago
						Connection conn = SH.getOpenClinicConnection();
						String sql = "select r.* from requestedlabanalyses r,transactions t where"+
									 " t.healthrecordid=? and"+
									 " r.transactionid=t.transactionid and"+
									 " r.serverid=t.serverid and"+
									 " r.analysiscode=? and"+
									 " (r.resultvalue is null or r.resultvalue='') and"+
									 " r.requestdatetime>=? order by r.requestdatetime desc";
						PreparedStatement ps =conn.prepareStatement(sql);
						ps.setInt(1,MedwanQuery.getInstance().getHealthRecordIdFromPersonId(Integer.parseInt(patientId)));
						ps.setString(2, code);
						ps.setTimestamp(3, SH.getSQLTimestamp(new java.util.Date(date.getTime()-SH.ci("s5.xml.kenza.maxdelay", 48)*SH.getTimeHour())));
						ResultSet rs = ps.executeQuery();
						if(rs.next()) {
							//It exists. Update the values for this lab test
							transactionId=rs.getString("transactionid");
							RequestedLabAnalysis ra = RequestedLabAnalysis.get(rs.getInt("serverid"), rs.getInt("transactionid"), code);
							ra.setResultValue(value.replaceAll(",", "."));
							ra.setComment(valuetext);
							ra.setResultUnit(unit);
							ra.setResultModifier(modifier);
							ra.setResultRefMin(min);
							ra.setResultRefMax(max);
							if(SH.ci("s5.xml.kenza.autovalidate", 1)==1) {
								ra.setTechnicalvalidation(SH.ci("s5.xml.kenza.defaultuser", 4));
								ra.setTechnicalvalidationdatetime(date);
								ra.setFinalvalidation(SH.ci("s5.xml.kenza.defaultuser", 4));
								ra.setFinalvalidationdatetime(date);
							}
							ra.store();
						}
						else if (bUnsolicited) {
							//Check if this result hasn't been read yet
							rs.close();
							ps.close();
							sql = "select r.* from requestedlabanalyses r,transactions t where"+
									 " t.healthrecordid=? and"+
									 " r.transactionid=t.transactionid and"+
									 " r.serverid=t.serverid and"+
									 " r.analysiscode=? and"+
									 " r.requestdatetime=?";
							ps =conn.prepareStatement(sql);
							ps.setInt(1,MedwanQuery.getInstance().getHealthRecordIdFromPersonId(Integer.parseInt(patientId)));
							ps.setString(2, code);
							ps.setTimestamp(3, SH.getSQLTimestamp(date));
							rs = ps.executeQuery();
							if(rs.next()) {
								transactionId=rs.getString("transactionid");
								//The result was already read, skip
								rs.close();
								ps.close();
								conn.close();
								continue;
							}
							//Check if a labrequest not older than x days exists. I yes, use it, if not create one
							TransactionVO tran = MedwanQuery.getInstance().getLastTransactionsByTypeAfter(Integer.parseInt(patientId), "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST", new java.util.Date(date.getTime()-SH.ci("s5.xml.kenza.maxdelay", 48)*SH.getTimeHour()));
							if(tran==null) {
				    			tran = new TransactionFactoryGeneral().createTransactionVO(MedwanQuery.getInstance().getUser(SH.cs("s5.xml.kenza.defaultuser", "4")),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST",false); 
				    			tran.setCreationDate(date);
				    			tran.setStatus(1);
				    			tran.setTransactionId(MedwanQuery.getInstance().getOpenclinicCounter("TransactionID"));
				    			tran.setServerId(SH.getServerId());
				    			tran.setHealthrecordId(MedwanQuery.getInstance().getHealthRecordIdFromPersonIdWithCreate(Integer.parseInt(patientId)));
				    			tran.setTransactionType("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST");
				    			try {
				    				tran.setUpdateTime(date);
				    			}
				    			catch(Exception ed) {
				    				tran.setUpdateTime(new java.util.Date());
				    			}
				    			UserVO user = MedwanQuery.getInstance().getUser(SH.cs("s5.xml.kenza.defaultuser", "4"));
				    			if(user==null){
				    				MedwanQuery.getInstance().getUser("4");
				    			}
				    			tran.setUser(user);
				    			tran.setVersion(1);
				    			tran.setItems(new Vector());
				    			String encounteruid="",service="";
				    			Encounter encounter = Encounter.getLastEncounter(patientId);
				    			if(encounter!=null) {
				    				encounteruid=encounter.getUid();
				    				service=encounter.getServiceUID();
				    			}
				    			tran.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
				    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID",encounteruid,new Date(),null));
				    			tran.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
				    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT",service,new Date(),null));
				    			tran.store();
							}
							transactionId=tran.getTransactionId()+"";
							//Add the analysis to the labrequest
							RequestedLabAnalysis ra = new RequestedLabAnalysis();
							ra.setServerId(tran.getServerId()+"");
							ra.setTransactionId(tran.getTransactionId()+"");
							ra.setPatientId(patientId);
							ra.setUpdatetime(new java.util.Date());
							ra.setAnalysisCode(code);
							ra.setResultValue(value.replaceAll(",", "."));
							ra.setComment(valuetext);
							ra.setResultUnit(unit);
							ra.setResultModifier(modifier);
							ra.setResultRefMin(min);
							ra.setResultRefMax(max);
							if(SH.ci("s5.xml.kenza.autovalidate", 1)==1) {
								ra.setTechnicalvalidation(SH.ci("s5.xml.kenza.defaultuser", 4));
								ra.setTechnicalvalidationdatetime(date);
								ra.setFinalvalidation(SH.ci("s5.xml.kenza.defaultuser", 4));
								ra.setFinalvalidationdatetime(date);
							}
							ra.store();
						}
						rs.close();
						ps.close();
						conn.close();
					}
				}
		        //The file has been processed correctly, store it
				Connection conn = SH.getOpenClinicConnection();
				String sql = "insert into oc_s5xml(oc_s5xml_id,oc_s5xml_device,oc_s5xml_received,oc_s5xml_transactionid,oc_s5xml_patientid,oc_s5xml_format,oc_s5xml_message) values(?,?,?,?,?,?,?)";
				PreparedStatement ps= conn.prepareStatement(sql);
				ps.setInt(1, MedwanQuery.getInstance().getOpenclinicCounter("S5XML"));
				ps.setString(2, device);
				ps.setTimestamp(3, SH.getSQLTime());
				ps.setString(4, transactionId);
				ps.setString(5, patientId);
				ps.setString(6, "KENZA");
				ps.setBytes(7, document.asXML().getBytes());
				ps.execute();
				ps.close();
				conn.close();
	        }
	        //The file has been processed correctly, move it
	        String donepath = SH.cs("s5.xml.kenza.donepath", "/tmp/done");
	        File doneDir = new File(donepath);
	        if(!doneDir.exists()){
	        	doneDir.mkdirs();
	        }
	        FileUtils.moveFile(file, new File(donepath+"/"+file.getName()));
        }
        catch(Exception e) {
        	e.printStackTrace();
        }
	}
}
