package be.openclinic.knowledge;

import java.util.Iterator;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONObject;

import be.mxs.common.util.system.HTMLEntities;
import be.openclinic.system.SH;

public class OpenAI {
	protected static JSONObject getSystemMessage() {
		JSONObject message = new JSONObject();
		message.put("role", "system");
		message.put("content", SH.cs("openai-expertise", "You are a tropical medicine expert"));
		return message;
	}
	
	protected static JSONObject getUserMessage(String sQuestion) {
		JSONObject message = new JSONObject();
		message.put("role", "user");
		message.put("content", sQuestion);
		return message;
	}
	
	public static JSONObject getResponse(String sQuestion) {
		JSONObject postRequest = new JSONObject();
		postRequest.put("model", SH.cs("openai-api-model","gpt-5-mini"));
		JSONArray messages = new JSONArray();
		messages.put(getSystemMessage());
		messages.put(getUserMessage(HTMLEntities.htmlentities(sQuestion)));
		postRequest.put("messages",messages);
		HttpClient	client = HttpClients.createDefault();
		HttpPost	req = new HttpPost(SH.cs("openai-url", "https://api.openai.com/v1/chat/completions"));
		req.setHeader("Content-Type", "application/json");  
		req.setHeader("Authorization", "Bearer "+SH.cs("openai-api-key",""));
	   	try {
		   	StringEntity reqEntity = new StringEntity(postRequest.toString());
		   	req.setEntity(reqEntity);
		   	HttpResponse resp = client.execute(req);
			HttpEntity entity = resp.getEntity();
			String s = EntityUtils.toString(entity);
			return new JSONObject(s);
	   	}
	   	catch(Exception e) {
	   		e.printStackTrace();
			JSONObject errorObject = new JSONObject();
			errorObject.put("httperror", HTMLEntities.htmlentities(e.getMessage()));
			return errorObject;
	   	}
	}
	
	public static String getTextResponse(String sQuestion) {
		StringBuffer textResponse = new StringBuffer();
		JSONObject response = getResponse(sQuestion);
		SH.syslog(response.toString());
		JSONArray messages = response.getJSONArray("choices");
		Iterator iMessages = messages.iterator();
		while(iMessages.hasNext()) {
			JSONObject message = ((JSONObject)iMessages.next()).getJSONObject("message");
			textResponse.append(message.getString("content"));
		}
		int tokensUsed=response.getJSONObject("usage").getInt("total_tokens");
		textResponse.append("<br/><br/><i>Cost: "+(tokensUsed*SH.ci("openai-milliontokencost."+SH.cs("openai-api-model","gpt-5-mini"),15000)/1000000)+" "+SH.cs("currency", "EUR"));
		textResponse.append("<br/>Model: OpenClinic-"+response.getString("model")+"</i>");
		return textResponse.toString();
	}
	
	public static String getPlainTextResponse(String sQuestion) {
		StringBuffer textResponse = new StringBuffer();
		JSONObject response = getResponse(sQuestion);
		SH.syslog(response.toString());
		JSONArray messages = response.getJSONArray("choices");
		Iterator iMessages = messages.iterator();
		while(iMessages.hasNext()) {
			JSONObject message = ((JSONObject)iMessages.next()).getJSONObject("message");
			textResponse.append(message.getString("content"));
		}
		return textResponse.toString();
	}
}
