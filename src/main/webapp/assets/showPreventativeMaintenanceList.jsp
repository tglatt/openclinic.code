<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
	String serviceUid = checkString(request.getParameter("service"));
	Service svc = Service.getService(serviceUid);
	String serviceuids = "";
	if(svc.getParentcode().length()>0){
		serviceuids = Service.getChildIdsAsString(serviceUid);
	}
	java.util.Date dBegin = ScreenHelper.parseDate(request.getParameter("begin"));
	java.util.Date dEnd = new java.util.Date(ScreenHelper.parseDate(request.getParameter("end")).getTime()+SH.getTimeDay());
	boolean bProgrammedOnly = SH.p(request,"programmedonly").equalsIgnoreCase("1");
%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='10'><%=getTran(request,"web","programmed.preventative.maintenance.in.period",sWebLanguage) %>: <%=request.getParameter("begin")+" - "+request.getParameter("end") %></td>
	</tr>
	<tr class='admin'>
		<td>#</td>
		<td><%=getTran(request,"asset","planned",sWebLanguage) %></td>
		<td><%=getTran(request,"asset","last",sWebLanguage) %></td>
		<td><%=getTran(request,"asset","service",sWebLanguage) %></td>
		<td><%=getTran(request,"asset","assetuid",sWebLanguage) %></td>
		<td><%=getTran(request,"asset","nomenclature",sWebLanguage) %></td>
		<td><%=getTran(request,"asset","description",sWebLanguage) %></td>
		<td><%=getTran(request,"asset","planuid",sWebLanguage) %></td>
		<td><%=getTran(request,"asset","name",sWebLanguage) %></td>
		<td><%=getTran(request,"asset","frequency",sWebLanguage) %></td>
	</tr>
	<%
		SortedMap interventions = new TreeMap();
		Connection conn = SH.getOpenClinicConnection();
		String sSql = 	"select * from oc_assets a,oc_maintenanceplans p where oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
			" oc_maintenanceplan_type=2 and oc_asset_service in ("+serviceuids+") and (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>'"+
			new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"') and oc_maintenanceplan_startdate<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'";
		if(svc.getParentcode().length()==0){
			sSql = 	"select * from oc_assets a,oc_maintenanceplans p where oc_asset_objectid=replace(oc_maintenanceplan_assetuid,'"+SH.getServerId()+".','') and"+
					" oc_maintenanceplan_type=2 and oc_asset_service like '"+serviceuids+"%' and (oc_maintenanceplan_enddate is null or oc_maintenanceplan_enddate>'"+
					new SimpleDateFormat("yyyy-MM-dd").format(dBegin)+"') and oc_maintenanceplan_startdate<'"+new SimpleDateFormat("yyyy-MM-dd").format(dEnd)+"'";
		}
		PreparedStatement ps = conn.prepareStatement(sSql);
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			String maintenancePlanUid = rs.getString("oc_maintenanceplan_serverid")+"."+rs.getString("oc_maintenanceplan_objectid");
			String frequency = rs.getString("oc_maintenanceplan_frequency");
			//Was there an intervention action planned in the selected period?
			//Check if any existing intervention had a nextdate in this period
			boolean bMaintenancePlanDue=false,bInit=false;
			java.util.Date dueDate = dBegin,effectiveDate=null;
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
					if(!d.before(dBegin) || !bProgrammedOnly){
						bMaintenancePlanDue=true;
						if(!d.before(dBegin)){
							dueDate=d;
						}
					}
				}
				else{
					continue;
				}
			}
			rs2.close();
			ps2.close();
			if(!bInit){
				if(!bProgrammedOnly){
					bMaintenancePlanDue=true;
				}
			}			
			if(bMaintenancePlanDue){
				//Show this plan and whent the operations where performed
				ps2 = conn.prepareStatement("select max(oc_maintenanceoperation_date) effectivedate from oc_maintenanceoperations where oc_maintenanceoperation_maintenanceplanuid=? and oc_maintenanceoperation_date>=?");
				ps2.setString(1,maintenancePlanUid);
				ps2.setDate(2,SH.toSQLDate(dBegin));
				rs2 = ps2.executeQuery();
				if(rs2.next()){
					java.util.Date d=rs2.getDate("effectivedate");
					if(d!=null){
						effectiveDate=d;
					}
				}
				rs2.close();
				ps2.close();
				StringBuffer sb = new StringBuffer();
				sb.append(rs.getString("oc_asset_serverid")+"."+rs.getString("oc_asset_objectid")+";");
				sb.append(rs.getString("oc_asset_nomenclature")+";");
				sb.append(rs.getString("oc_asset_description")+";");
				sb.append(maintenancePlanUid+";");
				sb.append(rs.getString("oc_maintenanceplan_name")+";");
				sb.append(frequency+";");
				sb.append(SH.formatDate(effectiveDate)+";");
				sb.append(rs.getString("oc_asset_service")+";-;");
				interventions.put(rs.getString("oc_asset_service")+";"+new SimpleDateFormat("yyyyMMdd").format(dueDate)+";"+rs.getString("oc_asset_nomenclature")+";"+rs.getString("oc_asset_objectid")+";"+maintenancePlanUid, sb.toString());
			}
		}
		rs.close();
		ps.close();
		conn.close();
		
		int counter=1;
		String sClass="admin2",activeAsset="";
		Iterator i = interventions.keySet().iterator();
		while(i.hasNext()){
			String key = (String)i.next();
			String values=(String)interventions.get(key);
			if(!values.split(";")[0].equalsIgnoreCase(activeAsset)){
				if(sClass.equalsIgnoreCase("admin2")){
					sClass="admin3";
				}
				else{
					sClass="admin2";
				}
				activeAsset=values.split(";")[0];
			}
			out.println("<tr>");
			out.println("<td class='admin'>"+(counter++)+"</td>");
			out.println("<td class='admin'>"+SH.formatDate(new SimpleDateFormat("yyyyMMdd").parse(key.split(";")[1]))+"</td>");
			out.println("<td class='"+sClass+"'><b>"+values.split(";")[6]+"</b></td>");
			out.println("<td class='"+sClass+"'>"+values.split(";")[7]+"</td>");
			out.println("<td class='"+sClass+"'>"+values.split(";")[0]+"</td>");
			out.println("<td class='"+sClass+"'>"+getTran(request,"admin.nomenclature.asset",values.split(";")[1],sWebLanguage)+"</td>");
			out.println("<td class='"+sClass+"'>"+values.split(";")[2]+"</td>");
			out.println("<td class='"+sClass+"'>"+values.split(";")[3]+"</td>");
			out.println("<td class='"+sClass+"'>"+values.split(";")[4]+"</td>");
			out.println("<td class='"+sClass+"'>"+getTran(request,"maintenanceplan.frequency",values.split(";")[5],sWebLanguage)+"</td>");
			out.println("</tr>");
		}
	%>
</table>