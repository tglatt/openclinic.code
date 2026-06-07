<%@include file="/includes/validateUser.jsp"%>
<%
	HashSet hActiveUsers = new HashSet();
	Hashtable sessions = MedwanQuery.getSessions();
	SortedMap sortedSessions = new TreeMap();
	Enumeration e = sessions.keys();
	while(e.hasMoreElements()){
		HttpSession s = (HttpSession)e.nextElement();
		try{
			if(s!=null){
				User user = (User)sessions.get(s);
				if(user!=null && user.person!=null){
					hActiveUsers.add(user.userid);
				}
			}
		}
		catch(Exception q){
			q.printStackTrace();
		}
	}
%>
{
	activeusers: <%=hActiveUsers.size() %>
}