<%@page import="be.mayele.MayeleAPI"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%
	Connection conn = SH.getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement("select * from nupsbi");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		String nups = SH.c(rs.getString("nups"));
		String original=SH.c(rs.getString("original"));
		String fr=SH.c(rs.getString("fr"));
		//First check if nups exists in nupsref
		SH.syslog("checking existence of "+nups+" ("+fr+")");
		PreparedStatement ps2 = conn.prepareStatement("select * from nupsref where nups=? or (originalcode=? and fr=?)");
		ps2.setString(1,nups);
		ps2.setString(2,original);
		ps2.setString(3,fr);
		ResultSet rs2 = ps2.executeQuery();
		if(rs2.next()){
			//The code exists
			SH.syslog("The code exists");
			String refnups = SH.c(rs2.getString("nups"));
			if(nups.equalsIgnoreCase(refnups)){
				//The code is identical, do nothing
				SH.syslog("The code is identical, do nothing");
			}
			else{
				SH.syslog("The code is different from "+refnups);
				//The code is different, update with refnups
				rs2.close();
				ps2.close();
				if(nups.length()>0){
					SH.syslog("Updating the code to "+refnups);
					ps2 = conn.prepareStatement("update nupsbi set nups=? where nups=?");
					ps2.setString(1,refnups);
					ps2.setString(2,nups);
					ps2.execute();
					ps2.close();
					SH.syslog("Updating the parents to "+refnups);
					ps2 = conn.prepareStatement("update nupsbi set parent=? where parent=?");
					ps2.setString(1,refnups);
					ps2.setString(2,nups);
					ps2.execute();
					ps2.close();
				}
				else{
					SH.syslog("Updating the code to "+refnups);
					ps2 = conn.prepareStatement("update nupsbi set nups=? where original=? and fr=?");
					ps2.setString(1,refnups);
					ps2.setString(2,original);
					ps2.setString(3,fr);
					ps2.execute();
					ps2.close();
				}
			}
		}
		else{
			//The code doesn't exist, create it
			SH.syslog("The code does not exist");
			String sql="select max(muid) muid from nupsref";
			ps2 = conn.prepareStatement(sql);
			rs2 = ps2.executeQuery();
			if(rs2.next()){
				int newmuid = rs2.getInt("muid")+1;
				String code =MayeleAPI.convertToNUPSUUID(newmuid);
				SH.syslog("Creating new code in nupsref: "+code);
				rs2.close();
				ps2.close();
				sql = "insert into nupsref(id,muid,csu,nups,originalcode,domain,fr,en,es,pt,sectioncode,section,parent) values(?,?,?,?,?,?,?,?,?,?,?,?,?)";
				ps2 = conn.prepareStatement(sql);
				ps2.setInt(1,newmuid);
				ps2.setInt(2,newmuid);
				ps2.setString(3,"true");
				ps2.setString(4,code);
				ps2.setString(5,original);
				ps2.setString(6,SH.c(rs.getString("domain")));
				ps2.setString(7,fr);
				ps2.setString(8,SH.c(rs.getString("en")));
				ps2.setString(9,"");
				ps2.setString(10,"");
				ps2.setInt(11,-1);
				ps2.setString(12,"");
				
				PreparedStatement ps3 = conn.prepareStatement("select * from nupsbi where original=? and fr=?");
				ps3.setString(1,original);
				ps3.setString(2, fr);
				String actualparent="";
				ResultSet rs3 = ps3.executeQuery();
				if(rs3.next()){
					actualparent=SH.c(rs.getString("parent"));
					ps2.setString(13,actualparent);
					ps2.execute();
				}
				rs3.close();
				ps3.close();
				SH.syslog("Updating code to "+code);
				ps2.close();
				ps2 = conn.prepareStatement("update nupsbi set nups=? where original=? and fr=?");
				ps2.setString(1,code);
				ps2.setString(2,original);
				ps2.setString(3,fr);
				ps2.execute();
				ps2.close();
				if(nups.length()>0){
					SH.syslog("Updating parents to "+code);
					ps2 = conn.prepareStatement("update nupsbi set parent=? where parent=?");
					ps2.setString(1,code);
					ps2.setString(2,nups);
					ps2.execute();
					ps2.close();
				}
			}
			rs2.close();
			ps2.close();
		}
		rs2.close();
		ps2.close();
		
	}
	rs.close();
	ps.close();
	conn.close();
%>