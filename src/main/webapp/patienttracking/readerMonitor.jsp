<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.system.Beacon"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'><%=getTran(request,"web","readermonitor",sWebLanguage) %></td>
		</tr>
		<tr>
			<td class='admin' width='1%' nowrap><%=getTran(request,"web","reader",sWebLanguage) %>&nbsp;</td>
			<td class='admin2'>
				<select id='reader' name='reader' class='text' onchange='showBeacons();'>
					<option/>
					<%
						String activeBLEReader = SH.c((String)session.getAttribute("activeBLEReader"));
						Connection conn = SH.getOpenClinicConnection();
						PreparedStatement ps = conn.prepareStatement("select distinct oc_beacon_id,oc_beacon_comment,oc_beacon_alias from oc_beacons where oc_beacon_resourcetype='reader' order by oc_beacon_alias");
						ResultSet rs = ps.executeQuery();
						while(rs.next()){
							out.println("<option "+(activeBLEReader.equalsIgnoreCase(rs.getString("oc_beacon_id"))?"selected":"")+" value='"+rs.getString("oc_beacon_id")+"'>"+rs.getString("oc_beacon_alias")+" - "+rs.getString("oc_beacon_comment")+"</option>");
						}
						rs.close();
						ps.close();
						conn.close();
					%>
				</select>
				<input class='text' type='checkbox' name='showUnidentified' id='showUnidentified' onchange='checkCriteria();'/>
				<%=getTran(request,"web","show.unidentified.beacons",sWebLanguage) %>&nbsp;
				<input class='text' type='checkbox' name='showUnlinked' id='showUnlinked' checked onchange='showBeacons();'/>
				<%=getTran(request,"web","show.unlinked.beacons",sWebLanguage) %>
				&nbsp;&nbsp;&nbsp;<img style='vertical-align: middle' height='16px' src='<%=sCONTEXTPATH %>/_img/icons/mobile/refresh.png' title='<%=getTranNoLink("web","refresh",sWebLanguage) %>' onclick='showBeacons()'/>
			</td>
		</tr>
	</table>
	<table width='100%' class='sortable' id=sortable>
		<thead>
			<tr class='admin'>
				<td>#</td>
				<td><%=getTran(request,"web","beaconid",sWebLanguage) %></td>
				<td><%=getTran(request,"web","alias",sWebLanguage) %></td>
				<td><%=SH.capitalize(getTran(request,"web","comment",sWebLanguage)) %></td>
				<td><%=getTran(request,"web","rssi",sWebLanguage) %></td>
				<td><%=SH.capitalize(getTran(request,"web","since",sWebLanguage)) %></td>
				<td><%=SH.capitalize(getTran(request,"web","duration",sWebLanguage)) %></td>
			</tr>
		</thead>
		<tbody id='beaconRecordings'>
		</tbody>
	</table>
	
</form>

<script>
  function checkCriteria(){
	  if(document.getElementById("showUnidentified").checked){
		  document.getElementById("showUnidentified").tag=document.getElementById("showUnlinked").checked;
		  document.getElementById("showUnlinked").checked=true;
		  document.getElementById("showUnlinked").disabled=true;
	  }
	  else{
		  document.getElementById("showUnlinked").checked=document.getElementById("showUnidentified").tag;
		  document.getElementById("showUnlinked").disabled=false;
	  }
	  showBeacons();
  }
  function showBeacons(){
    var url = "<c:url value='/patienttracking/ajax/getBeaconRecordings.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "readerid="+document.getElementById("reader").value+"&showunidentified="+document.getElementById("showUnidentified").checked+"&showunlinked="+document.getElementById("showUnlinked").checked,
      onSuccess: function(resp){
        $("beaconRecordings").innerHTML = resp.responseText;
        window.clearTimeout(timer);
        timer=window.setTimeout("showBeacons();",30000);
      },
      onFailure: function(resp){
        $("beaconRecordings").innerHTML = "Error in '/patienttracking/ajax/getBeaconRecordings.jsp' : "+resp.responseText.trim();
      }
    });
  }
  function openPatientRecord(id){
	  window.location.href='<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&PersonID='+id;
  }
  
  var timer = window.setTimeout("showBeacons();",500);
  
</script>