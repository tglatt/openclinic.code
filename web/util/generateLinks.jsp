<%@include file="/includes/helper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<form name='testForm' method='post'>
	<table>
		<tr>
			<td>Nodes: <input type='text' size='80' name='nodes' value='<%=SH.p(request,"nodes")%>'/></td>
		</tr>
		<tr>
			<td>Weight: <input type='text' size='5' name='weight' value='<%=SH.p(request,"weight")%>'/></td>
		</tr>
		<tr>
			<td>Type: <select name='type'><option value='1' <%=SH.p(request,"type").equalsIgnoreCase("1")?"selected":""%>>Directed</option><option value='2' <%=SH.p(request,"type").equalsIgnoreCase("2")?"selected":""%>>Undirected</option></select></td>
		</tr>
	</table>
	<input type='submit' name='submitDirectButton' value='Generate directed links'/>
</form>

<%
	boolean bInit=false;
	StringBuffer sb = new StringBuffer();
	out.println("Source;Target;Type;Weight<br/>");
	sb.append("Source;Target;Type;Weight\n");
	String[] links = (""+request.getParameter("nodes")).replaceAll(";",",").split(",");
	if(request.getParameter("type")!=null && request.getParameter("type").equals("1")){
		bInit=true;
		for(int n=0;n<links.length;n++){
			for(int i=0;i<links.length;i++){
				if(n!=i){
					sb.append(links[n]+";"+links[i]+";Directed;"+request.getParameter("weight")+"\n");
					out.println(links[n]+";"+links[i]+";Directed;"+request.getParameter("weight")+"<br/>");
				}
			}
		}
	}
	if(request.getParameter("type")!=null && request.getParameter("type").equals("2")){
		bInit=true;
		for(int n=0;n<links.length;n++){
			for(int i=n+1;i<links.length;i++){
				sb.append(links[n]+";"+links[i]+";Undirected;"+request.getParameter("weight")+"\n");
				out.println(links[n]+";"+links[i]+";Undirected;"+request.getParameter("weight")+"<br/>");
			}
		}
	}
	if(bInit){
		session.setAttribute("generatedLinks", sb);
		%>
		<br/><a href='<%=sCONTEXTPATH %>/util/getGeneratedLinks.jsp'/>Links CSV file</a><br/>
		<%
	}
%>