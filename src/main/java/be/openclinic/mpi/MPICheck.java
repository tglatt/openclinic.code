package be.openclinic.mpi;

import java.net.URI;
import java.net.URISyntaxException;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.openclinic.system.SH;

public class MPICheck implements Runnable {
	Thread thread;

	@Override
	public void run() {
		while(true) {
			try {
				long start = new java.util.Date().getTime();
				URI uri = new URI(SH.cs("MPIServerURL", "http://mpi.ocf.world/openclinic"));
				String host=uri.getHost();
				int port = uri.getPort()>0?uri.getPort():80;
				Debug.println("Connecting to MPI "+host+":"+port);
				long delay = SH.getServerResponseDelay(host, port, SH.ci("MPIServerResponseTimeout", 5000));
				Debug.println("Done in "+delay+"ms");
				MedwanQuery.getInstance().setConfigString("MPIServerResponseDelay",delay+"");
				MedwanQuery.getInstance().setConfigString("lastMPICheck", new java.util.Date().getTime()+"");
				if(SH.cl("intervalMPICheck", 10000)-(new java.util.Date().getTime()-start)>0) {
					Debug.println("Sleeping for "+SH.cl("intervalMPICheck", 10000)+" - "+(new java.util.Date().getTime()-start)+" = "+(SH.cl("intervalMPICheck", 10000)-(new java.util.Date().getTime()-start))+"ms");
					Thread.sleep(SH.cl("intervalMPICheck", 10000)-(new java.util.Date().getTime()-start));
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	public void start(){
		thread = new Thread(this);
		thread.start();
	}
	
	public static void check() {
		check(false);
	}
	
	public static void check(boolean bForce) {
		long lastCheck = SH.cl("lastMPICheck", 0);
		if(bForce || (new java.util.Date().getTime()-lastCheck>SH.ci("intervalMPICheck", 10000))) {
			MPICheck mc = new MPICheck();
			mc.start();
		}
	}

}
