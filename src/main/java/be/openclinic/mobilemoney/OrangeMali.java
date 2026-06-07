package be.openclinic.mobilemoney;

import java.io.BufferedReader;
import java.io.StringReader;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.DecimalFormat;
import java.util.ArrayList;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.json.JsonValue;

import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.params.BasicHttpParams;
import org.apache.http.params.HttpParams;
import org.apache.http.util.EntityUtils;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.system.SH;

public class OrangeMali {
	private String token = null;
	private java.util.Date tokenDateTime = null;  
	
	public void setToken(String token) {
		this.token = token;
	}

	public String getToken() {
		if(tokenDateTime==null || tokenDateTime.before(new java.util.Date(new java.util.Date().getTime()-SH.getTimeMinute()*SH.ci("mali.orangemoney.tokenValidityInMinutes",15)))) {
			if(!authorize()) {
				return null;
			}
			else {
				tokenDateTime=new java.util.Date();
			}
		}
		return this.token;		
	}

	public String getToken(String login, String password) {
		if(tokenDateTime==null || tokenDateTime.before(new java.util.Date(new java.util.Date().getTime()-SH.getTimeMinute()*SH.ci("mali.orangemoney.tokenValidityInMinutes",15)))) {
			if(!authorize(login,password)) {
				return null;
			}
			else {
				tokenDateTime=new java.util.Date();
			}
		}
		return this.token;		
	}

	public boolean authorize() {
		return authorize(SH.cs("mali.orangemoney.login", "test"),SH.cs("mali.orangemoney.password", "test"));
	}
	
	public boolean authorize(String login, String password) {
		HttpClient httpclient = HttpClients.createDefault();
		String url=SH.cs("mali.orangemoney.baseurl.login","http://10.172.1.109:8086");
		URIBuilder builder;
		try {
			builder = new URIBuilder(url+"/login");
			URI uri = builder.build();
			HttpPost req = new HttpPost(uri);
		    req.setHeader("Content-Type", "application/json");
		    req.setHeader("Accept", "application/json");
		    String payload="{\"loginOMY\": \""+login+"\", \"passwordOMY\": \""+password+"\"}";
		    StringEntity reqEntity = new StringEntity(payload);
		    req.setEntity(reqEntity);
		    HttpResponse resp = httpclient.execute(req);
		    if (resp.getStatusLine().getStatusCode()==200 ){
			    String sToken = resp.getFirstHeader("Authorization").getValue();
			    if(SH.c(sToken).length()>0) {
			    	setToken(sToken);
				    return true;
			    }
		    }
		} catch (Exception e) {
			e.printStackTrace();
		}
		return false;
	}
	
	public JsonObject requestPayment(String transactionId, String msisdn, int amount, String description, String patientuid, String userid) {
		JsonObject status = null;
		if(SH.ci("mali.orangemoney.useproxy",0)==1) {
			try {
				org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();
				String url=SH.cs("mali.orangemoney.proxyurl.payment","http://10.8.6.69:8080/openclinic")
						+"/financial/mobilemoney/requestPaymentOrangeProxy.jsp";
				PostMethod method = new PostMethod(url);
				org.apache.commons.httpclient.NameValuePair[] nvp = new org.apache.commons.httpclient.NameValuePair[8];
				nvp[0]= new org.apache.commons.httpclient.NameValuePair("login", SH.cs("mali.orangemoney.login", "test"));
				nvp[1]= new org.apache.commons.httpclient.NameValuePair("password", SH.cs("mali.orangemoney.password", "test"));
				nvp[2]= new org.apache.commons.httpclient.NameValuePair("transactionId", transactionId);
				nvp[3]= new org.apache.commons.httpclient.NameValuePair("amount", amount+"");
				nvp[4]= new org.apache.commons.httpclient.NameValuePair("phone", msisdn);
				nvp[5]= new org.apache.commons.httpclient.NameValuePair("patientuid", patientuid);
				nvp[6]= new org.apache.commons.httpclient.NameValuePair("userid", userid);
				nvp[7]= new org.apache.commons.httpclient.NameValuePair("message", description);
				method.setQueryString(nvp);
				int statusCode = client.executeMethod(method);
				BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
				String s = org.apache.commons.io.IOUtils.toString(br);
			    MobileMoney.createPaymentRequest(transactionId, transactionId.split("\\.")[0], patientuid , amount, SH.cs("currency","RWF"), msisdn, description, description, userid, "Orange");
		    	JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    	status = jr.readObject();
		    	jr.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		else {
			HttpClient httpclient = HttpClients.createDefault();
			String url=SH.cs("mali.orangemoney.baseurl.payment","http://10.172.1.109:8088");
			URIBuilder builder;
			try {
				builder = new URIBuilder(url+"/back/askPaymentPush");
				URI uri = builder.build();
				HttpPost req = new HttpPost(uri);
			    req.setHeader("Authorization", getToken());
			    req.setHeader("Content-Type", "application/json");
			    req.setHeader("Accept", "application/json");
			    String payload="{\"transactionId\": \""+transactionId+"\", \"msisdn\": \""+msisdn+"\", \"montant\": \""+amount+"\", \"motif\": \""+SH.c(description)+"\"}";
			    StringEntity reqEntity = new StringEntity(payload);
			    req.setEntity(reqEntity);
			    HttpResponse resp = httpclient.execute(req);
			    HttpEntity entity = resp.getEntity();
		    	JsonReader jr = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
		    	status = jr.readObject();
		    	jr.close();
			    MobileMoney.createPaymentRequest(transactionId, transactionId.split("\\.")[0], patientuid , amount, SH.cs("currency","RWF"), msisdn, description, description, userid, "Orange");
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return status;
	}
	
	public JsonObject requestPayment(String transactionId, String msisdn, int amount, String description, String login, String password, String patientuid, String userid) {
		JsonObject status = null;
		HttpClient httpclient = HttpClients.createDefault();
		String url=SH.cs("mali.orangemoney.baseurl.payment","http://10.172.1.109:8088");
		URIBuilder builder;
		try {
			builder = new URIBuilder(url+"/back/askPaymentPush");
			URI uri = builder.build();
			HttpPost req = new HttpPost(uri);
		    req.setHeader("Authorization", getToken(login,password));
		    req.setHeader("Content-Type", "application/json");
		    req.setHeader("Accept", "application/json");
		    String payload="{\"transactionId\": \""+transactionId+"\", \"msisdn\": \""+msisdn+"\", \"montant\": \""+amount+"\", \"motif\": \""+SH.c(description)+"\"}";
		    StringEntity reqEntity = new StringEntity(payload);
		    req.setEntity(reqEntity);
		    HttpResponse resp = httpclient.execute(req);
		    HttpEntity entity = resp.getEntity();
	    	JsonReader jr = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
	    	status = jr.readObject();
	    	jr.close();
		    MobileMoney.createPaymentRequest(transactionId, transactionId.split("\\.")[0], patientuid , amount, SH.cs("currency","RWF"), msisdn, description, description, userid, "Orange");
		} catch (Exception e) {
			e.printStackTrace();
		}
		return status;
	}
	
	public String getPaymentRequestCode(JsonObject jo) {
		return jo.getString("code");
	}
	
	public String getPaymentRequestError(JsonObject jo) {
		return jo.getString("error");
	}
	
	public String getPaymentRequestMessage(JsonObject jo) {
		return jo.getJsonObject("data").getString("message");
	}
	
	public JsonObject getPaymentStatus(String transactionId) {
		JsonObject status = null;
		if(SH.ci("mali.orangemoney.useproxy",0)==1) {
			try {
				org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();
				String url=SH.cs("mali.orangemoney.proxyurl.payment","http://10.8.6.69:8080/openclinic")
						+"/financial/mobilemoney/getPaymentStatusOrangeProxy.jsp";
				PostMethod method = new PostMethod(url);
				org.apache.commons.httpclient.NameValuePair[] nvp = new org.apache.commons.httpclient.NameValuePair[3];
				nvp[0]= new org.apache.commons.httpclient.NameValuePair("login", SH.cs("mali.orangemoney.login", "test"));
				nvp[1]= new org.apache.commons.httpclient.NameValuePair("password", SH.cs("mali.orangemoney.password", "test"));
				nvp[2]= new org.apache.commons.httpclient.NameValuePair("transactionId", transactionId);
				method.setQueryString(nvp);
				int statusCode = client.executeMethod(method);
				BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
				String s = org.apache.commons.io.IOUtils.toString(br);
		    	JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    	status = jr.readObject();
		    	jr.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
			return status;
		}
		else {
			HttpClient httpclient = HttpClients.createDefault();
			String url=SH.cs("mali.orangemoney.baseurl.payment","http://10.172.1.109:8088");
			URIBuilder builder;
			try {
				builder = new URIBuilder(url+"/back/payment/status/ref/"+transactionId);
				URI uri = builder.build();
				HttpGet req = new HttpGet(uri);
			    req.setHeader("Authorization", getToken());
			    req.setHeader("Content-Type", "application/json");
			    req.setHeader("Accept", "application/json");
			    HttpResponse resp = httpclient.execute(req);
			    HttpEntity entity = resp.getEntity();
		    	JsonReader jr = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
		    	status = jr.readObject();
		    	jr.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
			return status;
		}
	}

	public JsonObject getPaymentStatus(String transactionId, String login, String password) {
		JsonObject status = null;
		HttpClient httpclient = HttpClients.createDefault();
		String url=SH.cs("mali.orangemoney.baseurl.payment","http://10.172.1.109:8088");
		URIBuilder builder;
		try {
			builder = new URIBuilder(url+"/back/payment/status/ref/"+transactionId);
			URI uri = builder.build();
			HttpGet req = new HttpGet(uri);
		    req.setHeader("Authorization", getToken(login, password));
		    req.setHeader("Content-Type", "application/json");
		    req.setHeader("Accept", "application/json");
		    HttpResponse resp = httpclient.execute(req);
		    HttpEntity entity = resp.getEntity();
	    	JsonReader jr = Json.createReader(new java.io.StringReader(EntityUtils.toString(entity)));
	    	status = jr.readObject();
	    	jr.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return status;
	}

	public String getPaymentStatusCode(JsonObject jo) {
		return jo.getString("code");
	}

	public String getPaymentStatusError(JsonObject jo) {
		return jo.getString("error");
	}

	public String getPaymentStatusTransactionId(JsonObject jo) {
		return jo.getJsonObject("data").getString("txn_id");
	}

	public String getPaymentStatusRef(JsonObject jo) {
		return jo.getJsonObject("data").getString("ref");
	}

	public int getPaymentStatusAmount(JsonObject jo) {
		return jo.getJsonObject("data").getInt("montant");
	}

	public String getPaymentStatusState(JsonObject jo) {
		return jo.getJsonObject("data").getString("state");
	}

	public String getPaymentStatusType(JsonObject jo) {
		return jo.getJsonObject("data").getString("type");
	}

	public String getPaymentStatusTxnStatus(JsonObject jo) {
		return jo.getJsonObject("data").getString("txn_status");
	}

}
