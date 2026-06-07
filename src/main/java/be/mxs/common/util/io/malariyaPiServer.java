package be.mxs.common.util.io;

import java.io.File;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.malariyapi.MalariyaPi;
import be.openclinic.system.SH;
import uk.org.primrose.GeneralException;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class malariyaPiServer {

	public static void main(String[] args) throws GeneralException, IOException, SQLException {
		String processid=ManagementFactory.getRuntimeMXBean().getName();
		System.out.println(processid+" - Loading primrose configuration "+args[0]);
		try {
			PrimroseLoader.load(args[0], true);
			System.out.println(processid+" - Primrose loaded");
		}
		catch(Exception e) {
			e.printStackTrace();
			System.out.println(processid+" - Error - Closing system");
			System.exit(0);
		}
		try {
			MedwanQuery.getInstance(false);
			System.out.println(processid+" - MedwanQuery loaded");
		}
		catch(Exception e) {
			System.out.println(processid+" - Error - Closing system");
			System.exit(0);
		}
		MalariyaPi pi = new MalariyaPi(SH.cs("malariyapi.serverid", "0"));
		pi.start();
	}

}
