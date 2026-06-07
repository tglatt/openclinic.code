package be.openclinic.openimis;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Iterator;

import javax.json.JsonArray;
import javax.json.JsonObject;

import be.openclinic.system.SH;

public class FHIRInsurance {
	public JsonObject insurance;
	
	public JsonObject getInsurance() {
		return insurance;
	}

	public void setInsurance(JsonObject insurance) {
		this.insurance = insurance;
	}

	public FHIRInsurance(JsonObject insurance) {
		this.insurance=insurance;
	}
	
	public java.util.Date getBegin(){
		JsonObject period = insurance.getJsonObject("benefitPeriod");
		if(period!=null) {
			try {
				return new SimpleDateFormat("yyyy-MM-dd").parse(period.getString("start"));
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		return null;
	}
	public java.util.Date getEnd(){
		JsonObject period = insurance.getJsonObject("benefitPeriod");
		if(period!=null) {
			try {
				return new SimpleDateFormat("yyyy-MM-dd").parse(period.getString("end"));
			} catch (ParseException e) {
				e.printStackTrace();
			}
		}
		return null;
	}
	
	public String getCategory() {
		JsonArray items = insurance.getJsonArray("item");
		if(items!=null) {
			Iterator i = items.iterator();
			if(i.hasNext()) {
				JsonObject item = (JsonObject)i.next();
				return(SH.c(item.getString("name")));
			}
		}
		return "";
	}
	
	public String getReference() {
		JsonObject coverage = insurance.getJsonObject("coverage");
		if(coverage!=null) {
			return SH.c(coverage.getString("display"));
		}
		return "";
	}

}
