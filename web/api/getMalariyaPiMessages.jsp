<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	Vector<String> messages = new Vector<String>();
	String serverid = SH.p(request,"serverid");
	SH.syslog("serverid="+serverid);
	Connection conn = SH.getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_messages where oc_message_transport='none' and oc_message_type='malariyapi' and oc_message_sentto=? and oc_message_sentdatetime is null");
	ps.setString(1,serverid);
	ResultSet rs = ps.executeQuery();
	out.print("{\"messages\":[");
	boolean bInit=false;
	while(rs.next()){
		if(bInit){
			out.print(",");
		}
		out.print(rs.getString("oc_message_data"));
		messages.add(rs.getString("oc_message_messageid"));
	}
	out.print("]}");
	rs.close();
	ps.close();
	for(int n=0;n<messages.size();n++){
		ps = conn.prepareStatement("update oc_messages set oc_message_sentdatetime=? where oc_message_messageid=?");
		ps.setTimestamp(1,SH.getSQLTime());
		ps.setString(2,messages.elementAt(n));
		ps.execute();
		ps.close();
	}
	conn.close();
%>
