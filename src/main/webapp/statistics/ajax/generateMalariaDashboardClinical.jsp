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
<!-- CLINICAL -->
<tr class='admin'><td colspan='3'><%=getTran(request,"web","clinicalsigns",sWebLanguage) %></td></tr>
<%
	int[] signs = new int[15];
	int count=0;
	String sSql = "select OC_MALARIASTATS_SEVERITYSIGNS from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	Connection conn = SH.getStatsConnection();
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	ResultSet rs = ps.executeQuery();
	while (rs.next()){
		count++;
		if(SH.c(rs.getString("OC_MALARIASTATS_SEVERITYSIGNS")).length()==0){
			signs[14]++;
		}
		else{
			String[] ss = rs.getString("OC_MALARIASTATS_SEVERITYSIGNS").split(";");
			for(int n=0;n<ss.length;n++){
				signs[Integer.parseInt(ss[n])-1]++;
			}
		}
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","simplemalariaseveritysigns",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+(count-signs[14])+" ("+(count==0?"?":((count-signs[14])*100/count))+"%)</span></td><td class='admin2' rowspan='2'><table><tr><td width='800px'><canvas id='malariaSeveritySignsChart' width='800px' height='200px'></canvas></td></tr></table></td></tr>");
	String s="";
	for(int n=0;n<14;n++){
		if(n!=4){
			if(n>0){
				s+=",";
			}
			s+=signs[n];
		}
	}
	out.println("<input type='hidden' id='simpleMalariaSeveritySigns' value='"+s+"'/>");

	signs = new int[15];
 	count=0;
	sSql = "select OC_MALARIASTATS_SEVERITYSIGNS from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		count++;
		if(SH.c(rs.getString("OC_MALARIASTATS_SEVERITYSIGNS")).length()==0){
			signs[14]++;
		}
		else{
			String[] ss = rs.getString("OC_MALARIASTATS_SEVERITYSIGNS").split(";");
			for(int n=0;n<ss.length;n++){
				signs[Integer.parseInt(ss[n])-1]++;
			}
		}
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","severemalariaseveritysigns",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+(count-signs[14])+" ("+(count==0?"?":((count-signs[14])*100/count))+"%)</span></td></tr>");
	s="";
	for(int n=0;n<14;n++){
		if(n!=4){
			if(n>0){
				s+=",";
			}
			s+=signs[n];
		}
	}
	out.println("<input type='hidden' id='severeMalariaSeveritySigns' value='"+s+"'/>");

	signs = new int[7];
 	count=0;
	sSql = "select OC_MALARIASTATS_OTHERSIGNS from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		count++;
		if(SH.c(rs.getString("OC_MALARIASTATS_OTHERSIGNS")).length()==0){
			signs[6]++;
		}
		else{
			String[] ss = rs.getString("OC_MALARIASTATS_OTHERSIGNS").split(";");
			for(int n=0;n<ss.length;n++){
				signs[Integer.parseInt(ss[n])-1]++;
			}
		}
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","simplemalariaothersigns",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+(count-signs[6])+" ("+(count==0?"?":((count-signs[6])*100/count))+"%)</span></td><td class='admin2' rowspan='2'><table><tr><td width='800px'><canvas id='malariaOtherSignsChart' width='800px' height='200px'></canvas></td></tr></table></td></tr>");
	s="";
	for(int n=0;n<7;n++){
		if(n>0){
			s+=",";
		}
		s+=signs[n];
	}
	out.println("<input type='hidden' id='simpleMalariaOtherSigns' value='"+s+"'/>");

	signs = new int[7];
 	count=0;
	sSql = "select OC_MALARIASTATS_OTHERSIGNS from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		count++;
		if(SH.c(rs.getString("OC_MALARIASTATS_OTHERSIGNS")).length()==0){
			signs[6]++;
		}
		else{
			String[] ss = rs.getString("OC_MALARIASTATS_OTHERSIGNS").split(";");
			for(int n=0;n<ss.length;n++){
				signs[Integer.parseInt(ss[n])-1]++;
			}
		}
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","severemalariaothersigns",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+(count-signs[6])+" ("+(count==0?"?":((count-signs[6])*100/count))+"%)</span></td></tr>");
	s="";
	for(int n=0;n<7;n++){
		if(n>0){
			s+=",";
		}
		s+=signs[n];
	}
	out.println("<input type='hidden' id='severeMalariaOtherSigns' value='"+s+"'/>");

	conn.close();
%>
