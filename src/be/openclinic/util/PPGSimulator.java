package be.openclinic.util;

import java.io.*;

import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.*;

public class PPGSimulator {

	static String getArg(String[] args, String par, String defaultValue) {
		String s = defaultValue;
		for(int n=0;n<args.length;n++) {
			if(args[n].trim().startsWith(par+"=")) {
				s=args[n].trim().split("=")[1];
			}
		}
		return s;
	}
	
	static boolean hasArg(String[] args, String par) {
		for(int n=0;n<args.length;n++) {
			if(args[n].trim().startsWith(par)) {
				return true;
			}
		}
		return false;
	}
	
	public static void main(String[] args) throws IOException {
		if(hasArg(args, "--help")) {
			System.out.println("Usage: ppgsimulator [options]");
			System.out.println("Options: --broker=mqttserver (default=tcp://10.0.0.1:1883)");
			System.out.println("         --devices=mac-addresses of devices (default=empty = all devices)");
			System.out.println("         --input=input file (default=ppgdata.in)");
		}
		String broker = getArg(args,"--broker","tcp://10.0.0.1:1883");  
		String clientId = "simulator";
		String topic = "esppg";
		String device = getArg(args,"--devices","");
		String inputfile = getArg(args,"--input","ppgdata.in");
		
		try {
		    MqttClient client = new MqttClient(broker, clientId, new MemoryPersistence());
		    client.connect();
		
		    System.out.println("Connected to broker: " + broker);
		    if(device.length()==0) {
				BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(inputfile), "UTF8"));
				String cLine="";
			    while ((cLine = br.readLine()) != null) {
			    	if(!device.contains(cLine.split(";")[0].split("\\.")[0])){
			    		if(device.length()>0) {
			    			device+=",";
			    		}
			    		device+=cLine.split(";")[0].split("\\.")[0];
			    	}
			    }
		    }
			BufferedReader[] br = new BufferedReader[device.split(",").length];
			for(int c=0;c<device.split(",").length;c++){
			    br[c] = new BufferedReader(new InputStreamReader(new FileInputStream(inputfile), "UTF8"));
			}
			String cLine="";
			while (br[0].ready()) {
				java.util.Date start = new java.util.Date();
				for(int c=0;c<device.split(",").length;c++){
					boolean bQuit=false;
				    while (!bQuit && (cLine = br[c].readLine()) != null) {
				    	bQuit=false;
				    	if(device.split(",")[c].equalsIgnoreCase(cLine.split(";")[0].split("\\.")[0])){
					    	String messageContent = cLine.split(";")[2].replaceAll("b'","").replaceAll("'","");
					        MqttMessage message = new MqttMessage(messageContent.getBytes());
					        message.setQos(1); 
					        client.publish(topic+"/"+device.split(",")[c]+"/"+cLine.split(";")[0].split("\\.")[1], message);
					        System.out.println("Message sent from "+device.split(",")[c]+": " + messageContent);
					        while((cLine = br[c].readLine()) != null){
						    	if(device.split(",")[c].equalsIgnoreCase(cLine.split(";")[0].split("\\.")[0])){
							    	messageContent = cLine.split(";")[2].replaceAll("b'","").replaceAll("'","");
							        message = new MqttMessage(messageContent.getBytes());
							        message.setQos(1); 
							        client.publish(topic+"/"+device.split(",")[c]+"/"+cLine.split(";")[0].split("\\.")[1], message);
							        System.out.println("Message sent from "+device.split(",")[c]+": " + messageContent);
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
	}

}
