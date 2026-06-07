<%@page import="java.io.*"%>
<%@page import="org.eclipse.paho.client.mqttv3.*,org.eclipse.paho.client.mqttv3.persist.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String broker = "tcp://10.42.0.1:1883";  // e.g. tcp://test.mosquitto.org:1883
	String clientId = "simulator";
	String topic = "esppg";
	String device = "9c139e98da1d,e4b063831295,e4b063831235";
	
	try {
	    MqttClient client = new MqttClient(broker, clientId, new MemoryPersistence());
	    client.connect();
	
	    System.out.println("Connected to broker: " + broker);
	
		BufferedReader[] br = new BufferedReader[device.split(",").length];
		for(int c=0;c<device.split(",").length;c++){
		    br[c] = new BufferedReader(new InputStreamReader(new FileInputStream("/tmp/ppg/simulatordata"), "UTF8"));
		}
		String cLine="";
		while (br[0].ready()) {
			java.util.Date start = new java.util.Date();
			for(int c=0;c<device.split(",").length;c++){
				boolean bQuit=false;
			    while (!bQuit && (cLine = br[c].readLine()) != null) {
			    	bQuit=false;
			    	SH.syslog(device.split(",")[c]+" = "+cLine.split(";")[0].split("\\.")[0]);
			    	if(device.split(",")[c].equalsIgnoreCase(cLine.split(";")[0].split("\\.")[0])){
				    	String messageContent = cLine.split(";")[2].replaceAll("b'","").replaceAll("'","");
				        MqttMessage message = new MqttMessage(messageContent.getBytes());
				        message.setQos(1); 
				        client.publish(topic+"/"+device.split(",")[c]+"/"+cLine.split(";")[0].split("\\.")[1], message);
				        System.out.println("Message sent: " + messageContent);
				        while((cLine = br[c].readLine()) != null){
					    	if(device.split(",")[c].equalsIgnoreCase(cLine.split(";")[0].split("\\.")[0])){
						    	messageContent = cLine.split(";")[2].replaceAll("b'","").replaceAll("'","");
						        message = new MqttMessage(messageContent.getBytes());
						        message.setQos(1); 
						        client.publish(topic+"/"+device.split(",")[c]+"/"+cLine.split(";")[0].split("\\.")[1], message);
						        System.out.println("Message sent: " + messageContent);
						        bQuit=true;
						        break;
					    	}
				        }
			    	}
			    }
			}
	        Thread.sleep(1000-(new java.util.Date().getTime()-start.getTime())); 
		}
	} catch (MqttException | InterruptedException e) {
	    e.printStackTrace();
	}
%>