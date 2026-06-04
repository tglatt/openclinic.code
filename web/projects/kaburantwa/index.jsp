<%
    response.sendRedirect(request.getRequestURI().replaceAll(request.getServletPath(),"")+"/login.jsp?Title=Kaburantwa&Dir=projects/kaburantwa/");
%>