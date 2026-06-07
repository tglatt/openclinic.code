<%@include file="/includes/helper.jsp"%>
<%
	Vector v = MedwanQuery.getInstance().getTransactionsAfter(9966, new java.util.Date(0));
	System.out.println("Size="+v.size());
%>