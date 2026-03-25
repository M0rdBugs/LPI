<%@ include file="../basedados/basedados.h" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    session.removeAttribute("nomeUtilizador");
    session.removeAttribute("tipoUtilizador");
    session.invalidate();
    response.sendRedirect("login.html");
%>