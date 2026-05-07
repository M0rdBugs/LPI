<%--
    Ficheiro: adminDashboard.jsp
    Descricao: Painel de controlo do administrador (dashboard). Apresenta
    mensagem de boas-vindas e acesso rapido a todas as funcionalidades
    de administracao.
    Perfil: admin
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="sessao_admin.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="header.jsp" %>

<style>
    .dashboard-grid { display: flex; flex-wrap: wrap; gap: 15px; }
    .dashboard-grid .btn { flex: 1 1 200px; text-align: center; padding: 20px 15px; font-size: 1em; }
</style>

<div class="container">
    <div class="card">
        <h2>Bem-vindo, <%= session.getAttribute("nome") %>!</h2>
        <p>Area de administracao FelixUberShop.</p>
    </div>

    <div class="card">
        <h2>Acesso Rapido</h2>
        <div class="dashboard-grid">
            <a href="admin_produtos.jsp" class="btn btn-verde">Gestao de Produtos</a>
            <a href="admin_utilizadores.jsp" class="btn btn-azul">Gestao de Utilizadores</a>
            <a href="admin_promocoes.jsp" class="btn btn-verde">Gestao de Promocoes</a>
            <a href="admin_encomendas.jsp" class="btn btn-azul">Gestao de Encomendas</a>
            <a href="admin_carteiras.jsp" class="btn btn-verde">Carteiras de Clientes</a>
            <a href="auditoria.jsp" class="btn btn-cinza">Auditoria</a>
            <a href="admin_perfil.jsp" class="btn btn-cinza">O Meu Perfil</a>
            <a href="logout.jsp" class="btn btn-vermelho">Logout</a>
        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>