<%@page import="be.openclinic.medical.Diagnosis"%>
<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.system.Beacon"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'><td colspan='6'><%=getTran(request,"web","services",sWebLanguage) %></td></tr>
</table>
<table width='100%' class="sortable" id="readerTable">
	<tr class='admin'>
		<td><%=getTran(request,"web","reader",sWebLanguage) %></td>
		<td><%=getTran(request,"web","entries",sWebLanguage) %></td>
		<td colspan="2"><%=getTran(request,"web","averagedelay",sWebLanguage) %></td>
		<td colspan='2'><%=getTran(request,"web","totaldelay",sWebLanguage) %></td>
	</tr>
<%
	String icd10 = SH.p(request,"icd10");
	String begin = SH.p(request,"begin");
	String end = SH.p(request,"end");
	
	Connection conn = SH.getOpenClinicConnection();
	String sSql = "select oc_beacon_resourceid,oc_beacon_readerid,oc_beacon_movement,oc_beacon_updatetime"+
				  " FROM oc_beacon_recordings where oc_beacon_resourcetype='patient' and oc_beacon_updatetime>=?"+
				  " and oc_beacon_updatetime<? ORDER BY oc_beacon_resourceid,oc_beacon_updatetime";
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setDate(1, SH.getSQLDate(begin));
	ps.setDate(2, SH.getSQLDate(end));
	ResultSet rs = ps.executeQuery();
	String activepersonid = "";
	String activereader = "";
	int activemovement = -1;
	long time = 0;
	Hashtable<String,Vector<Long>> stays = new Hashtable<String,Vector<Long>>();
	Hashtable<String,Vector<Long>> journeys = new Hashtable<String,Vector<Long>>();
	while(rs.next()){
		String personid=rs.getString("oc_beacon_resourceid");
		String reader = rs.getString("oc_beacon_readerid");
		int movement = rs.getInt("oc_beacon_movement");
		if(!personid.equalsIgnoreCase(activepersonid)){
			//First check if the new patient is eligible
			if(icd10.length()>0){
				Vector<Diagnosis> diagnoses = Diagnosis.getPatientDiagnoses("", "icd10", personid, SH.getDateAdd(rs.getTimestamp("oc_beacon_updatetime"),-SH.getTimeDay()*7), SH.getDateAdd(rs.getTimestamp("oc_beacon_updatetime"),SH.getTimeDay()*7));
				boolean bOK=false;
				for(int n=0;n<diagnoses.size();n++){
					Diagnosis diagnosis = diagnoses.elementAt(n);
					String[] icdcodes = icd10.split(";");
					for(int i=0;i<icdcodes.length && !bOK;i++){
						if(icdcodes[i].contains("-")){
							bOK=diagnosis.getCode().toLowerCase().trim().compareTo(icdcodes[i].split("-")[0].toLowerCase().trim())>-1 && diagnosis.getCode().toLowerCase().trim().compareTo(icdcodes[i].split("-")[1].toLowerCase().trim())<1;
						}
						else{
							bOK=diagnosis.getCode().toLowerCase().trim().startsWith(icdcodes[i].toLowerCase().trim());
						}
					}
				}
				if(!bOK){
					continue;
				}
			}
			//Change of patient
			activepersonid=personid;
			activereader=reader;
			if(movement==0){
				activemovement=0;
				time=rs.getTimestamp("oc_beacon_updatetime").getTime();
			}
		}
		else if(!activereader.equalsIgnoreCase(reader)){
			//Change of reader
			if(activemovement==0 && movement==0){
				//Patient left the previous reader (no exit registered)
				if(stays.get(activereader)==null){
					stays.put(activereader, new Vector<Long>());
				}
				Vector<Long> v = stays.get(activereader);
				v.add(rs.getTimestamp("oc_beacon_updatetime").getTime()-time);
				activemovement=0;
			}
			else if(movement==0){
				activemovement=0;
				if(journeys.get(activereader+";"+reader)==null){
					journeys.put(activereader+";"+reader, new Vector<Long>());
				}
				Vector<Long> v = journeys.get(activereader+";"+reader);
				v.add(rs.getTimestamp("oc_beacon_updatetime").getTime()-time);
				activemovement=0;
				time=rs.getTimestamp("oc_beacon_updatetime").getTime();
			}
			activereader=reader;
		}
		else{
			//Change of movement
			if(activemovement==0 && movement==1){
				//Patient leaves the reader
				if(stays.get(activereader)==null){
					stays.put(activereader, new Vector<Long>());
				}
				Vector<Long> v = stays.get(activereader);
				v.add(rs.getTimestamp("oc_beacon_updatetime").getTime()-time);
				activemovement=1;
				time=rs.getTimestamp("oc_beacon_updatetime").getTime();
			}
			else if(activemovement==1 && movement==0){
				//Patient re-enters the same reader
				activemovement =0;
				time=rs.getTimestamp("oc_beacon_updatetime").getTime();
			}
		}
	}
	rs.close();
	ps.close();
	Hashtable<String,String> readers = new Hashtable<String,String>();
	sSql="select * from oc_beacons where oc_beacon_resourcetype='reader'";
	ps=conn.prepareStatement(sSql);
	rs=ps.executeQuery();
	while(rs.next()){
		readers.put(rs.getString("oc_beacon_id"),SH.c(rs.getString("oc_beacon_comment"))+" ["+SH.c(rs.getString("oc_beacon_alias"))+"]");
	}
	rs.close();
	ps.close();
	
	Enumeration<String> eStays= stays.keys();
	while(eStays.hasMoreElements()){
		String reader = eStays.nextElement();
		Vector<Long> v = stays.get(reader);
		Collections.sort(v);
		long sum = 0,min=-1,max=0,median=-1;
		for(int n=0;n<v.size();n++){
			sum+=v.elementAt(n);
			if(v.elementAt(n)>max){
				max=v.elementAt(n);
			}
			if(min==-1 || v.elementAt(n)<min){
				min=v.elementAt(n);
			}
			if(median==-1 && (n+1)>=v.size()/2){
				if(n<v.size()-1){
					median=(v.elementAt(n+1)+v.elementAt(n))/2;
				}
				else{
					median=v.elementAt(n);
				}
			}
		}
		if(readers.get(reader)!=null){
			out.println("<tr><td class='admin'>"+readers.get(reader)+"</td><td class='admin2'>"+v.size()+"</td><td class='admin2'>"+median+"</td><td class='admin2'><b>"+SH.getTimeBetween(new java.util.Date(0), new java.util.Date(median))+"</b> ["+SH.getTimeBetween(new java.util.Date(0), new java.util.Date(min))+" - "+SH.getTimeBetween(new java.util.Date(0), new java.util.Date(max))+"]</td><td class='admin2'>"+(sum/1000)+"</td><td class='admin2'><b>"+SH.getTimeBetween(new java.util.Date(0), new java.util.Date(sum))+"</b></td></tr>");
		}
	}
	conn.close();
%>
</table>
<table width='100%'>
	<tr><td><br/><hr/><br/></td></tr>
	<tr class='admin'><td><%=getTran(request,"web","journeys",sWebLanguage) %></td></tr>
</table>
<table width='100%' class="sortable" id="journeyTable">
	<tr class='admin'>
		<td><%=getTran(request,"web","from",sWebLanguage) %></td>
		<td><%=getTran(request,"web","to",sWebLanguage) %></td>
		<td><%=getTran(request,"web","entries",sWebLanguage) %></td>
		<td colspan='2'><%=getTran(request,"web","averagedelay",sWebLanguage) %></td>
		<td colspan='2'><%=getTran(request,"web","totaldelay",sWebLanguage) %></td>
	</tr>
<%
	Enumeration<String> eJourneys= journeys.keys();
	while(eJourneys.hasMoreElements()){
		String j = eJourneys.nextElement();
		Vector<Long> v = journeys.get(j);
		Collections.sort(v);
		long sum = 0,min=-1,max=0,median=-1;
		for(int n=0;n<v.size();n++){
			sum+=v.elementAt(n);
			if(v.elementAt(n)>max){
				max=v.elementAt(n);
			}
			if(min==-1 || v.elementAt(n)<min){
				min=v.elementAt(n);
			}
			if(median==-1 && (n+1)>=v.size()/2){
				if(n<v.size()-1){
					median=(v.elementAt(n+1)+v.elementAt(n))/2;
				}
				else{
					median=v.elementAt(n);
				}
			}
		}
		if(readers.get(j.split(";")[0])!=null && readers.get(j.split(";")[1])!=null){
			out.println("<tr><td class='admin'>"+readers.get(j.split(";")[0])+"</td><td class='admin'>"+readers.get(j.split(";")[1])+"</td><td class='admin2'>"+v.size()+"</td><td class='admin2'>"+median+"</td><td class='admin2'><b>"+SH.getTimeBetween(new java.util.Date(0), new java.util.Date(median))+"</b> ["+SH.getTimeBetween(new java.util.Date(0), new java.util.Date(min))+" - "+SH.getTimeBetween(new java.util.Date(0), new java.util.Date(max))+"]</td><td class='admin2'>"+(sum/1000)+"</td><td class='admin2'><b>"+SH.getTimeBetween(new java.util.Date(0), new java.util.Date(sum))+"</b></td></tr>");
		}
	}
%>
</table>