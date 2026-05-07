<%-- 
Página inicial da FelixUberShop. Apresenta informações gerais da mercearia
    e as promoções/alertas activos definidos pelos administradores.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="header.jsp" %>

<div class="container">

    <!-- Zona de Alertas/Promoções: só é mostrada se houver promoções activas -->
    <%
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        boolean temPromocoes = false;
        try {
            conn = connectBD();
            String sql = "SELECT * FROM promocoes WHERE estado = 'ativo' AND (data_fim IS NULL OR data_fim >= CURDATE()) ORDER BY id DESC";
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            if (rs.isBeforeFirst()) {
                temPromocoes = true;
    %>
    <div class="card" style="border-left: 5px solid #e67e22;">
        <h2 style="color:#e67e22;">&#128226; Informações e Promoções</h2>
        <% while (rs.next()) { %>
            <div class="msg-info">
                <strong><%= rs.getString("titulo") %></strong><br>
                <%= rs.getString("descricao") %>
                <% if (rs.getString("data_fim") != null) { %>
                    <small> &mdash; Válido até <%= rs.getString("data_fim") %></small>
                <% } %>
            </div>
        <% } %>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<div class='msg-erro'>Erro ao carregar promoções: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    %>

    <!-- Informações da Mercearia -->
    <div class="card">
        <h2>Bem-vindo à FelixUberShop</h2>
        <p>A sua mercearia de confiança em Castelo Branco. Oferecemos produtos frescos e de qualidade, com entrega ao domicílio.</p>
        <br>
        <table>
            <tr><th colspan="2">Informações da Loja</th></tr>
            <tr><td><strong>Morada</strong></td><td>Rua das Mercearias, 10, 6000-000 Castelo Branco</td></tr>
            <tr><td><strong>Telefone</strong></td><td>272 000 000</td></tr>
            <tr><td><strong>Email</strong></td><td>geral@felixubershop.pt</td></tr>
            <tr><td><strong>Segunda a Sexta</strong></td><td>08:00 - 20:00</td></tr>
            <tr><td><strong>Sábado</strong></td><td>09:00 - 18:00</td></tr>
            <tr><td><strong>Domingo</strong></td><td>Fechado</td></tr>
        </table>
    </div>

    <!-- Acesso Rápido -->
    <div class="card">
        <h2>Acesso Rápido</h2>
        <a href="produtos.jsp" class="btn btn-verde">Ver Produtos</a>
        <% if (session.getAttribute("perfil") == null) { %>
            &nbsp;<a href="login.jsp" class="btn btn-azul">Fazer Login</a>
            &nbsp;<a href="registo.jsp" class="btn btn-cinza">Registar</a>
        <% } else if ("cliente".equals(session.getAttribute("perfil"))) { %>
            &nbsp;<a href="cliente_encomendas.jsp" class="btn btn-azul">As Minhas Encomendas</a>
            &nbsp;<a href="cliente_carteira.jsp" class="btn btn-cinza">A Minha Carteira</a>
        <% } %>
    </div>

</div>

<%@ include file="footer.jsp" %>
