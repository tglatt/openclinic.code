<%@page import="be.mxs.common.util.system.QrCodeUtil"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
	String s = SH.c((String)session.getAttribute("malariyaPiBarcode"));
%>
<table>
	<tr>
		<td><img src='<%=QrCodeUtil.toBase64QrCode(s,120,120)%>'/></td>
		<td><img height='100px' src='<%=sCONTEXTPATH%>/_img/themes/default/malariyapi.png'/></td>
	</tr>
</table>
<script>

</script>