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
	<!-- TREATMENTS -->
	<tr class='admin'><td colspan='3'><%=getTran(request,"web","treatments",sWebLanguage) %></td></tr>
	<%
	int[] treatments = new int[8];
	int count=0;
	String sSql = "select OC_MALARIASTATS_MALARIATREATMENT from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	Connection conn = SH.getStatsConnection();
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	ResultSet rs = ps.executeQuery();
	while (rs.next()){
		count++;
		if(SH.c(rs.getString("OC_MALARIASTATS_MALARIATREATMENT")).length()==0){
			treatments[7]++;
		}
		else{
			String[] ss = rs.getString("OC_MALARIASTATS_MALARIATREATMENT").split(";");
			for(int n=0;n<ss.length;n++){
				treatments[Integer.parseInt(ss[n])-1]++;
			}
		}
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","simplemalariatreatments",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+(count-treatments[7])+" ("+(count==0?"?":((count-treatments[7])*100/count))+"%)</span></td><td class='admin2' rowspan='2'><table><tr><td width='800px'><canvas id='malariaTreatmentsChart' width='800px' height='200px'></canvas></td></tr></table></td></tr>");
	String s="";
	for(int n=0;n<7;n++){
		if(n!=3){
			if(n>0){
				s+=",";
			}
			s+=treatments[n];
		}
	}
	out.println("<input type='hidden' id='simpleMalariaTreatments' value='"+s+"'/>");
	
	treatments = new int[8];
	count=0;
	sSql = "select OC_MALARIASTATS_MALARIATREATMENT from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		count++;
		if(SH.c(rs.getString("OC_MALARIASTATS_MALARIATREATMENT")).length()==0){
			treatments[7]++;
		}
		else{
			String[] ss = rs.getString("OC_MALARIASTATS_MALARIATREATMENT").split(";");
			for(int n=0;n<ss.length;n++){
				treatments[Integer.parseInt(ss[n])-1]++;
			}
		}
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","severemalariatreatments",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+(count-treatments[7])+" ("+(count==0?"?":((count-treatments[7])*100/count))+"%)</span></td></tr>");
	s="";
	for(int n=0;n<7;n++){
		if(n!=3){
			if(n>0){
				s+=",";
			}
			s+=treatments[n];
		}
	}
	out.println("<input type='hidden' id='severeMalariaTreatments' value='"+s+"'/>");
	
	treatments = new int[7];
	count=0;
	sSql = "select OC_MALARIASTATS_COMPLICATIONSTREATMENT from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		count++;
		if(SH.c(rs.getString("OC_MALARIASTATS_COMPLICATIONSTREATMENT")).length()==0){
			treatments[6]++;
		}
		else{
			String[] ss = rs.getString("OC_MALARIASTATS_COMPLICATIONSTREATMENT").split(";");
			for(int n=0;n<ss.length;n++){
				treatments[Integer.parseInt(ss[n])-1]++;
			}
		}
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","simplemalariacomplicationstreatments",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+(count-treatments[6])+" ("+(count==0?"?":((count-treatments[6])*100/count))+"%)</span></td><td class='admin2' rowspan='2'><table><tr><td width='800px'><canvas id='malariaComplicationsTreatmentsChart' width='800px' height='200px'></canvas></td></tr></table></td></tr>");
	s="";
	for(int n=0;n<6;n++){
		if(n>0){
			s+=",";
		}
		s+=treatments[n];
	}
	out.println("<input type='hidden' id='simpleMalariaComplicationsTreatments' value='"+s+"'/>");
	
	treatments = new int[7];
	count=0;
	sSql = "select OC_MALARIASTATS_COMPLICATIONSTREATMENT from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	rs = ps.executeQuery();
	while (rs.next()){
		count++;
		if(SH.c(rs.getString("OC_MALARIASTATS_COMPLICATIONSTREATMENT")).length()==0){
			treatments[6]++;
		}
		else{
			String[] ss = rs.getString("OC_MALARIASTATS_COMPLICATIONSTREATMENT").split(";");
			for(int n=0;n<ss.length;n++){
				treatments[Integer.parseInt(ss[n])-1]++;
			}
		}
	}
	rs.close();
	ps.close();
	out.println("<tr><td class='admin' width='20%'>"+getTran(request,"malariastats","severemalariacomplicationstreatments",sWebLanguage)+"</td><td class='admin2' width='10%'><span style='font-size:12px;font-weight: bolder'>"+(count-treatments[6])+" ("+(count==0?"?":((count-treatments[6])*100/count))+"%)</span></td></tr>");
	s="";
	for(int n=0;n<6;n++){
		if(n>0){
			s+=",";
		}
		s+=treatments[n];
	}
	out.println("<input type='hidden' id='severeMalariaComplicationsTreatments' value='"+s+"'/>");

	conn.close();
%>