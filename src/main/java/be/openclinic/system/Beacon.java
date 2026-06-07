package be.openclinic.system;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Vector;

import javax.json.JsonArray;
import javax.json.JsonObject;

import be.mxs.common.util.db.MedwanQuery;

public class Beacon {
	private String id;
	private String alias;
	private String resourceType;
	private String resourceId;
	private String comment;
	private java.util.Date updatetime;
	
	public java.util.Date getUpdatetime() {
		return updatetime;
	}
	public void setUpdatetime(java.util.Date updatetime) {
		this.updatetime = updatetime;
	}
	public String getId() {
		return id;
	}
	public void setId(String id) {
		this.id = id;
	}
	public String getAlias() {
		return alias;
	}
	public void setAlias(String alias) {
		this.alias = alias;
	}
	public String getResourceType() {
		return resourceType;
	}
	public void setResourceType(String resourceType) {
		this.resourceType = resourceType;
	}
	public String getResourceId() {
		return resourceId;
	}
	public void setResourceId(String resourceId) {
		this.resourceId = resourceId;
	}
	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
	
	public static int storeRecordings(JsonObject jo,String readerHeader) {
		int numberOfBeacons=0;
		Connection conn = SH.getOpenClinicConnection();
		try {
			PreparedStatement ps = null;
			String gatewayId = "";
			java.sql.Timestamp ts = SH.getSQLTime();
			JsonArray data = jo.getJsonArray("data");
			HashMap<String,Integer> beaconRSSIs = new HashMap<String,Integer>();
			for(int n=0;n<data.size();n++) {
				numberOfBeacons++;
				JsonObject recording = data.getJsonObject(n);
				String beaconId = recording.getString("tag");
				gatewayId = recording.getString("gw");
				if(n==0 && SH.c(readerHeader).split(":").length>1) {
					//Check registration of the gateway
					Beacon reader = Beacon.get(gatewayId);
					if(reader==null || SH.c(reader.getResourceType()).length()==0) {
						reader = new Beacon();
						reader.setId(gatewayId);
						reader.setAlias(readerHeader.split(":")[0]);
						reader.setResourceType("reader");
						reader.setResourceId(readerHeader.split(":")[0]);
						reader.setComment(readerHeader.split(":")[1]);
						reader.setUpdatetime(ts);
						reader.store();
					}
				}
				int rssi = recording.getInt("rssi");
				beaconRSSIs.put(beaconId,rssi);
				//Exclude beacons with a too weak signal
				if(rssi<SH.ci("bleBeaconTreshhold", -70)) {
					continue;
				}
				Beacon beacon = Beacon.get(beaconId);
				try {
					ResultSet rs=null;
					//Here we only handle registered patient beacons
					if(beacon!=null && beacon.getResourceType().equalsIgnoreCase("patient")) {
						//First check if there hasn't been a recording for this beacon with a higher rssi less than x seconds
						//ago on another gateway
						ps=conn.prepareStatement ("select * from oc_beacon_recordings where oc_beacon_id=? and OC_BEACON_UPDATETIME>? and oc_beacon_readerid<>? order by oc_beacon_objectid desc");
						ps.setString(1, beaconId);
						ps.setTimestamp(2, new java.sql.Timestamp(ts.getTime()-SH.getTimeSecond()*SH.ci("bleGatwewayOverlapTimeInSeconds", 30)));
						ps.setString(3, gatewayId);
						rs = ps.executeQuery();
						if(rs.next()) {
							if(rs.getInt("oc_beacon_rssi")>=rssi-SH.ci("bleRSSIDifferenceTreshhold", 10)  && rs.getInt("oc_beacon_movement")!=1) {
								//An active registration for this beacon with STRONGER rssi exists for another gateway
								//less than x seconds ago. Discard this recording because it is an overlap and this is
								//the weakest signal of the two gateways
								rs.close();
								ps.close();
								continue;
							}
							else if(rs.getInt("oc_beacon_rssi")<rssi-SH.ci("bleRSSIDifferenceTreshhold", 10) && rs.getInt("oc_beacon_movement")==0){ 
								//IN on other weaker gateway
								//An active registration for this beacon with WEAKER rssi exists for another gateway
								//less than x seconds ago. Close the other recording because it is an overlap and this is
								//the strongest signal of the two gateways
								PreparedStatement ps2 = conn.prepareStatement("insert into OC_BEACON_RECORDINGS(OC_BEACON_ID,OC_BEACON_RESOURCETYPE,OC_BEACON_RESOURCEID,OC_BEACON_READERID,OC_BEACON_RSSI,OC_BEACON_EXITCOUNTER,OC_BEACON_MOVEMENT,OC_BEACON_UPDATETIME,OC_BEACON_OBJECTID,OC_BEACON_TS) values(?,?,?,?,?,?,?,?,?,?)");
								ps2.setString(1, rs.getString("OC_BEACON_ID"));
								ps2.setString(2, rs.getString("OC_BEACON_RESOURCETYPE"));
								ps2.setString(3, rs.getString("OC_BEACON_RESOURCEID"));
								ps2.setString(4, rs.getString("OC_BEACON_READERID"));
								ps2.setInt(5, rs.getInt("OC_BEACON_RSSI"));
								ps2.setInt(6, 0);
								ps2.setInt(7, 1); //OUT
								ps2.setTimestamp(8, rs.getTimestamp("OC_BEACON_UPDATETIME"));
								ps2.setInt(9, MedwanQuery.getInstance().getOpenclinicCounter("OC_BEACON_OBJECTID"));
								ps2.setTimestamp(10, SH.getSQLTime());
								ps2.execute();
								ps2.close();
							}
							else if(rs.getInt("oc_beacon_rssi")<rssi-SH.ci("bleRSSIDifferenceTreshhold", 10) && rs.getInt("oc_beacon_movement")==2){ 
								//SEEN on other weaker gateway
								//An active registration for this beacon with WEAKER rssi exists for another gateway
								//less than x seconds ago. Close the other recording because it is an overlap and this is
								//the strongest signal of the two gateways
								PreparedStatement ps2 = conn.prepareStatement("update OC_BEACON_RECORDINGS set OC_BEACON_UPDATETIME=?,OC_BEACON_RSSI=?,OC_BEACON_TS=?,OC_BEACON_EXITCOUNTER=1 where OC_BEACON_OBJECTID=?");
								ps2.setTimestamp(1, rs.getTimestamp("OC_BEACON_UPDATETIME"));
								ps2.setInt(2, rs.getInt("OC_BEACON_RSSI"));
								ps2.setTimestamp(3, SH.getSQLTime());
								ps2.setInt(4, rs.getInt("OC_BEACON_OBJECTID"));
								ps2.execute();
								ps2.close();
							}
						}
						rs.close();
						ps.close();
					}
					//Now check if this is a new or an existing record on the gateway
					boolean bEntered = false;
					ps=conn.prepareStatement("select * from OC_BEACON_RECORDINGS where OC_BEACON_ID=? and OC_BEACON_READERID=? and OC_BEACON_UPDATETIME>? order by OC_BEACON_OBJECTID DESC");
					ps.setString(1, beaconId);
					ps.setString(2, gatewayId);
					ps.setTimestamp(3, new java.sql.Timestamp(ts.getTime()-SH.getTimeMinute()*SH.ci("bleGatewayResetTimeInMinutes", 5)));
					rs = ps.executeQuery();
					if(rs.next()) {
						//The beacon is already active on this gateway
						if(rs.getInt("OC_BEACON_MOVEMENT")==0) {
							bEntered=true;
							//Switch from "IN" to "SEEN"
							PreparedStatement ps2 = conn.prepareStatement("insert into OC_BEACON_RECORDINGS(OC_BEACON_ID,OC_BEACON_RESOURCETYPE,OC_BEACON_RESOURCEID,OC_BEACON_READERID,OC_BEACON_RSSI,OC_BEACON_EXITCOUNTER,OC_BEACON_MOVEMENT,OC_BEACON_UPDATETIME,OC_BEACON_OBJECTID,OC_BEACON_TS) values(?,?,?,?,?,?,?,?,?,?)");
							ps2.setString(1, beaconId);
							ps2.setString(2, beacon!=null?beacon.resourceType:"");
							ps2.setString(3, beacon!=null?beacon.resourceId:"");
							ps2.setString(4, gatewayId);
							ps2.setInt(5, rssi);
							ps2.setInt(6, 0);
							ps2.setInt(7, 2); //SEEN
							ps2.setTimestamp(8, ts);
							ps2.setInt(9, MedwanQuery.getInstance().getOpenclinicCounter("OC_BEACON_OBJECTID"));
							ps2.setTimestamp(10, SH.getSQLTime());
							ps2.execute();
							ps2.close();
						}
						else if(rs.getInt("OC_BEACON_MOVEMENT")==2){
							bEntered=true;
							//Update "SEEN"
							PreparedStatement ps2 = conn.prepareStatement("update OC_BEACON_RECORDINGS set OC_BEACON_UPDATETIME=?,OC_BEACON_RSSI=?,OC_BEACON_TS=?,OC_BEACON_EXITCOUNTER=0 where OC_BEACON_OBJECTID=?");
							ps2.setTimestamp(1, ts);
							ps2.setInt(2, rssi);
							ps2.setTimestamp(3, SH.getSQLTime());
							ps2.setInt(4, rs.getInt("OC_BEACON_OBJECTID"));
							ps2.execute();
							ps2.close();
						}
					}
					rs.close();
					ps.close();
					if(!bEntered) {
						//The beacon is not yet registered on this gateway
						//Register "IN" and if last registration for this beacon id is not "OUT", add it
						PreparedStatement ps2 = conn.prepareStatement("select * from oc_beacon_recordings where oc_beacon_id=? order by oc_beacon_objectid desc limit 1");
						ps2.setString(1, beaconId);
						ResultSet rs2 = ps2.executeQuery();
						if(rs2.next()) {
							if(rs2.getInt("oc_beacon_movement")==0) {
								PreparedStatement ps3 = conn.prepareStatement("insert into OC_BEACON_RECORDINGS(OC_BEACON_ID,OC_BEACON_RESOURCETYPE,OC_BEACON_RESOURCEID,OC_BEACON_READERID,OC_BEACON_RSSI,OC_BEACON_EXITCOUNTER,OC_BEACON_MOVEMENT,OC_BEACON_UPDATETIME,OC_BEACON_OBJECTID,OC_BEACON_TS) values(?,?,?,?,?,?,?,?,?,?)");
								ps3.setString(1, rs2.getString("OC_BEACON_ID"));
								ps3.setString(2, rs2.getString("OC_BEACON_RESOURCETYPE"));
								ps3.setString(3, rs2.getString("OC_BEACON_RESOURCEID"));
								ps3.setString(4, rs2.getString("OC_BEACON_READERID"));
								ps3.setInt(5, rs2.getInt("OC_BEACON_RSSI"));
								ps3.setInt(6, 0);
								ps3.setInt(7, 1); //OUT
								ps3.setTimestamp(8, rs2.getTimestamp("OC_BEACON_UPDATETIME"));
								ps3.setInt(9, MedwanQuery.getInstance().getOpenclinicCounter("OC_BEACON_OBJECTID"));
								ps3.setTimestamp(10, SH.getSQLTime());
								ps3.execute();
								ps3.close();
							}
							else if(rs2.getInt("oc_beacon_movement")==2) {
								PreparedStatement ps3 = conn.prepareStatement("update OC_BEACON_RECORDINGS set OC_BEACON_TS=?,OC_BEACON_MOVEMENT=1 where OC_BEACON_OBJECTID=?");
								ps3.setTimestamp(1, SH.getSQLTime());
								ps3.setInt(2,rs2.getInt("OC_BEACON_OBJECTID"));
								ps3.execute();
								ps3.close();
							}
						}
						rs2.close();
						ps2.close();
						ps2 = conn.prepareStatement("insert into OC_BEACON_RECORDINGS(OC_BEACON_ID,OC_BEACON_RESOURCETYPE,OC_BEACON_RESOURCEID,OC_BEACON_READERID,OC_BEACON_RSSI,OC_BEACON_EXITCOUNTER,OC_BEACON_MOVEMENT,OC_BEACON_UPDATETIME,OC_BEACON_OBJECTID,OC_BEACON_TS) values(?,?,?,?,?,?,?,?,?,?)");
						ps2.setString(1, beaconId);
						ps2.setString(2, beacon!=null?beacon.resourceType:"");
						ps2.setString(3, beacon!=null?beacon.resourceId:"");
						ps2.setString(4, gatewayId);
						ps2.setInt(5, rssi);
						ps2.setInt(6, 0);
						ps2.setInt(7, 0); //IN
						ps2.setTimestamp(8, ts);
						ps2.setInt(9, MedwanQuery.getInstance().getOpenclinicCounter("OC_BEACON_OBJECTID"));
						ps2.setTimestamp(10, SH.getSQLTime());
						ps2.execute();
						ps2.close();
					}
					
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
			if(gatewayId.length()>0) {
				//Now retrieve all existing records on the gateway which have not been detected this time
				try {
					ps=conn.prepareStatement("select max(OC_BEACON_UPDATETIME) OC_BEACON_UPDATETIME,OC_BEACON_ID,OC_BEACON_RESOURCEID from OC_BEACON_RECORDINGS where OC_BEACON_READERID=? and OC_BEACON_MOVEMENT in (0,2) group by OC_BEACON_ID,OC_BEACON_RESOURCEID having max(OC_BEACON_UPDATETIME)<?");
					ps.setString(1, gatewayId);
					ps.setTimestamp(2, ts);
					ResultSet rs = ps.executeQuery();
					while(rs.next()) {
						//Exclude beacons with weak but visible signal
						if(beaconRSSIs.get(rs.getString("OC_BEACON_ID"))!=null && beaconRSSIs.get(rs.getString("OC_BEACON_ID"))>SH.ci("bleBeaconExitRSSITreshhold", SH.ci("bleBeaconTreshhold", -70)-15)) {
							continue;
						}
						//First check which was the last movement
						PreparedStatement ps2 = conn.prepareStatement("select * from OC_BEACON_RECORDINGS where OC_BEACON_ID=? and OC_BEACON_READERID=? and OC_BEACON_UPDATETIME>=? order by OC_BEACON_OBJECTID DESC");
						ps2.setString(1,rs.getString("OC_BEACON_ID"));
						ps2.setString(2,gatewayId);
						ps2.setTimestamp(3, rs.getTimestamp("OC_BEACON_UPDATETIME"));
						ResultSet rs2 = ps2.executeQuery();
						if(rs2.next()) {
							//Only handle data if a minimum number of seconds since last registration
							if(rs2.getTimestamp("OC_BEACON_TS")!=null && new java.util.Date().before(new java.util.Date(rs2.getTimestamp("OC_BEACON_TS").getTime()+SH.ci("bleMinimumDataIntervalInSeconds", 5)*SH.getTimeSecond()))){
								rs2.close();
								ps2.close();
								continue;
							}
							if(rs2.getInt("OC_BEACON_MOVEMENT")==0) {
								//Last movement was entry. Therefore add exit
								if(rs2.getInt("OC_BEACON_EXITCOUNTER")>SH.ci("bleExitCounterTreshhold",6)-1) {
									//Add an exit record
									PreparedStatement ps3 = conn.prepareStatement("insert into OC_BEACON_RECORDINGS(OC_BEACON_ID,OC_BEACON_RESOURCETYPE,OC_BEACON_RESOURCEID,OC_BEACON_READERID,OC_BEACON_RSSI,OC_BEACON_EXITCOUNTER,OC_BEACON_MOVEMENT,OC_BEACON_UPDATETIME,OC_BEACON_OBJECTID,OC_BEACON_TS) values(?,?,?,?,?,?,?,?,?,?)");
									ps3.setString(1, rs2.getString("OC_BEACON_ID"));
									ps3.setString(2, rs2.getString("OC_BEACON_RESOURCETYPE"));
									ps3.setString(3, rs2.getString("OC_BEACON_RESOURCEID"));
									ps3.setString(4, gatewayId);
									ps3.setInt(5, rs2.getInt("OC_BEACON_RSSI"));
									ps3.setInt(6, 0);
									ps3.setInt(7, 1); //OUT
									ps3.setTimestamp(8, rs2.getTimestamp("OC_BEACON_UPDATETIME"));
									ps3.setInt(9, MedwanQuery.getInstance().getOpenclinicCounter("OC_BEACON_OBJECTID"));
									ps3.setTimestamp(10, SH.getSQLTime());
									ps3.execute();
									ps3.close();
								}
								else {
									//Increase OC_BEACON_EXITCOUNTER
									PreparedStatement ps3 = conn.prepareStatement("update OC_BEACON_RECORDINGS set OC_BEACON_TS=?,OC_BEACON_EXITCOUNTER=OC_BEACON_EXITCOUNTER+1 where OC_BEACON_OBJECTID=?");
									ps3.setTimestamp(1, SH.getSQLTime());
									ps3.setInt(2,rs2.getInt("OC_BEACON_OBJECTID"));
									ps3.execute();
									ps3.close();
								}
							}
							else if(rs2.getInt("OC_BEACON_MOVEMENT")==1) {
								//Last movement was exit. Therefore do nothing
							}
							else if(rs2.getInt("OC_BEACON_MOVEMENT")==2) {
								//Last movement was seen. Therefore change to exit;
								if(rs2.getInt("OC_BEACON_EXITCOUNTER")>SH.ci("bleExitCounterTreshhold",6)-1) {
									//Change this record as the exit moment
									PreparedStatement ps3 = conn.prepareStatement("update OC_BEACON_RECORDINGS set OC_BEACON_TS=?,OC_BEACON_MOVEMENT=1 where OC_BEACON_OBJECTID=?");
									ps3.setTimestamp(1, SH.getSQLTime());
									ps3.setInt(2,rs2.getInt("OC_BEACON_OBJECTID"));
									ps3.execute();
									ps3.close();
								}
								else {
									//Increase OC_BEACON_EXITCOUNTER
									PreparedStatement ps3 = conn.prepareStatement("update OC_BEACON_RECORDINGS set OC_BEACON_TS=?,OC_BEACON_EXITCOUNTER=OC_BEACON_EXITCOUNTER+1 where OC_BEACON_OBJECTID=?");
									ps3.setTimestamp(1, SH.getSQLTime());
									ps3.setInt(2,rs2.getInt("OC_BEACON_OBJECTID"));
									ps3.execute();
									ps3.close();
								}
							}
						}
						rs2.close();
						ps2.close();
					}
					rs.close();
					ps.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		catch(Exception y) {
			y.printStackTrace();
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return numberOfBeacons;
	}
	public static Beacon get(String id) {
		Beacon beacon = null;
		if(SH.c(id).length()>0) {
			Connection conn = SH.getOpenClinicConnection();
			try {
				PreparedStatement ps = conn.prepareStatement("select * from oc_beacons where oc_beacon_id=?");
				ps.setString(1, id);
				ResultSet rs = ps.executeQuery();
				if(rs.next()) {
					beacon=new Beacon();
					beacon.setId(rs.getString("oc_beacon_id"));
					beacon.setAlias(rs.getString("oc_beacon_alias"));
					beacon.setResourceType(rs.getString("oc_beacon_resourcetype"));
					beacon.setResourceId(rs.getString("oc_beacon_resourceid"));
					beacon.setComment(rs.getString("oc_beacon_comment"));
					beacon.setUpdatetime(rs.getTimestamp("oc_beacon_updatetime"));
				}
				rs.close();
				ps.close();
				conn.close();
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}
		return beacon;
	}
	
	public static Beacon getByAlias(String alias) {
		Beacon beacon = null;
		if(SH.c(alias).length()>0) {
			Connection conn = SH.getOpenClinicConnection();
			try {
				PreparedStatement ps = conn.prepareStatement("select * from oc_beacons where oc_beacon_alias=?");
				ps.setString(1, alias);
				ResultSet rs = ps.executeQuery();
				if(rs.next()) {
					beacon=new Beacon();
					beacon.setId(rs.getString("oc_beacon_id"));
					beacon.setAlias(rs.getString("oc_beacon_alias"));
					beacon.setResourceType(rs.getString("oc_beacon_resourcetype"));
					beacon.setResourceId(rs.getString("oc_beacon_resourceid"));
					beacon.setComment(rs.getString("oc_beacon_comment"));
					beacon.setUpdatetime(rs.getTimestamp("oc_beacon_updatetime"));
				}
				rs.close();
				ps.close();
				conn.close();
			}
			catch(Exception e) {
				e.printStackTrace();
			}
		}
		return beacon;
	}
	
	public boolean store() {
		if(SH.c(getId()).length()>0) {
			Connection conn = SH.getOpenClinicConnection();
			try {
				delete(getId());
				PreparedStatement ps=conn.prepareStatement("insert into oc_beacons(oc_beacon_id,oc_beacon_alias,oc_beacon_resourcetype,oc_beacon_resourceid,oc_beacon_comment,oc_beacon_updatetime) values(?,?,?,?,?,?)");
				ps.setString(1, getId());
				ps.setString(2, getAlias());
				ps.setString(3, getResourceType());
				ps.setString(4, getResourceId());
				ps.setString(5, getComment());
				ps.setTimestamp(6, SH.getSQLTimestamp(new java.util.Date()));
				ps.execute();
				ps.close();
				conn.close();
				return true;
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return false;
	}
	
	public static boolean delete(String id) {
		if(SH.c(id).length()>0) {
			Connection conn = SH.getOpenClinicConnection();
			try {
				PreparedStatement ps = conn.prepareStatement("delete from oc_beacons where oc_beacon_id=?");
				ps.setString(1, id);
				ps.execute();
				ps.close();
				conn.close();
				return true;
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return false;
	}
	
	public static Vector<Beacon> getList(String id, String alias, String type){
		Vector<Beacon> list = new Vector<Beacon>();
		Connection conn = SH.getOpenClinicConnection();
		try {
			String sql = "select distinct b.* from oc_beacons b,oc_beacon_recordings r where b.oc_beacon_id=r.oc_beacon_id";
			if(SH.c(id).length()==0 && SH.c(alias).length()==0 && SH.c(type).length()==0) {
				sql+=" and b.oc_beacon_updatetime>?";
			}
			else {
				sql="select * from oc_beacons where 1=1";
				if(SH.c(id).length()>0) {
					sql+=" and oc_beacon_id=?";
				}
				if(SH.c(alias).length()>0) {
					sql+=" and oc_beacon_alias like ?";
				}
				if(SH.c(type).length()>0) {
					sql+=" and oc_beacon_resourcetype=?";
				}
			}
			sql+=" order by oc_beacon_alias";
			PreparedStatement ps = conn.prepareStatement(sql);
			if(SH.c(id).length()==0 && SH.c(alias).length()==0 && SH.c(type).length()==0) {
				ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()-SH.cl("deafultBeaconActivityPeriodShow", SH.getTimeDay()*7)));
			}
			else {
				sql="select * from oc_beacons where 1=1";
				int i=1;
				if(SH.c(id).length()>0) {
					ps.setString(i++, id);
				}
				if(SH.c(alias).length()>0) {
					ps.setString(i++, "%"+alias+"%");
				}
				if(SH.c(type).length()>0) {
					ps.setString(i++, type);
				}
			}
			ResultSet rs = ps.executeQuery();
			while(rs.next()) {
				Beacon beacon = new Beacon();
				beacon.setId(rs.getString("oc_beacon_id"));
				beacon.setAlias(rs.getString("oc_beacon_alias"));
				beacon.setResourceType(rs.getString("oc_beacon_resourcetype"));
				beacon.setResourceId(rs.getString("oc_beacon_resourceid"));
				beacon.setComment(rs.getString("oc_beacon_comment"));
				beacon.setUpdatetime(rs.getTimestamp("oc_beacon_updatetime"));
				list.add(beacon);
			}
			rs.close();
			ps.close();
			conn.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return list;
	}

}
