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
	<!-- ENCOUNTERS -->
	<tr class='admin'><td colspan='3'><%=getTran(request,"web","encounters",sWebLanguage) %></td></tr>
	<%
	int simplevisit=0,simpleadmission=0,severevisit=0,severeadmission=0;
	String sSql = "select count(*) total, OC_MALARIASTATS_ENCOUNTERTYPE,OC_MALARIASTATS_MALARIADIAGNOSIS from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by OC_MALARIASTATS_ENCOUNTERTYPE, OC_MALARIASTATS_MALARIADIAGNOSIS";
	Connection conn = SH.getStatsConnection();
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	ResultSet rs = ps.executeQuery();
	while (rs.next()){
		if(SH.c(rs.getString("OC_MALARIASTATS_ENCOUNTERTYPE")).equalsIgnoreCase("visit")){
			if(SH.c(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS")).contains("1")){
				simplevisit=rs.getInt("total");
			}
			else if(SH.c(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS")).contains("2")){
				severevisit=rs.getInt("total");
			}
		}
		else if(SH.c(rs.getString("OC_MALARIASTATS_ENCOUNTERTYPE")).equalsIgnoreCase("admission")){
			if(SH.c(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS")).contains("1")){
				simpleadmission=rs.getInt("total");
			}
			else if(SH.c(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS")).contains("2")){
				severeadmission=rs.getInt("total");
			}
		}
	}
	rs.close();
	ps.close();
	String s=simplevisit+","+simpleadmission+","+severevisit+","+severeadmission;
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","simplemalariavisits",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+simplevisit+"</span></td><td class='admin2' rowspan='8'><table><tr><td width='200px'><canvas id='malariaEncountersChart' width='200px' height='200px'></canvas></td><td width='200px'><canvas id='malariaGendersChart' width='200px' height='200px'></canvas></td><td width='200px'><canvas id='malariaAgeChart' width='400px' height='200px'></canvas></td></tr></table></td></tr>");
	out.println("<input type='hidden' id='malariaEncounters' value='"+s+"'/>");
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","simplemalariaadmissions",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+simpleadmission+"</span></td></tr>");
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","severemalariavisits",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+severevisit+"</span></td></tr>");
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","severemalariaadmissions",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+severeadmission+"</span></td></tr>");
	
	int malesimple=0, malesevere=0,femalesimple=0,femalesevere=0;
	sSql = "select count(*) total, OC_MALARIASTATS_GENDER,OC_MALARIASTATS_MALARIADIAGNOSIS from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by OC_MALARIASTATS_GENDER, OC_MALARIASTATS_MALARIADIAGNOSIS";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		if(SH.c(rs.getString("OC_MALARIASTATS_GENDER")).equalsIgnoreCase("F")){
			if(SH.c(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS")).contains("1")){
				femalesimple=rs.getInt("total");
			}
			else if(SH.c(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS")).contains("2")){
				femalesevere=rs.getInt("total");
			}
		}
		else if(SH.c(rs.getString("OC_MALARIASTATS_GENDER")).equalsIgnoreCase("M")){
			if(SH.c(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS")).contains("1")){
				malesimple=rs.getInt("total");
			}
			else if(SH.c(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS")).contains("2")){
				malesevere=rs.getInt("total");
			}
		}
	}
	rs.close();
	ps.close();
	s=malesimple+","+malesevere+","+femalesimple+","+femalesevere;
	out.println("<input type='hidden' id='malariaGenders' value='"+s+"'/>");
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","malesimplemalaria",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+malesimple+"</span></td></tr>");
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","maleseveremalaria",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+malesevere+"</span></td></tr>");
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","femalesimplemalaria",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+femalesimple+"</span></td></tr>");
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","femaleseveremalaria",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+femalesevere+"</span></td></tr>");
	
	int[] ages = {0,0,0,0,0};
	sSql = "select count(*) total, FLOOR(OC_MALARIASTATS_AGE/5) age from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by FLOOR(OC_MALARIASTATS_AGE/5)";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		int age = rs.getInt("age");
		if(age>=8){
			ages[4]+=rs.getInt("total");
		}
		else if(age>=3){
			ages[3]+=rs.getInt("total");
		}
		else if(age>=2){
			ages[2]+=rs.getInt("total");
		}
		else if(age>=1){
			ages[1]+=rs.getInt("total");
		}
		else {
			ages[0]+=rs.getInt("total");
		}
	}
	rs.close();
	ps.close();
	s=ages[0]+","+ages[1]+","+ages[2]+","+ages[3]+","+ages[4];
	out.println("<input type='hidden' id='simpleMalariaAge' value='"+s+"'/>");

	for(int n=0;n<5;n++){
		ages[n]=0;
	}
	sSql = "select count(*) total, FLOOR(OC_MALARIASTATS_AGE/5) age from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by FLOOR(OC_MALARIASTATS_AGE/5)";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		int age = rs.getInt("age");
		if(age>=8){
			ages[4]+=rs.getInt("total");
		}
		else if(age>=3){
			ages[3]+=rs.getInt("total");
		}
		else if(age>=2){
			ages[2]+=rs.getInt("total");
		}
		else if(age>=1){
			ages[1]+=rs.getInt("total");
		}
		else {
			ages[0]+=rs.getInt("total");
		}
	}
	rs.close();
	ps.close();
	s=ages[0]+","+ages[1]+","+ages[2]+","+ages[3]+","+ages[4];
	out.println("<input type='hidden' id='severeMalariaAge' value='"+s+"'/>");

	for(int n=0;n<5;n++){
		ages[n]=0;
	}
	sSql = "select count(*) total, FLOOR(OC_MALARIASTATS_AGE/5) age from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='fever' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by FLOOR(OC_MALARIASTATS_AGE/5)";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		int age = rs.getInt("age");
		if(age>=8){
			ages[4]+=rs.getInt("total");
		}
		else if(age>=3){
			ages[3]+=rs.getInt("total");
		}
		else if(age>=2){
			ages[2]+=rs.getInt("total");
		}
		else if(age>=1){
			ages[1]+=rs.getInt("total");
		}
		else {
			ages[0]+=rs.getInt("total");
		}
	}
	rs.close();
	ps.close();
	s=ages[0]+","+ages[1]+","+ages[2]+","+ages[3]+","+ages[4];
	out.println("<input type='hidden' id='feverNoMalariaAge' value='"+s+"'/>");

	conn.close();
%>