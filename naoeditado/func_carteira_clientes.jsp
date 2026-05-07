<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    Ficheiro func_carteira_clientes.jsp, redireciona para gestao de carteiras pelo funcionario, perfil funcionario/admin, tabelas carteiras
--%>
<%
    Integer idUtilizador = (Integer) session.getAttribute("id_utilizador");
    String perfil = (String) session.getAttribute("perfil");

    if (idUtilizador == null || perfil == null || (!perfil.equals("funcionario") && !perfil.equals("admin"))) {
        response.sendRedirect("login.html");
        return;
    }

    response.sendRedirect("func_carteiras.jsp");
%>
