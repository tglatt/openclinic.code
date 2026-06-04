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
	<!-- TESTS -->
	<tr class='admin'><td colspan='3'><%=getTran(request,"web","labtests",sWebLanguage) %></td></tr>
<%
		int[] tdr= new int[4];
		String sSql = "select OC_MALARIASTATS_RAPIDTEST result,count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='fever' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by OC_MALARIASTATS_RAPIDTEST";
		Connection conn = SH.getStatsConnection();
		PreparedStatement ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		ResultSet rs = ps.executeQuery();
		while (rs.next()){
			if(SH.c(rs.getString("result")).equalsIgnoreCase("+")){
				tdr[0]=rs.getInt("total");
			}
			else if(SH.c(rs.getString("result")).equalsIgnoreCase("-")){
				tdr[1]=rs.getInt("total");
			}
			else{
				tdr[2]=rs.getInt("total");
			}
			tdr[3]+=rs.getInt("total");
		}
		rs.close();
		ps.close();
		int[] ge= new int[4];
		sSql = "select OC_MALARIASTATS_THICKSMEAR result,count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='fever' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by OC_MALARIASTATS_THICKSMEAR";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		while (rs.next()){
			if(SH.c(rs.getString("result")).equalsIgnoreCase("+")){
				ge[0]=rs.getInt("total");
			}
			else if(SH.c(rs.getString("result")).equalsIgnoreCase("-")){
				ge[1]=rs.getInt("total");
			}
			else{
				ge[2]=rs.getInt("total");
			}
			ge[3]+=rs.getInt("total");
		}
		rs.close();
		ps.close();
		String s = tdr[0]+","+tdr[1]+","+tdr[2]+","+ge[0]+","+ge[1]+","+ge[2];
		out.println("<tr><td class='admin' width='25%'>"+getTran(request,"malariastats","fevernomalariatests",sWebLanguage)+"</td><td class='admin2' width='10%'><span id='simplemalariarapidtest' style='font-size:12px;font-weight: bolder'>"+(tdr[0]+tdr[1])+"</span> / <span id='simplemalariathicksmear' style='font-size:12px;font-weight: bolder'>"+(ge[0]+ge[1])+"</span></td><td class='admin2' rowspan='6'><table><tr><td width='400px'><canvas id='malariaTestBar' width='400px' height='200px'></canvas></td><td width='400px'><canvas id='malariaTestBarPct' width='400px' height='200px'></canvas></td></tr></table></td></tr>");
		out.println("<tr><td class='admin' width='25%'>"+getTran(request,"malariastats","fevernomalariamissingtests",sWebLanguage)+"</td><td class='admin2'><span style='font-size:12px;font-weight: bolder'>"+tdr[2]+"</span> / <span style='font-size:12px;font-weight: bolder'>"+ge[2]+"</span></td></tr>");
		out.println("<input type='hidden' id='feverNoMalariaTests' value='"+s+"'/>");
		s = (tdr[3]==0?0:(tdr[0]*100)/tdr[3])+","+(tdr[3]==0?0:(tdr[1]*100)/tdr[3])+","+(tdr[3]==0?0:(tdr[2]*100)/tdr[3])+","+(ge[3]==0?0:(ge[0]*100)/ge[3])+","+(ge[3]==0?0:(ge[1]*100)/ge[3])+","+(ge[3]==0?0:(ge[2]*100)/ge[3]);
		out.println("<input type='hidden' id='feverNoMalariaTestsPct' value='"+s+"'/>");
		
		tdr= new int[4];
		sSql = "select OC_MALARIASTATS_RAPIDTEST result,count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%'  and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by OC_MALARIASTATS_RAPIDTEST";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		while (rs.next()){
			if(SH.c(rs.getString("result")).equalsIgnoreCase("+")){
				tdr[0]=rs.getInt("total");
			}
			else if(SH.c(rs.getString("result")).equalsIgnoreCase("-")){
				tdr[1]=rs.getInt("total");
			}
			else{
				tdr[2]=rs.getInt("total");
			}
			tdr[3]+=rs.getInt("total");
		}
		rs.close();
		ps.close();
		ge= new int[4];
		sSql = "select OC_MALARIASTATS_THICKSMEAR result,count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%1%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by OC_MALARIASTATS_THICKSMEAR";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		while (rs.next()){
			if(SH.c(rs.getString("result")).equalsIgnoreCase("+")){
				ge[0]=rs.getInt("total");
			}
			else if(SH.c(rs.getString("result")).equalsIgnoreCase("-")){
				ge[1]=rs.getInt("total");
			}
			else{
				ge[2]=rs.getInt("total");
			}
			ge[3]+=rs.getInt("total");
		}
		rs.close();
		ps.close();
		s = tdr[0]+","+tdr[1]+","+tdr[2]+","+ge[0]+","+ge[1]+","+ge[2];
		out.println("<input type='hidden' id='simpleMalariaTests' value='"+s+"'/>");
		s = (tdr[3]==0?0:(tdr[0]*100)/tdr[3])+","+(tdr[3]==0?0:(tdr[1]*100)/tdr[3])+","+(tdr[3]==0?0:(tdr[2]*100)/tdr[3])+","+(ge[3]==0?0:(ge[0]*100)/ge[3])+","+(ge[3]==0?0:(ge[1]*100)/ge[3])+","+(ge[3]==0?0:(ge[2]*100)/ge[3]);
		out.println("<input type='hidden' id='simpleMalariaTestsPct' value='"+s+"'/>");
		out.println("<tr><td class='admin' width='25%'>"+getTran(request,"malariastats","simplemalariatests",sWebLanguage)+"</td><td class='admin2'><span style='font-size:12px;font-weight: bolder'>"+(tdr[0]+tdr[1])+"</span> / <span style='font-size:12px;font-weight: bolder'>"+(ge[0]+ge[1])+"</span></td></tr>");
		out.println("<tr><td class='admin' width='25%'>"+getTran(request,"malariastats","simplemalariamissingtests",sWebLanguage)+"</td><td class='admin2'><span style='font-size:12px;font-weight: bolder'>"+tdr[2]+"</span> / <span style='font-size:12px;font-weight: bolder'>"+ge[2]+"</span></td></tr>");

		tdr= new int[4];
		sSql = "select OC_MALARIASTATS_RAPIDTEST result,count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%'  and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by OC_MALARIASTATS_RAPIDTEST";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		while (rs.next()){
			if(SH.c(rs.getString("result")).equalsIgnoreCase("+")){
				tdr[0]=rs.getInt("total");
			}
			else if(SH.c(rs.getString("result")).equalsIgnoreCase("-")){
				tdr[1]=rs.getInt("total");
			}
			else{
				tdr[2]=rs.getInt("total");
			}
			tdr[3]+=rs.getInt("total");
		}
		rs.close();
		ps.close();
		ge= new int[4];
		sSql = "select OC_MALARIASTATS_THICKSMEAR result,count(*) total from OC_MALARIASTATS where OC_MALARIASTATS_TYPE='malaria' and OC_MALARIASTATS_MALARIADIAGNOSIS like '%2%' and OC_MALARIASTATS_BEGIN>=? and OC_MALARIASTATS_BEGIN<? and OC_MALARIASTATS_SITE like ? group by OC_MALARIASTATS_THICKSMEAR";
		ps = conn.prepareStatement(sSql);
		ps.setTimestamp(1,SH.getSQLTimestamp(dBegin));
		ps.setTimestamp(2,SH.getSQLTimestamp(dEnd));
		ps.setString(3,site);
		rs = ps.executeQuery();
		while (rs.next()){
			if(SH.c(rs.getString("result")).equalsIgnoreCase("+")){
				ge[0]=rs.getInt("total");
			}
			else if(SH.c(rs.getString("result")).equalsIgnoreCase("-")){
				ge[1]=rs.getInt("total");
			}
			else{
				ge[2]=rs.getInt("total");
			}
			ge[3]+=rs.getInt("total");
		}
		rs.close();
		ps.close();
		s = tdr[0]+","+tdr[1]+","+tdr[2]+","+ge[0]+","+ge[1]+","+ge[2];
		out.println("<input type='hidden' id='severeMalariaTests' value='"+s+"'/>");
		s = (tdr[3]==0?0:(tdr[0]*100)/tdr[3])+","+(tdr[3]==0?0:(tdr[1]*100)/tdr[3])+","+(tdr[3]==0?0:(tdr[2]*100)/tdr[3])+","+(ge[3]==0?0:(ge[0]*100)/ge[3])+","+(ge[3]==0?0:(ge[1]*100)/ge[3])+","+(ge[3]==0?0:(ge[2]*100)/ge[3]);
		out.println("<input type='hidden' id='severeMalariaTestsPct' value='"+s+"'/>");
		out.println("<tr><td class='admin' width='25%'>"+getTran(request,"malariastats","severemalariatests",sWebLanguage)+"</td><td class='admin2'><span style='font-size:12px;font-weight: bolder'>"+(tdr[0]+tdr[1])+"</span> / <span style='font-size:12px;font-weight: bolder'>"+(ge[0]+ge[1])+"</span></td></tr>");
		out.println("<tr><td class='admin' width='25%'>"+getTran(request,"malariastats","severemalariamissingtests",sWebLanguage)+"</td><td class='admin2'><span style='font-size:12px;font-weight: bolder'>"+tdr[2]+"</span> / <span style='font-size:12px;font-weight: bolder'>"+ge[2]+"</span></td></tr>");
		
		conn.close();
%>