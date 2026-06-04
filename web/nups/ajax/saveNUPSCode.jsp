<%@page import="be.mayele.MayeleAPI"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String code = SH.p(request,"code");
	String extension = SH.p(request,"extension");
	String parent = SH.p(request,"parent");
	String csu = SH.p(request,"csu");
	String originalcode = SH.p(request,"originalcode");
	String domain = SH.p(request,"domain");
	String fr = SH.p(request,"fr");
	String en = SH.p(request,"en");
	String es = SH.p(request,"es");
	String pt = SH.p(request,"pt");
	String section = SH.p(request,"section");
	String nsection = section;
	try{
		nsection=Double.parseDouble(section)+"";
	}
	catch(Exception e){
		e.printStackTrace();
	}
	Connection conn = SH.getOpenClinicConnection();
	boolean bGoodToGo=true;
	String msg = "";
	//First we do some checks
	if((fr+en+es+pt).length()==0){
		bGoodToGo=false;
		msg="Au moins une libellé doit être forunie";
	}
	else if(code.length()==0 && extension.length()>0){
		bGoodToGo=false;		
		msg="Il n'est pas autorisé de sauvegarder une extension sans code NUPS existante";
	}
	SH.syslog("1");
	if(bGoodToGo){
		SH.syslog("2");
		if(code.length()>0){
			SH.syslog("3");
			String newcode=code;
			if(extension.length()>0){
				newcode=newcode+"."+extension;
			}
			String sql="select * from nupsref where nups=?";
			PreparedStatement ps = conn.prepareStatement(sql);
			ps.setString(1,newcode);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				SH.syslog("4");
				//The code exists;
				rs.close();
				ps.close();
				sql="update nupsref set parent=?,csu=?,originalcode=?,domain=?,fr=?,en=?,es=?,pt=?,sectioncode=?,section=?,muid=? where nups=?";
				ps=conn.prepareStatement(sql);
				ps.setString(1,parent);
				ps.setString(2,csu);
				ps.setString(3,originalcode);
				ps.setString(4,domain);
				ps.setString(5,fr);
				ps.setString(6,en);
				ps.setString(7,es);
				ps.setString(8,pt);
				ps.setString(9,section);
				ps.setString(10,getTranNoLink("nups.section",nsection,sWebLanguage));
				ps.setInt(11,MayeleAPI.convertFromNUPSUUID(code));
				ps.setString(12,newcode);
				ps.execute();
				ps.close();
				String s = fr;
				if(sWebLanguage.equalsIgnoreCase("en")){
					s=en;
				}
				else if(sWebLanguage.equalsIgnoreCase("es")){
					s=es;
				}
				if(sWebLanguage.equalsIgnoreCase("pt")){
					s=pt;
				}
				msg="The NUPS code ["+newcode+": "+s.split(";")[0]+"] was succesfully updated";
			}
			else{
				rs.close();
				ps.close();
				//This is a new code, create a new entry
				sql="select max(muid) muid from nupsref";
				ps = conn.prepareStatement(sql);
				rs = ps.executeQuery();
				if(rs.next()){
					int newmuid = rs.getInt("muid")+1;
					rs.close();
					ps.close();
					sql = "insert into nupsref(id,muid,csu,nups,originalcode,domain,fr,en,es,pt,sectioncode,section,parent) values(?,?,?,?,?,?,?,?,?,?,?,?,?)";
					ps = conn.prepareStatement(sql);
					ps.setInt(1,newmuid);
					ps.setInt(2,newmuid);
					ps.setString(3,csu);
					ps.setString(4,newcode);
					ps.setString(5,originalcode);
					ps.setString(6,domain);
					ps.setString(7,fr);
					ps.setString(8,en);
					ps.setString(9,es);
					ps.setString(10,pt);
					ps.setString(11,section);
					ps.setString(12,getTranNoLink("nups.section",nsection,sWebLanguage));
					ps.setString(13,parent);
					ps.execute();
					ps.close();
					String s = fr;
					if(sWebLanguage.equalsIgnoreCase("en")){
						s=en;
					}
					else if(sWebLanguage.equalsIgnoreCase("es")){
						s=es;
					}
					if(sWebLanguage.equalsIgnoreCase("pt")){
						s=pt;
					}					
					msg="The NUPS code ["+newcode+": "+s.split(";")[0]+"] was succesfully created";
				}
				else{
					rs.close();
					ps.close();
					msg="Could not create the new NUPS code";
				}
			}
		}
		else {
			//This is a new code, create a new entry
			String sql="select max(muid) muid from nupsref";
			PreparedStatement ps = conn.prepareStatement(sql);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				int newmuid = rs.getInt("muid")+1;
				code =MayeleAPI.convertToNUPSUUID(newmuid);
				SH.syslog("muid="+newmuid+" / code="+code);
				rs.close();
				ps.close();
				sql = "insert into nupsref(id,muid,csu,nups,originalcode,domain,fr,en,es,pt,sectioncode,section,parent) values(?,?,?,?,?,?,?,?,?,?,?,?,?)";
				ps = conn.prepareStatement(sql);
				ps.setInt(1,newmuid);
				ps.setInt(2,newmuid);
				ps.setString(3,csu);
				ps.setString(4,code);
				ps.setString(5,originalcode);
				ps.setString(6,domain);
				ps.setString(7,fr);
				ps.setString(8,en);
				ps.setString(9,es);
				ps.setString(10,pt);
				ps.setString(11,section);
				ps.setString(12,getTranNoLink("nups.section",nsection,sWebLanguage));
				ps.setString(13,parent);
				ps.execute();
				ps.close();
			}
			rs.close();
			ps.close();
		}
	}
	conn.close();
%>
<h1>
<%=msg%>
</h1>