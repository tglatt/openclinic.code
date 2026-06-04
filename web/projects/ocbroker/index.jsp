<%
    response.sendRedirect(request.getRequestURI().replaceAll(request.getServletPath(),"")+"/login.jsp?Title=OCBROKER&Dir=projects/ocbroker/");
%>