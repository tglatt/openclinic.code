<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	//First export labanalysisgroups
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_labels where oc_label_type='labanalysisgroup' order by oc_label_id,oc_label_language");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		
	}

%>