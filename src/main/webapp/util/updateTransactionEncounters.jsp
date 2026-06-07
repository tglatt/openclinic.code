<%@include file="/includes/validateUser.jsp"%>

<%
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("SELECT * FROM transactions t WHERE NOT EXISTS"+
			" (SELECT * FROM items WHERE transactionid=t.transactionid AND"+
			" TYPE='be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID')");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		Encounter encounter = Encounter.getActiveEncounterOnDate(rs.getTimestamp("updatetime"),""+MedwanQuery.getInstance().getPersonIdFromHealthrecordId(rs.getInt("healthrecordid")));
		if(encounter==null){
			encounter = Encounter.getLastEncounterBefore(""+MedwanQuery.getInstance().getPersonIdFromHealthrecordId(rs.getInt("healthrecordid")),rs.getTimestamp("updatetime"));
		}
		if(encounter!=null){
			int id =MedwanQuery.getInstance().getOpenclinicCounter("ItemID");
			PreparedStatement ps2 = conn.prepareStatement("insert into items(itemid,type,value,date,transactionid,serverid,version,versionserverid,valuehash) values(?,?,?,?,?,?,?,?,?)");
			ps2.setInt(1,id);
			ps2.setString(2,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
			ps2.setString(3,encounter.getUid());
			ps2.setTimestamp(4,rs.getTimestamp("updatetime"));
			ps2.setInt(5,rs.getInt("transactionid"));
			ps2.setInt(6,SH.getServerId());
			ps2.setInt(7, 1);
			ps2.setInt(8,SH.getServerId());
			ps2.setInt(9,("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID"+encounter.getUid()).hashCode());
			ps2.execute();
			ps2.close();
			System.out.println("inserted "+id);
		}
		else{
			System.out.println("No contact for "+MedwanQuery.getInstance().getPersonIdFromHealthrecordId(rs.getInt("healthrecordid")));
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>