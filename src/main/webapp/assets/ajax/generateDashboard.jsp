<%@page import="be.openclinic.assets.Util"%>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<table width='100%'>
<%
	String serviceUid = checkString(request.getParameter("service"));
	Service svc = Service.getService(serviceUid);
	String serviceuids = "";
	if(svc.getParentcode().length()>0){
		serviceuids = Service.getChildIdsAsString(serviceUid);
	}
	java.util.Date dBegin = ScreenHelper.parseDate(request.getParameter("begin"));
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(request.getParameter("end")).getTime()+SH.getTimeDay());
	Hashtable parameters = new Hashtable();
	int count =0, total=0;
%>
	<!-- COVERED STRUCTURES -->
	<tr class='admin'><td colspan='3'><%=getTran(request,"web","coveredstructures",sWebLanguage) %></td></tr>
	<%
	Connection conn = SH.getAdminConnection();
	String sSql = "select costcenter, count(*) total from services where serviceid in ("+serviceuids+") group by costcenter";
	if(svc.getParentcode().length()==0){
		sSql = "select costcenter, count(*) total from services where serviceid like '"+serviceUid+"%' group by costcenter";
	}
	PreparedStatement ps = conn.prepareStatement(sSql);
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		if(SH.c(rs.getString("costcenter")).length()>0){
			out.println("<tr><tr><td class='admin'>"+getTran(request, "costcenter", rs.getString("costcenter"), sWebLanguage)+"</td>");
			out.println("<td class='admin2'>"+rs.getInt("total")+"</td>");
			if(svc.getParentcode().length()>0){
				out.println("<td class='admin'>");
				sSql = "select distinct serviceid from services where serviceid in ("+serviceuids+") and costcenter=?";
				PreparedStatement ps2 = conn.prepareStatement(sSql);
				ps2.setString(1,rs.getString("costcenter"));
				ResultSet rs2 =ps2.executeQuery();
				boolean bInit=false;
				while(rs2.next()){
					if(bInit){
						out.println(" | ");
					}
					bInit=true;
					out.println(getTranNoLink("service",rs2.getString("serviceid"),sWebLanguage).replaceAll(" ", "&nbsp;"));
				}
				rs2.close();
				ps2.close();
				out.println("</td></tr>");
			}
			else{
				out.println("<td class='admin2'/></tr>");
			}
		}
	}
	rs.close();
	ps.close();
	%>
	<!-- INFRASTRUCTURE -->
	<tr class='admin'><td colspan='3'><%=getTran(request,"web","infrastructure",sWebLanguage) %></td></tr>
	<%
		HashSet goodstates = new HashSet();
		//First add the assets that are still in good state
		sSql = "select oc_asset_objectid,oc_asset_comment13 from oc_assets where oc_asset_comment9 in ('0','1') and oc_asset_service in ("+serviceuids+") and oc_asset_nomenclature like 'I.%' and oc_asset_updatetime<=?";
		if(svc.getParentcode().length()==0){
			sSql = "select oc_asset_objectid,oc_asset_comment13 from oc_assets where oc_asset_comment9 in ('0','1') and oc_asset_service like '"+serviceUid+"%' and oc_asset_nomenclature like 'I.%' and oc_asset_updatetime<=?";
		}
		conn = SH.getOpenClinicConnection();
		ps = conn.prepareStatement(sSql);
		ps.setDate(1,SH.toSQLDate(dEnd));
		rs = ps.executeQuery();
		while (rs.next()){
			try{
				java.util.Date od =SH.parseDate(rs.getString("oc_asset_comment13"));
				if(od!=null && od.after(dEnd)){
					continue;
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
			String id = rs.getString("oc_asset_objectid");
			goodstates.add(id);
		}
		rs.close();
		ps.close();
		HashSet badstates = new HashSet();
		//Now add assets that were in good state at the end of the analyzed period
		sSql = "select oc_asset_objectid,oc_asset_comment9,oc_asset_comment13 from oc_assetshistory where oc_asset_service in ("+serviceuids+") and oc_asset_nomenclature like 'I.%' and oc_asset_updatetime<=? order by oc_asset_updatetime desc";
		if(svc.getParentcode().length()==0){
			sSql = "select oc_asset_objectid,oc_asset_comment9,oc_asset_comment13 from oc_assetshistory where oc_asset_service like '"+serviceUid+"%' and oc_asset_nomenclature like 'I.%' and oc_asset_updatetime<=? order by oc_asset_updatetime desc";
		}
		ps = conn.prepareStatement(sSql);
		ps.setDate(1,SH.toSQLDate(dEnd));
		rs = ps.executeQuery();
		while (rs.next()){
			try{
				java.util.Date od =SH.parseDate(rs.getString("oc_asset_comment13"));
				if(od!=null && od.after(dEnd)){
					continue;
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
			String id = rs.getString("oc_asset_objectid");
			if(!goodstates.contains(id)){
				if(!badstates.contains(id)){
					String state = rs.getString("oc_asset_comment9");
					if(state.equalsIgnoreCase("0") || state.equalsIgnoreCase("1")){
						goodstates.add(id);
					}
					else{
						badstates.add(id);
					}
				}
			}
		}
		rs.close();
		ps.close();
		conn.close();
		count=goodstates.size();
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalingoodstate",sWebLanguage)+"</td><td class='admin2'><span id='infragoodstate'>"+count+"</span></td><td class='admin2' rowspan='8'><table><tr><td width='200px'><canvas id='infraStateChart' width='200px' height='200px'></canvas></td><td width='200px'><canvas id='infraOperationChart' width='200px' height='200px'></canvas></td><td width='200px'><canvas id='infraSuccessChart' width='200px' height='200px'></canvas></td><td></td></tr></table></td></tr>");
		HashSet active = new HashSet();
		sSql = "select oc_asset_objectid,oc_asset_comment13 from oc_assets where oc_asset_service in ("+serviceuids+") and oc_asset_nomenclature like 'I.%' and oc_asset_updatetime<=?";
		if(svc.getParentcode().length()==0){
			sSql = "select oc_asset_objectid,oc_asset_comment13 from oc_assets where oc_asset_service like '"+serviceUid+"%' and oc_asset_nomenclature like 'I.%' and oc_asset_updatetime<=?";
		}
		conn = SH.getOpenClinicConnection();
		ps = conn.prepareStatement(sSql);
		ps.setDate(1,SH.toSQLDate(dEnd));
		rs = ps.executeQuery();
		while (rs.next()){
			try{
				java.util.Date od =SH.parseDate(rs.getString("oc_asset_comment13"));
				if(od!=null && od.after(dEnd)){
					continue;
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
			String id = rs.getString("oc_asset_objectid");
			active.add(id);
		}
		rs.close();
		ps.close();
		sSql = "select oc_asset_objectid,oc_asset_comment13 from oc_assetshistory where oc_asset_service in ("+serviceuids+") and oc_asset_nomenclature like 'I.%' and oc_asset_updatetime<=? order by oc_asset_updatetime desc";
		if(svc.getParentcode().length()==0){
			sSql = "select oc_asset_objectid,oc_asset_comment13 from oc_assetshistory where oc_asset_service like '"+serviceUid+"%' and oc_asset_nomenclature like 'I.%' and oc_asset_updatetime<=? order by oc_asset_updatetime desc";
		}
		ps = conn.prepareStatement(sSql);
		ps.setDate(1,SH.toSQLDate(dEnd));
		rs = ps.executeQuery();
		while (rs.next()){
			try{
				java.util.Date od =SH.parseDate(rs.getString("oc_asset_comment13"));
				if(od!=null && od.after(dEnd)){
					continue;
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
			String id = rs.getString("oc_asset_objectid");
			if(!active.contains(id)){
				active.add(id);
			}
		}
		total=active.size();
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalinfrastructure",sWebLanguage)+"</td><td class='admin2'><span id='infratotalstate'>"+total+"</span></td></tr>");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","fractioningoodstate",sWebLanguage)+"</td><td class='admin2'><b style='font-size: 14px'>"+new DecimalFormat("#0.00").format(new Double(count)*100/new Double(total))+"%</b></td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'I.%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'1'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		int controlInfrastructureOperations=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalcontroloperations",sWebLanguage)+"</td><td class='admin2'><span id='infracontrol'>"+controlInfrastructureOperations+"</span></td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'I.%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'2'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		int preventativeInfrastructureOperations=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalpreventiveoperations",sWebLanguage)+"</td><td class='admin2'><span id='infrapreventative'>"+preventativeInfrastructureOperations+"</span></td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'I.%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'3'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		count=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalcorrectiveoperations",sWebLanguage)+"</td><td class='admin2'><span id='infracorrective'>"+count+"</span></td></tr>");
		parameters.put("oc_maintenanceoperation_result","equals;'ok'");
		count=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalsuccesfulcorrectiveoperations",sWebLanguage)+"</td><td class='admin2'><span id='infracorrectivesuccess'>"+count+"</span></td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'I.%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_asset_comment13 like '%/%/%' and str_to_date(oc_asset_comment13,'%d/%m/%Y')","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_asset_comment13 like '%/%/%' and str_to_date(oc_asset_comment13,'%d/%m/%Y')","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		count=Util.countAssets(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalupdates",sWebLanguage)+"</td><td class='admin2'>"+count+"</td></tr>");
	%>
	<!-- EQUIPMENT -->
	<tr class='admin'><td colspan='3'><%=getTran(request,"web","equipment",sWebLanguage) %></td></tr>
	<%
		int state1=0,state2=0,state3=0,state4=0,stateother=0;
		
		active = new HashSet();
		//First add the assets that are still in good state
		sSql = "select oc_asset_objectid,oc_asset_comment7,oc_asset_comment13 from oc_assets where oc_asset_service in ("+serviceuids+") and oc_asset_nomenclature like 'E%' and oc_asset_updatetime<=?";
		if(svc.getParentcode().length()==0){
			sSql = "select oc_asset_objectid,oc_asset_comment7,oc_asset_comment13 from oc_assets where oc_asset_service like '"+serviceUid+"%' and oc_asset_nomenclature like 'E%' and oc_asset_updatetime<=?";
		}
		conn.close();
		conn = SH.getOpenClinicConnection();
		ps = conn.prepareStatement(sSql);
		ps.setDate(1,SH.toSQLDate(dEnd));
		rs = ps.executeQuery();
		while (rs.next()){
			try{
				java.util.Date od =SH.parseDate(rs.getString("oc_asset_comment13"));
				if(od!=null && od.after(dEnd)){
					continue;
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
			String id = rs.getString("oc_asset_objectid");
			if("1".equalsIgnoreCase(rs.getString("oc_asset_comment7"))){
				state1++;
			}
			else if("2".equalsIgnoreCase(rs.getString("oc_asset_comment7"))){
				state2++;
			}
			else if("3".equalsIgnoreCase(rs.getString("oc_asset_comment7"))){
				state3++;
			}
			else if("4".equalsIgnoreCase(rs.getString("oc_asset_comment7"))){
				state4++;
			}
			else{
				stateother++;
			}
			active.add(id);
		}
		rs.close();
		ps.close();
		sSql = "select oc_asset_objectid,oc_asset_comment7,oc_asset_comment13 from oc_assetshistory where oc_asset_service in ("+serviceuids+") and oc_asset_nomenclature like 'E%' and oc_asset_updatetime<=? order by oc_asset_updatetime desc";
		if(svc.getParentcode().length()==0){
			sSql = "select oc_asset_objectid,oc_asset_comment7,oc_asset_comment13 from oc_assetshistory where oc_asset_service like '"+serviceUid+"%' and oc_asset_nomenclature like 'E%' and oc_asset_updatetime<=? order by oc_asset_updatetime desc";
		}
		ps = conn.prepareStatement(sSql);
		ps.setDate(1,SH.toSQLDate(dEnd));
		rs = ps.executeQuery();
		while (rs.next()){
			try{
				java.util.Date od =SH.parseDate(rs.getString("oc_asset_comment13"));
				if(od!=null && od.after(dEnd)){
					continue;
				}
			}
			catch(Exception e){
				e.printStackTrace();
			}
			String id = rs.getString("oc_asset_objectid");
			if(!active.contains(id)){
				if("1".equalsIgnoreCase(rs.getString("oc_asset_comment7"))){
					state1++;
				}
				else if("2".equalsIgnoreCase(rs.getString("oc_asset_comment7"))){
					state2++;
				}
				else if("3".equalsIgnoreCase(rs.getString("oc_asset_comment7"))){
					state3++;
				}
				else if("4".equalsIgnoreCase(rs.getString("oc_asset_comment7"))){
					state4++;
				}
				else{
					stateother++;
				}
				active.add(id);
			}
		}
		rs.close();
		ps.close();
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totaloperational",sWebLanguage)+"</td><td class='admin2'><span id='matgoodstate'>"+state1+"</span></td><td class='admin2' rowspan='8'><input type='hidden' id='state2' value='"+state2+"'/><input type='hidden' id='state3' value='"+state3+"'/><input type='hidden' id='state4' value='"+state4+"'/><table><tr><td width='200px'><canvas id='matStateChart' width='200px' height='200px'></canvas></td><td width='200px'><canvas id='matOperationChart' width='200px' height='200px'></canvas></td><td width='200px'><canvas id='matSuccessChart' width='200px' height='200px'></canvas></td><td></td></tr></table></td></tr>");
		total=state1+state2+state3+state4+stateother;
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalequipment",sWebLanguage)+"</td><td class='admin2'><span id='mattotalstate'>"+total+"</span></td></tr>");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","fractionoperational",sWebLanguage)+"</td><td class='admin2'><b style='font-size: 14px'>"+new DecimalFormat("#0.00").format(new Double(state1)*100/new Double(total))+"%</b></td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'1'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<='"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		int controloperations=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalcontroloperations",sWebLanguage)+"</td><td class='admin2'><span id='matcontrol'>"+controloperations+"</span></td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'2'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		int preventativeoperations=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalpreventiveoperations",sWebLanguage)+"</td><td class='admin2'><span id='matpreventative'>"+preventativeoperations+"</span></td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'3'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		count=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalcorrectiveoperations",sWebLanguage)+"</td><td class='admin2'><span id='matcorrective'>"+count+"</span></td></tr>");
		parameters.put("oc_maintenanceoperation_result","equals;'ok'");
		count=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalsuccesfulcorrectiveoperations",sWebLanguage)+"</td><td class='admin2'><span id='matcorrectivesuccess'>"+count+"</span></td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_asset_comment13 like '%/%/%' and str_to_date(oc_asset_comment13,'%d/%m/%Y')","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_asset_comment13 like '%/%/%' and str_to_date(oc_asset_comment13,'%d/%m/%Y')","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		count=Util.countAssets(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalnewequipment",sWebLanguage)+"</td><td class='admin2'>"+count+"</td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_asset_saledate","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_asset_saledate","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		count=Util.countAssets(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalevacuatedequipment",sWebLanguage)+"</td><td class='admin2' colspan='2'>"+count+"</td></tr>");
		total=state2+state3+state4+stateother;
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totaldysfunctional",sWebLanguage)+"</td><td class='admin2' colspan='2'>"+total+"</td></tr>");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","fractionevacuated",sWebLanguage)+"</td><td class='admin2' colspan='2'>"+new DecimalFormat("#0.00").format(new Double(count)*100/new Double(total))+"%</td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'2'");
		parameters.put("length(oc_maintenanceoperation_supplier)","copy;>0");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		count=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalexternalpreventative",sWebLanguage)+"</td><td class='admin2' colspan='2'>"+count+"</td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'3'");
		parameters.put("length(oc_maintenanceoperation_supplier)","copy;>0");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		count=Util.countMaintenanceOperations(parameters);
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalexternalcorrective",sWebLanguage)+"</td><td class='admin2' colspan='2'>"+count+"</td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'3'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		String s=Util.analyzeMaintenanceOperations(parameters,"sum(oc_maintenanceoperation_comment1)+sum(oc_maintenanceoperation_comment2)+sum(oc_maintenanceoperation_comment3)+sum(oc_maintenanceoperation_comment4)");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalcorrectivecost",sWebLanguage)+"</td><td class='admin2' colspan='2'>"+checkString(s)+"</td></tr>");
		parameters = new Hashtable();
		parameters.put("oc_asset_nomenclature","like;'E%'");
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","equals;'2'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		s=Util.analyzeMaintenanceOperations(parameters,"sum(oc_maintenanceoperation_comment1)+sum(oc_maintenanceoperation_comment2)+sum(oc_maintenanceoperation_comment3)+sum(oc_maintenanceoperation_comment4)");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalpreventativecost",sWebLanguage)+"</td><td class='admin2' colspan='2'>"+checkString(s)+"</td></tr>");
	%>
	<!-- PERFORMANCE -->
	<tr class='admin'><td colspan='3'><%=getTran(request,"web","performances",sWebLanguage) %></td></tr>
	<%
		//First check how many preventative maintenance operations were scheduled in the period
		HashSet plans = new HashSet();
		int[] nFunctionalStatus = new int[5];
		int programmed = 0;
		String sid=MedwanQuery.getInstance().getServerId()+"";
		sSql = 	"select * from oc_assets a,oc_maintenanceplans p where oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
								" (oc_maintenanceplan_type=1 or oc_maintenanceplan_type=2) and oc_asset_service in ("+serviceuids+") and (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>'"+
								new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"') and oc_maintenanceplan_startdate<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'";
		if(svc.getParentcode().length()==0){
			sSql = 	"select * from oc_assets a,oc_maintenanceplans p where oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
					" (oc_maintenanceplan_type=1 or oc_maintenanceplan_type=2) and oc_asset_service like '"+serviceUid+"%' and (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>'"+
					new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"') and oc_maintenanceplan_startdate<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'";
		}

		ps = conn.prepareStatement(sSql);
		rs = ps.executeQuery();
		while(rs.next()){
			//Each of these maintenance plans is due if (i) there has never been an operation or (ii) the expiry date of the 
			//latest maintenance operation falls before enddate (it should have been done) 
			String maintenancePlanUid = rs.getString("oc_maintenanceplan_serverid")+"."+rs.getString("oc_maintenanceplan_objectid");
			String frequency = rs.getString("oc_maintenanceplan_frequency");
			//Was there an intervention action planned in the selected period?
			//Check if any existing intervention had a nextdate in this period
			boolean bMaintenancePlanDue=false,bInit=false;
			PreparedStatement ps2 = conn.prepareStatement("select * from oc_maintenanceoperations where oc_maintenanceoperation_maintenanceplanuid=? and oc_maintenanceoperation_date<? order by oc_maintenanceoperation_nextdate desc");
			ps2.setString(1,maintenancePlanUid);
			ps2.setDate(2, SH.toSQLDate(dBegin));
			ResultSet rs2 = ps2.executeQuery();
			while(rs2.next() && !bMaintenancePlanDue){
				java.util.Date d = rs2.getDate("oc_maintenanceoperation_nextdate");
				if(d!=null){
					if(d.after(dEnd)){
						bInit=true;
						break;
					}
					bMaintenancePlanDue=true;
					if(!d.before(dBegin)){
						programmed++;
					}
				}
				else{
					continue;
				}
				bInit=true;
			}
			rs2.close();
			ps2.close();
			if(!bInit){
				bMaintenancePlanDue=true;
			}
			if(bMaintenancePlanDue){
				String functionalStatus=SH.c(rs.getString("oc_asset_comment7"));
				if(functionalStatus.equalsIgnoreCase("1")){
					nFunctionalStatus[1]++;
				}
				else if(functionalStatus.equalsIgnoreCase("2")){
					nFunctionalStatus[2]++;
				}
				else if(functionalStatus.equalsIgnoreCase("3")){
					nFunctionalStatus[3]++;
				}
				else if(functionalStatus.equalsIgnoreCase("4")){
					nFunctionalStatus[4]++;
				}
				else{
					nFunctionalStatus[0]++;
				}
				plans.add(maintenancePlanUid);
			}
		}
		rs.close();
		ps.close();
		

		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalpreventativecontrolforeseen",sWebLanguage)+"</td><td class='admin2'><span id='perftotal'><a href='javascript:showPreventativeMaintenanceList(0)'>"+plans.size()+"</a></span></td><td class='admin2' rowspan='8'><table><tr><td width='200px'><canvas id='performanceChart' width='200px' height='200px'></canvas></td><td width='200px'><canvas id='functionalStatusChart' width='200px' height='200px'></canvas></td></tr></table></td></tr>");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalpreventativecontrolprogrammed",sWebLanguage)+"</td><td class='admin2'><span id='perfprogrammed'><a href='javascript:showPreventativeMaintenanceList(1)'>"+programmed+"</a></span></td></tr>");
		int totaloperations=preventativeoperations+preventativeInfrastructureOperations;
		parameters = new Hashtable();
		if(svc.getParentcode().length()>0){
			parameters.put("oc_asset_service","in;"+serviceuids);
		}
		else{
			parameters.put("oc_asset_service","like;'"+serviceUid+"%'");
		}
		parameters.put("oc_maintenanceplan_type","in;'1','2'");
		parameters.put("oc_maintenanceoperation_date","copy;>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"'");
		parameters.put(" oc_maintenanceoperation_date","copy;<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'");
		int maintenanceplanscovered=Util.countMaintenanceOperationPlans(parameters);

		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalmaintenanceplanscovered",sWebLanguage)+"</td><td class='admin2'><b><span  style='font-size: 14px'>"+maintenanceplanscovered+"</span></b></td></tr>");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","totalpreventativefraction",sWebLanguage)+"</td><td class='admin2'><b><span  style='font-size: 14px' id='perfseen'>"+new DecimalFormat("#0.00").format(new Double(maintenanceplanscovered)*100/new Double(plans.size()))+"</span>%</b></td></tr>");
		plans = new HashSet();
		sSql = 	"select * from oc_assets a,oc_maintenanceplans p where oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+sid+".','') and"+
				" oc_maintenanceplan_type=3 and oc_asset_service in ("+serviceuids+") and oc_maintenanceplan_startdate>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"' and oc_maintenanceplan_startdate<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"' and (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>'"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"')";
		if(svc.getParentcode().length()==0){
			sSql = 	"select * from oc_assets a,oc_maintenanceplans p where oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+sid+".','') and"+
					" oc_maintenanceplan_type=3 and oc_asset_service like '"+serviceUid+"%' and oc_maintenanceplan_startdate>='"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"' and oc_maintenanceplan_startdate<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"' and (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>'"+new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"')";
		}
		ps = conn.prepareStatement(sSql);
		rs = ps.executeQuery();
		int c = 0;
		long days=0,successdays=0;
		while(rs.next()){
			java.util.Date requestDate = rs.getTimestamp("oc_maintenanceplan_startdate");
			if(requestDate!=null){
				String maintenancePlanUid = rs.getString("oc_maintenanceplan_serverid")+"."+rs.getString("oc_maintenanceplan_objectid");
				PreparedStatement ps2 = conn.prepareStatement("select min(oc_maintenanceoperation_date) date from oc_maintenanceoperations where oc_maintenanceoperation_maintenanceplanuid=?");
				ps2.setString(1,maintenancePlanUid);
				ResultSet rs2 = ps2.executeQuery();
				if(rs2.next()){
					java.util.Date d = rs2.getTimestamp("date");
					if(d!=null && !d.before(requestDate)){
						c++;
						days+=(d.getTime()-requestDate.getTime());
					}
				}
				rs2.close();
				ps2.close();
				ps2 = conn.prepareStatement("select min(oc_maintenanceoperation_date) date from oc_maintenanceoperations where oc_maintenanceoperation_result='ok' and oc_maintenanceoperation_maintenanceplanuid=?");
				ps2.setString(1,maintenancePlanUid);
				rs2 = ps2.executeQuery();
				if(rs2.next()){
					java.util.Date d = rs2.getTimestamp("date");
					if(d!=null && !d.before(requestDate)){
						c++;
						successdays+=(d.getTime()-requestDate.getTime());
					}
				}
				rs2.close();
				ps2.close();
			}
		}
		rs.close();
		ps.close();
		conn.close();
		out.println("<input type='hidden' name='functionalStatus' id='functionalStatus' value='"+nFunctionalStatus[0]+","+nFunctionalStatus[1]+","+nFunctionalStatus[2]+","+nFunctionalStatus[3]+","+nFunctionalStatus[4]+"'/>");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","meanresponsetime",sWebLanguage)+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format((new Double(days)/new Double(c))/ScreenHelper.getTimeDay())+" "+getTran(request,"web","days",sWebLanguage)+"</td></tr>");
		out.println("<tr><td class='admin' width='30%'>"+getTran(request,"asset","meansuccessresponsetime",sWebLanguage)+"</td><td class='admin2'>"+new DecimalFormat("#0.00").format((new Double(successdays)/new Double(c))/ScreenHelper.getTimeDay())+" "+getTran(request,"web","days",sWebLanguage)+"</td></tr>");
	%>
</table>
<table width='100%'>
	<!-- HR -->
	<tr class='admin'><td><%=getTran(request,"web","hr",sWebLanguage) %></td></tr>
</table>
<table width='100%' class="sortable" id=hrresults>
    <%-- header --%>
    <tr class='admin'>
		<td><%=getTran(request,"web","userid",sWebLanguage) %></td>
		<td><%=getTran(request,"web","username",sWebLanguage) %></td>
		<td><%=getTran(request,"web","logins",sWebLanguage) %></td>
		<td><%=getTran(request,"web","inventorymodifications",sWebLanguage) %></td>
		<td><%=getTran(request,"web","preventativeoperations",sWebLanguage) %></td>
		<td><%=getTran(request,"web","curativeoperations",sWebLanguage) %></td>
		<td><%=getTran(request,"web","lastupdate",sWebLanguage) %></td>
	</tr>
	<tbody>
	<% 
		SH.syslog("Getting child services");
		Vector<String> serviceAndChildren = svc.getChildIds(svc.getCode());
		HashSet serviceUsers = new HashSet();
		serviceAndChildren.add(svc.getCode());
		
		SH.syslog("Getting parent services");
		Vector<String> parents = svc.getParentIds(svc.getCode());
		SH.syslog("Getting users");
		for(int n=0;n<parents.size();n++){
			Service service = Service.getService(parents.elementAt(n));
			String[] users = service.getUsers().split("\\$");
			for(int i=0;i<users.length;i++){
				if(User.getFullUserName(users[i]).length()>0){
					serviceUsers.add(users[i]);
				}
			}
		}

		for(int n=0;n<serviceAndChildren.size();n++){	
			Service service = Service.getService(serviceAndChildren.elementAt(n));
			//Créer la liste des utilisateurs rattachés à chaque service
			// - le service choisi
			// - les services sous-jacants au service choisi
			String[] users = service.getUsers().split("\\$");
			for(int i=0;i<users.length;i++){
				if(User.getFullUserName(users[i]).length()>0){
					serviceUsers.add(users[i]);
				}
			}
		}
		SH.syslog("Getting scores per user");

		Iterator iUsers = serviceUsers.iterator();
		while(iUsers.hasNext()){
			String userid=(String)iUsers.next();
			out.println("<tr>"+
					"<td class='admin'>"+userid+"</td>"+
	 				"<td class='admin2'>"+
						 User.getFullUserName(userid)+"</td>");
			
			//Ajouter le nombre de logins
			SH.syslog("Getting number of logins for "+userid);
			int logins=0;
			conn = SH.getAdminConnection();
			String sql = "SELECT COUNT(*) total FROM accesslogs WHERE userid=? "+
						 " AND accesscode IS NULL AND"+
						 " accesstime>=? AND accesstime<?;";
			ps = conn.prepareStatement(sql);
			ps.setString(1,userid);
			ps.setDate(2,SH.toSQLDate(dBegin));
			ps.setDate(3,SH.toSQLDate(dEnd));
			rs = ps.executeQuery();
			if(rs.next()){
				logins=rs.getInt("total");
			}
			rs.close();
			ps.close();
			conn.close();
			
			//Ajouter le nombre de créations/modifications d'inventaires (OC_ASSETS)
			SH.syslog("Logins for "+userid+" = "+logins);
			if(logins>0){
				out.println("<td class='admin2'><b>"+logins+"</b></td>");
				SH.syslog("Getting number of asset updates for "+userid);
				int updates=0;
				conn = SH.getOpenClinicConnection();
				sql = "SELECT SUM(total) total FROM"+
					  " (SELECT COUNT(*) total,1 id,oc_asset_updatetime updatetime"+
					  " FROM oc_assets WHERE "+
					  " oc_asset_updateid=?"+
					  " group by id,oc_asset_updatetime"+
				      " union"+
					  " SELECT COUNT(*) total,2 id,oc_asset_updatetime updatetime "+
					  " FROM oc_assetshistory WHERE "+
					  " oc_asset_historyuser=?"+
					  " group by id,oc_asset_updatetime"+
					  " ) a"+
					  " WHERE updatetime>=? AND updatetime<=?";
				ps = conn.prepareStatement(sql);
				ps.setString(1,userid);
				ps.setString(2,userid);
				ps.setDate(3,SH.toSQLDate(dBegin));
				ps.setDate(4,SH.toSQLDate(dEnd));
				rs = ps.executeQuery();
				if(rs.next()){
					updates=rs.getInt("total");
				}
				rs.close();
				ps.close();
				conn.close();
				if(updates>0){
					out.println("<td class='admin2'><b>"+updates+"</b></td>");
				}
				else{
					out.println("<td class='admin2'><font style='color: grey'>0</font></td>");
				}
				
				SH.syslog("Getting number of operations for "+userid);
				int prev_updates=0,cur_updates=0;
				//Ajouter le nombre de d'opérations
				// - pour l'utilisateur en question
				// - pendant la période sélectionnée
				// - de maintenance préventive
				// - sur les inventaires du service et ses enfants
				
				conn = SH.getOpenClinicConnection();
				sql = "SELECT count(*) total,oc_maintenanceplan_type FROM ("+
					  " SELECT oc_maintenanceoperation_objectid,1 id,oc_maintenanceoperation_updatetime,oc_maintenanceplan_type"+
					  " FROM oc_maintenanceoperations,oc_maintenanceplans,oc_assets WHERE"+ 
					  " oc_maintenanceoperation_updateid=? AND"+
					  " oc_maintenanceoperation_updatetime>=? AND"+ 
					  " oc_maintenanceoperation_updatetime<? AND"+
					  " REPLACE(oc_maintenanceoperation_maintenanceplanuid,'1.','')=oc_maintenanceplan_objectid and"+
					  " REPLACE(oc_maintenanceplan_assetuid,'1.','')=oc_asset_objectid and"+
					  " oc_asset_service like '"+svc.getCode()+"%'"+
					  " union"+
					  " SELECT oc_maintenanceoperation_objectid,2 id,oc_maintenanceoperation_updatetime,oc_maintenanceplan_type"+
					  " FROM oc_maintenanceoperationshistory,oc_maintenanceplans,oc_assets WHERE"+ 
					  " oc_maintenanceoperation_historyuser=? and"+
					  " oc_maintenanceoperation_updatetime>=? AND"+ 
					  " oc_maintenanceoperation_updatetime<? and"+
					  " REPLACE(oc_maintenanceoperation_maintenanceplanuid,'1.','')=oc_maintenanceplan_objectid and"+
					  " REPLACE(oc_maintenanceplan_assetuid,'1.','')=oc_asset_objectid and"+
					  " oc_asset_service like '"+svc.getCode()+"%'"+
					  ") a GROUP BY oc_maintenanceplan_type";
				ps = conn.prepareStatement(sql);
				ps.setString(1,userid);
				ps.setDate(2,SH.toSQLDate(dBegin));
				ps.setDate(3,SH.toSQLDate(dEnd));
				ps.setString(4,userid);
				ps.setDate(5,SH.toSQLDate(dBegin));
				ps.setDate(6,SH.toSQLDate(dEnd));
				rs = ps.executeQuery();
				while(rs.next()){
					if("1,2".contains(rs.getString("oc_maintenanceplan_type"))){
						prev_updates+=rs.getInt("total");
					}
					else if("3".contains(rs.getString("oc_maintenanceplan_type"))){
						cur_updates+=rs.getInt("total");
					}
				}
				rs.close();
				ps.close();
				conn.close();
				if(prev_updates>0){
					out.println("<td class='admin2'><b>"+prev_updates+"</b></td>");
				}
				else{
					out.println("<td class='admin2'><font style='color: grey'>0</font></td>");
				}
				if(cur_updates>0){
					out.println("<td class='admin2'><b>"+cur_updates+"</b></td>");
				}
				else{
					out.println("<td class='admin2'><font style='color: grey'>0</font></td>");
				}
			}	
			else{
				out.println("<td class='admin2'><font style='color: grey'>0</font></td><td class='admin2'><font style='color: grey'>0</font></td><td class='admin2'><font style='color: grey'>0</font></td><td class='admin2'><font style='color: grey'>0</font></td>");
			}
			conn.close();
			
			SH.syslog("Getting last modification for "+userid);
			conn=SH.getOpenClinicConnection();
			sql="SELECT MAX(maxdate) maxdate from"+
				" (SELECT max(oc_asset_updatetime) maxdate FROM oc_assets WHERE oc_asset_updateid=? AND oc_asset_updatetime<?"+
				" union"+
				" SELECT max(oc_asset_updatetime) maxdate FROM oc_assetshistory WHERE oc_asset_updateid=? AND oc_asset_updatetime<=?"+
				" UNION"+
				" SELECT MAX(oc_maintenanceplan_updatetime) maxdate FROM oc_maintenanceplans WHERE oc_maintenanceplan_updateid=?"+
				" AND oc_maintenanceplan_updatetime<=?"+
				" UNION"+
				" SELECT MAX(oc_maintenanceplan_updatetime) maxdate FROM oc_maintenanceplanshistory "+
				" WHERE oc_maintenanceplan_updateid=? AND oc_maintenanceplan_updatetime<=?"+
				" UNION"+
				" SELECT MAX(oc_maintenanceoperation_updatetime) maxdate FROM oc_maintenanceoperations "+
				" WHERE oc_maintenanceoperation_updateid=?  AND oc_maintenanceoperation_updatetime<=?"+
				" UNION"+
				" SELECT MAX(oc_maintenanceoperation_updatetime) maxdate FROM oc_maintenanceoperationshistory "+
				" WHERE oc_maintenanceoperation_updateid=? AND oc_maintenanceoperation_updatetime<=?"+
				" ) a";
			ps = conn.prepareStatement(sql);
			int n=1;
			ps.setString(n++,userid);
			ps.setDate(n++,SH.toSQLDate(dEnd));
			ps.setString(n++,userid);
			ps.setDate(n++,SH.toSQLDate(dEnd));
			ps.setString(n++,userid);
			ps.setDate(n++,SH.toSQLDate(dEnd));
			ps.setString(n++,userid);
			ps.setDate(n++,SH.toSQLDate(dEnd));
			ps.setString(n++,userid);
			ps.setDate(n++,SH.toSQLDate(dEnd));
			ps.setString(n++,userid);
			ps.setDate(n++,SH.toSQLDate(dEnd));
			rs = ps.executeQuery();
			if(rs.next()){
				out.println("<td class='admin2'><b>"+SH.formatDate(rs.getTimestamp("maxdate"),"yyyy/MM/dd HH:mm:ss")+(rs.getTimestamp("maxdate")==null?"":" ("+((new java.util.Date().getTime()-rs.getTimestamp("maxdate").getTime())/SH.getTimeDay())+"j)")+"</b></td>");
			}
			else{
				out.println("<td class='admin2'></td>");
			}
			rs.close();
			ps.close();
			conn.close();
	 		out.println("</tr>");
		}
	%>
	</tbody>
</table>
