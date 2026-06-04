package be.openclinic.malariyapi;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Vector;

import javax.json.Json;
import javax.json.JsonArray;
import javax.json.JsonBuilderFactory;
import javax.json.JsonObject;
import javax.json.JsonObjectBuilder;
import javax.json.JsonReader;

import org.apache.commons.lang3.StringUtils;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.protocol.HTTP;
import org.apache.http.util.EntityUtils;
import org.dcm4che2.data.Tag;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryGeneral;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Pointer;
import be.openclinic.adt.Encounter;
import be.openclinic.archiving.ArchiveDocument;
import be.openclinic.archiving.ScanDirectoryMonitor;
import be.openclinic.archiving.ScannableFileFilter;
import be.openclinic.reporting.MessageNotifier;
import be.openclinic.system.SH;

public class MalariyaPiClient implements Runnable{
	String server = null;
	Thread thread =null;
	boolean stop = false;
	
	public boolean isStop() {
		return stop;
	}

	public void setStop(boolean stop) {
		this.stop = stop;
	}

	public MalariyaPiClient(String server) {
		this.server=server;
	}
	
	@Override
	public void run() {
		while(true & !stop) {
			if(SH.ci("enableMalariyaPi", 0)==1 && SH.cs("malariyapi.server.url", "").length()>0) {
				try {
					HttpClient client = HttpClients.createDefault();
					HttpPost req = new HttpPost(SH.cs("malariyapi.server.url", ""));
					String aut = Base64.getEncoder().encodeToString((SH.cs("malariyapi.server.login","4")+":"+SH.cs("malariyapi.server.password","")).getBytes("utf-8"));
					req.setHeader("Authorization", "Basic "+aut);
				   	//req.setHeader("Content-Type", "application/json");
				   	List<NameValuePair> nvps = new ArrayList<>();
				   	nvps.add(new BasicNameValuePair("serverid",SH.cs("malariyapi.serverid","0")));
				   	req.setEntity(new UrlEncodedFormEntity(nvps, "UTF-8"));
				   	HttpResponse resp = client.execute(req);
				   	HttpEntity entity = resp.getEntity();
				   	String s = EntityUtils.toString(entity);
				    JsonReader jr = Json.createReader(new java.io.StringReader(s));
				    JsonObject jo = jr.readObject();
				    JsonArray messages = jo.getJsonArray("messages");
				    for(int n=0;n<messages.size();n++) {
				    	JsonObject message = messages.getJsonObject(n);
				    	String serverid = message.getString("serverid");
				    	String encounteruid = message.getString("encounteruid");
				    	String userdecision = message.getString("userdecision");
				    	String auderedecision = message.getString("auderedecision");
				    	String testimage="";
				    	if(!message.isNull("testimage")) testimage = message.getString("testimage");
				    	String detailimage="";
				    	if(!message.isNull("detailimage")) detailimage = message.getString("detailimage");
				    	Encounter encounter = Encounter.get(encounteruid);
				    	if(encounter!=null) {
			    			//Create new transaction
					    	TransactionVO transaction = new TransactionFactoryGeneral().createTransactionVO(MedwanQuery.getInstance().getUser(MedwanQuery.getInstance().getConfigString("defaultMalariyaPiuser","4")),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MALARIYAPI",false); 
			    			transaction.setCreationDate(new java.util.Date());
			    			transaction.setStatus(1);
			    			transaction.setTransactionId(MedwanQuery.getInstance().getOpenclinicCounter("TransactionID"));
			    			transaction.setServerId(MedwanQuery.getInstance().getConfigInt("serverId",1));
			    			transaction.setTransactionType("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MALARIYAPI");
		    				transaction.setUpdateTime(new java.util.Date());
			    			UserVO user = MedwanQuery.getInstance().getUser(MedwanQuery.getInstance().getConfigString("defaultMalariyaPiuser","4"));
			    			if(user==null){
			    				user = MedwanQuery.getInstance().getUser("4");
			    			}
			    			transaction.setUser(user);
			    			transaction.setVersion(1);
			    			transaction.setItems(new Vector());
			    			ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			    			transaction.getItems().add(new ItemVO(Integer.parseInt( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
			    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID",encounteruid,new Date(),itemContextVO));
			    			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			    			transaction.getItems().add(new ItemVO(Integer.parseInt( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
			    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_USERDECISION",userdecision,new Date(),itemContextVO));
			    			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			    			transaction.getItems().add(new ItemVO(Integer.parseInt( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
			    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUDEREDECISION",auderedecision,new Date(),itemContextVO));
		    				//Now store the documents...
				    		String filename=ArchiveDocument.generateUDI(MedwanQuery.getInstance().getOpenclinicCounter("ARCH_DOCUMENTS"));
				        	String sPathAndName = ScanDirectoryMonitor.getFilePathAndName(filename,"png");
				    		String SCANDIR_BASE = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_basePath","/var/tomcat/webapps/openclinic/scan");
				    	    String SCANDIR_TO   = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo","to");
							writeBase64ToImage(testimage,SCANDIR_BASE+"/"+SCANDIR_TO+"/"+sPathAndName);
			    			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			    			transaction.getItems().add(new ItemVO(Integer.parseInt( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
			    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TESTIMAGE",sPathAndName,new Date(),itemContextVO));
				    		filename=ArchiveDocument.generateUDI(MedwanQuery.getInstance().getOpenclinicCounter("ARCH_DOCUMENTS"));
				        	sPathAndName = ScanDirectoryMonitor.getFilePathAndName(filename,"png");
							writeBase64ToImage(detailimage,SCANDIR_BASE+"/"+SCANDIR_TO+"/"+sPathAndName);
			    			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			    			transaction.getItems().add(new ItemVO(Integer.parseInt( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
			    					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DETAILIMAGE",sPathAndName,new Date(),itemContextVO));
			    			MedwanQuery.getInstance().updateTransaction(Integer.parseInt(encounter.getPatientUID()),transaction);
				    	}
				    }
					Thread.sleep(SH.cl("malariyapi.scaninterval", 10000));
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}
	
	public void start() {
		thread = new Thread(this);
		thread.start();
	}
	
    public static void writeBase64ToImage(String base64Image, String outputFile)
            throws IOException {
        if (base64Image.contains(",")) {
            base64Image = base64Image.split(",")[1];
        }
        byte[] imageBytes = Base64.getDecoder().decode(base64Image);
        try (FileOutputStream fos = new FileOutputStream(outputFile)) {
            fos.write(imageBytes);
        }
    }

}
