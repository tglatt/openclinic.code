package be.opencarenet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.text.SimpleDateFormat;
import java.util.Hashtable;

import org.apache.http.HttpResponse;
import org.json.*;

import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Pointer;
import be.openclinic.system.SH;
import net.admin.AdminPerson;
import net.admin.AdminPrivateContact;

public class OpenCarenetClient {
	int counter=0;
	
	public void readMessages() throws Exception {
		readMessages(0);
	}
	
	public void readMessages(int minid) throws Exception {
		int maxid=0;
		String url = SH.cs("opencarenet_url", "https://oche.virtual.donexa.org/api/exchanges/");
		if(minid>0) {
			url+="?offset="+minid;
		}
		String username = SH.cs("opencarenet_username", "username");
		String password = SH.cs("opencarenet_password", "password");
		//Todo: add offset to URL
		HttpResponse resp = SH.getAuthenticated(url, username, password);
		org.json.JSONArray messages = SH.getJsonArray(resp);
		Debug.println("Total OpenCarenet messages retrieved: "+messages.length());
		for(int n=0;n<messages.length();n++){
			OpenCarenetForm ocForm = new OpenCarenetForm();
			JSONObject message = messages.getJSONObject(n);
			System.out.println(message.toString(4));
			ocForm.messageId = message.getInt("id");
			Connection conn = SH.getOpenClinicConnection();
			PreparedStatement ps = conn.prepareStatement("insert into oc_documents(oc_document_serverid,oc_document_objectid,oc_document_name,oc_document_createtime,oc_document_updatetime,oc_document_updateuid,oc_document_value)"+
														 " values(?,?,?,?,?,?,?)");
			ps.setInt(1, SH.getServerId());
			ps.setInt(2, MedwanQuery.getInstance().getOpenclinicCounter("DocumentID"));
			ps.setString(3,"OPENCARENTE.MESSAGE."+ocForm.messageId);
			ps.setTimestamp(4, SH.getSQLTime());
			ps.setTimestamp(5, SH.getSQLTime());
			ps.setInt(6, SH.ci("opencarenet_updateuser", 4));
			ps.setBytes(7, message.toString(4).getBytes());
			ps.execute();
			ps.close();
			conn.close();
			
			//Receiver
			JSONObject receiver = message.getJSONObject("receiver");
			int receiverId = receiver.getInt("id");
			if(!(SH.ci("opencarenet_clientid",-1)==receiverId)) {
				continue;
			}
			
			//Sender
			JSONObject sender = message.getJSONObject("sender");
			ocForm.inputs.put("senderid", sender.getInt("id")+"");
			ocForm.inputs.put("senderuser",sender.getString("displayName"));
			ocForm.inputs.put("senderentity",sender.getJSONObject("entity").getString("displayName"));
			
			//Data
			JSONObject data = message.getJSONObject("raw");
			JSONObject form = data.getJSONObject("form");
			ocForm.inputs.put("formname",form.getString("name_fr"));
			ocForm.inputs.put("formdate",SH.parseDate(data.getString("createdAt"),"yyyy-MM-dd HH:mm:ss.SSS"));
			JSONArray formInputs = form.getJSONArray("inputs");
			for(int i=0;i<formInputs.length();i++) {
				JSONObject input = formInputs.getJSONObject(i);
				storeInput(ocForm.inputs,input,"");
			}
			
			//Store message
			if(ocForm.store()) {
				if(ocForm.messageId>maxid) {
					maxid=ocForm.messageId;
				}
			}
			else {
				return;
			}
		}
		if(maxid>0) {
			Pointer.deletePointers("OPENCARENET.MAXMESSAGEID");
			Pointer.storePointer("OPENCARENET.MAXMESSAGEID", maxid+"");
		}
	}
	
	private void storeInput(Hashtable inputs, JSONObject input, String parent) {
		String key = parent+(input.getString("key")).toLowerCase().replaceAll(" ", "-");
		String type = input.getString("type");
		try {
			if(type.equalsIgnoreCase("patient")) {
				JSONObject personData = input.getJSONObject("value");
				AdminPerson person = new AdminPerson();
				person.personid = personData.getInt("key")+"";
				person.firstname = personData.getString("name").toUpperCase();
				person.lastname = personData.getString("lastname").toUpperCase();
				if(personData.getJSONObject("gender").getInt("id")==1) {
					person.gender="M";
				}
				else {
					person.gender="F";
				}
				person.dateOfBirth=SH.formatDate(SH.parseDate(personData.getString("birth-date"),"yyyy-MM-dd HH:mm:ss.SSS"));
				AdminPrivateContact pc = new AdminPrivateContact();
				pc.begin=SH.formatDate(new java.util.Date());
				pc.address=personData.getString("full-address");
				person.privateContacts.add(pc);
				person.nativeTown=personData.getString("birth-place");
				inputs.put(key, person);
			}
			else if(type.equalsIgnoreCase("text") || type.equalsIgnoreCase("long-text") || type.equalsIgnoreCase("date-time")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+input.getString("value"));
			}
			else if(type.equalsIgnoreCase("decimal")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+input.getFloat("value"));
			}
			else if(type.equalsIgnoreCase("integer")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+input.getInt("value"));
			}
			else if(type.equalsIgnoreCase("date")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+input.getString("value").substring(0,10));
			}
			else if(type.equalsIgnoreCase("time")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+input.getString("value").substring(10).trim());
			}
			else if(type.equalsIgnoreCase("range")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+input.getJSONObject("value").getFloat("value")+" ["+input.getJSONObject("value").getFloat("min")+" - "+input.getJSONObject("value").getFloat("max")+"]");
			}
			else if(type.equalsIgnoreCase("select")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+input.getJSONObject("value").getString("label_fr"));
			}
			else if(type.equalsIgnoreCase("select-multiple")) {
				String sValues="";
				JSONArray values = input.getJSONArray("value");
				for(int n=0;n<values.length();n++) {
					if(sValues.length()>0) {
						sValues+=", ";
					}
					sValues += values.getJSONObject(n).getString("label_fr");
				}
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+sValues);
			}
			else if(type.equalsIgnoreCase("boolean")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"="+(input.getBoolean("value")?SH.getTranNoLink("web", "yes", "fr"):SH.getTranNoLink("web", "no", "fr")));
			}
			else if(type.equalsIgnoreCase("nested-inputs")) {
				inputs.put(key, counter+++"="+input.getString("label_fr")+"=**TITLE**");
				JSONArray values = input.getJSONArray("value");
				for(int n=0;n<values.length();n++) {
					storeInput(inputs,values.getJSONObject(n),key+"_");
				}
			}
		}
		catch(Exception e) {
			SH.syslog("Error storing "+key+" of type "+type);
			e.printStackTrace();
		}
	}

}
