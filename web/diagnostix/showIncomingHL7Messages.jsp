<%@include file="/includes/helper.jsp"%>
<table width='100%'>
	<tr class='admin'>
		<td>Message ID</td>
		<td>Message Type</td>
		<td>Received</td>
		<td>Processed</td>
		<td>Transaction ID</td>
		<td>Patient ID</td>
		<td>Patient Name</td>
	</tr>
	<%
		Connection conn = SH.getOpenClinicConnection();
		String sql = "select * from oc_hl7in order by oc_hl7in_received desc";
		PreparedStatement ps = conn.prepareStatement(sql);
		ResultSet rs = ps.executeQuery();
		int count=0;
		while(rs.next() && count++<SH.ci("s5.hl7.maxrowstoshow",100)){
			out.println("<tr>");
			out.println("<td class='admin'><a href='javascript:decodeMessage(\""+rs.getString("oc_hl7in_id")+"\")'><img src='"+sCONTEXTPATH+"/_img/icons/icon_edit.png'> "+rs.getString("oc_hl7in_id")+"</a></td>");
			out.println("<td class='admin2'>"+rs.getString("oc_hl7in_type")+"</td>");
			out.println("<td class='admin2'>"+SH.formatDate(rs.getTimestamp("oc_hl7in_received"),"dd/MM/yyyy HH:mm:ss")+"</td>");
			out.println("<td class='admin2'>"+SH.formatDate(rs.getTimestamp("oc_hl7in_processed"),"dd/MM/yyyy HH:mm:ss")+"</td>");
			String transactionId = SH.c(rs.getString("oc_hl7in_transactionid"));
			out.println("<td class='admin2'>"+transactionId+"</td>");
			String patientId = "", patientName="";
			try{
				TransactionVO tran = TransactionVO.get(SH.getServerId(), Integer.parseInt(transactionId));
				if(tran!=null){
					patientId=tran.getPatientUid()+"";
					patientName=tran.getPatient().getFullName();
				}
			}
			catch(Exception e){
				//e.printStackTrace();
			}
			out.println("<td class='admin2'>"+patientId+"</td>");
			out.println("<td class='admin2'>"+patientName+"</td>");
			out.println("</tr>");
		}
		rs.close();
		ps.close();
		conn.close();
	%>
</table>
<center style="padding-top:10px;">
   	<input type="button" name="backButton" class="button" value="Home" onClick="goBack();">
</center>

<script>
	function decodeMessage(id){
		url='<%=sCONTEXTPATH%>/diagnostix/decodeHL7Message.jsp?id='+id;
    	parameters="toolbar=no,status=no,scrollbars=no,resizable=yes,width=1024,height=600,menubar=no";
		window.open(url,"HL7-Message",parameters).moveTo((screen.width-1024)/2,(screen.height-600)/2);
	}
	
</script>
