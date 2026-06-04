package be.openclinic.util;

import java.sql.*;
import java.util.Base64;

import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.NameValuePair;
import org.apache.commons.httpclient.methods.PostMethod;
import org.dom4j.Document;
import org.dom4j.Element;

import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.openclinic.system.SH;

public class Hemovigilance {

	public static void send() {
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
						PostMethod method = new PostMethod(SH.cs("hemovigilanceSyncServerAPI","http://localhost/openclinic/api/postOfflineData.jsp"));
						//Send object to destination server
						NameValuePair[] nvp = new NameValuePair[7];
						nvp[0]= new NameValuePair("objecttype",objecttype);
						nvp[1]= new NameValuePair("updateuser",SH.cs("defaultLabTechnicianId","4"));
						nvp[2]= new NameValuePair("xml",xml);
						nvp[3]= new NameValuePair("from",SH.cs("offlineLocalPrefix",""));
						nvp[4]= new NameValuePair("pocketnumber",SH.c(rs.getString("oc_hemovigilance_pocketnumber")));
						nvp[5]= new NameValuePair("minid","0");
						nvp[6]= new NameValuePair("minid2","0");
						method.setRequestBody(nvp);
						String authStr = SH.cs("hemovigilanceSyncServer.username", "nil") + ":" + SH.cs("hemovigilanceSyncServer.password", "nil");
						String authEncoded = Base64.getEncoder().encodeToString(authStr.getBytes());
					    method.setRequestHeader("Authorization", "Basic "+authEncoded);
					    try{
							int statusCode = client.executeMethod(method);
							String sResponse=method.getResponseBodyAsString();
							Document doc = org.dom4j.DocumentHelper.parseText(sResponse);
							Element eResponse = doc.getRootElement();
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
	}
	
}
