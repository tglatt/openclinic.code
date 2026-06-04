<%@page import="org.apache.commons.io.IOUtils"%>
<%@page import="java.io.*"%>
<%@page import="net.admin.*"%>
<%@page import="java.util.*"%>
<%@page import="org.apache.commons.httpclient.methods.PostMethod"%>
<%!
	public void addBasicAuthentification(PostMethod method,String login,String password){
		try{
			String auth=Base64.getEncoder().encodeToString((login+":"+password).getBytes("utf-8"));
			method.addRequestHeader("Authorization","Basic "+auth);
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}

	public boolean isAuthorized(HttpServletRequest request,String accessright){
		boolean bAuthorized = false;
		try{
			String auth = request.getHeader("Authorization");
			if(auth!=null && auth.startsWith("Basic ")){
				auth=auth.substring(6);
				String[] components = new String(Base64.getDecoder().decode(auth)).split(":");
				if(components.length>1){
					String login = components[0];
					String password = components[1];
					if(User.validate(login, password)){
						User user = User.get(Integer.parseInt(login));
						bAuthorized = user.getAccessRight(accessright);
					}
				}
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return bAuthorized;
	}
	
	public String getBody(HttpServletRequest request){
		try{
		    return IOUtils.toString(request.getReader());
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return "";
	}
%>