package be.openclinic.openimis;

import java.util.Iterator;
import java.util.Vector;

import javax.json.JsonArray;
import javax.json.JsonObject;

import be.openclinic.system.SH;

public class FHIRCoverage {
	private JsonObject coverage;
	
	public JsonObject getCoverage() {
		return coverage;
	}

	public void setCoverage(JsonObject coverage) {
		this.coverage = coverage;
	}

	public FHIRCoverage(JsonObject coverage) {
		this.coverage=coverage;
	}
	
	public static FHIRCoverage get(String patientid, String url, String username, String password) {
		OpenIMIS openIMIS = new OpenIMIS(url,username,password);
		JsonObject jo = openIMIS.getCoverage(patientid);
		if(jo!=null) {
			return new FHIRCoverage(jo);
		}
		return null;
	}
	
	public String getStatus() {
		return SH.c(coverage.getString("status"));
	}
	
	public String getInsurer() {
		JsonObject insurer = coverage.getJsonObject("insurer");
		if(insurer!=null) {
			return SH.c(insurer.getString("reference"));
		}
		return "";
	}
	
	public JsonArray getInsurance() {
		return coverage.getJsonArray("insurance");
	}
	
	public Vector<FHIRInsurance> getInsurances() {
		Vector insurances = new Vector();
		if(getInsurance()!=null) {
			Iterator i = getInsurance().iterator();
			while(i.hasNext()) {
				insurances.add(new FHIRInsurance((JsonObject)i.next()));
			}
		}
		return insurances;
	}
	
}
