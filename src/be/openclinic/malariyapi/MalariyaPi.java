package be.openclinic.malariyapi;

import java.io.File;
import java.nio.file.Files;
import java.util.Base64;
import java.util.HashMap;
import java.util.Vector;

import javax.json.Json;
import javax.json.JsonBuilderFactory;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.json.JsonReader;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;

import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Pointer;
import be.openclinic.archiving.ScannableFileFilter;
import be.openclinic.reporting.MessageNotifier;
import be.openclinic.system.SH;

public class MalariyaPi implements Runnable{
	String server = null;
	Thread thread =null;
	boolean stop = false;
	
	public boolean isStop() {
		return stop;
	}

	public void setStop(boolean stop) {
		this.stop = stop;
	}

	public MalariyaPi(String server) {
		this.server=server;
	}
	
	@Override
	public void run() {
		while(true & !stop) {
			try {
				Vector pointers = Pointer.getPointers("malariyapi");
				for(int n=0;n<pointers.size();n++) {
					String sEncounterUid = (String)pointers.elementAt(n);
					//Get the result from the server and store it in the message spooler
					JsonObject joMalariyaPiResult = getResult(sEncounterUid);
					MessageNotifier.SpoolMessage("none", joMalariyaPiResult.toString(), joMalariyaPiResult.getString("serverid"), "malariyapi", "en");
					Pointer.deletePointers("malariyapi",sEncounterUid);
				}
				Thread.sleep(SH.cl("malariyapi.scaninterval", 10000));
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	public void start() {
		thread = new Thread(this);
		thread.start();
	}
	
	private JsonObject getResult(String sEncounterUid) {
		//TODO: this function will get the content from the HealthPulse Pull API
		//For now this is a dummy function
		JsonBuilderFactory factory = Json.createBuilderFactory(new HashMap<>());
		JsonObjectBuilder message = factory.createObjectBuilder();
		message.add("serverid", sEncounterUid.split("\\.")[0]);
		message.add("encounteruid", sEncounterUid.split("\\.")[1]+"."+sEncounterUid.split("\\.")[2]);
		message.add("userdecision", "positive");
		message.add("auderedecision", "positive");
		try {
			File file = new File("/tmp/testimage.png");
			byte[] imageBytes = Files.readAllBytes(file.toPath());
			String base64Image = Base64.getEncoder().encodeToString(imageBytes);
			message.add("testimage",base64Image );
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		try {
			File file = new File("/tmp/detailimage.png");
			byte[] imageBytes = Files.readAllBytes(file.toPath());
			String base64Image = Base64.getEncoder().encodeToString(imageBytes);
			message.add("detailimage",base64Image );
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return message.build();
	}
}
