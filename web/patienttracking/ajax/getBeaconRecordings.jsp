<%@page import="be.openclinic.system.Beacon"%>
<%@page import="be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	SortedMap<Integer,String> sm = new TreeMap<Integer,String>();
	String readerId = SH.p(request,"readerid");
	session.setAttribute("activeBLEReader", readerId);
	String showUnidentified = SH.p(request,"showunidentified");
	String showUnlinked = SH.p(request,"showunlinked");
	Connection conn = SH.getOpenClinicConnection();
	String sSql="select max(a.oc_beacon_updatetime) oc_beacon_updatetime, a.oc_beacon_id, b.oc_beacon_alias, b.oc_beacon_comment, b.oc_beacon_resourcetype, b.oc_beacon_resourceid"+
			" from oc_beacon_recordings a,oc_beacons b where "+
			" a.oc_beacon_readerid=? and"+
			" a.oc_beacon_id=b.oc_beacon_id and"+
			" a.oc_beacon_updatetime>? and "+
			" a.oc_beacon_movement in (0,2) and"+
			" b.oc_beacon_resourcetype='patient'"+
			" group by a.oc_beacon_id,b.oc_beacon_alias,b.oc_beacon_comment,b.oc_beacon_resourcetype,b.oc_beacon_resourceid";
	if(showUnidentified.equalsIgnoreCase("true")){
		sSql="select max(oc_beacon_updatetime) oc_beacon_updatetime, oc_beacon_id, (select max(oc_beacon_alias) from oc_beacons b where b.oc_beacon_id=a.oc_beacon_id) oc_beacon_alias, (select max(oc_beacon_comment) from oc_beacons b where b.oc_beacon_id=a.oc_beacon_id) oc_beacon_comment,'' as oc_beacon_resourcetype,'' as oc_beacon_resourceid"+
				" from oc_beacon_recordings a where "+
				" oc_beacon_readerid=? and"+
				" oc_beacon_updatetime>? and "+
				" oc_beacon_movement in (0,2)"+
				" group by oc_beacon_id,oc_beacon_alias,oc_beacon_comment,oc_beacon_resourcetype,oc_beacon_resourceid";
	}
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setString(1,readerId);
	ps.setTimestamp(2, SH.getSQLTimestamp(new java.util.Date(new java.util.Date().getTime()-SH.getTimeMinute()*SH.ci("bleGatwewayResetTimeInMinutes", 5))));
	ResultSet rs = ps.executeQuery();
	int counter=1;
	while(rs.next()){
		if(!showUnidentified.equalsIgnoreCase("true") && !showUnlinked.equalsIgnoreCase("true") && SH.c(rs.getString("oc_beacon_resourceid")).length()==0){
			continue;
		}
		String beaconId = rs.getString("oc_beacon_id");
		String beaconAlias = SH.c(rs.getString("oc_beacon_alias"));
		String beaconComment = SH.c(rs.getString("oc_beacon_comment"));
		String beaconType = SH.c(rs.getString("oc_beacon_resourcetype"));
		String beaconRefId = SH.c(rs.getString("oc_beacon_resourceid"));
		java.util.Date in = null;
		int rssi=0;
		java.sql.Timestamp ts = rs.getTimestamp("oc_beacon_updatetime");
		PreparedStatement ps2 = conn.prepareStatement("select * from oc_beacon_recordings where "+
						" oc_beacon_id=? and"+
						" oc_beacon_readerid=? and"+
						" oc_beacon_updatetime>=?"+
						" order by oc_beacon_objectid desc");
		ps2.setString(1,beaconId);
		ps2.setString(2,readerId);
		ps2.setTimestamp(3, ts);
		ResultSet rs2 = ps2.executeQuery();
		if(rs2.next()){
			rssi=rs2.getInt("oc_beacon_rssi");
			if(rs2.getInt("oc_beacon_movement")==1){
				continue;
			}
			else if(rs2.getInt("oc_beacon_movement")==0){
				in=rs2.getTimestamp("oc_beacon_updatetime");
			}
			else if(rs2.getInt("oc_beacon_movement")==2){
				PreparedStatement ps3 = conn.prepareStatement("select max(oc_beacon_updatetime) oc_beacon_updatetime,avg(oc_beacon_rssi) oc_beacon_rssi from oc_beacon_recordings where"+
						" oc_beacon_id=? and"+
						" oc_beacon_readerid=? and"+
						" oc_beacon_updatetime<? and"+
						" oc_beacon_movement=0");
				ps3.setString(1,beaconId);
				ps3.setString(2,readerId);
				ps3.setTimestamp(3, rs2.getTimestamp("oc_beacon_updatetime"));
				ResultSet rs3 = ps3.executeQuery();
				if(rs3.next()){
					in=rs3.getTimestamp("oc_beacon_updatetime");
				}
				rs3.close();
				ps3.close();
			}	
			String type="";
			String comment = beaconComment;
			if(beaconType.equalsIgnoreCase("patient")){
				type="<img style='vertical-align: middle' height='24px' src='"+sCONTEXTPATH+"/_img/icons/mobile/patient.png'/>";
				comment="<a style='font-weight: bolder;color: darkblue' href='javascript:openPatientRecord("+beaconRefId+")'>"+beaconComment+"</a>";
			}
			sm.put(-rssi*10000-counter++,"<td class='admin2'>"+beaconId+"</td><td class='admin2'><b>"+beaconAlias+"</b></td><td class='admin2'><b>"+type+" "+comment+"</b></td><td class='admin2'>"+rssi+" dB</td><td class='admin2'>"+SH.formatDate(in,"dd/MM/yyyy HH:mm:ss")+"</td><td class='admin2'><b>"+SH.getTimeBetween(in, new java.util.Date(),sWebLanguage)+"</b></td></tr>");
		}
		rs2.close();
		ps2.close();
	}
	rs.close();
	ps.close();
	conn.close();
	counter=1;
	Iterator<Integer> iSm = sm.keySet().iterator();
	while(iSm.hasNext()){
		int key = iSm.next();
		out.println("<tr><td class='admin2'>"+counter+++"</td>"+sm.get(key));
	}
%>
