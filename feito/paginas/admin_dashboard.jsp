<%-- 
    Painel de controlo do administrador
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String _perfil = (String) session.getAttribute("tipo_util");
    String _nome = (String) session.getAttribute("nome");
    // Verifica que o utilizador é um administrador
    if (_perfil == null || !_perfil.equals("administrador")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Bem-vindo, <%= _nome %>!</h2>
        <p>A sua area de administrador FelixUberShop.</p>
    </div>

    <div class="card">
        <h2>Acesso Rapido</h2>
        <div class="dashboard-grid">
            <a href="produtos.jsp" class="btn btn-verde">Ver Produtos</a>
            <a href="admin_encomendas.jsp" class="btn btn-azul">Gerir Encomendas</a>
            <a href="auditoria.jsp" class="btn btn-laranja">Auditoria</a>
            <a href="logout.jsp" class="btn btn-vermelho">Sair</a>
        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>
