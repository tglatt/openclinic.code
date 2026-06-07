<%@page import="java.text.DecimalFormat"%>
<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<table width='100%' cellspacing='5px'>
<%!
	private String getResult(String code,Hashtable<String,Float>results,Hashtable<String,Integer>resultsCounter){
		return getResult(code, results, resultsCounter,"#0.0");	
	}
	private String getResult(String code,Hashtable<String,Float>results,Hashtable<String,Integer>resultsCounter,String format){
		if(results.get(code)==null){
			return "?";
		}
		return new DecimalFormat(format).format(results.get(code)/resultsCounter.get(code));
	}
	private double getNumericResult(String code,Hashtable<String,Float>results,Hashtable<String,Integer>resultsCounter){
		if(results.get(code)==null){
			return -1;
		}
		return results.get(code)/resultsCounter.get(code);
	}
	private String printMonitor(String personid,String deviceid,java.sql.Timestamp ts,double baseFontSize,double cellHeight){
		int nSamplesToAverage = SH.ci("monitorSamplesToAverage",10);
		Hashtable<String,Double> maxChanges = new Hashtable<String,Double>();
		maxChanges.put("8310-5",1.05); //Temperature
		maxChanges.put("8867-4",1.1); //Heartrate
		maxChanges.put("9279-1",1.1); //Respiratory rate
		maxChanges.put("73798-1",1.05); //Perfusion index
		maxChanges.put("59408-5",1.03); //sPO2
		double maxChangeDuration=5;
		String s="<table style='padding: 0px;border-spacing:0px' width='100%' height='"+cellHeight+"px'>";
		SortedSet<java.util.Date> movements = new TreeSet<java.util.Date>();
		Connection conn = SH.getOpenClinicConnection();
		try{
			PreparedStatement ps = null;
			if(SH.c(personid).length()>0){
				ps = conn.prepareStatement("select * from oc_observations where personid=? and ts>? and code='0000-9' and value>? order by ts desc");
				ps.setString(1,personid);
				ps.setTimestamp(2,new java.sql.Timestamp(ts.getTime()-SH.getTimeHour()*4));
				ps.setInt(3,SH.ci("monitorMotionTreshhold",0));
			}
			else{
				ps = conn.prepareStatement("select * from oc_observations where id=? and ts>? and code='0000-9' and value>? order by ts desc");
				ps.setString(1,deviceid);
				ps.setTimestamp(2,new java.sql.Timestamp(ts.getTime()-SH.getTimeHour()*4));
				ps.setInt(3,SH.ci("monitorMotionTreshhold",0));
			}
			ResultSet rs = ps.executeQuery();
			java.util.Date lastMovement = null;
			while(rs.next()){
				movements.add(new SimpleDateFormat("yyyyMMddHHmmss").parse(new SimpleDateFormat("yyyyMMddHHmmss").format(rs.getTimestamp("ts"))));
			}
			rs.close();
			ps.close();
			if(movements.size()>0){
				lastMovement=movements.last();

			}
			if(SH.c(personid).length()>0){
				ps = conn.prepareStatement("select * from oc_observations where personid=? and ts>? and code<>'0000-9' order by ts desc");
				ps.setString(1,personid);
				ps.setTimestamp(2,new java.sql.Timestamp(ts.getTime()-SH.getTimeSecond()*nSamplesToAverage));
			}
			else{
				ps = conn.prepareStatement("select * from oc_observations where id=? and ts>? and code<>'0000-9' order by ts desc");
				ps.setString(1,deviceid);
				ps.setTimestamp(2,new java.sql.Timestamp(ts.getTime()-SH.getTimeSecond()*nSamplesToAverage));
			}
			rs = ps.executeQuery();
			Hashtable<String,Float> results = new Hashtable<String,Float>();
			Hashtable<String,Integer> resultsCounter = new Hashtable<String,Integer>();
			Hashtable<String,Float> lastvalues = new Hashtable<String,Float>(); 
			Hashtable<String,java.util.Date> lastdates = new Hashtable<String,java.util.Date>(); 
			int v=1,z=1;
			while(rs.next() && results.size()<nSamplesToAverage){
				String code=rs.getString("code");
				if(movements.contains(new SimpleDateFormat("yyyyMMddHHmmss").parse(new SimpleDateFormat("yyyyMMddHHmmss").format(rs.getTimestamp("ts"))))){
					continue;
				}
				if(code.equalsIgnoreCase("8310-5") && SH.ci("deviceEnableTemperature."+rs.getString("id"),1)==0){
					continue;
				}
				else if(code.equalsIgnoreCase("8867-4") && SH.ci("deviceEnableHeartRate."+rs.getString("id"),1)==0){
					continue;
				}
				else if(code.equalsIgnoreCase("9279-1") && SH.ci("deviceEnableRespiratoryRate."+rs.getString("id"),1)==0){
					continue;
				}
				else if(code.equalsIgnoreCase("73798-1") && SH.ci("deviceEnablePerfusionIndex."+rs.getString("id"),1)==0){
					continue;
				}
				else if(code.equalsIgnoreCase("59408-5") && SH.ci("deviceEnableSaturation."+rs.getString("id"),1)==0){
					continue;
				}
				Float fValue=rs.getFloat("value");
				//Discard unrealistic limits
				if(code.equalsIgnoreCase("8310-5") && (fValue<25 || fValue>43)){
					continue;
				}
				else if(code.equalsIgnoreCase("8867-4") && (fValue<40 || fValue>250)){
					continue;
				}
				else if(code.equalsIgnoreCase("9279-1") && (fValue<2 || fValue>100)){
					continue;
				}
				else if(code.equalsIgnoreCase("73798-1") && (fValue>20)){
					continue;
				}
				else if(code.equalsIgnoreCase("59408-5") && (fValue<30 && fValue>105)){
					continue;
				}
				if(code.equalsIgnoreCase("59408-5")){
					if(fValue>100){
						fValue=new Float(100);
					}
					//SH.syslog("sample "+code+": "+fValue+" = "+z++);
				}
				if(lastvalues.get(code)!=null && (lastvalues.get(code)/fValue>maxChanges.get(code) || fValue/lastvalues.get(code)>maxChanges.get(code))){
					if(code.equalsIgnoreCase("59408-5")){
						//SH.syslog("exit: "+lastvalues.get(code)+"/"+fValue+": "+(lastvalues.get(code)/fValue));
					}
					if(rs.getTimestamp("ts").getTime()-lastdates.get(code).getTime()>SH.getTimeSecond()*maxChangeDuration){
						lastdates.put(code,rs.getTimestamp("ts"));
					}
					lastvalues.put(code,fValue);
					continue;
				}
				else{
					lastdates.put(code,rs.getTimestamp("ts"));
					lastvalues.put(code,fValue);
				}
				if(results.get(code)==null){
					if(code.equalsIgnoreCase("59408-5")){
						//SH.syslog(v+++" sPO2="+fValue);
					}
					results.put(code,fValue);
					resultsCounter.put(code,1);
				}
				else{
					results.put(code,results.get(code)+fValue);
					if(code.equalsIgnoreCase("59408-5")){
						//SH.syslog(v+++" sPO2="+fValue);
					}
					resultsCounter.put(code,resultsCounter.get(code)+1);
				}
			}
			rs.close();
			ps.close();
			conn.close();

			//SH.syslog("average SpO2="+getResult("59408-5",results,resultsCounter));

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
			String sPerfusionIndex="PI: "+getResult("73798-1",results,resultsCounter,"#0.00")+" %";
			double dPerfusionIndex=getNumericResult("73798-1",results,resultsCounter);
			String sMovement="Mouv: "+(lastMovement==null?"?":SH.getTimeBetween(lastMovement, new java.util.Date()));
			String sTitle="<td style='font-size:"+baseFontSize*1.2+";color: white;background-color: #383838;text-align: center;font-weight: bolder'>";
			String sMovementTitle="<td style='font-size:"+baseFontSize*1.2+";color: white;background-color: darkgrey;text-align: center;font-weight: bolder'>";
			String sSmallTitle="<td style='font-size:"+baseFontSize/1.2+";color: white;background-color: #383838;text-align: center;font-weight: bolder'>";
			String sSmallMovementTitle="<td style='font-size:"+baseFontSize/1.2+";color: white;background-color: darkgrey;text-align: center;font-weight: bolder'>";
			String sMainValue="<td style='white-space: nowrap;font-size:"+baseFontSize*2.5+";color: darkgreen;background-color: white;text-align: center;font-weight: bolder'>";
			String sMainMovementValue="<td style='white-space: nowrap;font-size:"+baseFontSize*2.5+";color: #d0f5da;background-color: white;text-align: center;font-weight: bolder'>";
			String sMainErrorValue=sError+"<td style='white-space: nowrap;font-size:"+baseFontSize*2.5+";color: white;background-color: red;text-align: center;font-weight: bolder'>";
			String sMainErrorMovementValue=sError+"<td style='white-space: nowrap;font-size:"+baseFontSize*2.5+";color: white;background-color: #fccacc;text-align: center;font-weight: bolder'>";
			String sValue="<td width='50%' style='font-size:"+baseFontSize*1.25+";color: darkgreen;background-color: white;text-align: center;font-weight: bolder'>";
			String sErrorValue=sError+"<td width='50%' style='font-size:"+baseFontSize*1.25+";color: white;background-color: red;text-align: center;font-weight: bolder'>";
			String sMovementValue="<td width='50%' style='font-size:"+baseFontSize*1.25+";color: #d0f5da;background-color: white;text-align: center;font-weight: bolder'>";
			String sErrorMovementValue=sError+"<td width='50%' style='font-size:"+baseFontSize*1.25+";color: white;background-color: #fccacc;text-align: center;font-weight: bolder'>";
			String sSingleValue="<td width='100%' colspan='2' style='font-size:"+baseFontSize*1.3+";color: darkgreen;background-color: white;text-align: center;font-weight: bolder'>";
			String sErrorSingleValue=sError+"<td width='100%' colspan='2' style='font-size:"+baseFontSize*1.3+";color: white;background-color: red;text-align: center;font-weight: bolder'>";
			String deviceidbutton=" <img src='"+sCONTEXTPATH+"/_img/icons/icon_newpage.png' onclick='copyTextToClipboard(\""+deviceid+"\")' height='24px'/>";
			if(lastMovement!=null && new java.util.Date().getTime()-lastMovement.getTime()<SH.getTimeSecond()*SH.ci("reliablePPGValuesAfterMotionInSeconds",30)){
				if(SH.cs("deviceAlias."+deviceid,deviceid).equalsIgnoreCase(deviceid)){
					s+="<tr height='"+cellHeight*1.2/12+"px'>"+sMovementTitle+(SH.c(personid).length()==0?"":AdminPerson.getFullName(personid))+"</td></tr>";
					s+="<tr height='"+cellHeight*0.8/12+"px'>"+sSmallMovementTitle+(personid.length()==0?deviceid+deviceidbutton:" ID: "+personid)+"</td></tr>";
				}
				else{
					s+="<tr><td><table width='100%'>";
					String sDeviceIdTitle="<td rowspan='2' style='font-size:"+baseFontSize*3+";color: #000000;background-color: yellow;text-align: center;font-weight: bolder'>";
					s+="<tr height='"+cellHeight*1.2/12+"px'>"+sDeviceIdTitle+SH.cs("deviceAlias."+deviceid,deviceid)+"</td>";
					s+=sMovementTitle+(SH.c(personid).length()==0?"":AdminPerson.getFullName(personid))+"</td></tr>";
					s+="<tr height='"+cellHeight*0.8/12+"px'>"+sSmallMovementTitle+(personid.length()==0?deviceid+deviceidbutton:" ID: "+personid)+"</td></tr>";
					s+="</table></td></tr>";
				}
				if(dRespiratoryRate>-1 && (dRespiratoryRate<SH.cd("deviceMinimumRespiratoryRate."+deviceid,SH.cd("monitorMinimumRespiratoryRate",10)) || dRespiratoryRate>SH.cd("deviceMaximumRespiratoryRate."+deviceid,SH.cd("monitorMaximumRespiratoryRate",30)))){
					s+="<tr height='"+cellHeight/3+"px'>"+sMainErrorMovementValue+sRespiratoryRate+"</td></tr>";
				}
				else{
					s+="<tr height='"+cellHeight/3+"px'>"+sMainMovementValue+sRespiratoryRate+"</td></tr>";
				}
				s+="<tr><td><table height='"+cellHeight/6+"px' style='padding: 0px;border-spacing:0px;border: 0px solid black;' width='100%'><tr>";
				if(dSaturation>-1 && dSaturation<SH.cd("deviceMinimumSaturation."+deviceid,SH.cd("monitorMinimumSaturation",90))){
					s+=sErrorMovementValue+sSaturation+"</td>";
				}
				else{
					s+=sMovementValue+sSaturation+"</td>";
				}
				if(dHeartRate>-1 && dHeartRate<SH.cd("deviceMinimumHeartRate."+deviceid,SH.cd("monitorMinimumHeartRate",100))){
					s+=sErrorMovementValue+sHeartRate+"</td>";
				}
				else{
					s+=sMovementValue+sHeartRate+"</td>";
				}
				s+="</tr></table></td></tr>";
				s+="<tr><td><table height='"+cellHeight/6+"px' style='padding: 0px;border-spacing:0px;border: 0px solid black;' width='100%'><tr>";
				if(dTemp>-1 && (dTemp<SH.cd("deviceMinimumTemperature."+deviceid,SH.cd("monitorMinimumTemperature",35)) || dTemp>SH.cd("deviceMaximumTemperature."+deviceid,SH.cd("monitorMaximumTemperature",38)))){
					s+=sErrorMovementValue+sTemp+"</td>";
				}
				else{
					s+=sMovementValue+sTemp+"</td>";
				}
				if(dPerfusionIndex>-1 && (dPerfusionIndex<SH.cd("deviceMinimumPerfusionIndex."+deviceid,SH.cd("monitorMinimumPerfusionIndex",0.4)) || dPerfusionIndex>SH.cd("deviceMaximumPerfusionIndex."+deviceid,SH.cd("monitorMaximumPerfusionIndex",30)))){
					s+=sErrorMovementValue+sPerfusionIndex+"</td>";
				}
				else{
					s+=sMovementValue+sPerfusionIndex+"</td>";
				}
				s+="</tr></table></td></tr>";
				s+="<tr><td><table height='"+cellHeight/6+"px' style='padding: 0px;border-spacing:0px;border: 0px solid black;' width='100%'><tr>";
			}
			else{
				if(SH.cs("deviceAlias."+deviceid,deviceid).equalsIgnoreCase(deviceid)){
					s+="<tr height='"+cellHeight*1.2/12+"px'>"+sTitle+(SH.c(personid).length()==0?"":AdminPerson.getFullName(personid))+"</td></tr>";
					s+="<tr height='"+cellHeight*0.8/12+"px'>"+sSmallTitle+(personid.length()==0?deviceid+deviceidbutton:" ID: "+personid)+"</td></tr>";
				}
				else{
					s+="<tr><td><table width='100%'>";
					String sDeviceIdTitle="<td rowspan='2' style='font-size:"+baseFontSize*3+";color: #000000;background-color: yellow;text-align: center;font-weight: bolder'>";
					s+="<tr height='"+cellHeight*1.2/12+"px'>"+sDeviceIdTitle+SH.cs("deviceAlias."+deviceid,deviceid)+"</td>";
					s+=sTitle+(SH.c(personid).length()==0?"":AdminPerson.getFullName(personid))+"</td></tr>";
					s+="<tr height='"+cellHeight*0.8/12+"px'>"+sSmallTitle+(personid.length()==0?deviceid+deviceidbutton:" ID: "+personid)+"</td></tr>";
					s+="</table></td></tr>";
				}
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
			}
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
	PreparedStatement ps = conn.prepareStatement("select personid,id,max(ts) maxts from oc_observations where ts>? group by personid,id order by max(ts) desc,personid,id");
	java.sql.Timestamp cutOffTime = new java.sql.Timestamp(new java.util.Date().getTime()-SH.getTimeSecond()*SH.ci("monitorMaximumDelayInSeconds",300));
	ps.setTimestamp(1, cutOffTime);
	double activeDevices=0;
	HashSet devices = new HashSet();
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		if(devices.contains(rs.getString("id"))){
			continue;
		}
		devices.add(rs.getString("id"));
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
	HashSet patients = new HashSet();
	devices = new HashSet();
	while(iPatientDevices.hasNext()){
		String key = iPatientDevices.next();
		if(key.split("\\|")[0].length()>0 && patients.contains(key.split("\\|")[0])){
			continue;
		}
		else{
			patients.add(key.split("\\|")[0]);
		}
		if(key.split("\\|")[1].length()>0 && devices.contains(key.split("\\|")[1])){
			continue;
		}
		else{
			devices.add(key.split("\\|")[1]);
		}
		if(activeColumn>cols){
			out.println("</tr>");
			activeColumn=1;
		}
		if(activeColumn==1){
			out.println("<tr>");
		}
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