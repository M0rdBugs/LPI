<%-- 
    Ficheiro: header.jsp
    Descrição: Cabeçalho comum a todas as páginas da aplicação FelixUberShop.
    Apresenta o menu de navegação adaptado ao perfil do utilizador em sessão.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Obter dados da sessão
    String perfilSessao = (String) session.getAttribute("tipo_util");
    String nomeSessao = (String) session.getAttribute("nome");
%>
<!DOCTYPE html>
<html lang="pt">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FelixUberShop</title>
    <style>
        /* Reset e estilos globais */
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: #f5f5f5; color: #333; }
        
        /* Cabeçalho */
        header { background: #2c7a2c; color: white; padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; }
        header h1 { font-size: 1.8em; }
        header h1 span { color: #a8e6a8; }
        
        /* Navegação */
        nav { background: #1a5c1a; padding: 10px 30px; }
        nav a { color: #ddd; text-decoration: none; margin-right: 20px; font-size: 0.95em; }
        nav a:hover { color: white; text-decoration: underline; }
        
        /* Área de utilizador */
        .user-area { font-size: 0.9em; }
        .user-area a { color: #a8e6a8; text-decoration: none; margin-left: 10px; }
        .user-area a:hover { text-decoration: underline; }
        
        /* Conteúdo principal */
        .container { max-width: 1100px; margin: 30px auto; padding: 0 20px; }
        
        /* Caixas de mensagem */
        .msg-sucesso { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; padding: 10px 15px; border-radius: 5px; margin-bottom: 15px; }
        .msg-erro { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; padding: 10px 15px; border-radius: 5px; margin-bottom: 15px; }
        .msg-info { background: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; padding: 10px 15px; border-radius: 5px; margin-bottom: 15px; }
        
        /* Tabelas */
        table { width: 100%; border-collapse: collapse; background: white; }
        th, td { padding: 10px 14px; border: 1px solid #ddd; text-align: left; }
        th { background: #2c7a2c; color: white; }
        tr:nth-child(even) { background: #f9f9f9; }
        
        /* Formulários */
        .form-grupo { margin-bottom: 15px; }
        .form-grupo label { display: block; margin-bottom: 5px; font-weight: bold; }
        .form-grupo input, .form-grupo select, .form-grupo textarea { width: 100%; padding: 8px 12px; border: 1px solid #ccc; border-radius: 4px; font-size: 0.95em; }
        .form-grupo textarea { height: 80px; }
        
        /* Botões */
        .btn { padding: 8px 18px; border: none; border-radius: 4px; cursor: pointer; font-size: 0.9em; text-decoration: none; display: inline-block; }
        .btn-verde { background: #2c7a2c; color: white; }
        .btn-verde:hover { background: #1a5c1a; }
        .btn-vermelho { background: #c0392b; color: white; }
        .btn-vermelho:hover { background: #a93226; }
        .btn-azul { background: #2980b9; color: white; }
        .btn-azul:hover { background: #1a6fa8; }
        .btn-cinza { background: #7f8c8d; color: white; }
        .btn-cinza:hover { background: #6c7a7d; }
        
        /* Cards */
        .card { background: white; border-radius: 8px; padding: 20px; margin-bottom: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        .card h2 { color: #2c7a2c; margin-bottom: 15px; border-bottom: 2px solid #2c7a2c; padding-bottom: 8px; }
        
        /* Rodapé */
        footer { background: #1a5c1a; color: #ccc; text-align: center; padding: 20px; margin-top: 40px; font-size: 0.85em; }
    </style>
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
    <!-- Menu de navegação adaptado ao perfil do utilizador -->
    <!-- Caso utilizador logado -->
    <% if (perfilSessao != null) { %>
        <a href="home.jsp">Início</a>
    <% } else { %>
    <!-- Caso visitante -->
        <a href="index.jsp">Início</a>
    <% } %>
    <a href="produtos.jsp">Produtos</a>
    <!-- Caso visitante -->
    <% if (perfilSessao == null) { %>
        <a href="login.jsp">Login</a>
        <a href="registo.jsp">Registar</a>
    <% } %>
    <!-- Caso cliente -->
    <% if ("cliente".equals(perfilSessao)) { %>
        <a href="clienteDashboard.jsp">Dashboard</a>
        <a href="cliente_carteira.jsp">Carteira</a>
        <a href="cliente_encomendas.jsp">Encomendas</a>
        <a href="cliente_perfil.jsp">O Meu Perfil</a>
    <% } %>
    <!-- Caso funcionário -->
    <% if ("funcionario".equals(perfilSessao)) { %>
        <a href="funcionarioDashboard.jsp">Dashboard</a>
        <a href="func_encomendas.jsp">Encomendas</a>
        <a href="func_carteiras.jsp">Carteiras</a>
        <a href="auditoria.jsp">Auditoria</a>
        <a href="func_perfil.jsp">O Meu Perfil</a>
    <% } %>
    <!-- Caso administrador -->
    <% if ("admin".equals(perfilSessao)) { %>
        <a href="adminDashboard.jsp">Dashboard</a>
        <a href="admin_produtos.jsp">Produtos</a>
        <a href="admin_utilizadores.jsp">Utilizadores</a>
        <a href="admin_carteiras.jsp">Carteiras</a>
        <a href="admin_encomendas.jsp">Encomendas</a>
        <a href="admin_promocoes.jsp">Promoções</a>
        <a href="auditoria.jsp">Auditoria</a>
        <a href="admin_perfil.jsp">O Meu Perfil</a>
    <% } %>
</nav>
