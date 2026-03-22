<%@ include file="../basedados/basedados.h" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    HttpSession currentSession = request.getSession(false);
    if (currentSession != null ) {
        currentSession.invalidate();
    }
    response.sendRedirect("login.html");

%>