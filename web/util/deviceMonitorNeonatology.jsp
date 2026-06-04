<%@page import="java.text.DecimalFormat"%>
<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<table width='100%' cellspacing='5px'>
<%!
	private String getResult(String code,Hashtable<String,Float>results,Hashtable<String,Integer>resultsCounter){
		if(results.get(code)==null){
			return "?";
		}
		return new DecimalFormat("#0.0").format(results.get(code)/resultsCounter.get(code));
	}
	private double getNumericResult(String code,Hashtable<String,Float>results,Hashtable<String,Integer>resultsCounter){
		if(results.get(code)==null){
			return -1;
		}
		return results.get(code)/resultsCounter.get(code);
	}
	private String printMonitor(String personid,String deviceid,java.sql.Timestamp ts,double baseFontSize,double cellHeight){
		String s="<table style='padding: 0px;border-spacing:0px' width='100%' height='"+cellHeight+"px'>";
		Connection conn = SH.getOpenClinicConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select * from oc_observations where personid=? and id=? and ts>? and code='0000-9' and value=1 order by ts desc");
			ps.setString(1,personid);
			ps.setString(2,deviceid);
			ps.setTimestamp(3,new java.sql.Timestamp(ts.getTime()-SH.getTimeDay()));
			ResultSet rs = ps.executeQuery();
			java.sql.Timestamp lastMovement = null;
			if(rs.next()){
				lastMovement = rs.getTimestamp("ts");
			}
			rs.close();
			ps.close();
			ps = conn.prepareStatement("select * from oc_observations where personid=? and id=? and ts>? and code<>'0000-9' order by ts desc");
			ps.setString(1,personid);
			ps.setString(2,deviceid);
			ps.setTimestamp(3,new java.sql.Timestamp(ts.getTime()-SH.getTimeSecond()*5));
			rs = ps.executeQuery();
			Hashtable<String,Float> results = new Hashtable<String,Float>();
			Hashtable<String,Integer> resultsCounter = new Hashtable<String,Integer>();
			while(rs.next() && results.size()<5){
				if(lastMovement!=null && lastMovement.equals(rs.getTimestamp("ts"))){
					continue;
				}
				String code=rs.getString("code");
				if(results.get(code)==null){
					results.put(code,rs.getFloat("value"));
					resultsCounter.put(code,1);
				}
				else{
					results.put(code,results.get(code)+rs.getFloat("value"));
					resultsCounter.put(code,resultsCounter.get(code)+1);
				}
			}
			rs.close();
			ps.close();
			conn.close();
			String sError = "<error/>";
			if(SH.ci("deviceAlarm."+deviceid,1)==0){
				sError="";
			}
			String sTemp = "Temp: "+getResult("8310-5",results,resultsCounter)+"°C";
			double dTemp = getNumericResult("8310-5",results,resultsCounter);
			String sSaturation="Sat O2: "+getResult("59408-5",results,resultsCounter)+"%";
			double dSaturation=getNumericResult("59408-5",results,resultsCounter);
			String sHeartRate="HR: "+getResult("8867-4",results,resultsCounter)+" bpm";
			double dHeartRate=getNumericResult("8867-4",results,resultsCounter);
			String sRespiratoryRate="Resp: "+getResult("9279-1",results,resultsCounter)+" rpm";
			double dRespiratoryRate=getNumericResult("9279-1",results,resultsCounter);
			String sPerfusionIndex="PI: "+getResult("73798-1",results,resultsCounter)+" %";
			double dPerfusionIndex=getNumericResult("73798-1",results,resultsCounter);
			String sMovement="Mouv: "+(lastMovement==null?"?":SH.getTimeBetween(lastMovement, new java.util.Date()));
			String sTitle="<td style='font-size:"+baseFontSize*1.2+";color: white;background-color: #383838;text-align: center;font-weight: bolder'>";
			String sSmallTitle="<td style='font-size:"+baseFontSize/1.2+";color: white;background-color: #383838;text-align: center;font-weight: bolder'>";
			String sMainValue="<td style='white-space: nowrap;font-size:"+baseFontSize*3+";color: darkgreen;background-color: white;text-align: center;font-weight: bolder'>";
			String sMainErrorValue=sError+"<td style='white-space: nowrap;font-size:"+baseFontSize*3+";color: white;background-color: red;text-align: center;font-weight: bolder'>";
			String sValue="<td width='50%' style='font-size:"+baseFontSize*1.3+";color: darkgreen;background-color: white;text-align: center;font-weight: bolder'>";
			String sErrorValue=sError+"<td width='50%' style='font-size:"+baseFontSize*1.3+";color: white;background-color: red;text-align: center;font-weight: bolder'>";
			String sSingleValue="<td width='100%' colspan='2' style='font-size:"+baseFontSize*1.3+";color: darkgreen;background-color: white;text-align: center;font-weight: bolder'>";
			String sErrorSingleValue=sError+"<td width='100%' colspan='2' style='font-size:"+baseFontSize*1.3+";color: white;background-color: red;text-align: center;font-weight: bolder'>";
			s+="<tr height='"+cellHeight*1.2/12+"px'>"+sTitle+(SH.c(personid).length()==0?"":AdminPerson.getFullName(personid))+"</td></tr>";
			s+="<tr height='"+cellHeight*0.8/12+"px'>"+sSmallTitle+"["+SH.cs("deviceAlias."+deviceid,deviceid)+"] "+deviceid+"</td></tr>";
			if(dRespiratoryRate>-1 && (dRespiratoryRate<SH.cd("deviceMinimumRespiratoryRate."+deviceid,SH.cd("monitorMinimumRespiratoryRate",10)) || dRespiratoryRate>SH.cd("deviceMaximumRespiratoryRate."+deviceid,SH.cd("monitorMaximumRespiratoryRate",30)))){
				s+="<tr height='"+cellHeight/3+"px'>"+sMainErrorValue+sRespiratoryRate+"</td></tr>";
			}
			else{
				s+="<tr height='"+cellHeight/3+"px'>"+sMainValue+sRespiratoryRate+"</td></tr>";
			}
			s+="<tr><td><table height='"+cellHeight/6+"px' style='padding: 0px;border-spacing:0px;border: 0px solid black;' width='100%'><tr>";
			if(dSaturation>-1 && dSaturation<SH.cd("deviceMinimumSaturation."+deviceid,SH.cd("monitorMinimumSaturation",90))){
				s+=sErrorValue+sSaturation+"</td>";
			}
			else{
				s+=sValue+sSaturation+"</td>";
			}
			if(dHeartRate>-1 && dHeartRate<SH.cd("deviceMinimumHeartRate."+deviceid,SH.cd("monitorMinimumHeartRate",100))){
				s+=sErrorValue+sHeartRate+"</td>";
			}
			else{
				s+=sValue+sHeartRate+"</td>";
			}
			s+="</tr></table></td></tr>";
			s+="<tr><td><table height='"+cellHeight/6+"px' style='padding: 0px;border-spacing:0px;border: 0px solid black;' width='100%'><tr>";
			if(dTemp>-1 && (dTemp<SH.cd("deviceMinimumTemperature."+deviceid,SH.cd("monitorMinimumTemperature",35)) || dTemp>SH.cd("deviceMaximumTemperature."+deviceid,SH.cd("monitorMaximumTemperature",38)))){
				s+=sErrorValue+sTemp+"</td>";
			}
			else{
				s+=sValue+sTemp+"</td>";
			}
			if(dPerfusionIndex>-1 && (dPerfusionIndex<SH.cd("deviceMinimumPerfusionIndex."+deviceid,SH.cd("monitorMinimumPerfusionIndex",0.4)) || dPerfusionIndex>SH.cd("deviceMaximumPerfusionIndex."+deviceid,SH.cd("monitorMaximumPerfusionIndex",30)))){
				s+=sErrorValue+sPerfusionIndex+"</td>";
			}
			else{
				s+=sValue+sPerfusionIndex+"</td>";
			}
			s+="</tr></table></td></tr>";
			s+="<tr><td><table height='"+cellHeight/6+"px' style='padding: 0px;border-spacing:0px;border: 0px solid black;' width='100%'><tr>";
			if(lastMovement!=null && new java.util.Date().getTime()-lastMovement.getTime()>(SH.cd("deviceMaximumMouvementIntervalInMinutes."+deviceid,SH.ci("monitorMaximumMouvementIntervalInMinutes",30))*SH.getTimeMinute())){
				s+=sErrorSingleValue+sMovement+"</td>";
			}
			else{
				s+=sSingleValue+sMovement+"</td>";
			}
			s+="</tr></table></td></tr>";
		}
		catch(Exception e){
			e.printStackTrace();
		}
		s+="</table>";
		return s;
	}
%>
<%
	//First calculate the number of rows/columns
	SortedMap<String,java.sql.Timestamp> patientDevices = new TreeMap<String,java.sql.Timestamp>();
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select personid,id,max(ts) maxts from oc_observations where ts>? group by personid,id order by personid,id");
	ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()-SH.getTimeSecond()*SH.ci("monitorMaximumDelayInSeconds",300)));
	double activeDevices=0;
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		activeDevices++;
		patientDevices.put(rs.getString("personid")+"|"+rs.getString("id"),rs.getTimestamp("maxts"));
	}
	rs.close();
	ps.close();
	conn.close();
	double cols = new Double(Math.ceil(Math.sqrt(activeDevices))).intValue();
	double rows=new Double(Math.ceil(activeDevices/cols)).intValue();
	Iterator<String> iPatientDevices = patientDevices.keySet().iterator();
	int activeColumn=1;
	while(iPatientDevices.hasNext()){
		if(activeColumn>cols){
			out.println("</tr>");
			activeColumn=1;
		}
		if(activeColumn==1){
			out.println("<tr>");
		}
		String key = iPatientDevices.next();
		//Put a table cell with content here
		if(activeDevices==1) cols=2;
		out.println("<td style='border: 2px solid black' width='"+100/cols+"%'>");
		out.println(printMonitor(key.split("\\|")[0],key.split("\\|")[1],patientDevices.get(key),48/cols,new Double(request.getParameter("screenHeight"))*0.8/rows));
		out.println("</td>");
		if(activeDevices==1){
			out.println("<td/>");
		}
		activeColumn++;
	}
	if(activeDevices>0){
		out.println("</tr>");
	}
	else{
		out.println("<tr><td style='font-size: 12px;font-weight: bolder'>No devices found that were transmitting data in the past "+SH.ci("monitorMaximumDelayInSeconds",300)+" seconds<br><img src='"+sCONTEXTPATH+"/_img/themes/default/ajax-loader.gif'</td></tr>");
	}
%>
</table>