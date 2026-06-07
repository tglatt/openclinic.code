<%@include file="/includes/validateUser.jsp"%>
<%
	String period = SH.p(request,"period");
	java.util.Date begin = new SimpleDateFormat("dd/MM/yyyy").parse("01/"+period);
	java.util.Date end = new SimpleDateFormat("dd/MM/yyyy").parse("01/"+new SimpleDateFormat("MM/yyyy").format(new java.util.Date(begin.getTime()+SH.getTimeDay()*35))); 
	double coverage=0,total=1;
	Vector<String> vContacts = new Vector();
	HashSet hEncounters = new HashSet();
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT oc_encounter_objectid FROM oc_encounters WHERE oc_encounter_begindate BETWEEN ? and ? "+
			" and exists (select * from oc_debets where oc_debet_credited=0 and oc_debet_encounteruid='"+SH.getServerId()+".'||oc_encounter_objectid)");
	ps.setDate(1,new java.sql.Date(begin.getTime()));
	ps.setDate(2,new java.sql.Date(end.getTime()));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		vContacts.add(SH.getServerId()+"."+rs.getString("oc_encounter_objectid"));
	}
	rs.close();
	ps.close();	
	total = vContacts.size();
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
		if(hEncounters.contains(vContacts.elementAt(n))){
			coverage++;
		}
	}
%>
{
	coverage: <%=coverage*100/total %>
}