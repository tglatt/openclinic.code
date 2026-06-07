<%
    response.sendRedirect(request.getRequestURI().replaceAll(request.getServletPath(),"")+"/login.jsp?Title=bwamanda&Dir=projects/bwamanda/");
%>