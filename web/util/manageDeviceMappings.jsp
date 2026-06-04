<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	if(SH.p(request,"action").equalsIgnoreCase("unlink")){
		MedwanQuery.getInstance().setConfigString("deviceMap."+SH.p(request,"deviceid"), "");
	}
	else if(SH.p(request,"action").equalsIgnoreCase("delete")){
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("delete from oc_config where oc_key=?");
		ps.setString(1,"deviceMap."+SH.p(request,"deviceid"));
		ps.execute();
		ps.close();
		conn.close();
		MedwanQuery.getInstance().reloadConfigValues();
	}
	else if(SH.p(request,"action").equalsIgnoreCase("link")){
		MedwanQuery.getInstance().setConfigString("deviceMap."+SH.p(request,"deviceid"), SH.p(request,"personid"));
	}
	else if(SH.p(request,"action").equalsIgnoreCase("updateReferenceValues")){
		String deviceid=SH.p(request,"deviceid");
		MedwanQuery.getInstance().setConfigString("deviceMinimumTemperature."+deviceid, SH.p(request,"deviceMinimumTemperature."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceMaximumTemperature."+deviceid, SH.p(request,"deviceMaximumTemperature."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceTemperatureCalibration."+deviceid, SH.p(request,"deviceTemperatureCalibration."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceMinimumRespiratoryRate."+deviceid, SH.p(request,"deviceMinimumRespiratoryRate."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceMaximumRespiratoryRate."+deviceid, SH.p(request,"deviceMaximumRespiratoryRate."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceMinimumSaturation."+deviceid, SH.p(request,"deviceMinimumSaturation."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceMinimumHeartRate."+deviceid, SH.p(request,"deviceMinimumHeartRate."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceMinimumPerfusionIndex."+deviceid, SH.p(request,"deviceMinimumPerfusionIndex."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceMaximumPerfusionIndex."+deviceid, SH.p(request,"deviceMaximumPerfusionIndex."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceMaximumMouvementIntervalInMinutes."+deviceid, SH.p(request,"deviceMaximumMouvementIntervalInMinutes."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceAlarm."+deviceid, SH.p(request,"deviceAlarm."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceAlias."+deviceid, SH.p(request,"deviceAlias."+deviceid));
		MedwanQuery.getInstance().setConfigString("deviceEnableTemperature."+deviceid, SH.p(request,"deviceEnableTemperature."+deviceid,"0"));
		MedwanQuery.getInstance().setConfigString("deviceEnableHeartRate."+deviceid, SH.p(request,"deviceEnableHeartRate."+deviceid,"0"));
		MedwanQuery.getInstance().setConfigString("deviceEnableRespiratoryRate."+deviceid, SH.p(request,"deviceEnableRespiratoryRate."+deviceid,"0"));
		MedwanQuery.getInstance().setConfigString("deviceEnableSaturation."+deviceid, SH.p(request,"deviceEnableSaturation."+deviceid,"0"));
		MedwanQuery.getInstance().setConfigString("deviceEnablePrefusionIndex."+deviceid, SH.p(request,"deviceEnablePrefusionIndex."+deviceid,"0"));
		MedwanQuery.getInstance().setConfigString("deviceLocation."+deviceid, SH.p(request,"deviceLocation."+deviceid,""));
		SH.syslog("location="+SH.p(request,"deviceLocation."+deviceid,""));
	}
	else if(SH.p(request,"action").equalsIgnoreCase("resetReferenceValues")){
		String deviceid=SH.p(request,"deviceid");
		MedwanQuery.getInstance().setConfigString("deviceMinimumTemperature."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceMaximumTemperature."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceTemperatureCalibration."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceMinimumRespiratoryRate."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceMaximumRespiratoryRate."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceMinimumSaturation."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceMinimumHeartRate."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceMinimumPerfusionIndex."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceMaximumPerfusionIndex."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceMaximumMouvementIntervalInMinutes."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceAlarm."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceEnableTemperature."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceEnableHeartRate."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceEnableRespiratoryRate."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceEnableSaturation."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceEnablePrefusionIndex."+deviceid, "");
		MedwanQuery.getInstance().setConfigString("deviceLocation."+deviceid, "");
	}
	else if(SH.p(request,"action").equalsIgnoreCase("updateDeviceType")){
		if(SH.p(request,"deviceid").split(";").length>1){
			MedwanQuery.getInstance().setConfigString(SH.p(request,"deviceid").split(";")[0], SH.p(request,"deviceid").split(";")[1]);
		}
		else{
			MedwanQuery.getInstance().setConfigString(SH.p(request,"deviceid").split(";")[0], "");
		}
	}

%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'><td colspan='4'><%=getTran(request,"web","devicemappings",sWebLanguage) %></td></tr>
	<%
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("select * from oc_config where oc_key like 'deviceMap.%' order by oc_key");
		ResultSet rs = ps.executeQuery();
		boolean bInit=false;
		while(rs.next()){
			bInit=true;
			String deviceid=rs.getString("oc_key").replaceAll("deviceMap.","");
			String personid=rs.getString("oc_value").trim();
			out.println("<tr><td class='admin'>"+deviceid+"</td>");
			out.println("<td class='admin'>");
			out.println("<select class='text' name='deviceType."+deviceid+"' id='deviceType."+deviceid+"' onchange='updateDeviceType(this)'>");
			out.println("<option/>");
			out.println("<option value='neonatalppg' "+(SH.cs("deviceType."+deviceid,"-").equalsIgnoreCase("neonatalppg")?"selected":"")+">"+getTranNoLink("web","neonatalppgsensor",sWebLanguage)+"</option>");
			out.println("</select>");
			out.println("</td>");
			out.println("<td class='admin'>"+rs.getString("oc_value")+" - <b>"+AdminPerson.getFullName(personid)+"</b></td>");
			out.println("<td class='admin'>");
			out.println("    <input class='button' type='button' onclick='searchPatient(\""+deviceid+"\",\""+personid+"\")' value='"+getTranNoLink("web","link.patient",sWebLanguage)+"'/>");
			out.println("    <input class='button' type='button' onclick='unlinkPatient(\""+deviceid+"\")' value='"+getTranNoLink("web","disconnect",sWebLanguage)+"'/>");
			out.println("    <input class='button' type='button' onclick='deleteDevice(\""+deviceid+"\")' value='"+getTranNoLink("web","delete",sWebLanguage)+"'/>");
			out.println("</td>");
			out.println("</tr>");
			if(SH.cs("deviceType."+deviceid,"-").equalsIgnoreCase("neonatalppg")){
				out.println("<tr>");
				out.println("<td><center><img height='50px' src='"+sCONTEXTPATH+"/_img/neo.png'/></center></td>");
				out.println("<td colspan='3'><table cellpadding='0' width='100%' style='border: 1px solid black;'><tr>");
				out.println("<td class='admin2' width='14%'>min T°: <input size='5' class='text' type='text' name='deviceMinimumTemperature."+deviceid+"' value='"+SH.cd("deviceMinimumTemperature."+deviceid,SH.cd("monitorMinimumTemperature",35.6))+"'/>°C</td>");
				out.println("<td class='admin2' width='14%'>max T°: <input size='5' class='text' type='text' name='deviceMaximumTemperature."+deviceid+"' value='"+SH.cd("deviceMaximumTemperature."+deviceid,SH.cd("monitorMaximumTemperature",38))+"'/>°C</td>");
				out.println("<td class='admin2' width='14%'>Corr T°: <input size='5' class='text' type='text' name='deviceTemperatureCalibration."+deviceid+"' value='"+SH.cd("deviceTemperatureCalibration."+deviceid,SH.cd("deviceTemperatureCalibration",0))+"'/>°C</td>");
				out.println("<td class='admin2' width='14%'>min HR: <input size='5' class='text' type='text' name='deviceMinimumHeartRate."+deviceid+"' value='"+SH.cd("deviceMinimumHeartRate."+deviceid,SH.cd("monitorMinimumHeartRate",90))+"'/>bpm</td>");
				out.println("<td class='admin2' width='14%'>min RR: <input size='5' class='text' type='text' name='deviceMinimumRespiratoryRate."+deviceid+"' value='"+SH.cd("deviceMinimumRespiratoryRate."+deviceid,SH.cd("monitorMinimumRespiratoryRate",10))+"'/>rpm</td>");
				out.println("<td class='admin2' width='14%'>max RR: <input size='5' class='text' type='text' name='deviceMaximumRespiratoryRate."+deviceid+"' value='"+SH.cd("deviceMaximumRespiratoryRate."+deviceid,SH.cd("monitorMaximumRespiratoryRate",55))+"'/>rpm</td>");
				out.println("<td rowspan='3' class='admin'><input type='button' class='button' onclick='updateReferenceValues(\""+deviceid+"\")' value='"+getTranNoLink("web","update",sWebLanguage)+"'/><input type='button' class='button' onclick='resetReferenceValues(\""+deviceid+"\")' value='"+getTranNoLink("web","reset",sWebLanguage)+"'/></td>");
				out.println("</tr><tr>");
				out.println("<td class='admin2' width='14%'>min PI: <input size='5' class='text' type='text' name='deviceMinimumPerfusionIndex."+deviceid+"' value='"+SH.cd("deviceMinimumPerfusionIndex."+deviceid,SH.cd("monitorMinimumPerfusionIndex",1.1))+"'/>%</td>");
				out.println("<td class='admin2' width='14%'>max PI: <input size='5' class='text' type='text' name='deviceMaximumPerfusionIndex."+deviceid+"' value='"+SH.cd("deviceMaximumPerfusionIndex."+deviceid,SH.cd("monitorMaximumPerfusionIndex",30))+"'/>%</td>");
				out.println("<td class='admin2' width='14%'>min O2: <input size='5' class='text' type='text' name='deviceMinimumSaturation."+deviceid+"' value='"+SH.cd("deviceMinimumSaturation."+deviceid,SH.cd("monitorMinimumSaturation",92))+"'/>%</td>");
				out.println("<td class='admin2' width='14%'>Mouv.&nbsp; : <input size='5' class='text' type='text' name='deviceMaximumMouvementIntervalInMinutes."+deviceid+"' value='"+SH.cd("deviceMaximumMouvementIntervalInMinutes."+deviceid,SH.cd("monitorMaximumMouvementIntervalInMinutes",30))+"'/>min</td>");
				out.println("<td class='admin2'>Alias:<input style='background-color: lightyellow;font-weight: bolder' type='text' class='text' size='10' name='deviceAlias."+deviceid+"' value='"+SH.cs("deviceAlias."+deviceid,"")+"'/></td>");
				out.println("<td class='admin2'>Alarm : <input type='radio' value='0' class='text' type='text' name='deviceAlarm."+deviceid+"' "+(SH.ci("deviceAlarm."+deviceid,1)==0?"checked":"")+"/>0 &nbsp;<input type='radio' value='1' class='text' type='text' name='deviceAlarm."+deviceid+"' "+(SH.ci("deviceAlarm."+deviceid,1)==1?"checked":"")+"/>1</td>");
				out.println("</tr><tr>");
				out.println("<td class='admin2' width='14%'><input class='text' type='checkbox' id='deviceEnableTemperature."+deviceid+"' name='deviceEnableTemperature."+deviceid+"' "+(SH.ci("deviceEnableTemperature."+deviceid,1)==1?"checked":"")+" value='1'/>T°</td>");
				out.println("<td class='admin2' width='14%'><input class='text' type='checkbox' id='deviceEnableHeartRate."+deviceid+"' name='deviceEnableHeartRate."+deviceid+"' "+(SH.ci("deviceEnableHeartRate."+deviceid,1)==1?"checked":"")+" value='1'/>HR</td>");
				out.println("<td class='admin2' width='14%'><input class='text' type='checkbox' id='deviceEnableRespiratoryRate."+deviceid+"' name='deviceEnableRespiratoryRate."+deviceid+"' "+(SH.ci("deviceEnableRespiratoryRate."+deviceid,1)==1?"checked":"")+" value='1'/>Resp</td>");
				out.println("<td class='admin2' width='14%'><input class='text' type='checkbox' id='deviceEnablePerfusionIndex."+deviceid+"' name='deviceEnablePerfusionIndex."+deviceid+"' "+(SH.ci("deviceEnablePerfusionIndex."+deviceid,1)==1?"checked":"")+" value='1'/>PI</td>");
				out.println("<td colspan='2' class='admin2' width='14%'><input class='text' type='checkbox' id='deviceEnableSaturation."+deviceid+"' name='deviceEnableSaturation."+deviceid+"' "+(SH.ci("deviceEnableSaturation."+deviceid,1)==1?"checked":"")+" value='1'/>SpO2</td>");
				//out.println("<td class='admin2'>Loc. <select onchange='setDeviceLocation(\""+deviceid+"\");' class='text' name='deviceLocation."+deviceid+"' id='deviceLocation."+deviceid+"'><option/><option value='thorax'"+(SH.cs("deviceLocation."+deviceid,"").equals("thorax")?" selected ":"")+">thorax</option><option "+(SH.cs("deviceLocation."+deviceid,"").equals("foot")?" selected ":"")+"value='foot'>foot</option><option "+(SH.cs("deviceLocation."+deviceid,"").equals("front")?" selected ":"")+"value='front'>front</option><option "+(SH.cs("deviceLocation."+deviceid,"").equals("other")?" selected ":"")+"value='other'>other</option></selected>");
				out.println("</tr></table></td>");
				out.println("</tr>");
				out.println("<script>window.setTimeout('setDeviceLocation(\""+deviceid+"\");',200);</script>");
			}
		}
		rs.close();
		ps.close();
		conn.close();
	%>
	</table>
	<center><br/><input type='button' class='button' name='new' onclick='newDevice()' value='<%=getTranNoLink("web","new.device",sWebLanguage) %>'/></center>
	<input type='hidden' name='personid' id='personid'/>
	<input type='hidden' name='deviceid' id='deviceid'/>
	<input type='hidden' name='action' id='action'/>
</form>

<script>
	function searchPatient(deviceid,personid){
		document.getElementById("personid").value=personid;
		document.getElementById("deviceid").value=deviceid;
	    openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>"+
		  		  "&PersonID=<%=activePatient==null?"":SH.c(activePatient.personid)%>"+
	    		  "&ReturnPersonID=personid"+
	    		  "&autoFind=1"+
	    		  "&ReturnFunction=linkPatient()");
	}

	function unlinkPatient(id){
		document.getElementById("deviceid").value=id;
		document.getElementById("action").value="unlink";
		transactionForm.submit();
	}

	function deleteDevice(id){
		if(window.confirm('<%=getTranNoLink("web","areyousure",sWebLanguage)%>')){
			document.getElementById("deviceid").value=id;
			document.getElementById("action").value="delete";
			transactionForm.submit();
		}
	}

	function linkPatient(){
		document.getElementById("action").value="link";
		transactionForm.submit();
	}
	
	function newDevice(){
		var id=window.prompt('<%=getTranNoLink("web","deviceid",sWebLanguage)%>');
		if(id.length>0){
			document.getElementById("deviceid").value=id;
			document.getElementById("action").value="unlink";
			transactionForm.submit();
		}
	}
	
	function updateDeviceType(element){
		document.getElementById("action").value="updateDeviceType";
		document.getElementById("deviceid").value=element.name+";"+element.value;
		transactionForm.submit();
	}
	
	function updateReferenceValues(id){
		document.getElementById("action").value="updateReferenceValues";
		document.getElementById("deviceid").value=id;
		transactionForm.submit();
	}
	function resetReferenceValues(id){
		document.getElementById("action").value="resetReferenceValues";
		document.getElementById("deviceid").value=id;
		transactionForm.submit();
	}
	function setDeviceLocation(id){
		if(document.getElementById('deviceLocation.'+id).value=='thorax'){
			document.getElementById('deviceEnableTemperature.'+id).checked=true;
			document.getElementById('deviceEnableRespiratoryRate.'+id).checked=false;
			document.getElementById('deviceEnableHeartRate.'+id).checked=true;
			document.getElementById('deviceEnableSaturation.'+id).checked=false;
			document.getElementById('deviceEnablePerfusionIndex.'+id).checked=false;
		}
		else {
			document.getElementById('deviceEnableTemperature.'+id).checked=true;
			document.getElementById('deviceEnableRespiratoryRate.'+id).checked=true;
			document.getElementById('deviceEnableHeartRate.'+id).checked=true;
			document.getElementById('deviceEnableSaturation.'+id).checked=true;
			document.getElementById('deviceEnablePerfusionIndex.'+id).checked=true;
		}
	}
</script>