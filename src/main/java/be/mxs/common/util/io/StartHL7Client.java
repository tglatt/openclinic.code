package be.mxs.common.util.io;

import java.io.IOException;
import java.sql.SQLException;

import be.openclinic.hl7.HL7Client;
import be.openclinic.system.SH;
import uk.org.primrose.GeneralException;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class StartHL7Client {

    public static String getParam(String[] args,String name, String defaultValue) {
    	for(int n=0;n<args.length;n++) {
    		if(args[n].equals(name) && n<args.length-1) {
    			return args[n+1];
    		}
    	}
    	return defaultValue;
    }

	public static void main(String[] args) throws InterruptedException, IOException, SQLException, ClassNotFoundException, GeneralException {
	    PrimroseLoader.load(getParam(args,"--cfg" ,""),true);
		HL7Client client = new HL7Client();
		int port = Integer.parseInt(getParam(args,"--port" ,"5100"));
		String host = getParam(args,"--host" ,"localhost");
		SH.syslog("Connecting HL7 client to host "+host+":"+port);
		SH.syslog(client.start(host,port));
	}

}
