package be.openclinic.datacenter;

import org.dom4j.Element;

import be.openclinic.system.SH;

public class GHBData {
	protected String healthFacilityUid = null;
	protected String subjectType = null;
	protected String subjectId = null;
	protected String dataType = null;
	protected String dataValue = null;
	protected java.util.Date ts = null;
	
	public static GHBData fromElement(Element e) {
		try {
			GHBData ghbData = new GHBData();
			ghbData.setHealthFacilityUid(SH.c(e.attributeValue("healthFacilityId")));
			ghbData.setSubjectType(SH.c(e.attributeValue("subjectType")));
			ghbData.setSubjectId(SH.c(e.attributeValue("subjectId")));
			ghbData.setDataType(SH.c(e.attributeValue("dataType")));
			ghbData.setDataValue(SH.c(e.attributeValue("dataValue")));
			ghbData.setTs(SH.parseDate(SH.c(e.attributeValue("dataValue"),"yyyyMMddHHmmss")));
			return ghbData;
		}
		catch(Exception o) {
			o.printStackTrace();
			return null;
		}
	}
	public String getHealthFacilityUid() {
		return healthFacilityUid;
	}
	public void setHealthFacilityUid(String healthFacilityUid) {
		this.healthFacilityUid = healthFacilityUid;
	}
	public String getSubjectType() {
		return subjectType;
	}
	public void setSubjectType(String subjectType) {
		this.subjectType = subjectType;
	}
	public String getSubjectId() {
		return subjectId;
	}
	public void setSubjectId(String subjectId) {
		this.subjectId = subjectId;
	}
	public String getDataType() {
		return dataType;
	}
	public void setDataType(String dataType) {
		this.dataType = dataType;
	}
	public String getDataValue() {
		return dataValue;
	}
	public void setDataValue(String dataValue) {
		this.dataValue = dataValue;
	}
	public java.util.Date getTs() {
		return ts;
	}
	public void setTs(java.util.Date ts) {
		this.ts = ts;
	}
	
	
}
