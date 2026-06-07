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

import be.mxs.common.util.system.Debug;
import be.openclinic.assets.Asset;
import be.openclinic.medical.BloodGift;
import be.openclinic.system.SH;
import net.admin.Service;
import ocdhis2.DHIS2Plugin;

public class CNTSBloodBagsTested extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		if(getRefObject()==null) {
			setRefObject(BloodGift.find(begin, end));
		}
		return null;
	}
	
	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		//First we collect all bloodgifts and store them in MedwanQuery static variable
		if(!getRefObjectId().equalsIgnoreCase("bloodgifts."+SH.formatDate(begin)+"."+SH.formatDate(end))) {
			setRefObject(null);
		}
		if(getRefObject()==null) {
			setRefObjectId("bloodgifts."+SH.formatDate(begin)+"."+SH.formatDate(end));
			setRefObject(BloodGift.find(begin, end));
		}

		int total=0;
		Vector<BloodGift> gifts = (Vector<BloodGift>)getRefObject();
		for(int n=0;n<gifts.size();n++) {
			BloodGift gift = gifts.elementAt(n);
			total+=gift.getTested();
		}
		
		Vector items = new Vector();
		items.add(total+";1;1");
		return items;
	}

}
