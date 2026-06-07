<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	Connection conn = SH.getAdminConnection();
	Vector<String> persons = new Vector();
	PreparedStatement ps = conn.prepareStatement("select personid,lastname,firstname,dateofbirth from admin");
	ResultSet rs = ps.executeQuery();
	while(rs.next()){
		persons.add(rs.getInt("personid")+"|"+rs.getString("lastname")+"|"+rs.getString("firstname")+"|"+(rs.getDate("dateofbirth")==null?0:rs.getDate("dateofbirth").getTime()));
	}
	rs.close();
	ps.close();
	ps = conn.prepareStatement("select personid,lastname,firstname,searchname from admin order by personid desc");
	rs = ps.executeQuery();
	int count=0;
	while(rs.next()){
		int personid=rs.getInt("personid");
		PreparedStatement ps2=conn.prepareStatement("update admin set lastname=? where personid=?");
		String lastname=persons.elementAt(new Double(Math.random()*persons.size()-1).intValue()).split("\\|")[1];	
		ps2.setString(1,lastname);
		ps2.setInt(2,personid);
		SH.syslog(rs.getString("lastname")+"-->"+lastname);
		ps2.execute();
		ps2.close();
		ps2=conn.prepareStatement("update admin set firstname=? where personid=?");
		String firstname=persons.elementAt(new Double(Math.random()*persons.size()-1).intValue()).split("\\|")[2];	
		ps2.setString(1,firstname);
		ps2.setInt(2,personid);
		SH.syslog(rs.getString("firstname")+"-->"+firstname);
		ps2.execute();
		ps2.close();
		ps2=conn.prepareStatement("update admin set searchname=? where personid=?");
		String searchname=SH.normalizeSpecialCharacters((lastname+","+firstname).toUpperCase().replaceAll(" ",""));	
		ps2.setString(1,searchname);
		ps2.setInt(2,personid);
		SH.syslog(rs.getString("searchname")+"-->"+searchname);
		ps2.execute();
		ps2.close();
		//
		//ps2=conn.prepareStatement("update admin set dateofbirth=? where personid=?");
		//java.sql.Date dob =new java.sql.Date(Long.parseLong(persons.elementAt(new Double(Math.random()*persons.size()-1).intValue()).split("\\|")[3]));	
		//ps2.setDate(1,dob);
		//ps2.setInt(2,personid);
		//ps2.execute();
		//ps2.close();
		//
	}
	rs.close();
	ps.close();
%>