<%@page import="be.mxs.common.util.io.OBR,javax.json.*"%>
<%
	JsonObject jo=OBR.addPatientInvoiceGetJSONObject("1.30", true);
%>
{
	"success" : <%=jo.getBoolean("success") %>,
	"msg" : <%=jo.getString("msg") %>
}