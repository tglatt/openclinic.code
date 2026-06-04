package be.openclinic.openimis;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.Vector;

import javax.json.JsonArray;
import javax.json.JsonObject;
import javax.json.JsonString;

import be.openclinic.finance.Insurance;
import be.openclinic.finance.Insurar;
import be.openclinic.system.SH;

public class FHIRPatient {
	private JsonObject patient;
	
	public FHIRPatient(JsonObject patient) {
		this.patient=patient;
	}
	
	public static String getOpenIMISUIDFromPersonId(String patientid) {
		Vector insurances = Insurance.getCurrentInsurances(patientid);
		for(int n=0;n<insurances.size();n++) {
			Insurance insurance = (Insurance)insurances.elementAt(n);
			if(insurance.getInsurar().isOpenIMISConfigured()) {
				return insurance.getInsuranceNr();
			}
		}
		return null;
	}
	
	public static Insurar getOpenIMISInsurarFromPersonId(String patientid) {
		Vector insurances = Insurance.getCurrentInsurances(patientid);
		for(int n=0;n<insurances.size();n++) {
			Insurance insurance = (Insurance)insurances.elementAt(n);
			if(insurance.getInsurar().isOpenIMISConfigured()) {
				return insurance.getInsurar();
			}
		}
		return null;
	}
	
	public static FHIRPatient get(String patientid, String url, String username, String password) {
		OpenIMIS openIMIS = new OpenIMIS(url,username,password);
		JsonObject jo = openIMIS.getPatient(patientid);
		if(jo!=null) {
			return new FHIRPatient(jo);
		}
		return null;
	}

	public JsonObject getAddress() {
		JsonArray addresses = patient.getJsonArray("address");
		if(addresses.size()>0) {
			Iterator i = addresses.iterator();
			if(i.hasNext()) {
				return (JsonObject)i.next();
			}
		}
		return null;
	}
	
	public JsonObject getName() {
		JsonArray names = patient.getJsonArray("name");
		if(names!=null && names.size()>0) {
			Iterator i = names.iterator();
			if(i.hasNext()) {
				return (JsonObject)i.next();
			}
		}
		return null;
	}
	
	public JsonObject getAddress(String type) {
		JsonArray addresses = patient.getJsonArray("address");
		if(addresses.size()>0) {
			Iterator i = addresses.iterator();
			while(i.hasNext()) {
				JsonObject address = (JsonObject)i.next();
				if(SH.c(address.getString("type")).equalsIgnoreCase(type)) {
					return address;
				}
			}
		}
		return null;
	}
	
	public String getState() {
		JsonObject address = getAddress();
		if(address!=null) {
			return SH.c(address.getString("state"));
		}
		return "";
	}
	
	public String getState(String addressType) {
		JsonObject address = getAddress(addressType);
		if(address!=null) {
			return SH.c(address.getString("state"));
		}
		return "";
	}
	
	public String getCity() {
		JsonObject address = getAddress();
		if(address!=null) {
			return SH.c(address.getString("city"));
		}
		return "";
	}
	
	public String getCity(String addressType) {
		JsonObject address = getAddress(addressType);
		if(address!=null) {
			return SH.c(address.getString("city"));
		}
		return "";
	}
	
	public String getDistrict() {
		JsonObject address = getAddress();
		if(address!=null) {
			return SH.c(address.getString("district"));
		}
		return "";
	}
	public String getDistrict(String addressType) {
		JsonObject address = getAddress(addressType);
		if(address!=null) {
			return SH.c(address.getString("district"));
		}
		return "";
	}
	public String getLocation() {
		JsonObject address = getAddress();
		if(address!=null && address.getJsonArray("extension")!=null) {
			JsonArray elements = address.getJsonArray("extension");
			Iterator i = elements.iterator();
			while(i.hasNext()) {
				JsonObject element = (JsonObject)i.next();
				if(SH.c(element.getString("url")).endsWith("address-location-reference")) {
					if(element.getJsonObject("ValueReference")!=null) {
						JsonObject valueReference = element.getJsonObject("ValueReference");
						if(SH.c(valueReference.getString("type")).equalsIgnoreCase("location")) {
							return SH.c(valueReference.getString("reference"));
						}
					}
				}
			}
		}
		return "";
	}
	public String getLastName() {
		JsonObject name = getName();
		if(name!=null) {
			return SH.c(name.getString("family"));
		}
		return "";
	}
	public String getFirstName() {
		String firstname="";
		JsonObject name = getName();
		if(name!=null) {
			JsonArray givens = name.getJsonArray("given");
			Iterator iGivens = givens.iterator();
			while(iGivens.hasNext()) {
				firstname+=SH.capitalizeFirst(((JsonString)iGivens.next()).toString())+" ";
			}
		}
		return firstname.trim();
	}
	public java.util.Date getDateOfBirth(){
		try {
			return new SimpleDateFormat("yyyy-MM-dd").parse(patient.getString("birthDate"));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return null;
	}
	public String getGender() {
		if(SH.c(patient.getString("gender")).equalsIgnoreCase("male")) {
			return("M");
		}
		else if(SH.c(patient.getString("gender")).equalsIgnoreCase("female")) {
			return("F");
		}
		return "";
	}
	public String getTelephone() {
		JsonArray telecoms = patient.getJsonArray("telecom");
		if(telecoms!=null && telecoms.size()>0) {
			Iterator i = telecoms.iterator();
			while(i.hasNext()) {
				JsonObject telecom = (JsonObject)i.next();
				if(SH.c(telecom.getString("system")).equalsIgnoreCase("phone")) {
					return SH.c(telecom.getString("value"));
				}
			}
		}
		return "";
	}
	public String getEmail() {
		JsonArray telecoms = patient.getJsonArray("telecom");
		if(telecoms!=null && telecoms.size()>0) {
			Iterator i = telecoms.iterator();
			while(i.hasNext()) {
				JsonObject telecom = (JsonObject)i.next();
				if(SH.c(telecom.getString("system")).equalsIgnoreCase("email")) {
					return SH.c(telecom.getString("value"));
				}
			}
		}
		return "";
	}
	public boolean isHead() {
		JsonArray extensions = patient.getJsonArray("extension");
		if(extensions!=null && extensions.size()>0){
			Iterator i = extensions.iterator();
			while(i.hasNext()) {
				JsonObject extension = (JsonObject)i.next();
				if(SH.c(extension.getString("url")).contains("patient-is-head")) {
					return extension.getBoolean("valueBoolean");
				}
			}
		}
		return false;
	}
	public boolean isCardIssued() {
		JsonArray extensions = patient.getJsonArray("extension");
		if(extensions!=null && extensions.size()>0){
			Iterator i = extensions.iterator();
			while(i.hasNext()) {
				JsonObject extension = (JsonObject)i.next();
				if(SH.c(extension.getString("url")).contains("patient-card-issued")) {
					return extension.getBoolean("valueBoolean");
				}
			}
		}
		return false;
	}
	public String getReference() {
		JsonArray identifiers = patient.getJsonArray("identifier");
		if(identifiers!=null) {
			Iterator i = identifiers.iterator();
			while(i.hasNext()) {
				JsonObject identifier = (JsonObject)i.next();
				JsonObject type = identifier.getJsonObject("type");
				if(type!=null) {
					JsonArray coding = type.getJsonArray("coding");
					if(coding!=null) {
						Iterator j = coding.iterator();
						while(j.hasNext()) {
							JsonObject code = (JsonObject)j.next();
							if(code.getString("code").equalsIgnoreCase("UUID")) {
								return "Patient/"+identifier.getString("value");
							}
						}
					}
				}
			}
		}
		return "";
	}
}
