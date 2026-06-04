package be.mxs.common.util.io;

import com.fasterxml.jackson.annotation.JsonProperty;

public class MedHubEmptyMessage {
	
	@JsonProperty("isu")
	private String isu;
	
	@JsonProperty("crd_mut_id")
	private String crd_mut_id;
	
	@JsonProperty("crd_num")
	private String crd_num;
	
	@JsonProperty("sxe")
	private String sxe;
	
	@JsonProperty("sts")
	private String sts;
	
	@Override
	public String toString() {
		return "Student [crd_mut_id=" + isu + 
				", crd_mut_id=" + crd_mut_id + 
				", crd_num=" + crd_num +
				", sxe=" + sxe +
				", sts=" + sts + "]";
	}
	
	
	public String getCrd_mut_id() {
		return isu;
	}
	public void setCrd_mut_id(String crd_mut_id) {
		this.crd_mut_id = crd_mut_id;
	}
	
	
	public String getIsu() {
		return isu;
	}
	public void setIsu(String isu) {
		this.isu = isu;
	}
	
	
	public void setCrd_num(String crd_num) {
		this.crd_num = crd_num;
	}
	
	public String getCrd_num() {
		return crd_num;
	}

	
	public void setSxe(String sxe) {
		this.sxe = sxe;
	}
	
	public String getSxe() {
		return sxe;
	}
	
	public void setSts(String sts) {
		this.sts = sts;
	}
	
	public String getSts() {
		return sts;
	}
}
