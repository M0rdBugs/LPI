<%--
    Ficheiro: home.jsp
    Descricao: Pagina de encaminhamento inicial. Redirecciona o utilizador
    com base no perfil da sessao activa. Sem sessao -> index.jsp.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String perfil = (String) session.getAttribute("perfil");
    if (perfil == null) {
        response.sendRedirect("index.jsp");
    } else if ("cliente".equals(perfil)) {
        response.sendRedirect("clienteDashboard.jsp");
    } else if ("funcionario".equals(perfil)) {
        response.sendRedirect("funcionarioDashboard.jsp");
    } else if ("admin".equals(perfil)) {
        response.sendRedirect("adminDashboard.jsp");
    } else {
        response.sendRedirect("index.jsp");
    }
%>