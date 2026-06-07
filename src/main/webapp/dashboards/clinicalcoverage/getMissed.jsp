<%@page import="be.openclinic.finance.Debet"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String prefix="clinicalcoverage";
	String serviceid = SH.p(request,"serviceid");
		String period = SH.p(request,"period");
		String language = SH.p(request,"language"); 
%>
<table width='100%'>
	<tr class='admin'>
		<td colspan='5'>Patients reçus sans contenu clinique pour <%=serviceid+" - "+getTranNoLink("service",serviceid,language) %> en <%=period %></td>
	</tr>
	<%
		java.util.Date begin = new SimpleDateFormat("dd/MM/yyyy").parse("01/"+period);
		java.util.Date end = new SimpleDateFormat("dd/MM/yyyy").parse("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(begin.getTime()+SH.getTimeDay()*35))); 
		double coverage=0,total=0,allcoverage=0,alltotal=0;
		Vector<String> vContacts = new Vector();
		HashSet hEncounters = new HashSet();
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("SELECT e.oc_encounter_updateuid,e.oc_encounter_objectid,oc_encounter_type,oc_encounter_patientuid,oc_encounter_servicebegindate FROM oc_encounters e, oc_encounter_services s WHERE "+
				" e.oc_encounter_objectid=s.oc_encounter_objectid and oc_encounter_servicebegindate BETWEEN ? and ? and oc_encounter_serviceuid=?"+
				" and exists (select * from oc_debets where oc_debet_credited=0 and oc_debet_encounteruid='"+SH.getServerId()+".'||e.oc_encounter_objectid)");
		ps.setDate(1,new java.sql.Date(begin.getTime()));
		ps.setDate(2,new java.sql.Date(end.getTime()));
		ps.setString(3,serviceid);
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			vContacts.add(SH.getServerId()+"."+rs.getString("oc_encounter_objectid")+";"+rs.getString("oc_encounter_patientuid")+";"+SH.formatDate(rs.getDate("oc_encounter_servicebegindate"))+";"+SH.c(rs.getString("oc_encounter_type"),"visit")+";"+SH.c(rs.getString("oc_encounter_updateuid")));
		}
		rs.close();
		ps.close();	
		alltotal=vContacts.size();
		ps = conn.prepareStatement("select i.value from transactions t, items i where t.updatetime>=? and t.updatetime<=? and t.transactionid=i.transactionid and i.type=?");
		ps.setDate(1,new java.sql.Date(begin.getTime()));
		ps.setDate(2,new java.sql.Date(end.getTime()+SH.ci("clinicalCoverageDelayInDays",2)*SH.getTimeDay()));
		ps.setString(3,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
		rs = ps.executeQuery();
		while(rs.next()){
			hEncounters.add(rs.getString("value"));
		}
		rs.close();
		ps.close();	
		conn.close();	
		for(int n=0;n<vContacts.size();n++){
			String uid = vContacts.elementAt(n).split(";")[0];
			if(!hEncounters.contains(uid)){
				String patientname=AdminPerson.getFullName(vContacts.elementAt(n).split(";")[1]);
				out.println("<tr>");
				out.println("<td class='admin' width='1%' nowrap>"+vContacts.elementAt(n).split(";")[2]+"&nbsp;</td>");
				out.println("<td class='admin2' width='1%' nowrap>"+getTranNoLink("encountertype",vContacts.elementAt(n).split(";")[3],sWebLanguage)+"&nbsp;</td>");
				out.println("<td class='admin2' width='1%' nowrap>"+User.getFullUserName(vContacts.elementAt(n).split(";")[4])+"&nbsp;</td>");
				out.println("<td class='admin2' width='1%' nowrap><a href='javascript:showPatient("+vContacts.elementAt(n).split(";")[1]+",\""+patientname+"\")'>"+vContacts.elementAt(n).split(";")[1]+"</a>&nbsp;</td>");
				out.println("<td class='admin2'><b>"+patientname+"</b></td>");
				out.println("</tr>");
				String sDebets="";
				Vector debets = Debet.getEncounterDebets(uid);
				for(int i=0;i<debets.size();i++){
					Debet debet = (Debet)debets.elementAt(i);
					if(debet.getPrestation()!=null && debet.getCredited()==0){
						if(sDebets.length()>0){
							sDebets+=", ";
						}
						sDebets+=debet.getQuantity()+" x "+debet.getPrestation().getDescription()+": "+debet.getAmount()+" "+SH.cs("currency","EUR");
					}
				}
				out.println("<tr><td/><td class='admin2' colspan='4'><i style='font-size: 9px'>"+sDebets+"</i></td>");
				out.println("</tr>");
				
			}
		}
	%>
</table>

<script>
	function showPatient(personid,patientname){
		window.open('<%=sCONTEXTPATH%>/main.do?Page=curative/index.jsp&PersonID='+personid+'&language=<%=sWebLanguage%>','Contact sans contenu clinique','toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1024,height=768,menubar=no').moveTo((this.screen.width-1024)/2,(this.screen.height-768)/2);
	}
</script>