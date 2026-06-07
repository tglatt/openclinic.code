<%@include file="/includes/validateUser.jsp"%>
<%
	int activesessions=0;
	Hashtable sessions = MedwanQuery.getSessions();
	SortedMap sortedSessions = new TreeMap();
	Enumeration e = sessions.keys();
	while(e.hasMoreElements()){
		HttpSession s = (HttpSession)e.nextElement();
		try{
			if(s!=null){
				User user = (User)sessions.get(s);
				if(user!=null && user.person!=null){
					activesessions++;
				}
			}
		}
		catch(Exception q){
			q.printStackTrace();
		}
	}
%>
{
	activesessions: <%=activesessions %>
}