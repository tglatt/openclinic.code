package be.mxs.common.util.io;

import java.io.BufferedReader;
import java.io.StringReader;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;
import org.dom4j.io.SAXReader;
import org.json.JSONObject;
import org.json.XML;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.system.SH;
import net.sf.json.JSON;
import net.sf.json.JSONSerializer;
import net.sf.json.xml.XMLSerializer;

public class GoogleTranslate {
	
	public static String translate(String key,String sourceLanguage,String targetLanguage, String text){
		if(SH.c(sourceLanguage).length()==0 || SH.c(targetLanguage).length()==0 || sourceLanguage.equalsIgnoreCase(targetLanguage)) {
			return text;
		}
		String message="";
		try{
			HttpClient client = new HttpClient();
			PostMethod method = new PostMethod(MedwanQuery.getInstance().getConfigString("googleTranslateURL","https://translation.googleapis.com/language/translate/v2"));
			NameValuePair[] nvp = new NameValuePair[4];
			nvp[0]= new NameValuePair("key",key);
			nvp[1]= new NameValuePair("target",targetLanguage);
			nvp[2]= new NameValuePair("source",sourceLanguage);
			nvp[3]= new NameValuePair("q",text);
			method.setQueryString(nvp);
			int statusCode = client.executeMethod(method);
			BufferedReader br = new BufferedReader(new StringReader(method.getResponseBodyAsString()));
			message = org.apache.commons.io.IOUtils.toString(br);
			JSONObject json = new JSONObject(message);
			String xml = XML.toString(json);  
			SAXReader reader=new SAXReader(false);
			org.dom4j.Document document=reader.read(new StringReader(xml));
			return document.getRootElement().element("translations").element("translatedText").getText();
		}
		catch(Exception e){
			e.printStackTrace();
			SH.syslog(message);
			return text;
		}
	}
}
