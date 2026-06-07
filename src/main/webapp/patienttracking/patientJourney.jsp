<%@page import="be.openclinic.system.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran(request,"web","reader",sWebLanguage) %></td>
		<td>RSSI</td>
		<td><%=getTran(request,"web","timeelapsed",sWebLanguage) %></td>
		<td><%=getTran(request,"web","from",sWebLanguage) %></td>
		<td><%=getTran(request,"web","to",sWebLanguage) %></td>
	</tr>
<%
	Vector<BeaconRecording> recordings = new Vector<BeaconRecording>();
	Connection conn = SH.getOpenClinicConnection();
	String sSql="select * from oc_beacon_recordings where oc_beacon_resourcetype='patient' and oc_beacon_resourceid=? and"+
		" oc_beacon_updatetime>? order by oc_beacon_objectid desc";
	java.sql.Timestamp now = SH.getSQLTime();
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setString(1,activePatient.personid);
	ps.setTimestamp(2,new java.sql.Timestamp(now.getTime()-SH.ci("deafultPatientJourneyTimeInDays",7)*SH.getTimeDay()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		BeaconRecording recording = new BeaconRecording();
		recording.setBeaconId(rs.getString("oc_beacon_id"));
		recording.setReaderId(rs.getString("oc_beacon_readerid"));
		recording.setResourceType(rs.getString("oc_beacon_resourcetype"));
		recording.setResourceId(rs.getString("oc_beacon_resourceid"));
		recording.setMovement(rs.getInt("oc_beacon_movement"));
		recording.setRssi(rs.getInt("oc_beacon_rssi"));
		recording.setExitCounter(rs.getInt("oc_beacon_exitcounter"));
		recording.setUpdatetime(rs.getTimestamp("oc_beacon_updatetime"));
		recordings.add(recording);
	}
	rs.close();
	ps.close();
	HashMap<String,String> readers = new HashMap<String,String>();
	ps=conn.prepareStatement("select * from oc_beacons where oc_beacon_resourcetype='reader'");
	rs=ps.executeQuery();
	while(rs.next()){
		readers.put(rs.getString("oc_beacon_id"),rs.getString("oc_beacon_comment"));
	}
	rs.close();
	ps.close();
	conn.close();
	java.util.Date previousOutTime =now;
	java.util.Date previousInTime =null;
	boolean bInit=false;
	int c=0;
	for(int n=0;n<recordings.size();n++){
		BeaconRecording recording = recordings.elementAt(n);
		if(c++<20){
			//SH.syslog(recording.getReaderId()+"/"+recording.getMovement()+"/"+SH.formatDate(recording.getUpdatetime(),"mm:ss.SSS"));
		}
		if(recording.getMovement()==1){
			previousOutTime=recording.getUpdatetime();
			if(bInit){
				out.println("<tr><td colspan='4' height='22px'><center><img height='20px' style='vertical-align: middle' src='"+sCONTEXTPATH+"/_img/icons/running-man.png'/> <i>"+getTran(request,"web","shift",sWebLanguage)+": <b>"+SH.getTimeBetween(previousOutTime, previousInTime, sWebLanguage)+"</b></i></center></td></tr>");
			}
		}
		else if(recording.getMovement()==0){
			previousInTime=recording.getUpdatetime();
			out.println("<tr><td class='admin"+(previousOutTime.equals(now)?"green":"")+"'><b>"+readers.get(recording.getReaderId())+"</b></td>"+
					"<td class='admin2'>"+recording.getRssi()+"dB</td>"+
					"<td class='admin2'><b>"+SH.getTimeBetween(recording.getUpdatetime(), previousOutTime, sWebLanguage)+"</b></td>"+
					"<td class='admin2'>"+SH.formatDate(recording.getUpdatetime(),"dd/MM/yyyy HH:mm:ss")+"</td>"+
					"<td class='admin2'>"+(previousOutTime.equals(now)?getTran(request,"web","now",sWebLanguage):SH.formatDate(previousOutTime,"dd/MM/yyyy HH:mm:ss"))+"</td></tr>"
						);
		}
		bInit=true;
	}
	
%>
</table>