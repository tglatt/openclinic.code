<%
    response.sendRedirect(request.getRequestURI().replaceAll(request.getServletPath(),"")+"/login.jsp?Title=SENEPACS&Dir=projects/senepacs/");
%>