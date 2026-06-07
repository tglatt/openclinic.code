<%@include file="/includes/validateUser.jsp"%>
<%
	String prefix="clinicalcoverage";
%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='3'>Couverture clinique par service</td>
	</tr>
	<%
		String period = SH.p(request,"period");
		String language = SH.p(request,"language"); 
		java.util.Date begin = new SimpleDateFormat("dd/MM/yyyy").parse("01/"+period);
		java.util.Date end = new SimpleDateFormat("dd/MM/yyyy").parse("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(begin.getTime()+SH.getTimeDay()*35))); 
		double coverage=0,total=0,allcoverage=0,alltotal=0;
		Vector<String> vContacts = new Vector();
		HashSet hEncounters = new HashSet(), hServices=new HashSet();
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("SELECT oc_encounter_objectid,oc_encounter_serviceuid FROM oc_encounter_services WHERE "+
				" oc_encounter_servicebegindate BETWEEN ? and ? "+
				" and exists (select * from oc_debets where oc_debet_credited=0 and oc_debet_encounteruid='"+SH.getServerId()+".'||oc_encounter_objectid)");
		ps.setDate(1,new java.sql.Date(begin.getTime()));
		ps.setDate(2,new java.sql.Date(end.getTime()));
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			vContacts.add(SH.getServerId()+"."+rs.getString("oc_encounter_objectid")+";"+rs.getString("oc_encounter_serviceuid"));
			hServices.add(rs.getString("oc_encounter_serviceuid"));
		}
		rs.close();
		ps.close();	
		alltotal=vContacts.size();
		ps = conn.prepareStatement("select i.value from transactions t, items i where t.updatetime>=? and t.updatetime<? and t.transactionid=i.transactionid and i.type=?");
		ps.setDate(1,new java.sql.Date(begin.getTime()));
		ps.setDate(2,new java.sql.Date(end.getTime()));
		ps.setString(3,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
		rs = ps.executeQuery();
		while(rs.next()){
			hEncounters.add(rs.getString("value"));
		}
		rs.close();
		ps.close();	
		conn.close();
		for(int n=0;n<vContacts.size();n++){
			if(hEncounters.contains(vContacts.elementAt(n))){
				coverage++;
			}
		}
		Iterator iServices = hServices.iterator();
		while(iServices.hasNext()){
			String serviceid = (String)iServices.next();
			total=0;
			coverage=0;
			allcoverage=0;
			for(int n=0;n<vContacts.size();n++){
				if(vContacts.elementAt(n).split(";").length>=2){
					String uid = vContacts.elementAt(n).split(";")[0];
					String service = vContacts.elementAt(n).split(";")[1];
					if(serviceid.equalsIgnoreCase(service)){
						total++;
						if(hEncounters.contains(uid)){
							coverage++;
						}
					}
					if(hEncounters.contains(uid)){
						allcoverage++;
					}
				}
			}
			if(coverage<total){
				out.println("<tr><td class='admin'>"+serviceid+"</td><td class='admin'><a title='Voir la liste des "+new Double(total-coverage).intValue()+" patients ratés' style='font-weight: bold' href='javascript:getMissed(\""+serviceid+"\",\""+period+"\")'>"+getTranNoLink("service",serviceid,language)+" ("+new Double(coverage).intValue()+"/"+new Double(total).intValue()+")</a></td>");
			}
			else{
				out.println("<tr><td class='admin'>"+serviceid+"</td><td class='admin'>"+getTranNoLink("service",serviceid,language)+" ("+new Double(coverage).intValue()+"/"+new Double(total).intValue()+")</td>");
			}
			out.println("<td class='admin2'><b>"+new DecimalFormat("0.0").format(coverage*100/total)+"%</b></td></tr>");
		}
		out.println("<tr class='admin'><td>"+getTranNoLink("web","total",language)+"</td><td>"+new Double(allcoverage).intValue()+"/"+new Double(alltotal).intValue()+"</td>");
		out.println("<td><b>"+new DecimalFormat("0.0").format(allcoverage*100/alltotal)+"%</b></td></tr>");
	%>
</table>

<script>
	function getMissed(serviceid,period){
		openPopup('dashboards/<%=prefix%>/getMissed.jsp&language=<%=sWebLanguage%>&period='+period+'&serviceid='+serviceid,800,400,'Dossiers ratés couverture clinique');
	}
</script>