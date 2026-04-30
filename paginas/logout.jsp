<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%!
    session.removeAttribute("utilizador_id");
    session.removeAttribute("tipo_util");
    session.invalidate();
    response.sendRedirect("login.html");
%>