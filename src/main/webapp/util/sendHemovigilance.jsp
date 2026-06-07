<%@page import="be.mxs.common.util.tools.ProcessFiles"%>
<%@page import="be.mxs.common.util.db.PersonMerger"%>
<%@page import="org.apache.poi.util.DocumentHelper"%>
<%@page import="org.apache.commons.httpclient.*,org.apache.commons.httpclient.methods.*,java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
try{
	Connection conn = SH.getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_hemovigilance where oc_hemovigilance_processed is null order by oc_hemovigilance_timestamp");
	ResultSet rs = ps.executeQuery();
	int n=0;
	while(rs.next()){
		TransactionVO transaction = TransactionVO.get(rs.getString("oc_hemovigilance_transactionuid"));
		if(transaction!=null){
			String xml = transaction.toXml();
			String objecttype="hemovigilance";
			if(xml.length()>0){
				HttpClient client = new HttpClient();
				PostMethod method = new PostMethod(SH.cs("offlineSyncServerAPI","http://localhost/openclinic/api/postOfflineData.jsp"));
				//Send object to destination server
				NameValuePair[] nvp = new NameValuePair[7];
				nvp[0]= new NameValuePair("objecttype",objecttype);
				nvp[1]= new NameValuePair("updateuser",activeUser.userid);
				nvp[2]= new NameValuePair("xml",xml);
				nvp[3]= new NameValuePair("from",SH.cs("offlineLocalPrefix",""));
				nvp[4]= new NameValuePair("pocketnumber",SH.c(rs.getString("oc_hemovigilance_pocketnumber")));
				nvp[5]= new NameValuePair("minid","0");
				nvp[6]= new NameValuePair("minid2","0");
				method.setRequestBody(nvp);
				String authStr = SH.cs("offlineSyncServer.username", "nil") + ":" + SH.cs("offlineSyncServer.password", "nil");
				String authEncoded = Base64.getEncoder().encodeToString(authStr.getBytes());
			    method.setRequestHeader("Authorization", "Basic "+authEncoded);
			    try{
					int statusCode = client.executeMethod(method);
					String sResponse=method.getResponseBodyAsString();
					Document doc = org.dom4j.DocumentHelper.parseText(sResponse);
					Element eResponse = doc.getRootElement();
					SH.syslog("type="+eResponse.attributeValue("type"));
					if(eResponse.attributeValue("type").equalsIgnoreCase("hemovigilance")){
						PreparedStatement ps2 = conn.prepareStatement("update oc_hemovigilance set oc_hemovigilance_processed=now() where oc_hemovigilance_transactionuid=? and oc_hemovigilance_pocketnumber=?");
						ps2.setString(1,transaction.getUid());
						ps2.setString(2,SH.c(rs.getString("oc_hemovigilance_pocketnumber")));
						ps2.execute();
						ps2.close();
					}
					else if(eResponse.attributeValue("type").equalsIgnoreCase("error")){
						break;
					}
				}
				catch(Exception e){
					e.printStackTrace();
					try{
						method.abort();
					}
					catch(Exception f){
						e.printStackTrace();
					}
					break;
				}
			}
		}
	}
	rs.close();
	ps.close();
	conn.close();
}
catch(Exception o){
	o.printStackTrace();
}
%>
