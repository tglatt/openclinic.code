<%@page import="be.mxs.common.util.system.UpdateSystem"%>
<%@include file="/includes/helper.jsp"%>
<!DOCTYPE html>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<%
	MedwanQuery.getInstance("http://"+request.getServerName()+":"+request.getServerPort()+request.getRequestURI().replaceAll(request.getServletPath(),"")+"/"+sAPPDIR);
	String sWebLanguage="en";
	if(request.getParameter("language")!=null){
		sWebLanguage=request.getParameter("language");
	}
	UpdateSystem.reloadSingletonNoSession();
	String sUserName = checkString(request.getParameter("username"));
	String sPassword = checkString(request.getParameter("password"));
	String sMessage="";
	
	if(sUserName.length()>0 && sPassword.length()>0){
		if(User.validate(sUserName, sPassword)){
			User user = null;
			int nUserId = User.getUseridByAlias(sUserName);
			if(nUserId>-1){
				user = User.getByAlias(sUserName);
			}
			else{
				try{
					user=User.get(Integer.parseInt(sUserName));
				}
				catch(Exception e){
					e.printStackTrace();
				}
			}
			if(user!=null && user.userid.length()>0 && User.hasPermission(user.userid,ScreenHelper.getSQLDate(new java.util.Date()))){
				session.setAttribute("activeUser",user);
				session.setAttribute(sAPPTITLE+"WebLanguage",user.getParameter("userlanguage"));
                MedwanQuery.setSession(session,user);
                if(SH.cs("redirectUser."+user.userid,"").length()>0){
                	out.println("<script>window.location.href='"+sCONTEXTPATH+SH.cs("redirectUser."+user.userid,"")+"';</script>");
                }
                else{
					out.println("<script>window.location.href='"+sCONTEXTPATH+"/nups/manageNUPSCodes.jsp';</script>");
                }
				out.flush();
			}
			else{
				sMessage=getTran(request,"web","invalidlogin",sWebLanguage);
			}
		}
	}
	
	
%>
<%=sCSSNORMAL %>
<title><%=SH.cs("nupsServerName","UNHS-NUPS") %></title>
<html>
	<head>
		<%=sKHINFAVICON %>
	</head>
	<body>
		<form name='transactionForm' method='post'>
			<input type='hidden' name='formaction' id='formaction'/>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
			    <tr>
			        <td align="center" style="vertical-align:top;" width="1%">
			            <img height='200px' src="<%=MedwanQuery.getInstance().getConfigString("nupsLoginLogo",sCONTEXTPATH+"/_img/cerfis2.png") %>" border="0">
						<br/>&nbsp;<br/>&nbsp;<br/>&nbsp;<br/>
			        </td>
			    </tr>
				<tr>
					<td>
						<center>
							<table>
								<tr>
									<td nowrap style='font-size: 1.5vw;text-align:right;padding=10px;font-family: Raleway, Geneva, sans-serif;'>
										<%=getTranNoLink("web","login",sWebLanguage) %>:&nbsp;
									</td>
									<td nowrap style='font-size: 1.5vw;text-align:left;padding=10px;font-family: Raleway, Geneva, sans-serif;'>
										<input style='padding:5px; font-size: 1.5vw;border: 1px solid #cccccc;background-color: #ffffe6' type='text' name='username' value="" size='15'/>
									</td>
								</tr>
								<tr>
									<td nowrap style='font-size: 1.5vw;text-align:right;padding=10px;font-family: Raleway, Geneva, sans-serif;'>
										<%=getTranNoLink("web","password",sWebLanguage) %>:&nbsp;
									</td>
									<td nowrap style='font-size: 1.5vw;text-align:left;padding=10px;font-family: Raleway, Geneva, sans-serif;'>
										<input style='padding:5px; font-size: 1.5vw;border: 1px solid #cccccc;background-color: #ffffe6' type='password' name='password' value="" size='15'/>
									</td>
								</tr>
								<tr>
									<td/>
									<td nowrap style='font-size: 1.5vw;ertical-align: middle; text-align:left;padding=10px;font-family: Raleway, Geneva, sans-serif;'>
										<input style='padding:2px; height: 30px;vertical-align: middle; font-size: 1.5vw;border: 1px solid #cccccc' type='submit' name='<%=getTranNoLink("web","login",sWebLanguage) %>' value="Login"/>
									</td>
								</tr>
								<tr>
									<td colspan='2' nowrap style='font-size: 12px;text-align:center;font-family: Raleway, Geneva, sans-serif;'>
										<br/>Public login: '<b style="font-size: 12px">guest</b>' with password '<b style="font-size: 12px">guest</b>'
									</td>
								</tr>
								<%if(sMessage.length()>0){ %>
								<tr>
									<td colspan='2' style='font-size: 1.5vw;text-align:center;color=red;padding=10px;font-family: Raleway, Geneva, sans-serif;'>
										<font style='padding:5px; font-size: 1.5vw;color: red;font-weight: bolder'><%=sMessage %></font>
									</td>
								</tr>
								<% } %>
								<tr>
									<td colspan='2' style='font-size: 1vw;border-bottom:1px solid lightgrey;text-align: center'><br/>&nbsp;<br/>&nbsp;<br/>&nbsp;<br/></td>
								</tr>
								<tr>
									<td colspan='2' style='text-align: center'>
										&nbsp;<br/><img height='80px' src='<%=MedwanQuery.getInstance().getConfigString("nupsCredits",sCONTEXTPATH+"/projects/nups/_img/credits.png") %>'/>
									</td>
								</tr>
							</table>
						</center>
					</td>
				</tr>
			</table>
		</form>
	</body>
</html>
