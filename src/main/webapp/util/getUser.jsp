<%
	/*
	API:		getUser.jsp
	Author:		frank@ict4d.be
	Method:		GET 					
	Version:	1.0
	Date:		03 Aug 2022				
	Parameters:	userid	(mandatory) 	
	Returns:	JSON object with errorcode, firstname and lastname of retrieved user
	*/
	String userid = request.getParameter("userid");
	String resp = "";
	
	if(userid==null){
		resp = "{\"error\": \"500\", \"firstname\": \"\", \"lastname\": \"\"}";
	}
	else{
		String error="",firstname="",lastname="",dateofbirth="",gender="";
		net.admin.User user = net.admin.User.get(Integer.parseInt(userid));
		if(user.person.isNotEmpty()){
			error="200";
			firstname=user.person.firstname;
			lastname=user.person.lastname;
			dateofbirth=user.person.dateOfBirth;
			gender=user.person.gender;
		}
		else{
			error="501";
		}
		
		resp = "{\"error\": \""+error
				+"\", \"firstname\": \""+firstname
				+"\", \"lastname\": \""+lastname
				+"\", \"dateofbirth\": \""+dateofbirth
				+"\", \"gender\": \""+gender
				+"\"}";
	}
	out.print(resp);
%>
