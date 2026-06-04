<%@page import="be.mxs.common.util.db.MedwanQuery"%>
<%@page import="be.mxs.common.model.vo.healthrecord.*"%>
<h1>La date d'aujourd'hui est:
<%
	out.println(new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()));

%>
</h1>
