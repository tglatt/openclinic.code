<%@page import="be.mxs.common.util.tools.ProcessFiles"%>
<%@page import="be.mxs.common.util.db.PersonMerger"%>
<%@page import="org.apache.poi.util.DocumentHelper"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
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
<table width='100%'>
	<tr><td colspan='2' id='info'><img src='<%=sCONTEXTPATH %>/_img/themes/default/ajax-loader.gif' height='12px'/>&nbsp;&nbsp;&nbsp;&nbsp;<font style='color: red;font-weight: bolder'><%=getTran(request,"web","waitforsync",sWebLanguage) %></font></td></tr>
	<tr class='admin'><td colspan='2'>Synchronizing offline data...</td></tr>
<%
boolean bComplete=true,bInitialized=false;
try{
	SortedMap hSync = new TreeMap();
	HashSet hPatients=new HashSet(),hTransactions=new HashSet(),hEncounters=new HashSet();
	Connection conn = SH.getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_sync where processed is null order by created");
	ResultSet rs = ps.executeQuery();
	int n=0;
	while(rs.next()){
		n++;
		String type = rs.getString("type");
		String oldid = rs.getString("oldid");
		java.util.Date created = rs.getTimestamp("created");
		hSync.put(n,created.getTime()+";"+type+";"+oldid);
	}
	rs.close();
	ps.close();
	conn.close();
	n=0;
	Iterator iSync = hSync.keySet().iterator();
	while(iSync.hasNext()){
		String xml="",objecttype="";
		n++;
		int minid=0,minid2=0;
		bInitialized=true;
		Integer key = (Integer)iSync.next();
		String values = (String)hSync.get(key);
		java.util.Date created = new java.util.Date(Long.parseLong(values.split(";")[0]));
		String type=values.split(";")[1];
		String oldid=values.split(";")[2];
		if(type.equalsIgnoreCase("admin")){
			if(hPatients.contains(oldid)){
				continue;
			}
			hPatients.add(oldid);
			AdminPerson person = AdminPerson.getAdminPerson(oldid);
			if(person.isNotEmpty()){
				out.println("<tr><td class='admin' width='1%'>"+oldid+"&nbsp;</td><td class='admin2'>Patient record <b>"+person.getFullName()+"</b> created on "+SH.formatDate(created, SH.fullDateFormatSS)+"</td></tr>");
				out.flush();
				xml = person.toXml();
				minid=MedwanQuery.getInstance().getOpenclinicCounterNoIncrement("PersonID");
				objecttype="admin";
			}
			else{
				SH.updateSync("admin", oldid,"-1");
				continue;
			}
		}
		else if(type.equalsIgnoreCase("encounter")){
			if(hEncounters.contains(SH.getServerId()+"."+oldid)){
				continue;
			}
			hEncounters.add(SH.getServerId()+"."+oldid);
    		MedwanQuery.getInstance().getObjectCache().removeObject("encounter", SH.getServerId()+"."+oldid);
			Encounter encounter = Encounter.get(SH.getServerId()+"."+oldid);
			if(encounter!=null && encounter.getPatientUID()!=null && encounter.getPatient()!=null){
				out.println("<tr><td class='admin' width='1%'>"+oldid+"&nbsp;</td><td class='admin2'>Patient encounter at <b>"+getTranNoLink("service",encounter.getServiceUID(),sWebLanguage)+"</b> for <b>"+encounter.getPatient().getFullName()+"</b> created on "+SH.formatDate(created, SH.fullDateFormatSS)+"</td></tr>");
				out.flush();
				xml=encounter.toXml();
				minid=MedwanQuery.getInstance().getOpenclinicCounterNoIncrement("OC_ENCOUNTERS");
				objecttype="encounter";
			}
			else{
				SH.updateSync("encounter", oldid,"-1");
				continue;
			}
		}
		else if(type.equalsIgnoreCase("transaction")){
			if(hTransactions.contains(SH.getServerId()+"."+oldid)){
				continue;
			}
			hTransactions.add(SH.getServerId()+"."+oldid);
			MedwanQuery.getInstance().getObjectCache().removeObject("transaction", SH.getServerId()+"."+oldid);
			TransactionVO transaction = TransactionVO.get(SH.getServerId(), Integer.parseInt(oldid));
			if(transaction!=null){
				out.println("<tr><td class='admin' width='1%'>"+oldid+"&nbsp;</td><td class='admin2'>Transaction <b>"+getTranNoLink("web.occup",transaction.getTransactionType(),sWebLanguage)+"</b> for <b>["+transaction.getPatient().personid+"] "+transaction.getPatient().getFullName()+"</b> created on "+SH.formatDate(created, SH.fullDateFormatSS)+"</td></tr>");
				out.flush();
				String sOldObjectid=transaction.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_OBJECTID");
				if(sOldObjectid.length()>0 && !sOldObjectid.equalsIgnoreCase("-1")){
					String newid=SH.getSync("transaction", sOldObjectid);
					if(!newid.equalsIgnoreCase("-1")){
						transaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_OBJECTID").setValue(newid);
					}
				}
				xml = transaction.toXml();
				minid=MedwanQuery.getInstance().getOpenclinicCounterNoIncrement("TransactionID");
				minid2=MedwanQuery.getInstance().getOpenclinicCounterNoIncrement("ItemID");
				objecttype="transaction";
			}
			else{
				SH.updateSync("transaction", oldid,"-1");
				continue;
			}
		}

		if(xml.length()>0){
			HttpClient client = new HttpClient();
			PostMethod method = new PostMethod(SH.cs("offlineSyncServerAPI","http://localhost/openclinic/api/postOfflineData.jsp"));
			//Send object to destination server
			NameValuePair[] nvp = new NameValuePair[6];
			nvp[0]= new NameValuePair("objecttype",objecttype);
			nvp[1]= new NameValuePair("updateuser",activeUser.userid);
			nvp[2]= new NameValuePair("minid",minid+"");
			nvp[3]= new NameValuePair("minid2",minid2+"");
			nvp[4]= new NameValuePair("xml",xml);
			nvp[5]= new NameValuePair("from",SH.cs("offlineLocalPrefix",""));
			method.setRequestBody(nvp);
			String authStr = SH.cs("offlineSyncServer.username", "nil") + ":" + SH.cs("offlineSyncServer.password", "nil");
			String authEncoded = Base64.getEncoder().encodeToString(authStr.getBytes());
		    method.setRequestHeader("Authorization", "Basic "+authEncoded);

		    try{
				int statusCode = client.executeMethod(method);
				String sResponse=method.getResponseBodyAsString();
				Document doc = org.dom4j.DocumentHelper.parseText(sResponse);
				Element eResponse = doc.getRootElement();
				if(eResponse.attributeValue("type").equalsIgnoreCase("admin")){
					new PersonMerger().update(Integer.parseInt(eResponse.attributeValue("newid")), Integer.parseInt(eResponse.attributeValue("oldid")), false);
					out.println("<tr><td><img src='"+sCONTEXTPATH+"/_img/icons/icon_check.png'/></td><td class='admin'>Updated to "+eResponse.attributeValue("newid")+"</td></tr>");
					SH.updateSync("admin", eResponse.attributeValue("oldid"), eResponse.attributeValue("newid"));
					checkCounter("PersonID",Integer.parseInt(eResponse.attributeValue("newid"))+1);
				}
				else if(eResponse.attributeValue("type").equalsIgnoreCase("encounter")){
					Encounter.updateEncounterUid(SH.getServerId()+"."+eResponse.attributeValue("oldid"), SH.getServerId()+"."+eResponse.attributeValue("newid"));
					out.println("<tr><td><img src='"+sCONTEXTPATH+"/_img/icons/icon_check.png'/></td><td class='admin'>Updated to "+eResponse.attributeValue("newid")+"</td></tr>");
					SH.updateSync("encounter", eResponse.attributeValue("oldid"), eResponse.attributeValue("newid"));
					checkCounter("OC_ENCOUNTERS",Integer.parseInt(eResponse.attributeValue("newid"))+1);
				}
				else if(eResponse.attributeValue("type").equalsIgnoreCase("transaction")){
					TransactionVO.updateTransactionUid(SH.getServerId()+"."+eResponse.attributeValue("oldid"), SH.getServerId()+"."+eResponse.attributeValue("newid"));
					Iterator<Element> items = eResponse.elementIterator("item");
					while(items.hasNext()){
						Element item = items.next();
						ItemVO.updateItemUid(SH.getServerId()+"."+item.attributeValue("oldid"), SH.getServerId()+"."+item.attributeValue("newid"));
						checkCounter("ItemID",Integer.parseInt(item.attributeValue("newid"))+1);
					}
					out.println("<tr><td><img src='"+sCONTEXTPATH+"/_img/icons/icon_check.png'/></td><td class='admin'>Updated to "+eResponse.attributeValue("newid")+"</td></tr>");
					SH.updateSync("transaction", eResponse.attributeValue("oldid"), eResponse.attributeValue("newid"));
					checkCounter("TransactionID",Integer.parseInt(eResponse.attributeValue("newid"))+1);
				}
				else if(eResponse.attributeValue("type").equalsIgnoreCase("error")){
					out.println("<tr><td><img src='"+sCONTEXTPATH+"/_img/icons/icon_error.gif'/></td><td class='adminred'>Error detected: <b>"+eResponse.attributeValue("message")+"</b>. Process stopped.</td></tr>");	
					bComplete=false;
					break;
				}
			}
			catch(Exception e){
				e.printStackTrace();
				out.println("<tr><td><img src='"+sCONTEXTPATH+"/_img/icons/icon_error.gif'/></td><td class='adminred'>Error detected: <b>Could not connect to "+SH.cs("offlineSyncServerAPI","http://localhost/openclinic/api/postOfflineData.jsp")+"</b>. Process stopped. Please check URL and API credentials.</td></tr>");	
				bComplete=false;
				try{
					method.abort();
				}
				catch(Exception f){
					e.printStackTrace();
				}
				break;
			}
		    method.releaseConnection();
		}
		MedwanQuery.getInstance().getObjectCache().reset();
	}
	if(!bInitialized){
		out.println("<tr><td class='admin2' colspan='2'>No data in synchronization queue.</td></tr>");	
	}
}
catch(Exception a){
	a.printStackTrace();
}
%>
		<tr class='admin'><td colspan='2'>...End of synchronization</td></tr>
</table>
<p/>
<% 	if(bComplete){ %>
	<script>
		document.getElementById('info').innerHTML="<input class='button' type='button' name='syncButtonPartial' value='<%=getTranNoLink("web","partialofflineserverdata",sWebLanguage)%>' onclick='partialOfflineServerData()'/>";
	</script>
<%	} %>
<script>
	function partialOfflineServerData(){
		window.location.href='<%=sCONTEXTPATH%>/main.do?Page=util/getPartialServerCopyIncremental.jsp';
	}
</script>

