<%@include file="/includes/validateUser.jsp"%>
<%
	try{
		String group1 = SH.p(request,"group1");
		String group2 = SH.p(request,"group2");
		String group3 = SH.p(request,"group3");
		String nups = SH.p(request,"nups");
		Connection conn = SH.getOpenClinicConnection();
		PreparedStatement ps = conn.prepareStatement("delete from nupsapplications where application='groups' and nups=?");
		ps.setString(1,nups);
		ps.execute();
		ps.close();
		if(group1.length()>0){
			ps = conn.prepareStatement("insert into nupsapplications(id,application,data,nups) values(?,?,?,?)");
			ps.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("NUPSAPPLICATION"));
			ps.setString(2,"groups");
			ps.setString(3,group1);
			ps.setString(4,nups);
			ps.execute();
		}
		if(group2.length()>0){
			ps = conn.prepareStatement("insert into nupsapplications(id,application,data,nups) values(?,?,?,?)");
			ps.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("NUPSAPPLICATION"));
			ps.setString(2,"groups");
			ps.setString(3,group2);
			ps.setString(4,nups);
			ps.execute();
		}
		if(group3.length()>0){
			ps = conn.prepareStatement("insert into nupsapplications(id,application,data,nups) values(?,?,?,?)");
			ps.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("NUPSAPPLICATION"));
			ps.setString(2,"groups");
			ps.setString(3,group3);
			ps.setString(4,nups);
			ps.execute();
		}
		conn.close();
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>