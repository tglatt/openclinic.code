package be.diagnostix.s5;

import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;

import org.apache.log4j.BasicConfigurator;

import be.openclinic.hl7.HL7Server;
import be.openclinic.system.SH;
import uk.org.primrose.GeneralException;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class S5Server {
	public static void main(String[] args) throws InterruptedException, IOException, SQLException, ClassNotFoundException, GeneralException {
		BasicConfigurator.configure();
		PrimroseLoader.load(args[0],true);
		showStartBanner();
		boolean bSuccess=startHL7Server();
		bSuccess=bSuccess && startXMLServer();
		bSuccess=bSuccess && startCSVServer();
		showEndBanner(bSuccess);
	}
	
	public static void showStartBanner() {
		SH.syslog("***********************************************************");
		SH.syslog("* Diagnostix S5 middleware v0.3                           *");
		SH.syslog("* (c)"+SH.formatDate(new java.util.Date(),"yyyy")+" Diagnostix BV, Belgium                          *");
		SH.syslog("* E-mail: diagnostix@ict4d.be                             *");
		SH.syslog("***********************************************************");
		SH.syslog("");
		SH.syslog("Starting S5 middleware servers...");
	}
	
	public static void showEndBanner(boolean bSuccess) {
		SH.syslog(    "***********************************************************");
		if(bSuccess) {
			SH.syslog("* All S5 middleware servers successfully started          *");
			SH.syslog("***********************************************************");
		}
		else {
			SH.syslog("* S5 middleware servers started with errors               *");
			SH.syslog("***********************************************************");
		}
	}
	
	public static boolean startHL7Server() throws InterruptedException {
		boolean bSuccess=true;
	    if(SH.ci("s5.hl7.enabled", 0)==1) {
			HL7Server hl7server = new HL7Server();
			int port = 4001;
			try{
				port=SH.ci("s5.hl7.serverPort",4001);
			}
			catch(Exception e) {
				e.printStackTrace();
			}
			SH.syslog("***********************************************************");
			System.out.print(new SimpleDateFormat("mm:ss:SSS").format(new java.util.Date())+" ||SYSLOG|| "+"* Starting S5 HL7 server on port "+port+"... ");
			String sResult=hl7server.start(port);
			System.out.println(sResult);
			bSuccess = bSuccess && sResult.equalsIgnoreCase("OK");
			SH.syslog("***********************************************************");
			SH.syslog(" - HL7 version 2.5.1");
			SH.syslog(" - Supported messages: OML-O21, ORU-R01, OUL-R22");
			SH.syslog(" - Authored by Frank Verbeke, frank@ict4d.be");
			SH.syslog("");
	    }
	    return bSuccess;
	}
	
	public static boolean startXMLServer() {
		boolean bSuccess=true;
		if(SH.ci("s5.xml.kenza.enabled", 0)==1) {
			KenzaServer kenzaServer = new KenzaServer();
			String inpath = SH.cs("s5.xml.kenza.inpath", "/tmp");
			SH.syslog("***********************************************************");
			System.out.print(new SimpleDateFormat("mm:ss:SSS").format(new java.util.Date())+" ||SYSLOG|| "+"Starting S5 Kenza XML server on incoming path "+inpath+"... ");
			String sResult=kenzaServer.startXMLserver(inpath);
			System.out.println(sResult);
			bSuccess = bSuccess && sResult.equalsIgnoreCase("OK");
			SH.syslog("***********************************************************");
			SH.syslog(" - Kenza XML SUP/MAN/0011 - Version 0 - 26/09/2023");
			SH.syslog(" - Authored by Frank Verbeke, frank@ict4d.be");
			SH.syslog("");
		}
		return bSuccess;
	}
	
	public static boolean startCSVServer() {
		boolean bSuccess=true;
		if(SH.ci("s5.csv.kenza.enabled", 0)==1) {
			KenzaServer kenzaServer = new KenzaServer();
			String inpath = SH.cs("s5.csv.kenza.inpath", "");
			SH.syslog("***********************************************************");
			System.out.print(new SimpleDateFormat("mm:ss:SSS").format(new java.util.Date())+" ||SYSLOG|| "+"Starting S5 Kenza CSV server on incoming path "+inpath+"... ");
			String sResult=kenzaServer.startCSVserver(inpath);
			System.out.println(sResult);
			bSuccess = bSuccess && sResult.equalsIgnoreCase("OK");
			SH.syslog("***********************************************************");
			SH.syslog(" - Kenza XML SUP/MAN/0011 - Version 0 - 26/09/2023");
			SH.syslog(" - Authored by Frank Verbeke, frank@ict4d.be");
			SH.syslog("");
		}
		return bSuccess;
	}
}
