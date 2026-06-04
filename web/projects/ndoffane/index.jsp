<%
    response.sendRedirect(request.getRequestURI().replaceAll(request.getServletPath(),"")+"/login.jsp?Title=Ndoffane&Dir=projects/ndoffane/");
%>