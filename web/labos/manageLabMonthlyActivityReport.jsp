<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran(request,"web","labgroup",sWebLanguage) %></td>
		<td><%=getTran(request,"web","consultations",sWebLanguage) %></td>
		<td><%=getTran(request,"web","admissions",sWebLanguage) %></td>
		<td><%=getTran(request,"web","admissionpercentage",sWebLanguage) %></td>
	</tr>
<%
	String sBegin=SH.p(request,"start");
	String sEnd=SH.p(request,"end");
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = null;
	ResultSet rs = null;
	String sDoc = SH.cs("templateSource","")+SH.cs("lab.report.1.xml","lab.report.ml.1.xml");
	SAXReader reader = new SAXReader(false);
	Document document = reader.read(new URL(sDoc));
	Element root = document.getRootElement();
	Iterator elements = root.elementIterator("group");
	double totalVisits=0,totalAdmissions=0;
	while(elements.hasNext()){
		Element group = (Element)elements.next();
		String groupname = group.getText();
		String ids = group.attributeValue("ids").replaceAll(";", "','");
		ps=conn.prepareStatement("SELECT count(DISTINCT t.transactionid) total FROM requestedlabanalyses l,transactions t,labanalysis a,items i,oc_encounters e WHERE"+
				" l.transactionid=t.transactionid AND"+
				" t.updatetime>=? AND"+
				" t.updatetime<? AND"+
				" length(l.resultvalue)>0 AND"+
				" l.analysiscode=a.labcode AND"+
				" i.transactionid=t.transactionid AND"+
				" i.serverid=t.serverid AND"+
				" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID' AND"+
				" e.OC_ENCOUNTER_OBJECTID=replace(i.value,i.serverid||'.','') AND"+
				" e.OC_ENCOUNTER_TYPE='visit' AND"+
				" labgroup IN ('"+ids+"')");
		ps.setDate(1,SH.toSQLDate(sBegin));
		ps.setDate(2,SH.toSQLDate(sEnd));
		rs=ps.executeQuery();
		if(rs.next()){
			totalVisits = rs.getInt("total");
		}
		rs.close();
		ps.close();
		ps=conn.prepareStatement("SELECT count(DISTINCT t.transactionid) total FROM requestedlabanalyses l,transactions t,labanalysis a,items i,oc_encounters e WHERE"+
				" l.transactionid=t.transactionid AND"+
				" t.updatetime>=? AND"+
				" t.updatetime<? AND"+
				" length(l.resultvalue)>0 AND"+
				" l.analysiscode=a.labcode AND"+
				" i.transactionid=t.transactionid AND"+
				" i.serverid=t.serverid AND"+
				" i.type='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID' AND"+
				" e.OC_ENCOUNTER_OBJECTID=replace(i.value,i.serverid||'.','') AND"+
				" e.OC_ENCOUNTER_TYPE='admission' AND"+
				" labgroup IN ('"+ids+"')");
		ps.setDate(1,SH.toSQLDate(sBegin));
		ps.setDate(2,SH.toSQLDate(sEnd));
		rs=ps.executeQuery();
		if(rs.next()){
			totalAdmissions = rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<tr>");
		out.println("<td class='admin'>"+groupname+"</td>");
		out.println("<td class='admin2'>"+totalVisits+"</td>");
		out.println("<td class='admin2'>"+totalAdmissions+"</td>");
		out.println("<td class='admin2'>"+(totalVisits+totalAdmissions==0?"":new DecimalFormat("#0.0").format(totalAdmissions*100/(totalVisits+totalAdmissions)))+"%</td>");
		out.println("</tr>");
	}
	if(rs!=null){
		rs.close();
	}
	if(ps!=null){
		ps.close();
	}
%>
</table>
<table width='100%'>
	<tr class='admin'>
		<td><%=getTran(request,"web","labexam",sWebLanguage) %></td>
		<td><%=getTran(request,"web","total",sWebLanguage) %></td>
		<td><%=getTran(request,"web","positive",sWebLanguage) %></td>
		<td><%=getTran(request,"web","positivepercentage",sWebLanguage) %></td>
	</tr>
<%
	sDoc = SH.cs("templateSource","")+SH.cs("lab.report.2.xml","lab.report.ml.2.xml");
	reader = new SAXReader(false);
	document = reader.read(new URL(sDoc));
	root = document.getRootElement();
	elements = root.elementIterator("analysis");
	double totalAnalysis=0,totalPositive=0;
	while(elements.hasNext()){
		Element analysis = (Element)elements.next();
		String analysisname = analysis.getText();
		String codes=analysis.attributeValue("codes").replaceAll(";","','");
		String positive = analysis.attributeValue("positive");
		ps=conn.prepareStatement("SELECT count(distinct l.transactionid) total FROM requestedlabanalyses l,transactions t WHERE"+
				" l.transactionid=t.transactionid AND"+
				" t.updatetime>=? AND"+
				" t.updatetime<? AND"+
				" length(l.resultvalue)>0 AND"+
				" analysiscode IN ('"+codes+"')");
		ps.setDate(1,SH.toSQLDate(sBegin));
		ps.setDate(2,SH.toSQLDate(sEnd));
		rs=ps.executeQuery();
		if(rs.next()){
			totalAnalysis = rs.getInt("total");
		}
		rs.close();
		ps.close();
		ps=conn.prepareStatement("SELECT count(distinct l.transactionid) total FROM requestedlabanalyses l,transactions t WHERE"+
				" l.transactionid=t.transactionid AND"+
				" t.updatetime>=? AND"+
				" t.updatetime<? AND"+
				" l.resultvalue=? AND"+
				" analysiscode IN ('"+codes+"')");
		ps.setDate(1,SH.toSQLDate(sBegin));
		ps.setDate(2,SH.toSQLDate(sEnd));
		ps.setString(3,positive);
		rs=ps.executeQuery();
		if(rs.next()){
			totalPositive = rs.getInt("total");
		}
		rs.close();
		ps.close();
		out.println("<tr>");
		out.println("<td class='admin'>"+analysisname+"</td>");
		out.println("<td class='admin2'>"+totalAnalysis+"</td>");
		out.println("<td class='admin2'>"+totalPositive+"</td>");
		out.println("<td class='admin2'>"+(totalAnalysis==0?"":new DecimalFormat("#0.0").format(totalPositive*100/totalAnalysis))+"%</td>");
		out.println("</tr>");
	}
	if(rs!=null){
		rs.close();
	}
	if(ps!=null){
		ps.close();
	}
	conn.close();
%>
</table>