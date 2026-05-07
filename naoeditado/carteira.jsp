<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    Ficheiro carteira.jsp, redireciona para gestao de carteira do cliente, perfil cliente, tabelas carteiras
--%>
<%
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String perfil = (String) session.getAttribute("perfil");

    if (idUtilizador == null || perfil == null || !perfil.equals("cliente")) {
        response.sendRedirect("login.html");
        return;
    }

    response.sendRedirect("cliente_carteira.jsp");
%>
