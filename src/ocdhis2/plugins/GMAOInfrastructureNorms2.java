package ocdhis2.plugins;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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

public class GMAOInfrastructureNorms2 extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		return null;
	}
	
	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		Vector items = new Vector();
		//Item composition = <count/result>;<categoryoption>;<attributeoption>;<dataelement code>
		//*************************************
		//* Find all infrastructures by nomenclature for healthcenters under the actual orgunitid
		//*************************************
		String rootService=SH.c((String)pluginParameters.get("organisationlevel"));
		Connection conn = SH.getOpenClinicConnection();
		String sSql="";
		if(rootService.length()==0) {
			sSql = "SELECT COUNT(*) total, oc_asset_nomenclature,oc_asset_comment9 FROM oc_assets where "+
					  " oc_asset_comment9<>'' AND"+
					  " oc_asset_nomenclature<>''"+
					  " GROUP BY oc_asset_nomenclature,oc_asset_comment9";
		}
		else {
			Service svc = Service.getService(rootService);
			if(svc.getParentcode().length()==0) {
				sSql = "SELECT COUNT(*) total, oc_asset_nomenclature,oc_asset_comment9 FROM oc_assets where "+
						  " oc_asset_comment9<>'' AND"+
						  " oc_asset_nomenclature<>''"+
						  " GROUP BY oc_asset_nomenclature,oc_asset_comment9";
			}
			else {
				sSql = "SELECT COUNT(*) total, oc_asset_nomenclature,oc_asset_comment9 FROM oc_assets where "+
		    		  " oc_asset_service in ("+Service.getChildIdsAsString(rootService)+") AND"+
					  " oc_asset_comment9<>'' AND"+
					  " oc_asset_nomenclature<>''"+
					  " GROUP BY oc_asset_nomenclature,oc_asset_comment9";
			}
		}
		try {
			PreparedStatement ps = conn.prepareStatement(sSql);
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				items.add(rs.getInt("total")+";"+rs.getString("oc_asset_comment9")+";0;"+rs.getString("oc_asset_nomenclature"));
			}
			rs.close();
			ps.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return items;
	}

}
