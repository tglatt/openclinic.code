<%@page import="be.mxs.common.util.system.*,be.mxs.common.util.db.*,be.mxs.common.util.io.*,be.openclinic.system.*"%>
<%
	String translation="";
	try{
		String sourcelanguage = request.getParameter("sourcelanguage");
		String targetlanguage = request.getParameter("targetlanguage");
		String sourcelabel = request.getParameter("labelvalue");
		translation = GoogleTranslate.translate(SH.cs("GoogleAPIKey",""),sourcelanguage,targetlanguage,sourcelabel);
		if(sourcelabel.substring(0, 1)==sourcelabel.substring(0, 1).toUpperCase()){
			translation=translation.substring(0,1).toUpperCase()+(translation.length()<=1?"":translation.substring(1));
		}
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
{
"translation":"<%=translation%>"
}