package be.mxs.common.util.io;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Mail;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.finance.Insurar;
import be.openclinic.system.SH;

public class CloseVisits {

	public static void main(String[] args) {
		try{
			// This will load the MySQL driver, each DB has its own driver
		    System.out.println("driver="+args[0]);
		    System.out.println("url="+args[1]);
		    Class.forName(args[0]);			
		    Connection conn =  DriverManager.getConnection(args[1]);
            String sSQL = "update oc_encounters set oc_encounter_enddate =oc_encounter_begindate,oc_encounter_outcome='missing' where oc_encounter_type='visit' and oc_encounter_enddate is null and oc_encounter_begindate<?";
            PreparedStatement ps = conn.prepareStatement(sSQL);
            ps.setDate(1,new java.sql.Date(new java.util.Date().getTime()-(SH.ci("autoCloseVisitsAfterDays",1)-1)*ScreenHelper.getTimeDay()));
			ps.execute();
			ps.close();
			//This only works on MySQL
			ps=conn.prepareStatement(args[2]);
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
}
