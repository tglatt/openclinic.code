<%
    response.sendRedirect(request.getRequestURI().replaceAll(request.getServletPath(),"")+"/login.jsp?Title=HGRSJ&Dir=projects/hgrsj/");
%>