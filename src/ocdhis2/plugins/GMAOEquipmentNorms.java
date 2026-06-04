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
import be.openclinic.system.SH;
import net.admin.Service;
import ocdhis2.DHIS2Plugin;

public class GMAOEquipmentNorms extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		return null;
	}
	
	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		Vector items = new Vector();
		try {
			Vector<String> scores = new Vector<String>();
			String rootService=SH.c((String)pluginParameters.get("organisationlevel"));
			if(rootService.length()>0) {
				String score = be.openclinic.assets.Util.getNormsScoreForService(rootService,"e",end);
				if(score.length()>0) {
					scores.add(score);
				}
				Vector children=Service.getChildIds(rootService);
				for(int n=0;n<children.size();n++){
					score = be.openclinic.assets.Util.getNormsScoreForService((String)children.elementAt(n),"e",end);
					if(score.length()>0) {
						scores.add(score);
					}
				}
			}
			double totalscore=0;
			for(int n=0;n<scores.size();n++) {
				String score = scores.elementAt(n);
				totalscore+=Double.parseDouble(score.split(";")[1]);
			}
			items.add(new Double(totalscore*100/scores.size()).intValue()+";0;0;1");
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return items;
	}

}
