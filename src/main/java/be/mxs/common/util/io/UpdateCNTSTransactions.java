package be.mxs.common.util.io;

import java.io.File;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.dcm4che2.io.DicomInputStream;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.openclinic.archiving.*;
import be.openclinic.system.SH;
import uk.org.primrose.vendor.standalone.PrimroseLoader;

public class UpdateCNTSTransactions {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
    	try {
    		Debug.enabled=true;
			System.out.println("------------------------------ Primrose Loading "+args[0]);
    		PrimroseLoader.load(args[0], true);
			System.out.println("------------------------------ Primrose Loaded");
			System.out.println("------------------------------ Updating lab requests");
			updateTransactions("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST");
			System.out.println("------------------------------ Updating lab records");
			updateTransactions("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNTSLAB_RECORD");
		}
    	catch (Exception e) {
			e.printStackTrace();
		}
		System.exit(0);
	}
	
	private static void updateTransactions(String sTransactionType) throws SQLException {
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("select * from transactions where transactiontype=?  and updatetime>? order by updatetime");
		ps.setString(1, sTransactionType);
		ps.setDate(2, new java.sql.Date(new java.util.Date().getTime()-60*SH.getTimeDay()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			//SH.syslog("Verifying transaction "+rs.getInt("transactionid"));
			boolean bValidReference=false;
			//First we check if a reference to a bloodgift exists
			PreparedStatement ps2 = conn.prepareStatement("select * from items where transactionid=? and type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_OBJECTID'");
			ps2.setInt(1,rs.getInt("transactionid"));
			ResultSet rs2 = ps2.executeQuery();
			if(rs2.next()){
				//The reference exists, check if is valid
				//SH.syslog("Reference to "+SH.c(rs2.getString("value"))+" exists");
				int nRefTransactionId=-1;
				try{
					if(SH.c(rs2.getString("value")).length()>0){
						nRefTransactionId = Integer.parseInt(rs2.getString("value"));
						rs2.close();
						ps2.close();
						ps2 = conn.prepareStatement("select * from transactions where transactionid=? and healthrecordid=? and transactiontype='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNTS_BLOODGIFT'");
						ps2.setInt(1, nRefTransactionId);
						ps2.setInt(2, rs.getInt("healthrecordid"));
						rs2=ps2.executeQuery();
						bValidReference=rs2.next(); //the value refers to a valid BLOODGIFT transaction from the same patient
					}
				}
				catch(Exception ex){
					ex.printStackTrace();
				}
			}
			else{
				//The reference does not exist, do nothing
			}
			rs2.close();
			ps2.close();
			if(bValidReference){
				SH.syslog(rs.getString("transactionid")+" ==> CHECK");
			}
			else{
				//SH.syslog(rs.getString("transactionid")+" ==> ERROR");
				//The reference is not valid, first remove it
				ps2=conn.prepareStatement("delete from items where transactionid=? and type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_OBJECTID'");
				ps2.setInt(1,rs.getInt("transactionid"));
				ps2.execute();
				ps2.close();
				//Now try to find a valid reference. This is a bloodgift from the same donod that is more recent than 1 week before the LABRECORD
				ps2=conn.prepareStatement("select * from transactions where healthrecordid=? and updatetime>=? and updatetime<=? and transactiontype='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_CNTS_BLOODGIFT'");
				ps2.setInt(1,rs.getInt("healthrecordid"));
				ps2.setDate(2,new java.sql.Date(rs.getDate("updatetime").getTime()-SH.getTimeDay()*7));
				ps2.setDate(3,new java.sql.Date(rs.getDate("updatetime").getTime()+SH.getTimeDay()));
				rs2=ps2.executeQuery();
				if(rs2.next()){
					//A valid reference exists, store it
					int nRefTransactionId=rs2.getInt("transactionid");
					rs2.close();
					ps2.close();
					ps2=conn.prepareStatement("insert into items(itemid,type,value,date,transactionid,serverid,version,versionserverid,priority,valuehash) values(?,?,?,?,?,?,1,?,1,?)");
					ps2.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("ItemID"));
					ps2.setString(2,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_OBJECTID");
					ps2.setString(3,nRefTransactionId+"");
					ps2.setDate(4,rs.getDate("updatetime"));
					ps2.setInt(5,rs.getInt("transactionid"));
					ps2.setInt(6,rs.getInt("serverid"));
					ps2.setInt(7,rs.getInt("serverid"));
					ps2.setInt(8,(nRefTransactionId+"").hashCode());
					ps2.execute();
					SH.syslog("Replaced by reference ==> "+nRefTransactionId);
				}
				else{
					//No valid reference, leave it
					SH.syslog("NO Valid reference found for transaction "+rs.getInt("transactionid"));
				}
			}
		}
		rs.close();
		ps.close();
		conn.close();
	}

}
