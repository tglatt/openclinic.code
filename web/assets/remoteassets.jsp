<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String url=MedwanQuery.getInstance().getConfigString("remoteAssetURL","http://localhost/openclinic/assets/enterAssets.jsp")+"?autologin="+SH.cs("remotelogingmao."+activeUser.userid,"")+";"+SH.cs("remotepasswordgmao."+activeUser.userid,"");
%>
<script>
	window.open('<%=url%>');
</script>