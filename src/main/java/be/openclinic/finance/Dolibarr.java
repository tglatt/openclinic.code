package be.openclinic.finance;

import java.io.IOException;

import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.util.EntityUtils;
import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;
import org.json.XML;

import be.openclinic.system.OCHttpClient;
import be.openclinic.system.SH;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;

public class Dolibarr {
	public static String patientInvoiceToJSON(PatientInvoice invoice) {
		return XML.toJSONObject(patientInvoiceToXML(invoice)).toString(4);
	}
	
	public static String patientInvoiceToXML(PatientInvoice invoice) {
		String s = "";
		if(invoice!=null) {
			Document doc = DocumentHelper.createDocument();
			Element root = DocumentHelper.createElement("item");
			doc.setRootElement(root);
			root.addElement("socid").setText(SH.cs("dolibarr_PatientInvoiceGenericAccount", invoice.getPatientUid()));
			root.addElement("ref_client",invoice.getUid());
			s= doc.asXML();
		}
		return s;
	}
	
	public static boolean createOrUpdatePatientInvoice(String uid) {
		PatientInvoice invoice = PatientInvoice.get(uid);
		if(invoice!=null) {
			return createOrUpdatePatientInvoice(invoice);
		}
		else {
			return false;
		}
	}
	
	public static boolean createOrUpdatePatientInvoice(PatientInvoice invoice) {
		boolean bSuccess = false;
		if(existsPatientInvoice(invoice)) {
			bSuccess= updatePatientInvoice(invoice);
		}
		else {
			bSuccess=createPatientInvoice(invoice);
		}
		return bSuccess;
	}
	
	public static boolean existsPatientInvoice(PatientInvoice invoice) {
		return existsPatientInvoice(invoice.getUid());
	}
	
	public static OCHttpClient getDolibarrHttpClient() {
		OCHttpClient dolibarrClient = new OCHttpClient();
		dolibarrClient.addHeader("DOLAPIKEY", SH.cs("dolibarr_APIkey", ""));
		dolibarrClient.addHeader("Accept", "application/xml");
		return dolibarrClient;
	}

	public static boolean existsPatientInvoice(String uid) {
		boolean bSuccess = false;
		OCHttpClient dolibarrClient = getDolibarrHttpClient();
		dolibarrClient.addParam("sqlfilters", "ref_client="+uid);
		String url=SH.cs("dolibarr_APIURL", "")+"invoices";
		try {
			Element root = dolibarrClient.getRootElement(dolibarrClient.get(url));
			if(root!=null && root.elements("item").size()==1) {
				bSuccess=true;
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
		return bSuccess;
	}
	
	public static boolean updatePatientInvoice(PatientInvoice invoice) {
		boolean bSuccess = false;
		return bSuccess;
	}
	
	public static boolean createPatientInvoice(PatientInvoice invoice) {
		boolean bSuccess = false;
		OCHttpClient dolibarrClient = getDolibarrHttpClient();
		dolibarrClient.addBody(patientInvoiceToXML(invoice));
		String url=SH.cs("dolibarr_APIURL", "")+"invoices";
		try {
			dolibarrClient.post(url);
			bSuccess=true;
		} 
		catch (Exception e) {
			e.printStackTrace();
		}
		return bSuccess;
	}
}
