<%@include file="/includes/validateUser.jsp"%>
<%
	String assetuid = SH.p(request,"assetuid");
	String serialnumber = SH.p(request,"serialnumber");
	boolean bExists=false;
	Connection conn = SH.getOpenClinicConnection();
	try{
		if(assetuid.split("\\.").length>1){
			PreparedStatement ps = conn.prepareStatement("select * from oc_assets where oc_asset_serial=? and oc_asset_objectid<>?");
			ps.setString(1, serialnumber);
			ps.setInt(2, Integer.parseInt(assetuid.split("\\.")[1]));
			ResultSet rs = ps.executeQuery();
			bExists=rs.next();
			rs.close();
			ps.close();
		}
	}
	catch(Exception e){
		e.printStackTrace();
	}
	if(conn!=null) conn.close();
%>
{
	"exists" : <%=bExists %>
}