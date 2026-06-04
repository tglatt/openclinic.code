<%@page import="be.mxs.common.util.system.Pointer"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,java.io.*,be.openclinic.medical.*"%>
<%@include file="/includes/helper.jsp"%>
<%!
	void checkCounter(String name, int minvalue){
		try{
			if(MedwanQuery.getInstance().getOpenclinicCounterNoIncrement(name)<minvalue){
				MedwanQuery.getInstance().getOpenclinicCounterNoOffline(name, minvalue-1);
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
%>
<%
	int apiId=-1;
	Connection apiconn= null;
	if(SH.ci("enableAPILog",0)==1){
		apiId=MedwanQuery.getInstance().getOpenclinicCounter("APILOG");
		apiconn = SH.getStatsConnection();
	}
	String sResult="<response type='error' message='[0.0] Undefined error'/>";
	String from = SH.c(request.getParameter("from"),"?");
	try{
		String objecttype=request.getParameter("objecttype");
		String xml=request.getParameter("xml");
		if(apiId>-1){
			PreparedStatement ps = apiconn.prepareStatement("insert into oc_apilog(apilog_id,apilog_from,apilog_ip,apilog_ts,apilog_received) values (?,?,?,?,?)");
			ps.setInt(1, apiId);
			ps.setString(2,from);
			ps.setString(3, request.getRemoteAddr());
			ps.setTimestamp(4,SH.getSQLTime());
			ps.setString(5,xml);
			ps.execute();
			ps.close();
		}
		String updateuser=request.getParameter("updateuser");
		int minid = Integer.parseInt(request.getParameter("minid"));
		int minid2 = Integer.parseInt(request.getParameter("minid2"));
		Pointer.deletePointers("offlinesync."+from);
		Pointer.storePointer("offlinesync."+from, SH.formatDate(new java.util.Date(),"yyyyMMddHHmmss"));
		if(objecttype.equalsIgnoreCase("admin")){
			AdminPerson person = AdminPerson.fromXml(xml, true);
			person.updateuserid=updateuser;
			String oldid=person.personid;
			String p = Pointer.getPointer("offlinesync.admin."+from+"."+oldid);
			if(p.length()>0){
				person.personid=p.split(";")[4].split("=")[1];
			}
			else{
				person.personid = AdminPerson.getPersonIdByImmatnew(person.getID("immatnew"));
				if(person.personid==null){
					person.personid="";
					checkCounter("PersonID",Math.max(minid,Integer.parseInt(oldid)));
				}
			}
			if(person.store()){
				Pointer.storePointer("offlinesync.admin."+from+"."+oldid,"lastname="+person.lastname+";firstname="+person.firstname+";immatnew="+person.getID("immatnew")+";oldid="+oldid+";newid="+person.personid+";minid="+minid);
				sResult="<response type='admin' oldid='"+oldid+"' newid='"+person.personid+"'/>";
			}
			else{
				Pointer.storePointer("offlinesync.error."+SH.getTs(),"from="+from+";lastname="+person.lastname+";firstname="+person.firstname+";immatnew="+person.getID("immatnew")+";oldid="+oldid+";newid="+person.personid+";minid="+minid);
			}
		}
		else if(objecttype.equalsIgnoreCase("encounter")){
			Encounter encounter = Encounter.fromXml(xml);
			encounter.setUpdateUser(updateuser);
			String oldid=encounter.getObjectId()+"";
			String p = Pointer.getPointer("offlinesync.encounter."+from+"."+oldid);
			if(p.length()>0 && p.split(";").length>1){
				encounter.setUid(p.split(";")[1].split("=")[1]);
			}
			else{
				encounter.setUid("");
				checkCounter("OC_ENCOUNTERS",Math.max(minid,Integer.parseInt(oldid)));
			}
			encounter.store();
			Pointer.deletePointers("offlinesync.encounter."+from+"."+oldid);
			Pointer.storePointer("offlinesync.encounter."+from+"."+oldid,"personid="+encounter.getPatientUID()+";oldid="+oldid+";newid="+encounter.getObjectId()+";minid="+minid);
			sResult="<response type='encounter' oldid='"+oldid+"' newid='"+encounter.getObjectId()+"'/>";
		}
		else if(objecttype.equalsIgnoreCase("transaction")){
			TransactionVO transaction = TransactionVO.fromXml(xml);
			transaction.setUpdateUser(updateuser);
			String oldid=transaction.getTransactionId()+"";
			String p = Pointer.getPointer("offlinesync.transaction."+from+"."+oldid);
			if(p.length()>0){
				transaction.setUid(p.split(";")[1].split("=")[1]);
			}
			else{
				transaction.setTransactionId(-1);
				checkCounter("TransactionID",Math.max(minid,Integer.parseInt(oldid)));
			}
			if(minid2>0){
				checkCounter("ItemID",minid2);
			}
			int personid=MedwanQuery.getInstance().getPersonIdFromHealthrecordId(transaction.getHealthrecordId());
			Hashtable<String,Integer> oldItemIds=new Hashtable();
			Iterator<ItemVO> items = transaction.getItems().iterator();
			while(items.hasNext()){
				ItemVO item = items.next();
				oldItemIds.put(item.getType(),item.getItemId());
				item.setItemId(-1);
			}
			Connection conn = SH.getOpenClinicConnection();
			PreparedStatement ps = conn.prepareStatement("delete from Transactions where healthrecordid=? and transactiontype=? and updatetime=?");
			ps.setInt(1,transaction.getHealthrecordId());
			ps.setString(2,transaction.getTransactionType());
			ps.setTimestamp(3,SH.getSQLTimestamp(transaction.getUpdateTime()));
			ps.execute();
			ps.close();
			conn.close();
			transaction = MedwanQuery.getInstance().updateTransaction(personid, transaction);
			for(int n=0;n<transaction.getAnalyses().size();n++){
				RequestedLabAnalysis a = (RequestedLabAnalysis)transaction.getAnalyses().elementAt(n);
				a.setServerId(transaction.getServerId()+"");
				a.setTransactionId(transaction.getTransactionId()+"");
				a.store();
			}
			
			Pointer.storePointer("offlinesync.transaction."+from+"."+oldid,"personid="+transaction.getPatientUid()+";oldid="+oldid+";newid="+transaction.getTransactionId()+";minid="+minid);
			sResult="<response type='transaction' oldid='"+oldid+"' newid='"+transaction.getTransactionId()+"'>";
			items = transaction.getItems().iterator();
			while(items.hasNext()){
				ItemVO item = items.next();
				sResult+="<item oldid='"+oldItemIds.get(item.getType())+"' newid='"+item.getItemId()+"'/>";
			}
			sResult+="</response>";
		}
		else if(objecttype.equalsIgnoreCase("hemovigilance")){
			TransactionVO transaction = TransactionVO.fromXml(xml);
			//First store the transaction
			transaction.setUpdateUser(updateuser);
			transaction.setTransactionId(-1);
			//Find the bloodgift that matches this pocketid
			TransactionVO bloodgift = MedwanQuery.getInstance().loadTransaction(MedwanQuery.getInstance().getServerId(), Integer.parseInt(request.getParameter("pocketnumber").split("\\.")[0]));
			if(bloodgift!=null){
				transaction.setHealthrecordId(bloodgift.getHealthrecordId());
				transaction = MedwanQuery.getInstance().updateTransaction(bloodgift.getPatientUid(), transaction);
				Connection conn = SH.getOpenClinicConnection();
				PreparedStatement ps = conn.prepareStatement("insert into oc_hemovigilance(oc_hemovigilance_transactionuid,oc_hemovigilance_pocketnumber,oc_hemovigilance_processed,oc_hemovigilance_timestamp) values(?,?,now(),now())");
				ps.setString(1,transaction.getUid());
				ps.setString(2, request.getParameter("pocketnumber"));
				ps.execute();
				ps.close();
				conn.close();
			}
			sResult="<response type='hemovigilance'/>";
		}
		else{
			sResult="<response type='error' message='[1.0] Undefined objecttype: "+objecttype+"'/>";
			Pointer.storePointer("offlinesync.error."+SH.getTs(),"from="+from+";objecttype="+objecttype);
		}
		if(apiId>-1){
			PreparedStatement ps = apiconn.prepareStatement("update oc_apilog set apilog_sent=? where apilog_id=?");
			ps.setString(1,sResult);
			ps.setInt(2,apiId);
			ps.execute();
			ps.close();
		}
	}
	catch(Exception e){
		Pointer.storePointer("offlinesync.error."+SH.getTs(),"from="+from+";undefined");
		e.printStackTrace();
	}
	if(apiconn!=null){
		apiconn.close();
	}
%>
<%=sResult %>
