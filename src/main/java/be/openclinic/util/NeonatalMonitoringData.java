package be.openclinic.util;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.Vector;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryGeneral;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.pdf.general.PDFNeonatologyMonitor;
import be.openclinic.archiving.ArchiveDocument;
import be.openclinic.archiving.ScanDirectoryMonitor;
import be.openclinic.system.SH;
import net.admin.User;

public class NeonatalMonitoringData {

	public static boolean store(User user, int personid, java.util.Date date) {
		boolean bSuccess=false;
		ByteArrayOutputStream baosPDF = null;
	    try {
	        // PDF generator
	        PDFNeonatologyMonitor pdfNeonatologyMonitor = new PDFNeonatologyMonitor(user, "OpenClinic");
	        baosPDF = pdfNeonatologyMonitor.generatePDFDocumentBytes(personid, SH.parseDate(SH.formatDate(date,"yyyyMMdd")+" 00:00","yyyyMMdd HH:mm"), SH.parseDate(SH.formatDate(date,"yyyyMMdd")+" 23:59","yyyyMMdd HH:mm"));
	        // write PDF to file
	        // new archive file number
	        File file = new File(SH.cs("tempDirectory","/tmp")+"/"+new java.util.Date().getTime()+".pdf");
	        FileOutputStream fos = new FileOutputStream(file);
	        baosPDF.writeTo(fos);
	        fos.flush();
	        fos.close();
	        
	        Vector v = MedwanQuery.getInstance().getTransactionsByTypeBetween(personid, "be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ARCHIVE_DOCUMENT", date, new java.util.Date(date.getTime()+SH.getTimeHour()));
	        for (int n=0;n<v.size();n++) {
	        	TransactionVO transaction = (TransactionVO)v.elementAt(n);
	        	if(transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_TITLE").equalsIgnoreCase("Neonatal Monitoring Data")) {
	        		SH.syslog("Monitoring Data Report already exists for personid "+personid+" on "+SH.formatDate(date)+", skipping");
	        		return true;
	        	}
	        }
	        
			TransactionVO transaction = new TransactionFactoryGeneral().createTransactionVO(MedwanQuery.getInstance().getUser(MedwanQuery.getInstance().getConfigString("defaultPACSuser","4")),"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ARCHIVE_DOCUMENT",false); 
			transaction.setCreationDate(new java.util.Date());
			transaction.setStatus(1);
			transaction.setTransactionId(MedwanQuery.getInstance().getOpenclinicCounter("TransactionID"));
			transaction.setServerId(MedwanQuery.getInstance().getConfigInt("serverId",1));
			transaction.setTransactionType("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_ARCHIVE_DOCUMENT");
			transaction.setUpdateTime(date);
			transaction.setUser(MedwanQuery.getInstance().getUser(user.userid));
			transaction.setVersion(1);
			transaction.setItems(new Vector());
			ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_TITLE","Neonatal Monitoring Data",date,itemContextVO));
			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_PERSONID",personid+"",new Date(),itemContextVO));
			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_CATEGORY","medical",new Date(),itemContextVO));
    		ArchiveDocument archiveDocument = ArchiveDocument.save(true, transaction, transaction.getUser());
			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_UDI",archiveDocument.udi,new Date(),itemContextVO));
			itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
			transaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),
					"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DOC_UID",archiveDocument.getUid(),new Date(),itemContextVO));
			MedwanQuery.getInstance().updateTransaction(personid,transaction);
			System.out.println("Monitoring Data - UDI="+archiveDocument.udi);
			ScanDirectoryMonitor.acceptIncomingFile(archiveDocument.udi, file);
			System.out.println(archiveDocument.udi+" - Incoming file accepted");
			file.delete();
			System.out.println(archiveDocument.udi+" - Temporary file "+file.getName()+" deleted");
			bSuccess= true;
	    }
	    catch (Exception e) {
	    	e.printStackTrace();
	    }
	    finally {
	        if (baosPDF != null) {
	            baosPDF.reset();
	        }
	    }
	    return bSuccess;
	}
	
	public static void clean() {
		SH.syslog("Cleaning Neonatal Monitoring Tables");
		java.sql.Timestamp cutOff = new java.sql.Timestamp(new java.util.Date().getTime()-SH.getTimeHour());
		Connection conn = SH.getOpenClinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("insert into oc_observations_history(personid,id,ts,code,value) select personid,id,DATE_FORMAT(ts,'%Y-%m-%d %H:%i'),code,avg(VALUE) from oc_observations where ts<? GROUP BY personid,id,CODE,DATE_FORMAT(ts,'%Y-%m-%d %H:%i');");
			ps.setTimestamp(1, cutOff);
			ps.execute();
			ps.close();
			ps = conn.prepareStatement("delete from oc_observations where ts<?");
			ps.setTimestamp(1, cutOff);
			ps.execute();
			ps.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public static void exportReports() {
		Connection conn= SH.getOpenClinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select distinct personid from oc_observations_history where personid>0 and ts>=? and ts<?");
			ps.setTimestamp(1, SH.getSQLTimestamp(SH.getYesterday()));
			ps.setTimestamp(2, SH.getSQLTimestamp(SH.getToday()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				SH.syslog("Storing Monitoring Report for "+rs.getInt("personid"));
				NeonatalMonitoringData.store(User.get(MedwanQuery.getInstance().getConfigInt("defaultNeonatalMonitoringUser",4)), rs.getInt("personid"), SH.getYesterday());
			}
			rs.close();
			ps.close();
			ps=conn.prepareStatement("delete from oc_observations_history where ts<?");
			ps.setTimestamp(1, SH.getSQLTimestamp(new java.util.Date(SH.getToday().getTime()-SH.getTimeDay()*SH.ci("keepNeonatalMonitoringHistoryForDays", 7))));
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
	}
}
