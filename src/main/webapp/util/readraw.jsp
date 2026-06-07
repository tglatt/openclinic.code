<%@page import="java.io.*,javax.json.*"%>
<%@include file="/includes/helper.jsp"%>
<%
	Hashtable devices= new Hashtable();
	BufferedReader br = new BufferedReader(new FileReader("/tmp/ppg/ppg.rawdata"));
	String line;
	br.readLine();
	while ((line = br.readLine()) != null) {
	    String[] values = line.split(";");
	    String deviceName = values[0];
	    String timestamp = values[1];
	    String data = values[2].replaceAll("b'", "").replaceAll("'", "");
	    JsonReader jr = Json.createReader(new java.io.StringReader(data));
	    JsonObject jo = jr.readObject();
	    boolean motion = false;
	    try{
	    	motion = jo.getBoolean("motion");
	    }
	    catch(Exception e){}
	    JsonArray red = jo.getJsonArray("red");
	    JsonArray ir = jo.getJsonArray("ir");
	    if(devices.get(deviceName)==null){
	    	devices.put(deviceName,new StringBuffer());
	    }
	    StringBuffer csv = (StringBuffer)devices.get(deviceName);
	    for(int n=0;n<red.size();n++){
	    	csv.append(new Long(timestamp)+n*20+";"+(motion?"1":"0")+";"+red.getInt(n)+";"+ir.getInt(n)+"\n");
	    }
	}
	Iterator iDeviceNames = devices.keySet().iterator();
	while(iDeviceNames.hasNext()){
		String deviceName=(String)iDeviceNames.next();
		StringBuffer csv=(StringBuffer)devices.get(deviceName);
		BufferedWriter bw = new BufferedWriter(new FileWriter("/tmp/ppg/"+deviceName+".csv"));
		bw.write("timestamp;motion;red;ir\n");
		bw.write(csv.toString());
		bw.flush();
		bw.close();
	}


%>