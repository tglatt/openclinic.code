<%@page import="be.openclinic.medical.RequestedLabAnalysis,be.mxs.common.model.vo.healthrecord.*"%>
<%@page import="org.dom4j.*,org.dom4j.tree.*"%>
<%@page import="be.openclinic.system.*,be.mxs.common.util.system.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
	String sMessage="<message>";
	String serverid = SH.p(request,"serverid");
	String datetime = SH.p(request,"datetime");
	Debug.println("request="+serverid+" from ip "+request.getHeader("x-forwarded-for")+" for date "+datetime);
	Connection conn = SH.getStatsConnection();
	PreparedStatement ps = conn.prepareStatement("select * from GHB_ACK where GHB_ACK_TARGETSERVERID=? and GHB_ACK_DATETIME>?");
	ps.setInt(1,Integer.parseInt(serverid));
	ps.setTimestamp(2, SH.getSQLTimestamp(SH.parseDate(datetime,"yyyyMMddHHmmssSSS")));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		sMessage+="<ack ref='"+rs.getString("GHB_ACK_REF")+"' source='"+rs.getString("GHB_ACK_SOURCESERVERID")+"' datetime='"+SH.formatDate(rs.getTimestamp("GHB_ACK_DATETIME"),"yyyyMMddHHmmssSSS")+"' comment='"+SH.c(rs.getString("GHB_ACK_COMMENT"))+"'/>";
	}
	rs.close();
	ps.close();
	conn.close();
	sMessage+="</message>";
	out.print(sMessage);
%>
