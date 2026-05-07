<%--
    Ficheiro: clienteDashboard.jsp
    Descricao: Painel de controlo do cliente (dashboard). Apresenta
    mensagem de boas-vindas, saldo da carteira e acesso rapido as
    funcionalidades do cliente.
    Perfil: cliente
    Tabelas: carteiras
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_cliente.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="header.jsp" %>

<style>
    .dashboard-grid { display: flex; flex-wrap: wrap; gap: 15px; }
    .dashboard-grid .btn { flex: 1 1 200px; text-align: center; padding: 20px 15px; font-size: 1em; }
    .saldo-card { background: #d4edda; border: 2px solid #27ae60; border-radius: 8px; padding: 15px 20px; margin-bottom: 20px; font-size: 1.2em; text-align: center; }
</style>

<div class="container">
    <div class="card">
        <h2>Bem-vindo, <%= session.getAttribute("nome") %>!</h2>
        <p>A sua area de cliente FelixUberShop.</p>
    </div>

    <%
        int idUtilizador = (Integer) session.getAttribute("id_utilizador");
        Connection conn = null; PreparedStatement stmt = null; ResultSet rs = null;
        try {
            conn = ligarBaseDados();
            stmt = conn.prepareStatement("SELECT saldo FROM carteiras WHERE id_utilizador = ?");
            stmt.setInt(1, idUtilizador);
            rs = stmt.executeQuery();
            if (rs.next()) {
                double saldo = rs.getDouble("saldo");
    %>
    <div class="saldo-card">
        <strong>Saldo da Carteira: <%= String.format("%.2f", saldo) %> &euro;</strong>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<div class='msg-erro'>Erro ao carregar saldo: " + e.getMessage() + "</div>");
        } finally {
            desligarBaseDados(conn, stmt, rs);
        }
    %>

    <div class="card">
        <h2>Acesso Rapido</h2>
        <div class="dashboard-grid">
            <a href="produtos.jsp" class="btn btn-verde">Ver Produtos</a>
            <a href="nova_encomenda.jsp" class="btn btn-azul">Nova Encomenda</a>
            <a href="cliente_encomendas.jsp" class="btn btn-azul">As Minhas Encomendas</a>
            <a href="cliente_carteira.jsp" class="btn btn-verde">A Minha Carteira</a>
            <a href="cliente_perfil.jsp" class="btn btn-cinza">O Meu Perfil</a>
            <a href="logout.jsp" class="btn btn-vermelho">Logout</a>
        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>