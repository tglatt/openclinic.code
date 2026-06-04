package be.mxs.common.util.io;

import com.fasterxml.jackson.annotation.JsonProperty;

public class MedHubMessageHeader {
	
	@JsonProperty("msg_function")
	private String msg_function;
	
	@JsonProperty("msg_date")
	private String msg_date;
	
	@JsonProperty("msg_snd")
	private String msg_snder;
	
	@JsonProperty("msg_rcv")
	private String msg_rcv;
	
	@JsonProperty("msg_key")
	private String msg_key;
	
	@Override
	public String toString() {
		return "Student [msg_function=" + msg_function + 
				", msg_date=" + msg_date + 
				", msg_rcv=" + msg_rcv +
				", msg_key=" + msg_key +
				", msg_snd=" + msg_snder + "]";
	}
	
	
	public String getMsg_function() {
		return msg_function;
	}
	public void setMsg_function(String msg_function) {
		this.msg_function = msg_function;
	}
	
	
	public void setMsg_date(String msg_date) {
		this.msg_date = msg_date;
	}
	public String getMsg_snd() {
		return msg_snder;
	}
	
	public void setMsg_sd(String msg_sd) {
		this.msg_snder = msg_sd;
	}
	
	
	public void setMsg_rcv(String msg_rcv) {
		this.msg_rcv = msg_rcv;
	}
	public String getMsg_rcv() {
		return msg_rcv;
	}
	public void setMsgkey(String msg_key) {
		this.msg_key = msg_key;
	}
}
