<%@page import="ca.uhn.hl7v2.*,ca.uhn.hl7v2.parser.*"%>
<%@include file="/includes/helper.jsp"%>
<pre><code><script style="display:block" type="text/plain">
<%
	Connection conn = SH.getOpenClinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from oc_s5xml where oc_s5xml_id=?");
	ps.setString(1,SH.p(request,"id"));
	ResultSet rs = ps.executeQuery();
	if(rs.next()){
		try{
			String msg = new String(rs.getBytes("oc_s5xml_message"));
			out.println(msg);
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	rs.close();
	ps.close();
	conn.close();
%>
</script>