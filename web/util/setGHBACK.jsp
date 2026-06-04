<%@page import="be.openclinic.medical.RequestedLabAnalysis,be.mxs.common.model.vo.healthrecord.*"%>
<%@page import="org.dom4j.*,org.dom4j.tree.*"%>
<%@page import="be.openclinic.system.*,be.mxs.common.util.system.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
	String ref = SH.p(request,"ref");
	String source = SH.p(request,"source");
	String target = SH.p(request,"target");
	String comment = SH.p(request,"comment");
	
	if(ref.length()>0 && source.length()>0 && target.length()>0){
		Connection conn = SH.getStatsConnection();
		for(int n=0;n<ref.split(";").length;n++){
			PreparedStatement ps = conn.prepareStatement("insert into GHB_ACK(GHB_ACK_REF,GHB_ACK_SOURCESERVERID,GHB_ACK_TARGETSERVERID,GHB_ACK_DATETIME,GHB_ACK_COMMENT) values(?,?,?,?,?)");
			ps.setString(1, ref.split(";")[n]);
			ps.setInt(2,Integer.parseInt(source));
			ps.setInt(3,Integer.parseInt(target));
			ps.setTimestamp(4, SH.getSQLTime());
			ps.setString(5, comment);
			ps.execute();
			ps.close();
		}
		conn.close();
	}
%>
<ok>