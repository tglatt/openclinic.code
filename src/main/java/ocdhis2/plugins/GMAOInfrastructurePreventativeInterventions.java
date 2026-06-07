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

public class GMAOInfrastructurePreventativeInterventions extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		return null;
	}
	
	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		String rootService=SH.c((String)pluginParameters.get("organisationlevel"));
		int operations = be.openclinic.assets.Util.countPreventativeInterventions("i",begin,end,rootService);
		int plannedoperations = be.openclinic.assets.Util.countPlannedPreventativeInterventions("i",begin,end,rootService);
		int expiredoperations = be.openclinic.assets.Util.countExpiredPlannedPreventativeInterventions("i",begin,end,rootService);
		Vector items = new Vector();
		items.add(plannedoperations+";0;0;1");
		items.add(operations+";0;0;2");
		items.add(expiredoperations+";0;0;3");
		return items;
	}

}
