package be.mxs.common.util.io;

import java.io.File;
import java.net.URL;
import java.sql.Connection;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import org.apache.commons.io.FileUtils;
import org.dcm4che2.data.DicomObject;
import org.dcm4che2.data.Tag;
import org.dcm4che2.data.VR;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.openclinic.archiving.DcmSnd;
import be.openclinic.archiving.Dicom;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class SpoolMPIDocuments {
    public static String getParam(String[] args,String name, String defaultValue) {
    	for(int n=0;n<args.length;n++) {
    		if(args[n].equals(name) && n<args.length-1) {
    			return args[n+1];
    		}
    	}
    	return defaultValue;
    }

    public static void main(String[] args) {
		// TODO Auto-generated method stub
    	try {
			PrimroseLoader.load(getParam(args, "--config", "/var/tomcat/conf/db.cfg"), true);
			try {
				MedwanQuery.getInstance(false);
				System.out.println("Starting DICOM spooler --> MedwanQuery loaded");
			}
			catch(Exception e) {
				System.out.println(" - Error - Closing system");
				System.exit(0);
			}
			int nLoop=1;
			while(true) {
				System.out.print("\rLoop "+nLoop++);
				if(getParam(args,"--debug" ,"1").equalsIgnoreCase("1")) {
					Debug.enabled=true;
				}
				Connection conn = null;
				try {
					//Remove transmission logs older than x days
					conn = MedwanQuery.getInstance(false).getOpenclinicConnection();
					PreparedStatement ps = conn.prepareStatement("delete from oc_mpidocuments where oc_mpidocument_sentdatetime<?");
					int days=MedwanQuery.getInstance().getConfigInt("numberOfDaysBeforeDeletingSentDocumentsFromSpooler",7);
					long minute=60*1000;
					long day=24*60*minute;
					ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()-day*days));
					ps.execute();
					ps = conn.prepareStatement("delete from oc_mpidocuments where oc_mpidocument_updatetime<?");
					days=MedwanQuery.getInstance().getConfigInt("numberOfDaysBeforeDeletingUnsentDocumentsFromSpooler",90);
					ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()-day*days));
					ps.execute();
					ps = conn.prepareStatement("select * from oc_mpidocuments where oc_mpidocument_sentdatetime is null");
					ResultSet rs = ps.executeQuery();
					while(rs.next()) {
						String direction = rs.getString("oc_mpidocument_direction");
						if(direction.equalsIgnoreCase("uploadDICOM")) {
							//Upload the dicom file to the destionation MPI server
							String id=rs.getString("oc_mpidocument_id");
							//First set the patient ID to the mpiid
							String filename = rs.getString("oc_mpidocument_url");
					    	try {
					    		System.out.println("Loading DICOM file "+filename);
								DicomObject obj = Dicom.getDicomObject(filename);
								obj.putString(Tag.PatientID, VR.LO, id.split("\\$")[2]);
						    	File toFile = new File(filename);
						    	Dicom.writeDicomObject(obj, toFile);
					    		System.out.println("[SpoolMPIDocuments] Trying to send "+filename);
								if(DcmSnd.isSendTest(	getParam(args, "--aetitle", "OCPX"), 
													getParam(args, "--pacshost", MedwanQuery.getInstance().getConfigString("MPIPACSServerHost","cloud.hnrw.org")), 
													Integer.parseInt(getParam(args, "--pacsport", MedwanQuery.getInstance().getConfigString("MPIPACSServerPort","10555"))), 
													filename)) {
						    		System.out.println("[SpoolMPIDocuments] "+filename+" sent");
									PreparedStatement ps2 = conn.prepareStatement("update oc_mpidocuments set oc_mpidocument_sentdatetime=? where oc_mpidocument_id=?");
									ps2.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
									ps2.setString(2,id);
									ps2.execute();
									ps2.close();
								}
								else {
									System.out.println("Error while sending "+filename+". Will retry later.");
								}
					    	}
					    	catch(Exception ee) {
					    		System.out.println("Error loading DICOM file, removing from spooler");
					    		Connection conn2 = MedwanQuery.getInstance(false).getOpenclinicConnection();
					    		PreparedStatement ps2 = conn2.prepareStatement("delete from oc_mpidocuments where oc_mpidocument_id=?");
								ps2.setString(1,id);
								ps2.execute();
								ps2.close();
								conn2.close();
					    		ee.printStackTrace();
					    	}
						}
						if(direction.equalsIgnoreCase("downloadDICOM")) {
							//Download the dicom files and store it in the document scanner 'from' directory
							String id=rs.getString("oc_mpidocument_id");
							String url = rs.getString("oc_mpidocument_url");
				    		System.out.println("[SpoolMPIDocuments] Trying to fetch "+url);
					    	try {
								String toFile=MedwanQuery.getInstance(false).getConfigString("scanDirectoryMonitor_basePath","/var/tomcat/webapps/openclinic/scan")+"/"+MedwanQuery.getInstance(false).getConfigString("scanDirectoryMonitor_dirFrom","from")+"/"+id+".dcm";
								FileUtils.copyURLToFile(new URL(url), new File(toFile));				    	
								PreparedStatement ps2 = conn.prepareStatement("delete from oc_mpidocuments where oc_mpidocument_id=?");
								ps2.setString(1,id);
								ps2.execute();
								ps2.close();
					    		System.out.println("[SpoolMPIDocuments] Fetched "+url);
					    	}
					    	catch(Exception ee) {
					    		ee.printStackTrace();
					    	}
						}
					}
					rs.close();
					ps.close();
					conn.close();
				}
				catch(Exception q) {
					if(conn!=null) {
						try {
							conn.close();
						}
						catch(Exception y) {
							y.printStackTrace();
						}
					}
					q.printStackTrace();
				}
				
				Thread.sleep(5000);
			}
    	}
    	catch (Exception e) {
			e.printStackTrace();
		}
		System.exit(0);
	}
}
