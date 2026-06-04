package be.diagnostix.s5;

public class KenzaServer {
	public String startXMLserver(String pathin) {
		KenzaXMLServer xmlServer = new KenzaXMLServer(pathin);
		xmlServer.start();		
		return "OK";
	}
	public String startCSVserver(String pathin) {
		return "OK";
	}
}