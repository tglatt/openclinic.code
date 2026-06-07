package be.openclinic.mobilemoney;

import java.io.BufferedReader;
import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.net.URI;
import java.util.Base64;

import javax.json.*;

import org.apache.commons.httpclient.methods.PostMethod;
import org.apache.http.*;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.utils.URIBuilder;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import be.openclinic.dhis2.Util;
import be.openclinic.system.SH;

public class Malitel {

	public static String getBasicAuthentication() {
		try {
			return "Basic "+Base64.getEncoder().encodeToString((SH.cs("mali.malitel.login", "test")+":"+SH.cs("mali.malitel.password", "test")).getBytes("utf-8" ));
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return "";
		}
	}
	
	public static String getBasicAuthentication(String sLogin, String sPassword) {
		try {
			return "Basic "+Base64.getEncoder().encodeToString((sLogin+":"+sPassword).getBytes("utf-8" ));
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
			return "";
		}
	}
	
	public static void importCertificate() {
    	try {
			Util.importCertificate(SH.cs("mali.malitel.baseurl.host","localhost"), SH.ci("mali.malitel.baseurl.port",11280), SH.cs("java.keystore","C:/Program Files/Java/jre1.8.0_241/lib/security/cacerts"), SH.cs("java.keystore.pass","changeit"));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	public static JsonObject getSubscriberInfo(String msisdn, String requestId, String login, String password) {
		JsonObject info=null;
		HttpClient httpclient = HttpClients.createDefault();
		String url="https://"+SH.cs("mali.malitel.baseurl.host","localhost")+":"+SH.cs("mali.malitel.baseurl.port","11280");
		URIBuilder builder;
		try {
			builder = new URIBuilder(url+SH.cs("mali.malitel.context","/sit/gateway/3pp/transaction/process"));
			URI uri = builder.build();
			HttpPost req = new HttpPost(uri);
		    req.setHeader("Authorization", getBasicAuthentication(login,password));
		    req.setHeader("Content-Type", "application/json");
		    req.setHeader("Accept", "application/json");
		    req.setHeader("command-id", "process-check-subscriber");
		    String payload="{\"destination\": \""+msisdn+"\", \"request-id\": \""+requestId+"\"}";
		    StringEntity reqEntity = new StringEntity(payload);
		    req.setEntity(reqEntity);
		    HttpResponse resp = httpclient.execute(req);
		    HttpEntity entity = resp.getEntity();
	    	String sResponse = EntityUtils.toString(entity);
	    	SH.syslog(sResponse);
		    JsonReader jr = Json.createReader(new java.io.StringReader(sResponse));
	    	info = jr.readObject();
	    	jr.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return info;
	}
	
	public static JsonObject getSubscriberInfo(String msisdn, String requestId) {
		JsonObject info=null;
		if(SH.ci("mali.malitel.useproxy",0)==1) {
			try {
				org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();
				String url=SH.cs("mali.malitel.proxyurl","http://10.8.6.69:8080/openclinic")
						+"/financial/mobilemoney/getSubscriberInfoMalitelProxy.jsp";
				SH.syslog("url="+url);
				PostMethod method = new PostMethod(url);
				org.apache.commons.httpclient.NameValuePair[] nvp = new org.apache.commons.httpclient.NameValuePair[4];
				nvp[0]= new org.apache.commons.httpclient.NameValuePair("login", SH.cs("mali.malitel.login", "test"));
				nvp[1]= new org.apache.commons.httpclient.NameValuePair("password", SH.cs("mali.malitel.password", "test"));
				nvp[2]= new org.apache.commons.httpclient.NameValuePair("requestId", requestId);
				nvp[3]= new org.apache.commons.httpclient.NameValuePair("msisdn", msisdn);
				method.setQueryString(nvp);
				int statusCode = client.executeMethod(method);
				BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
				String s = org.apache.commons.io.IOUtils.toString(br);
		    	JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    	info = jr.readObject();
		    	jr.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
			return info;
		}
		else {
			HttpClient httpclient = HttpClients.createDefault();
			String url="https://"+SH.cs("mali.malitel.baseurl.host","localhost")+":"+SH.cs("mali.malitel.baseurl.port","11280");
			URIBuilder builder;
			try {
				builder = new URIBuilder(url+SH.cs("mali.malitel.context","/sit/gateway/3pp/transaction/process"));
				URI uri = builder.build();
				HttpPost req = new HttpPost(uri);
			    req.setHeader("Authorization", getBasicAuthentication());
			    req.setHeader("Content-Type", "application/json");
			    req.setHeader("Accept", "application/json");
			    req.setHeader("command-id", "process-check-subscriber");
			    String payload="{\"destination\": \""+msisdn+"\", \"request-id\": \""+requestId+"\"}";
			    StringEntity reqEntity = new StringEntity(payload);
			    req.setEntity(reqEntity);
			    HttpResponse resp = httpclient.execute(req);
			    HttpEntity entity = resp.getEntity();
		    	String sResponse = EntityUtils.toString(entity);
		    	SH.syslog("Response: "+sResponse);
			    JsonReader jr = Json.createReader(new java.io.StringReader(sResponse));
		    	info = jr.readObject();
		    	jr.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return info;
	}

	public static JsonObject requestPayment(String transactionId, String msisdn, int amount, String message, String patientuid,String userid, String sLogin, String sPassword) {
		JsonObject status=null;
		HttpClient httpclient = HttpClients.createDefault();
		String url="https://"+SH.cs("mali.malitel.baseurl.host","localhost")+":"+SH.cs("mali.malitel.baseurl.port","11280");
		URIBuilder builder;
		try {
			builder = new URIBuilder(url+SH.cs("mali.malitel.context","/sit/gateway/3pp/transaction/process"));
			URI uri = builder.build();
			HttpPost req = new HttpPost(uri);
		    req.setHeader("Authorization", getBasicAuthentication(sLogin,sPassword));
		    req.setHeader("Content-Type", "application/json");
		    req.setHeader("Accept", "application/json");
		    req.setHeader("command-id", "mror-transaction-ussd");
		    String payload="{\"request-id\": \""+transactionId+"\",\"destination\": \""+msisdn+"\",\"message\": \""+message+"\",\"amount\": "+amount+",\"remarks\": \""+patientuid+"\",\"extended-data\": {}}";
		    StringEntity reqEntity = new StringEntity(payload);
		    req.setEntity(reqEntity);
		    HttpResponse resp = httpclient.execute(req);
		    HttpEntity entity = resp.getEntity();
	    	String sResponse = EntityUtils.toString(entity);
		    MobileMoney.createPaymentRequest(transactionId, transactionId.split("\\.")[0], patientuid , amount, SH.cs("currency","RWF"), msisdn, message, message, userid, "Moov");
	    	SH.syslog("Response: "+sResponse);
		    JsonReader jr = Json.createReader(new java.io.StringReader(sResponse));
	    	status = jr.readObject();
	    	jr.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return status;
	}
	
	public static JsonObject requestPayment(String transactionId, String msisdn, int amount, String message, String patientuid, String userid) {
		JsonObject status=null;
		if(SH.ci("mali.malitel.useproxy",0)==1) {
			try {
				org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();
				String url=SH.cs("mali.malitel.proxyurl","http://10.8.6.69:8080/openclinic")
						+"/financial/mobilemoney/requestPaymentMalitelProxy.jsp";
				PostMethod method = new PostMethod(url);
				org.apache.commons.httpclient.NameValuePair[] nvp = new org.apache.commons.httpclient.NameValuePair[8];
				nvp[0]= new org.apache.commons.httpclient.NameValuePair("login", SH.cs("mali.malitel.login", "test"));
				nvp[1]= new org.apache.commons.httpclient.NameValuePair("password", SH.cs("mali.malitel.password", "test"));
				nvp[2]= new org.apache.commons.httpclient.NameValuePair("transactionId", transactionId);
				nvp[3]= new org.apache.commons.httpclient.NameValuePair("msisdn", msisdn);
				nvp[4]= new org.apache.commons.httpclient.NameValuePair("amount", amount+"");
				nvp[5]= new org.apache.commons.httpclient.NameValuePair("message", message);
				nvp[6]= new org.apache.commons.httpclient.NameValuePair("patientuid", patientuid);
				nvp[7]= new org.apache.commons.httpclient.NameValuePair("userid", userid);
				method.setQueryString(nvp);
				int statusCode = client.executeMethod(method);
				BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
			    MobileMoney.createPaymentRequest(transactionId, transactionId.split("\\.")[0], patientuid , amount, SH.cs("currency","RWF"), msisdn, message, message, userid, "Moov");
				String s = org.apache.commons.io.IOUtils.toString(br);
		    	JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    	status = jr.readObject();
		    	jr.close();
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}
		else {
			HttpClient httpclient = HttpClients.createDefault();
			String url="https://"+SH.cs("mali.malitel.baseurl.host","localhost")+":"+SH.cs("mali.malitel.baseurl.port","11280");
			URIBuilder builder;
			try {
				builder = new URIBuilder(url+SH.cs("mali.malitel.context","/sit/gateway/3pp/transaction/process"));
				URI uri = builder.build();
				HttpPost req = new HttpPost(uri);
			    req.setHeader("Authorization", getBasicAuthentication());
			    req.setHeader("Content-Type", "application/json");
			    req.setHeader("Accept", "application/json");
			    req.setHeader("command-id", "mror-transaction-ussd");
			    String payload="{\"request-id\": \""+transactionId+"\",\"destination\": \""+msisdn+"\",\"message\": \""+message+"\",\"amount\": \""+amount+"\",\"remarks\": \""+patientuid+"\",\"extended-data\": {}";
			    StringEntity reqEntity = new StringEntity(payload);
			    req.setEntity(reqEntity);
			    HttpResponse resp = httpclient.execute(req);
			    HttpEntity entity = resp.getEntity();
		    	String sResponse = EntityUtils.toString(entity);
			    MobileMoney.createPaymentRequest(transactionId, transactionId.split("\\.")[0], patientuid , amount, SH.cs("currency","RWF"), msisdn, message, message, userid, "Moov");
			    JsonReader jr = Json.createReader(new java.io.StringReader(sResponse));
		    	status = jr.readObject();
		    	jr.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return status;
	}

	public static JsonObject getPaymentStatus(String requestId,String sLogin, String sPassword) {
		JsonObject status=null;
		HttpClient httpclient = HttpClients.createDefault();
		String url="https://"+SH.cs("mali.malitel.baseurl.host","localhost")+":"+SH.cs("mali.malitel.baseurl.port","11280");
		URIBuilder builder;
		try {
			builder = new URIBuilder(url+SH.cs("mali.malitel.context","/sit/gateway/3pp/transaction/process"));
			URI uri = builder.build();
			HttpPost req = new HttpPost(uri);
		    req.setHeader("Authorization", getBasicAuthentication(sLogin,sPassword));
		    req.setHeader("Content-Type", "application/json");
		    req.setHeader("Accept", "application/json");
		    req.setHeader("command-id", "process-check-transaction");
		    String payload="{\"request-id\": \""+requestId+"\"}";
		    StringEntity reqEntity = new StringEntity(payload);
		    req.setEntity(reqEntity);
		    HttpResponse resp = httpclient.execute(req);
		    HttpEntity entity = resp.getEntity();
	    	String sResponse = EntityUtils.toString(entity);
	    	SH.syslog(sResponse);
		    JsonReader jr = Json.createReader(new java.io.StringReader(sResponse));
	    	status = jr.readObject();
	    	jr.close();
		} catch (Exception e) {
			e.printStackTrace();
		}
		return status;
	}
	
	public static JsonObject getPaymentStatus(String requestId) {
		JsonObject status=null;
		if(SH.ci("mali.malitel.useproxy",0)==1) {
			try {
				org.apache.commons.httpclient.HttpClient client = new org.apache.commons.httpclient.HttpClient();
				String url=SH.cs("mali.malitel.proxyurl","http://10.8.6.69:8080/openclinic")
						+"/financial/mobilemoney/getPaymentStatusMalitelProxy.jsp";
				PostMethod method = new PostMethod(url);
				org.apache.commons.httpclient.NameValuePair[] nvp = new org.apache.commons.httpclient.NameValuePair[3];
				nvp[0]= new org.apache.commons.httpclient.NameValuePair("login", SH.cs("mali.malitel.login", "test"));
				nvp[1]= new org.apache.commons.httpclient.NameValuePair("password", SH.cs("mali.malitel.password", "test"));
				nvp[2]= new org.apache.commons.httpclient.NameValuePair("requestId", requestId);
				method.setQueryString(nvp);
				int statusCode = client.executeMethod(method);
				BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
				String s = org.apache.commons.io.IOUtils.toString(br);
		    	JsonReader jr = Json.createReader(new java.io.StringReader(s));
		    	status = jr.readObject();
		    	jr.close();
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}
		else {
			HttpClient httpclient = HttpClients.createDefault();
			String url="https://"+SH.cs("mali.malitel.baseurl.host","localhost")+":"+SH.cs("mali.malitel.baseurl.port","11280");
			URIBuilder builder;
			try {
				builder = new URIBuilder(url+SH.cs("mali.malitel.context","/sit/gateway/3pp/transaction/process"));
				URI uri = builder.build();
				HttpPost req = new HttpPost(uri);
			    req.setHeader("Authorization", getBasicAuthentication());
			    req.setHeader("Content-Type", "application/json");
			    req.setHeader("Accept", "application/json");
			    req.setHeader("command-id", "process-check-transaction");
			    String payload="{\"request-id\": \""+requestId+"\"}";
			    StringEntity reqEntity = new StringEntity(payload);
			    req.setEntity(reqEntity);
			    HttpResponse resp = httpclient.execute(req);
			    HttpEntity entity = resp.getEntity();
		    	String sResponse = EntityUtils.toString(entity);
		    	SH.syslog("Response: "+sResponse);
			    JsonReader jr = Json.createReader(new java.io.StringReader(sResponse));
		    	status = jr.readObject();
		    	jr.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return status;
	}
}
