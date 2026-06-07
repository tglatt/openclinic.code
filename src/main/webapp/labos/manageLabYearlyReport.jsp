<%@include file="/includes/validateUser.jsp"%>
<%
	String sBegin=SH.p(request,"start");
	int year = Integer.parseInt(sBegin.substring(6, 10));
%>
<table width='100%'>
	<tr class='admin'>
		<td width='28%'><%=getTran(request,"web","year",sWebLanguage)+": "+year %></td>
		<td width='6%'><%=getTran(request,"web","january",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","february",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","march",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","april",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","may",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","june",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","july",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","august",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","september",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","october",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","november",sWebLanguage) %></td>
		<td width='6%'><%=getTran(request,"web","december",sWebLanguage) %></td>
	</tr>
	<%
	int[] totals = new int[13];
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = null;
	ResultSet rs = null;
	out.println("<tr><td class='admin'>"+getTran(request,"web","totalpatients",sWebLanguage)+"</td>");
	ps=conn.prepareStatement("select count(distinct patientid) total, month(resultdate) month from requestedlabanalyses where"+
			" resultdate>=? and resultdate<? and "+
			" length(resultvalue)>0 group by month order by month");
	ps.setDate(1,SH.getSQLDate("01/01/"+year));
	ps.setDate(2,SH.getSQLDate("01/01/"+(year+1)));
	rs=ps.executeQuery();
	int month=1;
	while(rs.next()){
		int m = rs.getInt("month");
		while(m>month){
			out.println("<td class='admin2'>0</td>");
			totals[month]=0;
			month++;
		}
		out.println("<td class='admin2'>"+rs.getInt("total")+"</td>");
		totals[month]=rs.getInt("total");
		month++;
	}
	while(13>month){
		out.println("<td class='admin2'>0</td>");
		totals[month]=0;
		month++;
	}
	out.println("</tr>");
	rs.close();
	ps.close();
	out.println("<tr><td class='admin'>&nbsp;&nbsp;&nbsp;&nbsp;"+getTran(request,"web","male",sWebLanguage)+"</td>");
	ps=conn.prepareStatement("select count(distinct patientid) total, month(resultdate) month from requestedlabanalyses,adminview where"+
			" personid=patientid and gender='m' and resultdate>=? and resultdate<? and "+
			" length(resultvalue)>0 group by month order by month");
	ps.setDate(1,SH.getSQLDate("01/01/"+year));
	ps.setDate(2,SH.getSQLDate("01/01/"+(year+1)));
	rs=ps.executeQuery();
	month=1;
	while(rs.next()){
		int m = rs.getInt("month");
		while(m>month){
			out.println("<td class='admin2'>0</td>");
			month++;
		}
		out.println("<td class='admin2'>"+rs.getInt("total")+"</td>");
		month++;
	}
	while(13>month){
		out.println("<td class='admin2'>0</td>");
		month++;
	}
	out.println("</tr>");
	rs.close();
	ps.close();
	out.println("<tr><td class='admin'>&nbsp;&nbsp;&nbsp;&nbsp;"+getTran(request,"web","female",sWebLanguage)+"</td>");
	ps=conn.prepareStatement("select count(distinct patientid) total, month(resultdate) month from requestedlabanalyses,adminview where"+
			" personid=patientid and gender='f' and resultdate>=? and resultdate<? and "+
			" length(resultvalue)>0 group by month order by month");
	ps.setDate(1,SH.getSQLDate("01/01/"+year));
	ps.setDate(2,SH.getSQLDate("01/01/"+(year+1)));
	rs=ps.executeQuery();
	month=1;
	while(rs.next()){
		int m = rs.getInt("month");
		while(m>month){
			out.println("<td class='admin2'>0</td>");
			month++;
		}
		out.println("<td class='admin2'>"+rs.getInt("total")+"</td>");
		month++;
	}
	while(13>month){
		out.println("<td class='admin2'>0</td>");
		month++;
	}
	out.println("</tr>");
	rs.close();
	ps.close();
	out.println("<tr><td class='admin'>&nbsp;&nbsp;&nbsp;&nbsp;"+getTran(request,"web","children",sWebLanguage)+"</td>");
	ps=conn.prepareStatement("select count(distinct patientid) total, month(resultdate) month from requestedlabanalyses,adminview where"+
			" personid=patientid and resultdate>=? and resultdate<? and datediff(resultdate,dateofbirth)<? and "+
			" length(resultvalue)>0 group by month order by month");
	ps.setDate(1,SH.getSQLDate("01/01/"+year));
	ps.setDate(2,SH.getSQLDate("01/01/"+(year+1)));
	ps.setInt(3,365*SH.ci("childAgeLimit",14));
	rs=ps.executeQuery();
	month=1;
	while(rs.next()){
		int m = rs.getInt("month");
		while(m>month){
			out.println("<td class='admin2'>0</td>");
			month++;
		}
		out.println("<td class='admin2'>"+rs.getInt("total")+"</td>");
		month++;
	}
	while(13>month){
		out.println("<td class='admin2'>0</td>");
		month++;
	}
	out.println("</tr>");
	rs.close();
	ps.close();
	out.println("<tr><td class='admin'>&nbsp;&nbsp;&nbsp;&nbsp;"+getTran(request,"web","adults",sWebLanguage)+"</td>");
	ps=conn.prepareStatement("select count(distinct patientid) total, month(resultdate) month from requestedlabanalyses,adminview where"+
			" personid=patientid and resultdate>=? and resultdate<? and datediff(resultdate,dateofbirth)>=? and "+
			" length(resultvalue)>0 group by month order by month");
	ps.setDate(1,SH.getSQLDate("01/01/"+year));
	ps.setDate(2,SH.getSQLDate("01/01/"+(year+1)));
	ps.setInt(3,365*SH.ci("childAgeLimit",14));
	rs=ps.executeQuery();
	month=1;
	while(rs.next()){
		int m = rs.getInt("month");
		while(m>month){
			out.println("<td class='admin2'>0</td>");
			month++;
		}
		out.println("<td class='admin2'>"+rs.getInt("total")+"</td>");
		month++;
	}
	while(13>month){
		out.println("<td class='admin2'>0</td>");
		month++;
	}
	out.println("</tr>");
	rs.close();
	ps.close();
	out.println("<tr><td class='admin'>&nbsp;&nbsp;&nbsp;&nbsp;"+getTran(request,"web","external",sWebLanguage)+"</td>");
	ps=conn.prepareStatement("select count(distinct patientid) total, month(resultdate) month"+
			" from requestedlabanalyses l, transactions t, items i where"+
			" resultdate>=? and resultdate<? and "+
			" l.transactionid=t.transactionid AND"+
			" i.transactionid=t.transactionid AND"+
			" i.serverid=t.serverid AND"+
			" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EXTERNAL' AND"+
			" i.value='medwan.common.true' AND"+
			" length(resultvalue)>0 group by month order by month");
	ps.setDate(1,SH.getSQLDate("01/01/"+year));
	ps.setDate(2,SH.getSQLDate("01/01/"+(year+1)));
	rs=ps.executeQuery();
	month=1;
	while(rs.next()){
		int m = rs.getInt("month");
		while(m>month){
			out.println("<td class='admin2'>0</td>");
			month++;
		}
		out.println("<td class='admin2'>"+rs.getInt("total")+"</td>");
		month++;
	}
	while(13>month){
		out.println("<td class='admin2'>0</td>");
		month++;
	}
	out.println("</tr>");
	rs.close();
	ps.close();
	out.println("<tr><td class='admin'>&nbsp;&nbsp;&nbsp;&nbsp;"+getTran(request,"web","internal",sWebLanguage)+"</td>");
	ps=conn.prepareStatement("select count(distinct patientid) total, month(resultdate) month"+
			" from requestedlabanalyses l, transactions t, items i where"+
			" resultdate>=? and resultdate<? and "+
			" l.transactionid=t.transactionid AND"+
			" i.transactionid=t.transactionid AND"+
			" i.serverid=t.serverid AND"+
			" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EXTERNAL' AND"+
			" i.value='medwan.common.true' AND"+
			" length(resultvalue)>0 group by month order by month");
	ps.setDate(1,SH.getSQLDate("01/01/"+year));
	ps.setDate(2,SH.getSQLDate("01/01/"+(year+1)));
	rs=ps.executeQuery();
	month=1;
	while(rs.next()){
		int m = rs.getInt("month");
		while(m>month){
			out.println("<td class='admin2'>"+totals[month]+"</td>");
			month++;
		}
		out.println("<td class='admin2'>"+(totals[month]-rs.getInt("total"))+"</td>");
		month++;
	}
	while(13>month){
		out.println("<td class='admin2'>"+totals[month]+"</td>");
		month++;
	}
	out.println("</tr><tr><td colspan='13'><hr/></td></tr>");
	rs.close();
	ps.close();
	
	String sDoc = SH.cs("templateSource","")+SH.cs("lab.report.3.xml","lab.report.ml.3.xml");
	SAXReader reader = new SAXReader(false);
	Document document = reader.read(new URL(sDoc));
	Element root = document.getRootElement();
	Iterator elements = root.elementIterator();
	while(elements.hasNext()){
		Element element = (Element)elements.next();
		if(element.getName().equals("title")){
			%>
			<tr class='admin'>
				<td width='28%'><%=element.getText() %></td>
				<td width='6%'><%=getTran(request,"web","january",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","february",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","march",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","april",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","may",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","june",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","july",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","august",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","september",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","october",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","november",sWebLanguage) %></td>
				<td width='6%'><%=getTran(request,"web","december",sWebLanguage) %></td>
			</tr>
			<%
		}
		else if(element.getName().equals("analysis")){
			String codes=element.attributeValue("codes").replaceAll(";","','");
			String analysisName=element.getText();
			out.println("<tr><td class='admin'>&nbsp;&nbsp;&nbsp;&nbsp;"+analysisName+"</td>");
			ps=conn.prepareStatement("select count(distinct transactionid) total, month(resultdate) month from requestedlabanalyses,adminview where"+
					" personid=patientid and resultdate>=? and resultdate<? and analysiscode in ('"+codes+"') and "+
					" length(resultvalue)>0 group by month order by month");
			ps.setDate(1,SH.getSQLDate("01/01/"+year));
			ps.setDate(2,SH.getSQLDate("01/01/"+(year+1)));
			rs=ps.executeQuery();
			month=1;
			while(rs.next()){
				int m = rs.getInt("month");
				while(m>month){
					out.println("<td class='admin2'>0</td>");
					month++;
				}
				out.println("<td class='admin2'>"+rs.getInt("total")+"</td>");
				month++;
			}
			while(13>month){
				out.println("<td class='admin2'>0</td>");
				month++;
			}
			out.println("</tr>");
			rs.close();
			ps.close();
		}
	}
	
	
	
	
	conn.close();
%>