<%-- 
    Painel de controlo do cliente 
    Apresenta saldo da carteira e as funcionalidades principais
    Tabelas usadas: carteira
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
    // Verificar se o utilizador é cliente
    String _perfil = (String) session.getAttribute("tipo_util");
    Integer _idUtil = (Integer) session.getAttribute("id");
    String _nome = (String) session.getAttribute("nome");
    if (_perfil == null || !_perfil.equals("cliente")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Bem-vindo, <%= _nome %>!</h2>
        <p>A sua area de cliente da FelixUberShop</p>
    </div>

    <%
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        try {
            conn = connectBD();
            stmt = conn.prepareStatement("SELECT saldo FROM carteira WHERE utilizador_id = ?");
            stmt.setInt(1, _idUtil);
            rs = stmt.executeQuery();
            if (rs.next()) {
                double saldo = rs.getDouble("saldo");
    %>
    <div class="saldo-card">
        <strong>Saldo da Carteira: <%= String.format("%.2f", saldo) %> EUR</strong>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<div class='msg-erro'>Erro ao carregar saldo: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ex) {}
            if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
            if (conn != null) try { conn.close(); } catch (Exception ex) {}
        }
    %>

    <div class="card">
        <h2>Acesso Rapido</h2>
        <div class="dashboard-grid">
            <a href="produtos.jsp" class="btn btn-verde">Ver Produtos</a>
            <a href="nova_encomenda.jsp" class="btn btn-azul">Nova Encomenda</a>
            <a href="encomendas.jsp" class="btn btn-azul">As Minhas Encomendas</a>
            <a href="carteira.jsp" class="btn btn-verde">A Minha Carteira</a>
            <a href="logout.jsp" class="btn btn-vermelho">Sair</a>
        </div>
    </div>
</div>

<%@ include file="footer.jsp" %>
