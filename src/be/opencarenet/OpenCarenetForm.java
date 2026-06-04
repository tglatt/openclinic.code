package be.opencarenet;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Pointer;
import be.openclinic.system.SH;
import net.admin.AdminPerson;

public class OpenCarenetForm {
	int messageId;
	Hashtable inputs = new Hashtable();
	
	public boolean store() {
		//First check that this message hasn't been stored yet
		Connection conn = SH.getOpenClinicConnection();
		try {
			PreparedStatement ps = conn.prepareStatement("select * from transactions t,items i where i.transactionid=t.transactionid and"+
														 " i.serverid=t.serverid and"+
														 " t.transactionType='be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_OPENCARENET' and"+
														 " i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPENCARENET_MESSAGEID' and"+
														 " i.value=?");
			ps.setInt(1, messageId);
			ResultSet rs = ps.executeQuery();
			if(!rs.next()) {
				int personid=-1;
				//Now we check if we can find a patient match
				AdminPerson person = (AdminPerson)inputs.get("patient");
				//First check if this patientid was already matched before
				if(SH.c(Pointer.getPointer("OPENCARENET.PATIENTID."+inputs.get("senderid")+"."+person.personid)).length()>0) {
					personid=Integer.parseInt(Pointer.getPointer("OPENCARENET.PATIENTID."+inputs.get("senderid")+"."+person.personid));
				}
				if(personid<0) {
					//Now check if there's a full match based on name, firstname, gender and dateofbirth
					Vector matches = AdminPerson.searchPatients(person.lastname, person.firstname, person.gender, person.dateOfBirth, false);
					if(matches.size()==1) {
						Hashtable h = (Hashtable)matches.elementAt(0);
						personid=Integer.parseInt((String)h.get("personid"));
						Pointer.storePointer("OPENCARENET.PATIENTID."+inputs.get("senderid")+"."+person.personid, personid+"");
					}
				}
				if(personid<0) {
					//No match was found, let's create a new patient record
					personid=person.getPersonId();
					person.personid="";
					person.sourceid="4";
					person.setUpdateUser(SH.cs("opencarenet_updateuser", "4"));
					person.store();
					Pointer.storePointer("OPENCARENET.PATIENTID."+inputs.get("senderid")+"."+personid, person.personid);
					personid=person.getPersonId();
				}
				int healthRecordId = MedwanQuery.getInstance().getHealthRecordIdFromPersonIdWithCreate(personid);
				TransactionVO transaction = new TransactionVO();
		    	transaction.setCreationDate((java.util.Date)inputs.get("formdate"));
		    	transaction.setTransactionType("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_OPENCARENET");
		    	transaction.setUpdateUser(SH.cs("opencarenet_updateuser", "4"));
		    	transaction.setUser(MedwanQuery.getInstance().getUser(SH.cs("opencarenet_updateuser", "4")));
		    	transaction.setStatus(1);
		    	transaction.setTimestamp(new java.util.Date());
		    	transaction.setServerId(SH.getServerId());
		    	transaction.setTransactionId(-1);
		    	transaction.setUpdateTime((java.util.Date)inputs.get("formdate"));
		    	transaction.setVersion(1);
		    	transaction.setItems(new Vector<ItemVO>());
		        transaction.getItems().add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
		        		"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPENCARENET_MESSAGEID",
		        		messageId+"",
		                new Date(),
		                null));				
		    	transaction.setHealthrecordId(healthRecordId);
				Enumeration e = inputs.keys();
				while(e.hasMoreElements()) {
					String key = ((String)e.nextElement()).toLowerCase();
					if(!key.contains("patient") && !key.contains("formdate")) {
				        transaction.getItems().add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
				        		"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPENCARENET_"+key.toUpperCase(),
				        		(String)inputs.get(key),
				                new Date(),
				                null));				
				    }
				}
				MedwanQuery.getInstance().updateTransaction(personid, transaction);
				SH.syslog("Stored OpenCarenet message #"+messageId+" of type ["+transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPENCARENET_FORMNAME").toUpperCase()+"] for patient "+person.getFullName());
			}
			rs.close();
			ps.close();
			conn.close();
			return true;
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return false;
	}
}
