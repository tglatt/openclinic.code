<%
    response.sendRedirect(request.getRequestURI().replaceAll(request.getServletPath(),"")+"/login.jsp?Title=Guinguineo&Dir=projects/guinguineo/");
%>