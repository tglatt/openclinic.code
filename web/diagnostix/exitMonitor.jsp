<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.system.Beacon"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>
<form name='transactionForm' method='post'>
	<table width='100%'>
		<tr class='admin'>
			<td colspan='2'><%=getTran(request,"web","exitmonitor",sWebLanguage) %></td>
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
							out.println("<option value='"+rs.getString("oc_beacon_id")+"'>"+rs.getString("oc_beacon_alias")+" - "+rs.getString("oc_beacon_comment")+"</option>");
						}
						rs.close();
						ps.close();
						conn.close();
					%>
				</select>
			</td>
		</tr>
	</table>
	<div id='beaconRecordings'></div>
</form>

<script>
  function showBeacons(){
    if(timer) window.clearInterval(timer);
    var url = "<c:url value='/patienttracking/ajax/getExitBeaconRecordings.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,{
      method: "GET",
      parameters: "readerid="+document.getElementById("reader").value+"&showunidentified=true&showunlinked=true",
      onSuccess: function(resp){
        $("beaconRecordings").innerHTML = resp.responseText;
        if(resp.responseText.indexOf("<beep/>")>0){
        	beat.play();
        }
        timer=window.setInterval("showBeacons();",2000);
      },
      onFailure: function(resp){
        $("beaconRecordings").innerHTML = "Error in '/patienttracking/ajax/getBeaconRecordings.jsp' : "+resp.responseText.trim();
      }
    });
  }
  
  var beat= new Audio('<%=sCONTEXTPATH %>/_sound/alarm.mp3');
  
  var timer;
  
</script>