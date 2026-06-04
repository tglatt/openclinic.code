<%@page import="be.openclinic.assets.Util"%>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %><table width='100%'>
<%
	String site = checkString(request.getParameter("site"));
	if(site.equalsIgnoreCase("-1")){
		site="%";
	}
	java.util.Date dBegin = ScreenHelper.parseDate(request.getParameter("begin"));
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(request.getParameter("end")).getTime()+SH.getTimeDay());
%>
	<!-- FEVER -->
	<tr class='admin'><td colspan='3'><%=getTran(request,"web","numberofcases",sWebLanguage) %></td></tr>
	<%
		//First the non-malaria fevers
		int count=0;
		String sSql = "select count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='fever' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
		Connection conn = SH.getStatsConnection();
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		ResultSet rs = ps.executeQuery();
		if (rs.next()){
			count=rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","fevernomalaria",sWebLanguage)+"</td><td class='admin2' width='10%'><span id='feverNoMalaria' style='font-size:12px;font-weight: bolder'>"+count+"</span></td><td class='admin2' rowspan='4'><table><tr><td width='200px'><canvas id='allCasesChart' width='200px' height='200px'></canvas></td><td width='200px'><canvas id='malariaFeverChart' width='200px' height='200px'></td><td width='200px'></canvas><canvas id='malariaFeverLine' width='300px' height='200px'></canvas></td></tr></table></td></tr>");

		sSql = "select count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		if (rs.next()){
			count=rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","simplemalaria",sWebLanguage)+"</td><td class='admin2'><span id='feverSimpleMalaria' style='font-size:12px;font-weight: bolder'>"+count+"</span></td></tr>");
		
		sSql = "select count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		if (rs.next()){
			count=rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","severemalaria",sWebLanguage)+"</td><td class='admin2'><span id='feverSevereMalaria' style='font-size:12px;font-weight: bolder'>"+count+"</span></td></tr>");
		
		sSql = "select count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%3%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		if (rs.next()){
			count=rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","othermalaria",sWebLanguage)+"</td><td class='admin2'><span id='feverOtherMalaria' style='font-size:12px;font-weight: bolder'>"+count+"</span></td></tr>");
		
		sSql = "select count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_TEMPERATURE>=38 and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		if (rs.next()){
			count=rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<span style='display: none' id='feverSimpleMalaria'>"+count+"</span>");
		
		sSql = "select count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and (OC_MALARIASTATS_TEMPERATURE is null or OC_MALARIASTATS_TEMPERATURE<38) and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		if (rs.next()){
			count=rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<span style='display: none' id='noFeverSimpleMalaria'>"+count+"</span>");
		
		sSql = "select count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_TEMPERATURE>=38 and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		if (rs.next()){
			count=rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<span style='display: none' id='feverSevereMalaria'>"+count+"</span>");
		
		sSql = "select count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and (OC_MALARIASTATS_TEMPERATURE is null or OC_MALARIASTATS_TEMPERATURE<38) and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		if (rs.next()){
			count=rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<span style='display: none' id='noFeverSevereMalaria'>"+count+"</span>");
		
		sSql = "SELECT floor(oc_malariastats_temperature*2) temperature,COUNT(*) total FROM oc_malariastats where oc_malariastats_temperature is not null and OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? GROUP BY floor(oc_malariastats_temperature*2)";
		int[] fevers = new int[6];
		int allfevers = 0;
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		while (rs.next()){
			int temp = rs.getInt("temperature");
			int total = rs.getInt("total");
			allfevers+=total;
			if(temp<76){
				fevers[0]+=total;
			}
			else if(temp<77){
				fevers[1]+=total;
			}
			else if(temp<78){
				fevers[2]+=total;
			}
			else if(temp<79){
				fevers[3]+=total;
			}
			else if(temp<80){
				fevers[4]+=total;
			}
			else {
				fevers[5]+=total;
			}
		}
		rs.close();
		ps.close();
		String s="";
		for(int n=0;n<6;n++){
			if(n>0){
				s+=",";
			}
			if(fevers[n]>0){
				s+=(fevers[n]*100/allfevers);
			}
		}
		out.println("<input type='hidden' id='simpleMalariaTemperatures' value='"+s+"'/>");
		
		sSql = "SELECT floor(oc_malariastats_temperature*2) temperature,COUNT(*) total FROM oc_malariastats where oc_malariastats_temperature is not null and OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? GROUP BY floor(oc_malariastats_temperature*2)";
		fevers = new int[6];
		allfevers = 0;
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		while (rs.next()){
			int temp = rs.getInt("temperature");
			int total = rs.getInt("total");
			allfevers+=total;
			if(temp<76){
				fevers[0]+=total;
			}
			else if(temp<77){
				fevers[1]+=total;
			}
			else if(temp<78){
				fevers[2]+=total;
			}
			else if(temp<79){
				fevers[3]+=total;
			}
			else if(temp<80){
				fevers[4]+=total;
			}
			else {
				fevers[5]+=total;
			}
		}
		rs.close();
		ps.close();
		s="";
		for(int n=0;n<6;n++){
			if(n>0){
				s+=",";
			}
			if(fevers[n]>0){
				s+=(fevers[n]*100/allfevers);
			}
		}
		out.println("<input type='hidden' id='severeMalariaTemperatures' value='"+s+"'/>");
		
		sSql = "SELECT floor(oc_malariastats_temperature*2) temperature,COUNT(*) total FROM oc_malariastats where oc_malariastats_temperature is not null and OC_MALARIASTATS_TYPE='fever' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? GROUP BY floor(oc_malariastats_temperature*2)";
		fevers = new int[6];
		allfevers = 0;
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		while (rs.next()){
			int temp = rs.getInt("temperature");
			int total = rs.getInt("total");
			allfevers+=total;
			if(temp<76){
				fevers[0]+=total;
			}
			else if(temp<77){
				fevers[1]+=total;
			}
			else if(temp<78){
				fevers[2]+=total;
			}
			else if(temp<79){
				fevers[3]+=total;
			}
			else if(temp<80){
				fevers[4]+=total;
			}
			else {
				fevers[5]+=total;
			}
		}
		rs.close();
		ps.close();
		s=",";
		for(int n=1;n<6;n++){
			if(n>1){
				s+=",";
			}
			if(fevers[n]>0){
				s+=(fevers[n]*100/allfevers);
			}
		}
		out.println("<input type='hidden' id='feverNoMalariaTemperatures' value='"+s+"'/>");
		
		conn.close();
	%>
</table>

