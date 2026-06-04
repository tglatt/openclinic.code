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
import be.openclinic.system.SH;
import net.admin.Service;
import ocdhis2.DHIS2Plugin;

public class GMAOInfrastructureWorks extends DHIS2Plugin {

	@Override
	public Vector getItems(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		return null;
	}
	
	@Override
	public Vector getResults(Date begin, Date end, Element dataset, Hashtable pluginParameters) {
		Vector items = new Vector();
		try {
			Hashtable costcenters = Service.getCostCenters();
			Vector<String> scores = new Vector<String>();
			String rootService=SH.c((String)pluginParameters.get("organisationlevel"));
			if(rootService.length()>0) {
				Connection conn=SH.getOpenClinicConnection();
				String sql = 	"select count(*) total ,sum(oc_asset_purchaseprice) value, oc_asset_comment18, oc_asset_comment1, oc_asset_service"+
								" from oc_assets where"+
								" str_to_date(oc_asset_comment12,'%d/%m/%Y') between ? and ? and"+
								" oc_asset_nomenclature LIKE 'i%' and"+
								" oc_asset_service in ("+Service.getChildIdsAsString(rootService)+")"+
								" group by oc_asset_comment18, oc_asset_comment1, oc_asset_service";
				Service svc = Service.getService(rootService);
				if(svc.getParentcode().length()==0) {
					sql = 	"select count(*) total ,sum(oc_asset_purchaseprice) value, oc_asset_comment18, oc_asset_comment1, oc_asset_service"+
							" from oc_assets where"+
							" str_to_date(oc_asset_comment12,'%d/%m/%Y') between ? and ? and"+
							" oc_asset_nomenclature LIKE 'i%' and"+
							" oc_asset_service like '"+rootService+"%'"+
							" group by oc_asset_comment18, oc_asset_comment1, oc_asset_service";
				}
				PreparedStatement ps = conn.prepareStatement(sql);
				ps.setDate(1, SH.toSQLDate(begin));
				ps.setDate(2, SH.toSQLDate(end));
				ResultSet rs = ps.executeQuery();
				while(rs.next()) {
					String service = SH.c(rs.getString("oc_asset_service"));
					if(service.length()>0 && SH.hasParentKey(costcenters,service)){
						String currency = SH.c(rs.getString("oc_asset_comment18"));
						if(currency.length()==0) {
							currency="bif";
						}
						double amount = rs.getDouble("value");
						String type = SH.c(rs.getString("oc_asset_comment1"));
						if(type.length()==0) {
							type="3";
						}
						scores.add(SH.getParentValue(costcenters,service)+";"+rs.getInt("total")+";"+amount+";"+currency+";"+type);
					}
				}
				rs.close();
				ps.close();
				double[] results = new double[4];
				for(int n=0;n<scores.size();n++) {
					String score = scores.elementAt(n);
					int number =Integer.parseInt(score.split(";")[1]);
					double amount =Double.parseDouble(score.split(";")[2]);
					String currency =score.split(";")[3];
					String type =score.split(";")[4];
					if(type.equalsIgnoreCase("2")) { //new construction
						results[0]+=number;
						if(currency.equalsIgnoreCase("bif")) results[1]+=amount;
						if(currency.equalsIgnoreCase("usd")) results[1]+=amount*SH.cd("usd2bif", 3000);
						if(currency.equalsIgnoreCase("eur")) results[1]+=amount*SH.cd("eur2bif", 3200);
					}
					else if(type.equalsIgnoreCase("1")) { //rehabilitation
						results[2]+=number;
						if(currency.equalsIgnoreCase("bif")) results[3]+=amount;
						if(currency.equalsIgnoreCase("usd")) results[3]+=amount*SH.cd("usd2bif", 3000);
						if(currency.equalsIgnoreCase("eur")) results[3]+=amount*SH.cd("eur2bif", 3200);
					}
				}
				for(int n=0;n<4;n++) {
					if(results[n]>0) items.add(new Double(results[n]).intValue()+";0;0;"+(n+1));
				} 
			}
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return items;
	}

}
