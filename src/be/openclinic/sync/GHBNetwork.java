package be.openclinic.sync;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.sql.*;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.commons.httpclient.methods.multipart.MultipartRequestEntity;
import org.apache.commons.httpclient.methods.multipart.Part;
import org.apache.commons.httpclient.methods.multipart.StringPart;
import org.apache.commons.io.IOUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.ContentType;
import org.apache.http.entity.mime.HttpMultipartMode;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.entity.mime.content.StringBody;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.message.BasicNameValuePair;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import be.mxs.common.model.vo.healthrecord.HealthRecordVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.medical.RequestedLabAnalysis;
import be.openclinic.system.Encryption;
import be.openclinic.system.SH;
import net.admin.AdminPerson;

public class GHBNetwork {
	
	public static String syncGHBServers(String domain) {
		try {
			HttpClient client = new HttpClient();
			PostMethod method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_updateurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/getGHBServers.jsp"));
			method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
			NameValuePair[] nvp = new NameValuePair[1];
			nvp [0] = new NameValuePair("domain",domain);
			method.setQueryString(nvp);
			int statusCode = client.executeMethod(method);
			if(method.getResponseBodyAsString().contains("<servers")){
				Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
				PreparedStatement ps = conn.prepareStatement("delete from GHB_SERVERS");
				ps.execute();
				ps.close();
				Document document=DocumentHelper.parseText(method.getResponseBodyAsString().substring(method.getResponseBodyAsString().indexOf("<servers")));
				Element root = document.getRootElement();
				Iterator servers = root.elementIterator("server");
				while(servers.hasNext()){
					Element server = (Element)servers.next();
					ps=conn.prepareStatement("insert into GHB_SERVERS(GHB_SERVER_DOMAIN,GHB_SERVER_NAME,GHB_SERVER_CONTACT,GHB_SERVER_PHONE,GHB_SERVER_EMAIL,GHB_SERVER_PUBKEY,GHB_SERVER_UPDATETIME,GHB_SERVER_ID) values(?,?,?,?,?,?,?,?)");
					ps.setString(1,server.elementText("domain"));
					ps.setString(2,server.elementText("name"));
					ps.setString(3,server.elementText("contact"));
					ps.setString(4,server.elementText("telephone"));
					ps.setString(5,server.elementText("email"));
					ps.setString(6,server.elementText("pubkey"));
					ps.setTimestamp(7, new Timestamp(new java.util.Date().getTime()));
					ps.setInt(8,Integer.parseInt(server.elementText("serverid")));
					ps.execute();
					ps.close();
				}
				ps.close();
				conn.close();
				return "Updated "+root.elements("server").size()+" GHB servers";
			}
			return "<ERROR E001>No servers synced";
		}
		catch(Exception e) {
			return "<ERROR E002>Error syncing GHB servers: "+e.getMessage();
		}
	}
	
	public static String getServerNameById(String serverid) {
		try {
			return getServerNameById(Integer.parseInt(serverid));
		}
		catch(Exception e) {
			return "";
		}
	}
	
	public static String getServerNameById(int serverid) {
		String sName = "?";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from ghb_servers where ghb_server_id=?");
			ps.setInt(1,serverid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				sName = rs.getString("ghb_server_name");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return sName;
	}
	
	public static String getServerNameByDomain(String domain) {
		String sName = domain;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		if(SH.ci("isMPIServer", 0)==1) {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			conn = MedwanQuery.getInstance().getStatsConnection();
		}
		try {
			PreparedStatement ps = conn.prepareStatement("select * from ghb_servers where ghb_server_domain=?");
			ps.setString(1,domain);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				sName = rs.getString("ghb_server_name");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return sName;
	}
	
	public static void readMessages() {
		if(MedwanQuery.getInstance().getConfigString("ghb_ref_serverid","").trim().length()==0) {
			return;
		}
		try {
			Debug.println("Getting GHB message count from "+MedwanQuery.getInstance().getConfigString("ghb_ref_countmessagesurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/getGHBMessageCount.jsp"));
			HttpClient client = new HttpClient();
			PostMethod method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_countmessagesurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/getGHBMessageCount.jsp"));
			Part[] parts= {
					new StringPart("serverid",MedwanQuery.getInstance().getConfigString("ghb_ref_serverid","")),
					new StringPart("project",MedwanQuery.getInstance().getConfigString("defaultProject",""))
			};
			method.setRequestEntity(new MultipartRequestEntity(parts, method.getParams()));
			client.executeMethod(method);
			String sResponse = IOUtils.toString(method.getResponseBodyAsStream(), StandardCharsets.UTF_8);
			if(sResponse.contains("<messages")){
				Document document=DocumentHelper.parseText(sResponse.substring(sResponse.indexOf("<messages")));
				Element root = document.getRootElement();
				Debug.println("Received message count: "+root.attributeValue("count"));
				if(ScreenHelper.checkString(root.attributeValue("count")).length()>0) {
					if(Integer.parseInt(root.attributeValue("count"))>0) {
						//Read all the messages
						method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_readmessagesurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/readGHBMessages.jsp"));
						method.setRequestEntity(new MultipartRequestEntity(parts, method.getParams()));
						client.executeMethod(method);
						Debug.println("Retrieving GHB message list from "+MedwanQuery.getInstance().getConfigString("ghb_ref_readmessagesurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/readGHBMessages.jsp"));
						sResponse = IOUtils.toString(method.getResponseBodyAsStream(), StandardCharsets.UTF_8);
						if(sResponse.contains("<messages")){
							document=DocumentHelper.parseText(sResponse.substring(sResponse.indexOf("<messages")));
							root = document.getRootElement();
							Iterator iMessages = root.elementIterator("message");
							while(iMessages.hasNext()) {
								Element message = (Element)iMessages.next();
								String messageid = message.attributeValue("id");
								Debug.println("Retrieving message id "+messageid);
								//Now load this message
								method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_readmessageurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/readGHBMessage.jsp"));
								Part[] parts2= {
										new StringPart("messageid",messageid)
								};
								method.setRequestEntity(new MultipartRequestEntity(parts2, method.getParams()));
								client.executeMethod(method);
								sResponse = IOUtils.toString(method.getResponseBodyAsStream(), StandardCharsets.UTF_8);
								if(sResponse.contains("<message")){
									Debug.println("Received message id "+messageid);
									document=DocumentHelper.parseText(sResponse.substring(sResponse.indexOf("<message")));
									root = document.getRootElement();
									String targetserverid = root.elementText("targetserverid");
									String sourceserverid = root.elementText("sourceserverid");
									String encryptedData = root.elementText("data");
									String encryptedToken = root.elementText("token");
									Debug.println("ENC-- Decrypting token with private key");
									Debug.println("ENC-- Encrypted token = "+encryptedToken);
									String token="";
									try {
										token = Encryption.decryptTextWithPrivateKey(encryptedToken, MedwanQuery.getInstance().getConfigString("ghb_ref_privkey"));
									}
									catch(Exception e) {
										e.printStackTrace();
										continue;
									}
									Debug.println("ENC-- Decrypted token = "+token);
									Debug.println("ENC-- Decrypting text with token");
									String data = Encryption.decryptTextSymmetric(encryptedData, token);
									//For security reasons: check that this server is indeed the intended target
									Debug.println("Target server "+MedwanQuery.getInstance().getConfigString("ghb_ref_serverid","")+" = "+targetserverid);
									String tranids = "";
									if(MedwanQuery.getInstance().getConfigString("ghb_ref_serverid","").equalsIgnoreCase(targetserverid)) {
										Debug.println("Source server "+MedwanQuery.getInstance().getConfigString("ghb_ref_serverid","")+" <> "+sourceserverid);
										//We don't want to treat messages that come from ourselves
										if(!MedwanQuery.getInstance().getConfigString("ghb_ref_serverid","").equalsIgnoreCase(sourceserverid)) {
											//Now integrate the message into the medical record system
											//Replace the serverid in every record by the serverid of the source server
											Debug.println("Integrating message");
											document=DocumentHelper.parseText(data); 
											Element record = document.getRootElement();
											Element patient = record.element("person");
											String personid="";
											Debug.println("destpersonid="+ScreenHelper.checkString(patient.attributeValue("destpersonid")));
											if(ScreenHelper.checkString(patient.attributeValue("destpersonid")).length()>0) {
												personid=patient.attributeValue("destpersonid");
												if(personid.length()>0 && AdminPerson.getAdminPerson(personid).lastname.length()==0) {
													//The destination personid does not exist (anymore)
													personid="";
												}
											}
											AdminPerson person = new AdminPerson();
											person.fromXmlElement(patient, true);
											String pointer="GHB.PATIENTREF."+sourceserverid+"."+person.personid;
											Debug.println("patientref="+pointer);
											if(personid.length()==0) {
												//First match based on pointer
												personid=Pointer.getPointer(pointer);
												if(personid.length()>0 && AdminPerson.getAdminPerson(personid).lastname.length()==0) {
													personid="";
												}
											}
											Debug.println("personid 1="+personid);
											if(personid.length()==0 && person.getExtendedValue("mpiid").length()>0) {
												//Match patient on MPI ID
												Connection conn = SH.getAdminConnection();
												PreparedStatement ps = conn.prepareStatement("SELECT * FROM adminextends WHERE labelid='mpiid' AND extendvalue=?");
												ps.setString(1, person.getExtendedValue("mpiid"));
												ResultSet rs = ps.executeQuery();
												if(rs.next()) {
													personid=rs.getString("personid");
												}
												rs.close();
												ps.close();
												conn.close();
											}
											if(MedwanQuery.getInstance().getConfigInt("enableGHBMatchOnNatreg",0)==1 && personid.length()==0 && person.getID("natreg").length()>0) {
												//Match patient on natreg and name and firstname
												personid = AdminPerson.getUniquePersonIdByNatReg(person.getID("natreg"));
												if(personid!=null) {
													AdminPerson dbPerson = AdminPerson.getAdminPerson(personid);
													if(!dbPerson.lastname.equalsIgnoreCase(person.lastname) || !dbPerson.firstname.equalsIgnoreCase(person.firstname)) {
														personid="";
													}
													if(personid.length()>0) {
														Pointer.storePointer(pointer, personid);
														Pointer.storePointer("GHB.PATIENTBACKREF."+sourceserverid+"."+person.personid,patient.attributeValue("personid"));
													}
												}
												else {
													personid="";
												}
												Debug.println("personid 2="+personid);
											}
											if(MedwanQuery.getInstance().getConfigInt("enableGHBMatchOnNameAndDateOfBirth",1)==1 && personid.length()==0 && person.lastname.length()>0 && person.firstname.length()>0 && person.dateOfBirth.length()>0) {
												//Match patient on lastname, firstname and date of birth
												Hashtable hSelect = new Hashtable();
												hSelect.put(" lastname = ? AND",person.lastname);
												hSelect.put(" firstname = ? AND",person.firstname);
												hSelect.put(" dateofbirth = ? AND",person.dateOfBirth);
												personid = ScreenHelper.checkString(AdminPerson.getUniquePersonIdBySearchNameDateofBirth(hSelect));
												if(personid.length()>0) {
													pointer="GHB.PATIENTREF."+sourceserverid+"."+person.personid;
													Pointer.storePointer(pointer, personid);
													Pointer.storePointer("GHB.PATIENTBACKREF."+sourceserverid+"."+person.personid,patient.attributeValue("personid"));
												}
												Debug.println("personid 3="+personid);
											}
											if(personid.length()==0) {
												Debug.println("NEW PATIENT");
												//This is a new, unknown patient. Let's save the record
												person.personid="";
												person.store();
												Pointer.storePointer("GHB.PATIENTBACKREF."+sourceserverid+"."+person.personid,patient.attributeValue("personid"));
												personid=person.personid;
												Pointer.storePointer(pointer, personid);
											}
											Iterator transactions = record.elementIterator("Transaction");
											while(transactions.hasNext()) {
												Element transaction = (Element)transactions.next();
												TransactionVO transactionVO = TransactionVO.fromXMLElement(transaction);
												Debug.println("Transaction serverid = "+transactionVO.getServerId());
												if(transactionVO.getServerId()!=Integer.parseInt(targetserverid)) {
													//We don't handle our own transactions
													if(transactionVO.getServerId()==1) {
														//We don't translate already translated ids
														transactionVO.setServerId(Integer.parseInt(sourceserverid));
														transactionVO.setVersionServerId(Integer.parseInt(sourceserverid));
													}
													//Remove encounter data because we don't import encounters
													for(int n=0;n<transactionVO.getItems().size();n++) {
														ItemVO i = (ItemVO)new Vector(transactionVO.getItems()).elementAt(n);
														if(i.getType().equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID")) {
															transactionVO.getItems().remove(i);
														}
													}
													//Replace transaction user by default system user because original userid is unknown
													transactionVO.setUser(MedwanQuery.getInstance().getUser(MedwanQuery.getInstance().getConfigString("externalUserId","4")));
													//transactionVO.setTransactionId(MedwanQuery.getInstance().getOpenclinicCounter("TransactionID"));
													MedwanQuery.getInstance().updateTransaction(Integer.parseInt(personid), transactionVO);
													if(tranids.length()>0) {
														tranids+=";";
													}
													tranids+="T:"+Math.abs(transactionVO.getServerId())+"."+transactionVO.getTransactionId();
												}
											}
											Iterator labanalyses = record.elementIterator("RequestedLabAnalysis");
											while(labanalyses.hasNext()) {
												Element labanalysis = (Element)labanalyses.next();
												RequestedLabAnalysis requestedLabAnalysis = RequestedLabAnalysis.fromXMLElement(labanalysis);
												if(!requestedLabAnalysis.getServerId().equalsIgnoreCase(targetserverid)) {
													//We don't handle our own transactions
													if(requestedLabAnalysis.getServerId().equalsIgnoreCase("1")) {
														//We don't translate already translated ids
														requestedLabAnalysis.setServerId(sourceserverid);
													}
													requestedLabAnalysis.setPatientId(personid);
													requestedLabAnalysis.store();
												}
											}
										}
										else {
											Debug.println("ERROR: Discarding message because comes from this server");
										}
										//The message was correctly read, send the Transaction ACK to the server
										if(tranids.length()>0) {
											method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_ackurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/setGHBACK.jsp"));
											method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
											NameValuePair[] nvp = new NameValuePair[4];
											nvp [0] = new NameValuePair("ref",tranids);
											nvp [1] = new NameValuePair("source",targetserverid);
											nvp [2] = new NameValuePair("target",sourceserverid);
											nvp [3] = new NameValuePair("comment","");
											method.setQueryString(nvp);
											client.executeMethod(method);
											sResponse = IOUtils.toString(method.getResponseBodyAsStream(), StandardCharsets.UTF_8);
											if(sResponse.contains("<ok>")){
												//The ACK was correctly sent or was empty, store the delivery date on the server
												method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_delivermessageurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/deliverGHBMessage.jsp"));
												method.setRequestEntity(new MultipartRequestEntity(parts2, method.getParams()));
												client.executeMethod(method);
											}
										}
										else {
											//The ACK was correctly sent or was empty, store the delivery date on the server
											method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_delivermessageurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/deliverGHBMessage.jsp"));
											method.setRequestEntity(new MultipartRequestEntity(parts2, method.getParams()));
											client.executeMethod(method);
										}
									}
									else {
										//Wrong target server, discard the message
										Debug.println("ERROR: Discarding message because not addressed to this server");
									}
								}
							}
						}
					}
				}
			}
			Debug.println("Getting GHB ACK from "+MedwanQuery.getInstance().getConfigString("ghb_ref_getackurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/getGHBACK.jsp"));
			method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_getackurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/getGHBACK.jsp"));
			method.setRequestHeader("Content-type","text/xml; charset=windows-1252");
			NameValuePair[] nvp = new NameValuePair[2];
			nvp [0] = new NameValuePair("serverid",MedwanQuery.getInstance().getConfigString("ghb_ref_serverid",""));
			java.util.Date date = SH.parseDate("01/01/1900");
			Connection conn = SH.getOpenClinicConnection();
			PreparedStatement ps = conn.prepareStatement("select max(GHB_ACK_DATETIME) datetime from GHB_ACK");
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				if(rs.getTimestamp("datetime")!=null) {
					date=rs.getTimestamp("datetime");
				}
			}
			ps.close();
			rs.close();
			nvp [1] = new NameValuePair("datetime",SH.formatDate(date, "yyyyMMddHHmmssSSS"));
			method.setQueryString(nvp);
			client.executeMethod(method);
			sResponse = IOUtils.toString(method.getResponseBodyAsStream(), StandardCharsets.UTF_8);
			if(sResponse.contains("<message>")){
				Document document=DocumentHelper.parseText(sResponse);
				Element root = document.getRootElement();
				Iterator<Element> iAck = root.elementIterator("ack");
				while(iAck.hasNext()) {
					Element ack =iAck.next();
					String ref=SH.c(ack.attributeValue("ref"));
					if(ref.length()>0) {
						ps = conn.prepareStatement("delete from GHB_ACK where GHB_ACK_REF=?");
						ps.setString(1, ref);
						ps.execute();
						ps.close();
						ps = conn.prepareStatement("insert into GHB_ACK(GHB_ACK_REF,GHB_ACK_SOURCESERVERID,GHB_ACK_DATETIME,GHB_ACK_COMMENT) values(?,?,?,?)");
						ps.setString(1, ref);
						ps.setString(2, SH.c(ack.attributeValue("source")));
						ps.setTimestamp(3, SH.getSQLTimestamp(SH.parseDate(SH.c(ack.attributeValue("datetime")),"yyyyMMddHHmmssSSS")));
						ps.setString(4, SH.c(ack.attributeValue("comment")));
						ps.execute();
						ps.close();
					}
				}
			}
			conn.close();
		}
		catch(Exception e) {
			Debug.printStackTrace(e);
		}
	}
	
	public static void sendMessages() {
		if(MedwanQuery.getInstance().getConfigString("ghb_ref_serverid","").trim().length()==0) {
			return;
		}
		try {
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			PreparedStatement ps = conn.prepareStatement("select * from GHB_Messages where GHB_MESSAGE_DELIVEREDDATETIME is null and GHB_MESSAGE_ERROR is null");
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				int targetServerId = rs.getInt("GHB_MESSAGE_TARGETSERVERID");
				String data = new String(rs.getBytes("GHB_MESSAGE_DATA"));
				int messageid=rs.getInt("GHB_MESSAGE_ID");
				Debug.println("Sending GHB message id "+messageid);
				Debug.println("Getting pubkey for destination server "+targetServerId);
				//Get pubkey for this targetserver
				HttpClient client = new HttpClient();
				PostMethod method = new PostMethod(MedwanQuery.getInstance().getConfigString("ghb_ref_getpubkeyurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/getGHBPubkey.jsp"));
				Part[] parts= {
						new StringPart("serverid",targetServerId+""),
				};
				method.setRequestEntity(new MultipartRequestEntity(parts, method.getParams()));
				client.executeMethod(method);
				String sResponse = IOUtils.toString(method.getResponseBodyAsStream(), StandardCharsets.UTF_8);
				if(sResponse.contains("<pubkey")){
					Document document=DocumentHelper.parseText(sResponse.substring(sResponse.indexOf("<pubkey")));
					Element root = document.getRootElement();
					if(ScreenHelper.checkString(root.attributeValue("error")).length()>0) {
						Debug.println("Received ERROR "+root.attributeValue("error"));
						PreparedStatement ps2 = conn.prepareStatement("update GHB_MESSAGES set GHB_MESSAGE_ERROR=? where GHB_MESSAGE_ID=?");
						ps2.setString(1, root.attributeValue("error"));
						ps2.setInt(2, messageid);
						ps2.execute();
						ps2.close();
					}
					else {
						Debug.println("Received pubkey for destination server "+targetServerId);
						String pubkey = root.getText();
						String token = Encryption.getToken(16);
						String encryptedToken = Encryption.encryptTextWithPublicKey(token, pubkey);
						String encryptedData = Encryption.encryptTextSymmetric(data, token);
						//Now we post the encrypted data to the GHB server
						String storeurl=MedwanQuery.getInstance().getConfigString("ghb_ref_storemessageurl","http://www.globalhealthbarometer.net/globalhealthbarometer/util/storeGHBMessage.jsp");
						Debug.println("Posting message to "+storeurl);
						PostMethod post = new PostMethod(storeurl);
						Part[] parts2= {
							new StringPart("sourceserverid",MedwanQuery.getInstance().getConfigString("ghb_ref_serverid","")),
							new StringPart("targetserverid",targetServerId+""),
							new StringPart("data",encryptedData),
							new StringPart("token",encryptedToken)
						};
						post.setRequestEntity(new MultipartRequestEntity(parts2, post.getParams()));
						int status = client.executeMethod(post);
						sResponse = IOUtils.toString(post.getResponseBodyAsStream(), StandardCharsets.UTF_8);
						if(sResponse.contains("<ok>")){
							Debug.println("Message successfully posted");
							//Message successfully delivered
							PreparedStatement ps2 = conn.prepareStatement("update GHB_MESSAGES set GHB_MESSAGE_DELIVEREDDATETIME=? where GHB_MESSAGE_ID=?");
							ps2.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()));
							ps2.setInt(2, messageid);
							ps2.execute();
							ps2.close();
						}
						else {
							Debug.println("Error posting message");
						}
					}
				}
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}

}
