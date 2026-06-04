package ocdhis2.plugins;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.Vector;

import org.dom4j.Element;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.openclinic.system.SH;
import net.admin.Service;
import ocdhis2.DHIS2Plugin;

public class GMAOEquipmentCorrectiveInterventions extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		return null;
	}
	
	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		String rootService=SH.c((String)pluginParameters.get("organisationlevel"));
		int operations = be.openclinic.assets.Util.countCorrectiveInterventions("e",begin,end,"",rootService);
		int succesfuloperations = be.openclinic.assets.Util.countCorrectiveInterventions("e",begin,end,"ok",rootService);
		Vector items = new Vector();
		items.add(operations+";0;0;1");
		items.add(succesfuloperations+";0;0;2");
		return items;
	}

}
