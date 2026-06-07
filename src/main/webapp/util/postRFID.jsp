<%@page import="be.openclinic.system.Beacon"%>
<%@page import="javax.json.*"%>
<%@page import="java.io.BufferedReader"%>
<%@include file="/includes/helper.jsp"%>
<%
	SH.syslog("Receiving post from "+request.getRemoteAddr());
	SortedMap<String,JsonObject> beacons = new TreeMap<String,JsonObject>();
	BufferedReader br = request.getReader();
    JsonReader jr = Json.createReader(new java.io.StringReader(request.getReader().readLine()));
	JsonObject jo = jr.readObject();
	String header = SH.c(request.getHeader("station"));
	int numberOfBeacons=Beacon.storeRecordings(jo,header);
	if(header.split(":").length>2 && header.split(":")[2].equalsIgnoreCase("1")){
		System.out.println(SH.formatDate(new java.util.Date(),"dd/MM/yyyy HH:mm:ss")+" - "+header.split(":")[0]+" ["+header.split(":")[1]+"] = "+numberOfBeacons+" beacons");
	}
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("delete from oc_beacon_recordings where (oc_beacon_resourcetype='' or oc_beacon_resourcetype is null) and oc_beacon_updatetime<?");
	ps.setTimestamp(1, SH.getSQLTimestamp(new java.util.Date(new java.util.Date().getTime()-SH.ci("removeUnidentifiedBLEBeaconsAfterMinutes",5)*SH.getTimeMinute())));
	ps.execute();
	ps.close();
	conn.close();
%>
