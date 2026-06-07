<%@page import="be.mxs.common.util.system.Pointer"%>
<% 
	Pointer.storePointer("paymentstatus."+request.getParameter("invoice"), request.getParameter("result"));
%>
<script>window.close();</script>