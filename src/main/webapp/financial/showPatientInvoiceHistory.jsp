<%@ page import="be.openclinic.finance.*,be.openclinic.adt.Encounter,java.text.*,be.mxs.common.util.system.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width='100%'>
	<tr class='admin'><td  colspan='3'><%=getTran(request,"web","invoicehistory",sWebLanguage) %></td></tr>
<%
	int maxversion=0;
	String invoiceuid=checkString(request.getParameter("invoiceuid"));
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_patientinvoices_history where oc_patientinvoice_objectid=? order by oc_patientinvoice_version");
	ps.setInt(1,Integer.parseInt(invoiceuid));
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		if(rs.getInt("oc_patientinvoice_version")>maxversion){
			maxversion=rs.getInt("oc_patientinvoice_version");
		}
		out.println("<tr><td class='admin'>"+rs.getInt("oc_patientinvoice_version")+"</td><td class='admin2'><a href='javascript:showInvoice("+rs.getInt("oc_patientinvoice_version")+")'>"+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(rs.getTimestamp("oc_patientinvoice_updatetime"))+"</a></td><td class='admin2'>"+User.getFullUserName(rs.getString("oc_patientinvoice_updateuid"))+"</td></tr>");
	}
	rs.close();
	ps.close();
	conn.close();
%>

</table>

<script>
	function showInvoice(version){
	  	openPopup("/healthrecord/showPatientInvoiceFromHistory.jsp&ts=<%=getTs()%>&maxversion=<%=maxversion%>&uid=<%=SH.getServerId()+"."+invoiceuid%>&version="+version,1024,600);
	}
</script>