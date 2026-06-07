<%@include file="/includes/validateUser.jsp"%>
<%
	try{
		String level = SH.p(request,"level");
		String nups = SH.p(request,"nups");
		String active = SH.p(request,"active");
		Connection conn = SH.getOpenClinicConnection();
		if(active.equalsIgnoreCase("0")){
			PreparedStatement ps = conn.prepareStatement("delete from nupsapplications where application='levels' and nups=? and data=?");
			ps.setString(1,nups);
			ps.setString(2,level);
			ps.execute();
			ps.close();
		}
		else if(active.equalsIgnoreCase("1")){
			PreparedStatement ps = conn.prepareStatement("select * from nupsapplications where application='levels' and nups=? and data=?");
			ps.setString(1,nups);
			ps.setString(2,level);
			ResultSet rs = ps.executeQuery();
			if(!rs.next()){
				rs.close();
				ps.close();
				ps = conn.prepareStatement("insert into nupsapplications(id,application,data,nups) values(?,?,?,?)");
				ps.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("NUPSAPPLICATION"));
				ps.setString(2,"levels");
				ps.setString(3,level);
				ps.setString(4,nups);
				ps.execute();
			}
			else{
				rs.close();
			}
			ps.close();
		}
		conn.close();
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>