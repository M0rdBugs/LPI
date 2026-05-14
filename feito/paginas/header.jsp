<%-- 
    Cabecalho comum a todas as paginas da aplicacao
    Apresenta o menu de navegação adaptado ao perfil do utilizador
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String perfilSessao = (String) session.getAttribute("tipo_util");
    String nomeSessao = (String) session.getAttribute("nome");
    Integer idSessao = (Integer) session.getAttribute("id");
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FelixUberShop</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<header>
    <h1>Felix<span>Uber</span>Shop</h1>
    <div class="user-area">
        <% if (nomeSessao != null) { %>
            Bem-vindo, <strong><%= nomeSessao %></strong> (<%= perfilSessao %>)
            <a href="logout.jsp">Sair</a>
        <% } else { %>
            <a href="login.jsp">Entrar</a>
            <a href="registo.jsp">Registar</a>
        <% } %>
    </div>
</header>
<nav>
    <% if (perfilSessao != null) { %>
        <a href="home.jsp">Inicio</a>
    <% } else { %>
        <a href="index.jsp">Inicio</a>
    <% } %>
    <a href="produtos.jsp">Produtos</a>
    <% if (perfilSessao == null) { %>
        <a href="login.jsp">Login</a>
        <a href="registo.jsp">Registar</a>
    <% } %>
    <% if ("cliente".equals(perfilSessao)) { %>
        <a href="cliente_dashboard.jsp">Dashboard</a>
        <a href="carteira.jsp">Carteira</a>
        <a href="encomendas.jsp">Encomendas</a>
    <% } %>
    <% if ("funcionario".equals(perfilSessao)) { %>
        <a href="funcionario_dashboard.jsp">Dashboard</a>
        <a href="func_encomendas.jsp">Encomendas</a>
        <a href="auditoria.jsp">Auditoria</a>
    <% } %>
    <% if ("administrador".equals(perfilSessao)) { %>
        <a href="admin_dashboard.jsp">Dashboard</a>
        <a href="admin_encomendas.jsp">Encomendas</a>
        <a href="auditoria.jsp">Auditoria</a>
    <% } %>
</nav>
<main>
