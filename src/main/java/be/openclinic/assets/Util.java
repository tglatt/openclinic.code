package be.openclinic.assets;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Hashtable;
import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;
import java.util.TreeSet;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.system.SH;
import net.admin.Service;

public class Util {
	
	public static int countAssets(Hashtable<String,String> parameters) {
		int count = 0;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			String sSql="select count(*) total from oc_assets where 1=1";
			Enumeration<String> pars = parameters.keys();
			while(pars.hasMoreElements()) {
				String key = pars.nextElement();
				String value = parameters.get(key);
				if(value.split(";")[0].equalsIgnoreCase("in")) {
					sSql+=" and "+key+" in ("+value.split(";")[1]+")";
				}
				else if(value.split(";")[0].equalsIgnoreCase("like")) {
					sSql+=" and "+key+" like "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("notlike")) {
					sSql+=" and "+key+" NOT like "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("equals")) {
					sSql+=" and "+key+" = "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("notequals")) {
					sSql+=" and NOT "+key+" = "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("copy")) {
					sSql+=" and "+key+value.split(";")[1];
				}
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				count=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return count;
	}
	
	public static int countMaintenanceOperations(Hashtable<String,String> parameters) {
		int count = 0;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			String sSql="select count(distinct oc_maintenanceoperation_objectid) total from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o where a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')";
			Enumeration<String> pars = parameters.keys();
			while(pars.hasMoreElements()) {
				String key = pars.nextElement();
				String value = parameters.get(key);
				if(value.split(";")[0].equalsIgnoreCase("in")) {
					sSql+=" and "+key+" in ("+value.split(";")[1]+")";
				}
				else if(value.split(";")[0].equalsIgnoreCase("like")) {
					sSql+=" and "+key+" like "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("notlike")) {
					sSql+=" and "+key+" NOT like "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("equals")) {
					sSql+=" and "+key+" = "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("notequals")) {
					sSql+=" and NOT "+key+" = "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("copy")) {
					sSql+=" and "+key+value.split(";")[1];
				}
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				count=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return count;
	}
	
	public static int countMaintenanceOperationPlans(Hashtable<String,String> parameters) {
		int count = 0;
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			String sSql="select count(distinct oc_maintenanceoperation_maintenanceplanuid) total from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o where a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')";
			Enumeration<String> pars = parameters.keys();
			while(pars.hasMoreElements()) {
				String key = pars.nextElement();
				String value = parameters.get(key);
				if(value.split(";")[0].equalsIgnoreCase("in")) {
					sSql+=" and "+key+" in ("+value.split(";")[1]+")";
				}
				else if(value.split(";")[0].equalsIgnoreCase("like")) {
					sSql+=" and "+key+" like "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("notlike")) {
					sSql+=" and "+key+" NOT like "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("equals")) {
					sSql+=" and "+key+" = "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("notequals")) {
					sSql+=" and NOT "+key+" = "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("copy")) {
					sSql+=" and "+key+value.split(";")[1];
				}
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				count=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return count;
	}
	
	public static String analyzeMaintenanceOperations(Hashtable<String,String> parameters,String returnValue) {
		String s="";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		try {
			String sSql="select "+returnValue+" total from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o where a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','')";
			Enumeration<String> pars = parameters.keys();
			while(pars.hasMoreElements()) {
				String key = pars.nextElement();
				String value = parameters.get(key);
				if(value.split(";")[0].equalsIgnoreCase("in")) {
					sSql+=" and "+key+" in ("+value.split(";")[1]+")";
				}
				else if(value.split(";")[0].equalsIgnoreCase("like")) {
					sSql+=" and "+key+" like "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("notlike")) {
					sSql+=" and "+key+" NOT like "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("equals")) {
					sSql+=" and "+key+" = "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("notequals")) {
					sSql+=" and NOT "+key+" = "+value.split(";")[1];
				}
				else if(value.split(";")[0].equalsIgnoreCase("copy")) {
					sSql+=" and "+key+value.split(";")[1];
				}
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				s=rs.getString("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return s;
	}
	
	public static SortedMap getNormsForService(String serviceid){
		SortedMap norms = new TreeMap();
		//First check which kind of structure we have
		Connection conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
		try{
			Service service = Service.getService(serviceid);
			if(service!=null && ScreenHelper.checkString(service.costcenter).length()>0 ){
				PreparedStatement ps = conn.prepareStatement("select * from oc_standards where structure=? and quantity>0 order by nomenclature");
				ps.setString(1, service.costcenter);
				ResultSet rs = ps.executeQuery();
				while(rs.next()){
					double total = 0, nonfunctional=0;
					String[] noms = rs.getString("nomenclature").split(";");
					double quantity = rs.getDouble("quantity");
					for(int n=0;n<noms.length;n++){
						String nomenclature = noms[n];
						if(noms[n].toUpperCase().startsWith("E")) {
				    		String sSql="select count(*) total from oc_assets where (oc_asset_service=? OR oc_asset_service in ("+Service.getChildIdsAsString(serviceid)+")) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and (oc_asset_comment7 is null or oc_asset_comment7='' or oc_asset_comment7<3)";
					    	if(service.getParentcode().length()==0) {
					    		sSql="select count(*) total from oc_assets where (oc_asset_service=? OR oc_asset_service like'"+serviceid+"%') and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and (oc_asset_comment7 is null or oc_asset_comment7='' or oc_asset_comment7<3)";
					    	}
							PreparedStatement ps2 = conn.prepareStatement(sSql);
							ps2.setString(1, serviceid);
							ps2.setString(2,nomenclature);
							ps2.setString(3,nomenclature+".%");
							ps2.setTimestamp(4, new java.sql.Timestamp(new java.util.Date().getTime()));
							ResultSet rs2 = ps2.executeQuery();
							if(rs2.next()){
								total+=rs2.getInt("total");
							}
							rs2.close();
							ps2.close();
				    		sSql="select count(*) total from oc_assets where (oc_asset_service=? OR oc_asset_service in ("+Service.getChildIdsAsString(serviceid)+")) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and oc_asset_comment7='3'";
					    	if(service.getParentcode().length()==0) {
					    		sSql="select count(*) total from oc_assets where (oc_asset_service=? OR oc_asset_service like '"+serviceid+"%') and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and oc_asset_comment7='3'";
					    	}
							ps2 = conn.prepareStatement(sSql);
							ps2.setString(1, serviceid);
							ps2.setString(2,nomenclature);
							ps2.setString(3,nomenclature+".%");
							ps2.setTimestamp(4, new java.sql.Timestamp(new java.util.Date().getTime()));
							rs2 = ps2.executeQuery();
							if(rs2.next()){
								nonfunctional+=rs2.getInt("total");
							}
							rs2.close();
							ps2.close();
						}
						else if(noms[n].toUpperCase().startsWith("I")) {
				    		String sSql="select sum(oc_asset_comment17) total from oc_assets where (oc_asset_service=? OR oc_asset_service in ("+Service.getChildIdsAsString(serviceid)+")) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and (oc_asset_comment7 is null or oc_asset_comment7='' or oc_asset_comment7<3)";
					    	if(service.getParentcode().length()==0) {
					    		sSql="select sum(oc_asset_comment17) total from oc_assets where (oc_asset_service=? OR oc_asset_service like'"+serviceid+"%') and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and (oc_asset_comment7 is null or oc_asset_comment7='' or oc_asset_comment7<3)";
					    	}
							PreparedStatement ps2 = conn.prepareStatement(sSql);
							ps2.setString(1, serviceid);
							ps2.setString(2,nomenclature);
							ps2.setString(3,nomenclature+".%");
							ps2.setTimestamp(4, new java.sql.Timestamp(new java.util.Date().getTime()));
							ResultSet rs2 = ps2.executeQuery();
							if(rs2.next()){
								total+=rs2.getInt("total");
							}
							rs2.close();
							ps2.close();
				    		sSql="select sum(oc_asset_comment17) total from oc_assets where (oc_asset_service=? OR oc_asset_service in ("+Service.getChildIdsAsString(serviceid)+")) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and oc_asset_comment7='3'";
					    	if(service.getParentcode().length()==0) {
					    		sSql="select sum(oc_asset_comment17) total from oc_assets where (oc_asset_service=? OR oc_asset_service like '"+serviceid+"%') and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and oc_asset_comment7='3'";
					    	}
							ps2 = conn.prepareStatement(sSql);
							ps2.setString(1, serviceid);
							ps2.setString(2,nomenclature);
							ps2.setString(3,nomenclature+".%");
							ps2.setTimestamp(4, new java.sql.Timestamp(new java.util.Date().getTime()));
							rs2 = ps2.executeQuery();
							if(rs2.next()){
								nonfunctional+=rs2.getInt("total");
							}
							rs2.close();
							ps2.close();
						}
					}
					norms.put(noms[0],quantity+";"+total+";"+nonfunctional);
				}
				rs.close();
				ps.close();
				conn.close();
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return norms;
	}
	
	public static String getNormsScoreForService(String serviceid, String assettype, java.util.Date refDate){
		double needed=0, available=0;
		String sResult="";
		//First check which kind of structure we have
		Connection conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
		try{
			Service service = Service.getService(serviceid);
			if(service!=null && ScreenHelper.checkString(service.costcenter).length()>0 ){
				PreparedStatement ps = conn.prepareStatement("select * from oc_standards where structure=? and quantity>0 order by nomenclature");
				ps.setString(1, service.costcenter);
				ResultSet rs = ps.executeQuery();
				while(rs.next()){
					String[] noms = rs.getString("nomenclature").split(";");
					if(SH.c(assettype).length()>0 && !noms[0].toLowerCase().startsWith(assettype.toLowerCase())) {
						continue;
					}
					needed++;
					for(int n=0;n<noms.length;n++){
						String nomenclature = noms[n];
						String sSql="select count(*) totalassets from oc_assets where (oc_asset_service=? OR oc_asset_service in("+Service.getChildIdsAsString(serviceid)+")) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and (oc_asset_comment7 is null or oc_asset_comment7='' or oc_asset_comment7<3) and (oc_asset_comment12 is NULL or length(oc_asset_comment12)=0 or STR_TO_DATE(oc_asset_comment12,'%d/%m/%Y')<=?)";
						PreparedStatement ps2 = conn.prepareStatement(sSql);
						if(service.getParentcode().length()==0) {
				    		ps2 = conn.prepareStatement("select count(*) total from oc_assets where (oc_asset_service=? OR oc_asset_service like '"+serviceid+".%') and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and (oc_asset_comment7 is null or oc_asset_comment7='' or oc_asset_comment7<3) and (oc_asset_comment12 is NULL or length(oc_asset_comment12)=0 or STR_TO_DATE(oc_asset_comment12,'%d/%m/%Y')<=?)");
				    	}
						ps2.setString(1, serviceid);
						ps2.setString(2,nomenclature);
						ps2.setString(3,nomenclature+".%");
						ps2.setTimestamp(4, SH.toSQLTimestamp(refDate));
						ps2.setDate(5, SH.toSQLDate(refDate));
						ResultSet rs2 = ps2.executeQuery();
						if(rs2.next()){
							if(rs2.getInt("totalassets")>=rs.getDouble("quantity")) {
								available++;
							}
						}
						rs2.close();
						ps2.close();
					}
				}
				rs.close();
				ps.close();
				if(needed>0) {
					sResult=service.costcenter+";"+(available/needed);
				}
			}
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return sResult;
	}
	
	public static Hashtable getPreventativeInterventions(String assettype, java.util.Date begin, java.util.Date end){
		Hashtable operations = new Hashtable();
		//First we retrieve all interventions in the period
		try {
			Connection conn = SH.getOpenClinicConnection();
			String sSql="select count(*) total,oc_asset_service "+
						" from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o, servicesview s "+
						" where "+
						" a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
						" oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
						" serviceid=oc_asset_service and"+
						" oc_maintenanceplan_type=2 and"+
						" oc_asset_nomenclature like '"+assettype+"%' and"+
						" oc_maintenanceoperation_date>=? and"+
						" oc_maintenanceoperation_date<?"+
						" group by oc_asset_service"
						;
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				operations.put(rs.getString("oc_asset_service"),rs.getInt("total"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return operations;
	}
	
	public static int countPreventativeInterventions(String assettype, java.util.Date begin, java.util.Date end, String rootService){
		int n=0;
		try {
			Connection conn = SH.getOpenClinicConnection();
			String sSql="";
			Service svc = Service.getService(rootService);
			if(svc.getParentcode().length()==0) {
				sSql="select count(*) total "+
				" from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o, servicesview s "+
				" where "+
				" a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
				" oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
				" serviceid=oc_asset_service and"+
				" oc_maintenanceplan_type=2 and"+
				" oc_asset_nomenclature like '"+assettype+"%' and"+
				" oc_maintenanceoperation_date>=? and"+
				" oc_maintenanceoperation_date<?"
				;
			}
			else {
				sSql="select count(*) total "+
				" from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o, servicesview s "+
				" where "+
				" a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
				" oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
				" serviceid=oc_asset_service and"+
				" oc_maintenanceplan_type<3 and"+
				" oc_asset_nomenclature like '"+assettype+"%' and"+
				" oc_maintenanceoperation_date>=? and"+
				" oc_maintenanceoperation_date<? and"+
				" serviceid in ("+Service.getChildIdsAsString(rootService)+")"
				;
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				n=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return n;
	}
	
	public static Hashtable getCorrectiveInterventions(String assettype, java.util.Date begin, java.util.Date end, String success){
		Hashtable operations = new Hashtable();
		//First we retrieve all interventions in the period
		try {
			Connection conn = SH.getOpenClinicConnection();
			String sSql="select count(*) total,oc_asset_service "+
						" from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o, servicesview s "+
						" where "+
						" a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
						" oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
						" serviceid=oc_asset_service and"+
						" oc_maintenanceplan_type=3 and"+
						" oc_asset_nomenclature like '"+assettype+"%' and"+
						" oc_maintenanceoperation_date>=? and"+
						" oc_maintenanceoperation_date<? and"+
						" oc_maintenanceoperation_result like '"+success+"%'"+
						" group by oc_asset_service"
						;
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				operations.put(rs.getString("oc_asset_service"),rs.getInt("total"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return operations;
	}
	
	public static int countCorrectiveInterventions(String assettype, java.util.Date begin, java.util.Date end, String success, String rootService){
		int n=0;
		try {
			Connection conn = SH.getOpenClinicConnection();
			String sSql="";
			Service svc = Service.getService(rootService);
			if(svc.getParentcode().length()==0) {
				sSql="select count(*) total"+
						" from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o, servicesview s "+
						" where "+
						" a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
						" oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
						" serviceid=oc_asset_service and"+
						" oc_maintenanceplan_type=3 and"+
						" oc_asset_nomenclature like '"+assettype+"%' and"+
						" oc_maintenanceoperation_date>=? and"+
						" oc_maintenanceoperation_date<? and"+
						" oc_maintenanceoperation_result like '"+success+"%'"
						;
			}
			else {
				sSql="select count(*) total"+
					" from oc_assets a,oc_maintenanceplans p,oc_maintenanceoperations o, servicesview s "+
					" where "+
					" a.oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
					" oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'"+MedwanQuery.getInstance().getConfigInt("serverId")+".','') and"+
					" serviceid=oc_asset_service and"+
					" oc_maintenanceplan_type=3 and"+
					" oc_asset_nomenclature like '"+assettype+"%' and"+
					" oc_maintenanceoperation_date>=? and"+
					" oc_maintenanceoperation_date<? and"+
					" oc_maintenanceoperation_result like '"+success+"%' and"+
					" serviceid in ("+Service.getChildIdsAsString(rootService)+")"
					;
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			if(rs.next()) {
				n=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return n;
	}
	
	public static String getPreventativeInterventionsForService(String serviceid, String assettype, java.util.Date begin, java.util.Date end){
		String sResult="";
		Service service = Service.getService(serviceid);
		if(service!=null && ScreenHelper.checkString(service.costcenter).length()>0){
			Hashtable parameters = new Hashtable();
			parameters.put("oc_asset_nomenclature","like;'"+assettype+"%'");
			parameters.put("oc_asset_service","like;'"+serviceid+"%'");
			parameters.put("oc_maintenanceplan_type","equals;'2'");
			parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(begin)+"'");
			parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(end)+"'");
			int done=Util.countMaintenanceOperations(parameters);
		    int planned = getPlannedPreventativeInterventionsForService(serviceid, assettype, begin, end);
		    if(planned>0) {
				sResult = service.costcenter+";"+done+";"+planned;
			}
		}
		return sResult;
	}

	public static Hashtable getExpiredPlannedPreventativeInterventions(String assettype,java.util.Date begin,java.util.Date end) {
		Hashtable planned = new Hashtable();
		try {
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sSql = 	"select count(*) total,oc_asset_service from oc_assets a,oc_maintenanceplans p where "+
							" oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
							" oc_maintenanceplan_type=2 and"+
							" oc_asset_nomenclature like '"+assettype+"%' and"+
							" (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>?) and"+
							" oc_maintenanceplan_startdate<? and"+
							" not exists ("+
							" 	select * from oc_maintenanceoperations where "+
							" 	oc_maintenanceoperation_maintenanceplanuid=oc_maintenanceplan_serverid||'.'||oc_maintenanceplan_objectid and"+
							"   oc_maintenanceoperation_nextdate>=? and"+
							"   oc_maintenanceoperation_nextdate<?"+
							" )"+
							" group by oc_asset_service";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ps.setDate(3, SH.toSQLDate(begin));
			ps.setDate(4, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				planned.put(rs.getString("oc_asset_service"),rs.getInt("total"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return planned;
	}
	
	public static int countExpiredPlannedPreventativeInterventions(String assettype,java.util.Date begin,java.util.Date end,String rootService) {
		int n=0;
		try {
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sSql="";
			Service svc = Service.getService(rootService);
			if(svc.getParentcode().length()==0) {
				sSql = 	"select count(*) total from oc_assets a,oc_maintenanceplans p where "+
						" oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
						" oc_maintenanceplan_type=2 and"+
						" oc_asset_nomenclature like '"+assettype+"%' and"+
						" (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>?) and"+
						" oc_maintenanceplan_startdate<? and"+
						" not exists ("+
						" 	select * from oc_maintenanceoperations where "+
						" 	oc_maintenanceoperation_maintenanceplanuid=oc_maintenanceplan_serverid||'.'||oc_maintenanceplan_objectid and"+
						"   oc_maintenanceoperation_nextdate>=? and"+
						"   oc_maintenanceoperation_nextdate<?"+
						" )"
						;
			}
			else {
				sSql = 	"select count(*) total from oc_assets a,oc_maintenanceplans p where "+
						" oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
						" oc_maintenanceplan_type=2 and"+
						" oc_asset_nomenclature like '"+assettype+"%' and"+
						" (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>?) and"+
						" oc_maintenanceplan_startdate<? and"+
						" not exists ("+
						" 	select * from oc_maintenanceoperations where "+
						" 	oc_maintenanceoperation_maintenanceplanuid=oc_maintenanceplan_serverid||'.'||oc_maintenanceplan_objectid and"+
						"   oc_maintenanceoperation_nextdate>=? and"+
						"   oc_maintenanceoperation_nextdate<?"+
						" ) and"+
						" oc_asset_service in ("+Service.getChildIdsAsString(rootService)+")"
						;
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ps.setDate(3, SH.toSQLDate(begin));
			ps.setDate(4, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				n=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return n;
	}
	
	public static Hashtable getPlannedPreventativeInterventions(String assettype,java.util.Date begin,java.util.Date end) {
		Hashtable planned = new Hashtable();
		try {
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sSql = 	"select count(*) total,oc_asset_service from oc_assets a,oc_maintenanceplans p where "+
							" oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
							" oc_maintenanceplan_type=2 and"+
							" oc_asset_nomenclature like '"+assettype+"%' and"+
							" (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>?) and"+
							" oc_maintenanceplan_startdate<? and"+
							" exists ("+
							" 	select * from oc_maintenanceoperations where "+
							" 	oc_maintenanceoperation_maintenanceplanuid=oc_maintenanceplan_serverid||'.'||oc_maintenanceplan_objectid and"+
							"   oc_maintenanceoperation_nextdate>=? and"+
							"   oc_maintenanceoperation_nextdate<?"+
							" )"+
							" group by oc_asset_service";
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ps.setDate(3, SH.toSQLDate(begin));
			ps.setDate(4, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				planned.put(rs.getString("oc_asset_service"),rs.getInt("total"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return planned;
	}
	
	public static int countPlannedPreventativeInterventions(String assettype,java.util.Date begin,java.util.Date end,String rootService) {
		int n=0;
		try {
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sSql="";
			Service svc = Service.getService(rootService);
			if(svc.getParentcode().length()==0) {
				sSql = 	"select count(*) total from oc_assets a,oc_maintenanceplans p, oc_maintenanceoperations o where "+
						" oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
						" oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'1.','') AND"+ 
						" oc_maintenanceplan_type=2 and"+
						" oc_asset_nomenclature like '"+assettype+"%' and"+
						" (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>?) and"+
						" oc_maintenanceplan_startdate<? and"+
						" oc_maintenanceoperation_nextdate>=? and"+
						" oc_maintenanceoperation_nextdate<?"
						;
			}
			else {
				sSql = 	"select count(*) total from oc_assets a,oc_maintenanceplans p, oc_maintenanceoperations o where "+
						" oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
						" oc_maintenanceplan_objectid=replace(oc_maintenanceoperation_maintenanceplanuid,'1.','') AND"+ 
						" oc_maintenanceplan_type=2 and"+
						" oc_asset_nomenclature like '"+assettype+"%' and"+
						" (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>?) and"+
						" oc_maintenanceplan_startdate<? and"+
						" oc_maintenanceoperation_nextdate>=? and"+
						" oc_maintenanceoperation_nextdate<? and"+
						" oc_asset_service in ("+Service.getChildIdsAsString(rootService)+")"
						;
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ps.setDate(1, SH.toSQLDate(begin));
			ps.setDate(2, SH.toSQLDate(end));
			ps.setDate(3, SH.toSQLDate(begin));
			ps.setDate(4, SH.toSQLDate(end));
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				n=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return n;
	}
	
	public static int getPlannedPreventativeInterventionsForService(String serviceid,String assettype,java.util.Date begin,java.util.Date end) {
		int planned = 0;
		//First check how many preventative maintenance operations were scheduled in the period
		HashSet plans = new HashSet();
		try {
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			String sid=MedwanQuery.getInstance().getServerId()+"";
			String sSql = 	"select * from oc_assets a,oc_maintenanceplans p where oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+sid+".','') and"+
									" oc_maintenanceplan_type=2 and oc_asset_service in ("+Service.getChildIdsAsString(serviceid)+") and oc_asset_nomenclature like '"+assettype+"%' and (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>'"+
									new SimpleDateFormat("yyyy-MM-dd").format(begin)+"') and oc_maintenanceplan_startdate<'"+new SimpleDateFormat("yyyy-MM-dd").format(end)+"'";
	    	Service service = Service.getService(serviceid);
			if(service.getParentcode().length()==0) {
				sSql = 	"select * from oc_assets a,oc_maintenanceplans p where oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+sid+".','') and"+
						" oc_maintenanceplan_type=2 and oc_asset_service like '"+serviceid+"%' and oc_asset_nomenclature like '"+assettype+"%' and (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>'"+
						new SimpleDateFormat("yyyy-MM-dd").format(begin)+"') and oc_maintenanceplan_startdate<'"+new SimpleDateFormat("yyyy-MM-dd").format(end)+"'";
			}
			PreparedStatement ps = conn.prepareStatement(sSql);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				//Each of these maintenance plans is due if (i) there has never been an operation or (ii) the expiry date of the 
				//latest maintenance operation falls before enddate (it should have been done) 
				String maintenancePlanUid = rs.getString("oc_maintenanceplan_serverid")+"."+rs.getString("oc_maintenanceplan_objectid");
				//Was there an intervention action planned in the selected period?
				//Check if any existing intervention had a nextdate in this period or
				//if the last nextdate has already expired
				boolean bMaintenancePlanDue=false,bInit=false;
				PreparedStatement ps2 = conn.prepareStatement("select * from oc_maintenanceoperations where oc_maintenanceoperation_maintenanceplanuid=? and oc_maintenanceoperation_date<? order by oc_maintenanceoperation_nextdate desc");
				ps2.setString(1,maintenancePlanUid);
				ps2.setDate(2, SH.toSQLDate(begin));
				ResultSet rs2 = ps2.executeQuery();
				while(rs2.next() && !bMaintenancePlanDue){
					java.util.Date d = rs2.getDate("oc_maintenanceoperation_nextdate");
					if(d!=null && !d.before(begin) && d.before(end)){
						bMaintenancePlanDue=true;
					}
					else if(!bInit && d!=null && d.before(end)) {
						bMaintenancePlanDue=true;
					}
					else if(d!=null && d.before(begin)) {
						break;
					}
					bInit=true;
				}
				rs2.close();
				ps2.close();
				if(!bInit){
					bMaintenancePlanDue=true;
				}
				if(bMaintenancePlanDue){
					plans.add(maintenancePlanUid);
				}
			}
			rs.close();
			ps.close();
			conn.close();
			planned=plans.size();
		}
		catch(Exception e) {
			e.printStackTrace();
		}
		return planned;
	}
	
	public static SortedMap getServicesForNorm(String structure,String nomenclature){
		SortedMap norms = new TreeMap();
		Connection conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
		Connection conna = MedwanQuery.getInstance().getLongAdminConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select * from oc_standards where structure=? and nomenclature=?");
			ps.setString(1, structure);
			ps.setString(2,nomenclature);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				double quantity = rs.getDouble("quantity");
				rs.close();
				ps.close();
				ps=conna.prepareStatement("select * from services where costcenter=? order by serviceid");
				ps.setString(1, structure);
				rs=ps.executeQuery();
				while(rs.next()){
					String serviceid = rs.getString("serviceid");
					double total = 0, nonfunctional=0;
					PreparedStatement ps2 = conn.prepareStatement("select count(*) from oc_assets where (oc_asset_service=? or oc_asset_service in(?)) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and (oc_asset_comment7 is null or oc_asset_comment7='' or oc_asset_comment7<3)");
			    	Service service = Service.getService(serviceid);
					if(service.getParentcode().length()==0) {
			    		ps2 = conn.prepareStatement("select count(*) from oc_assets where (oc_asset_service=? or oc_asset_service like ?) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and (oc_asset_comment7 is null or oc_asset_comment7='' or oc_asset_comment7<3)");
			    	}
					ps2.setString(1, serviceid);
					if(service.getParentcode().length()==0) {
						ps2.setString(2, serviceid+"%");
					}
					else {
						ps2.setString(2, Service.getChildIdsAsString(serviceid));
					}
					ps2.setString(3, nomenclature);
					ps2.setString(4, nomenclature+".%");
					ps2.setTimestamp(5, new java.sql.Timestamp(new java.util.Date().getTime()));
					ResultSet rs2 = ps2.executeQuery();
					if(rs2.next()){
						total = rs2.getDouble("total");
					}
					rs2.close();
					ps2.close();
					ps2 = conn.prepareStatement("select count(*) from oc_assets where (oc_asset_service=? or oc_asset_service in(?)) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and oc_asset_comment7='3'");
					if(service.getParentcode().length()==0) {
			    		ps2 = conn.prepareStatement("select count(*) from oc_assets where (oc_asset_service=? or oc_asset_service like ?) and (oc_asset_nomenclature=? or oc_asset_nomenclature like ?) and (oc_asset_saledate is null OR oc_asset_saledate>?) and oc_asset_comment7='3'");
			    	}
					ps2.setString(1, serviceid);
					if(service.getParentcode().length()==0) {
						ps2.setString(2, serviceid+"%");
					}
					else {
						ps2.setString(2, Service.getChildIdsAsString(serviceid));
					}
					ps2.setString(3, nomenclature);
					ps2.setString(4, nomenclature+".%");
					ps2.setTimestamp(5, new java.sql.Timestamp(new java.util.Date().getTime()));
					rs2 = ps2.executeQuery();
					if(rs2.next()){
						nonfunctional = rs2.getDouble("total");
					}
					rs2.close();
					ps2.close();
					norms.put(serviceid, quantity+";"+total+";"+nonfunctional);
				}
			}
			rs.close();
			ps.close();
			conn.close();
			conna.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return norms;
	}

}
