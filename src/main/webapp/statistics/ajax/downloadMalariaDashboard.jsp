<%@page import="be.openclinic.assets.Util"%>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %><table width='100%'>
<%!
	String getField(String s){
		String s2 = s.replaceAll(";","+");
		if(s2.endsWith("+")){
			s2=s2.substring(0,s2.length()-1);
		}
		return s2;
	}
%>
<%
	StringBuffer report = new StringBuffer();
	String site = checkString(request.getParameter("site"));
	if(site.equalsIgnoreCase("-1")){
		site="%";
	}
	java.util.Date dBegin = ScreenHelper.parseDate(request.getParameter("begin"));
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(request.getParameter("end")).getTime()+SH.getTimeDay());
	String sSql = "select * from OC_MALARIASTATS where OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ?";
	Connection conn = SH.getStatsConnection();
	PreparedStatement ps = conn.prepareStatement(sSql);
	ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
	ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
	ps.setString(3,site);
	ResultSet rs = ps.executeQuery();
	report.append("SITE;ID;TYPE;BEGIN;END;TEMPERATURE;SEVERITYSIGNS;OTHERSIGNS;MALARIADIAGNOSIS;MALARIATREATMENT;COMPLICATIONSTREATMENT;RAPIDTEST;THICKSMEAR;");
	report.append("COMPLICATIONSNEURO;COMPLICATIONSDIGESTIVE;COMPLICATIONSSKIN;COMPLICATIONSRESPIRATORY;GENDER;AGE;ENCOUNTERTYPE;LENGTHOFSTAY\n");
	while (rs.next()){
		report.append(rs.getString("OC_MALARIASTATS_SITE")+";");
		report.append(rs.getString("OC_MALARIASTATS_ID")+";");
		report.append(rs.getString("OC_MALARIASTATS_TYPE")+";");
		report.append(SH.formatDate(rs.getTimestamp("OC_MALARIASTATS_BEGIN"),"yyyy-MM-dd HH:mm:ss")+";");
		report.append(SH.formatDate(rs.getTimestamp("OC_MALARIASTATS_END"),"yyyy-MM-dd HH:mm:ss")+";");
		report.append(rs.getString("OC_MALARIASTATS_TEMPERATURE")+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_SEVERITYSIGNS"))+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_OTHERSIGNS"))+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_MALARIADIAGNOSIS"))+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_MALARIATREATMENT"))+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_COMPLICATIONSTREATMENT"))+";");
		report.append(rs.getString("OC_MALARIASTATS_RAPIDTEST")+";");
		report.append(rs.getString("OC_MALARIASTATS_THICKSMEAR")+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_COMPLICATIONSNEURO"))+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_COMPLICATIONSDIGESTIVE"))+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_COMPLICATIONSSKIN"))+";");
		report.append(getField(rs.getString("OC_MALARIASTATS_COMPLICATIONSRESPIRATORY"))+";");
		report.append(rs.getString("OC_MALARIASTATS_GENDER")+";");
		report.append(rs.getString("OC_MALARIASTATS_AGE")+";");
		report.append(rs.getString("OC_MALARIASTATS_ENCOUNTERTYPE")+";");
		report.append(rs.getString("OC_MALARIASTATS_LENGTHOFSTAY")+"\n");
	}
	rs.close();
	ps.close();
	conn.close();
    response.setContentType("application/octet-stream; charset=windows-1252");
    response.setHeader("Content-Disposition", "Attachment;Filename=\"OpenClinicStatistic"+new SimpleDateFormat("yyyyMMddHHmmss").format(new java.util.Date())+".csv\"");
    ServletOutputStream os = response.getOutputStream();
    byte[] b = report.toString().getBytes("ISO-8859-1");
    for(int n=0; n<b.length; n++){
        os.write(b[n]);
    }
    os.flush();
    os.close();
%>