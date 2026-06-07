<%@include file="/includes/validateUser.jsp"%>
<%
	if(activeUser.getAccessRightNoSA("mpi.serveradmin.delete")){
		String messageId=SH.p(request,"messageid");
		if(messageId.length()>0){
			Connection conn = SH.getStatsConnection();
			PreparedStatement ps = conn.prepareStatement("delete from ghb_messages where ghb_message_id=?");
			ps.setString(1,messageId);
			ps.execute();
			ps.close();
			conn.close();
		}
	}
%>