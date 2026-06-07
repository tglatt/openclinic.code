<%@page import="java.util.*"%>
<%@page import="org.json.*"%>
<%@page import="org.dom4j.*"%>
<%@page import="org.apache.commons.httpclient.*"%>
<%@page import="org.apache.commons.httpclient.methods.*"%>
<%@page import="org.apache.http.entity.*"%>
<%@include file="/includes/helper.jsp"%>

<%!
	public String addParameter(HttpServletRequest request, PostMethod method, String parameter,
														String defaultValue){
		String value = SH.c(request.getParameter(parameter),defaultValue);
		method.addParameter(parameter,value);
		return value;
	}

	public void addAuthorizationHeader(HttpServletRequest request, PostMethod method){
		try{
			String login = SH.c(request.getParameter("login"));
			String password = SH.c(request.getParameter("password"));
			String credentials = Base64.getEncoder().encodeToString((login+":"+password).getBytes());
			method.addRequestHeader("Authorization","Basic "+credentials);
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public boolean isAuthorized(HttpServletRequest request,String accessright){
		try{
			String credentials = SH.c(request.getHeader("Authorization"));
			if(credentials.startsWith("Basic ")){
				credentials=new String(Base64.getDecoder().decode(credentials.substring(6)));
				if(credentials.split(":").length>1){
					String login = credentials.split(":")[0];
					String password = credentials.split(":")[1];
					//Vérifier si la combinaison login/mot de passe est valide
					if(User.validate(login, password)){
						//Vérifier si l'utilisateur a les droits d'accès nécessaires
						User user = User.get(Integer.parseInt(login));
						if(user.getAccessRightNoSA(accessright)){
							return true;
						}
					}
				}
			}
			return false;
		}
		catch(Exception e){
			e.printStackTrace();
			return false;
		}
	}

%>