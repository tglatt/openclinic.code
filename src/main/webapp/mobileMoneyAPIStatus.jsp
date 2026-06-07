<%@page import="be.mxs.common.util.system.Pointer"%>
<%
	System.out.println("Checking payment status: "+"paymentstatus."+request.getParameter("invoice"));
	String s = "Payment status not yet available";
	if(Pointer.getPointer("paymentstatus."+request.getParameter("invoice")).equalsIgnoreCase("1")){
		s="Payment successful";
	}
	if(Pointer.getPointer("paymentstatus."+request.getParameter("invoice")).equalsIgnoreCase("0")){
		s="Payment unsuccesfull";
	}
%>
{
	"status":"<%=s %>"
}