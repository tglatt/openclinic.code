package ocdhis2.plugins;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Vector;

import org.dom4j.Element;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.openclinic.assets.Asset;
import be.openclinic.medical.BloodGift;
import be.openclinic.system.SH;
import net.admin.AdminPerson;
import net.admin.Service;
import ocdhis2.DHIS2Plugin;

public class CNTSSeroprevalence extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		//First we collect all bloodgifts and store them in MedwanQuery static variable
		if(!getRefObjectId().equalsIgnoreCase("bloodgifts."+SH.formatDate(begin)+"."+SH.formatDate(end))) {
			setRefObject(null);
		}
		if(getRefObject()==null) {
			setRefObjectId("bloodgifts."+SH.formatDate(begin)+"."+SH.formatDate(end));
			setRefObject(BloodGift.find(begin, end));
		}
		
		String labcode=(String)pluginParameters.get("labcode");
		boolean bNewcase = ((String)pluginParameters.get("newcase")).equalsIgnoreCase("1");
		Vector items = new Vector();
		Vector<BloodGift> gifts = (Vector<BloodGift>)getRefObject();
		for(int n=0;n<gifts.size();n++) {
			BloodGift gift = gifts.elementAt(n);
			if(bNewcase!=gift.isNewDonor()) {
				continue;
			}
			if(gift.getTested()>0 && gift.getDateofbirth()!=null) {
				if((labcode.equalsIgnoreCase("HIV") && gift.getHiv()==1) || (labcode.equalsIgnoreCase("HBS") && gift.getHepatitisB()==1) || (labcode.equalsIgnoreCase("HCV") && gift.getHepatitisC()==1) || (labcode.equalsIgnoreCase("BW") && gift.getSyphilis()==1)){
					items.add(gift.getPersonid()+";"+gift.getGender()+";"+SH.formatDate(gift.getDateofbirth())+";+;"+new SimpleDateFormat("yyyyMMddHHmm").format(gift.getDate())+";;"+gift.getTransaction().getTransactionId());
				}
				else {
					items.add(gift.getPersonid()+";"+gift.getGender()+";"+SH.formatDate(gift.getDateofbirth())+";-;"+new SimpleDateFormat("yyyyMMddHHmm").format(gift.getDate())+";;"+gift.getTransaction().getTransactionId());
				}
			}
		}
		return items;
	}
	
	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		return null;
	}

}
