<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    Ficheiro encomendas.jsp, redireciona para encomendas do cliente, perfil cliente, tabelas encomendas
--%>
<%
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String perfil = (String) session.getAttribute("perfil");

    if (idUtilizador == null || perfil == null || !perfil.equals("cliente")) {
        response.sendRedirect("login.html");
        return;
    }

    response.sendRedirect("cliente_encomendas.jsp");
%>
