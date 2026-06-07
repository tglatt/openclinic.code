<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<span style='font-size: 14px;font-weight: bolder'><%=getTran(request,"web","report.inapproriate.content",sWebLanguage) %>: </span>
<a  style='font-size: 14px;font-weight: bolder;color:blue' href='mailto:<%=SH.cs("reportAbuseEmail","abuse@ict4d.be") %>'><%=SH.cs("reportAbuseEmail","abuse@ict4d.be") %></a>