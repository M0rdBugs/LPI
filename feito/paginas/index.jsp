<%-- 
    Ficheiro: index.jsp
    Descricao: Pagina inicial publica da FelixUberShop. Apresenta informacoes
    gerais da mercearia, localizacao, contactos, horarios e as promocoes
    activas carregadas da BD. Esconde a seccao de promocoes se nao houver.
    Perfil de acesso: visitante, qualquer utilizador
    Tabelas usadas: promocao
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="header.jsp" %>

<div class="container">

    <%
        /* Carregar promocoes activas dentro do periodo de validade */
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        boolean temPromocoes = false;
        try {
            conn = connectBD();
            String sql = "SELECT * FROM promocao WHERE estado = 'ativo' AND CURDATE() BETWEEN data_inicio AND data_fim ORDER BY data_inicio DESC";
            stmt = conn.prepareStatement(sql);
            rs = stmt.executeQuery();
            if (rs.isBeforeFirst()) {
                temPromocoes = true;
    %>
    <div class="secao-promocoes">
        <h2>Informacoes e Promocoes</h2>
        <% while (rs.next()) { %>
            <div class="promocao-item">
                <strong><%= rs.getString("titulo") %></strong>
                <p><%= rs.getString("conteudo") %></p>
                <small>Valido ate <%= rs.getString("data_fim") %></small>
            </div>
        <% } %>
    </div>
    <%
            }
        } catch (Exception e) {
            out.println("<div class='msg-erro'>Erro ao carregar promocoes: " + e.getMessage() + "</div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ex) {}
            if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
            if (conn != null) try { conn.close(); } catch (Exception ex) {}
        }
    %>

    <!-- Informacoes da Mercearia -->
    <div class="card">
        <h2>Bem-vindo a FelixUberShop</h2>
        <p>A sua mercearia de confianca em Castelo Branco. Oferecemos produtos frescos e de qualidade, com entrega ao domicilio.</p>
        <br>
        <table>
            <tr><th colspan="2">Informacoes da Loja</th></tr>
            <tr><td><strong>Morada</strong></td><td>Rua das Mercearias, 10, 6000-000 Castelo Branco</td></tr>
            <tr><td><strong>Telefone</strong></td><td>272 000 000</td></tr>
            <tr><td><strong>Email</strong></td><td>geral@felixubershop.pt</td></tr>
            <tr><td><strong>Segunda a Sexta</strong></td><td>08:00 - 20:00</td></tr>
            <tr><td><strong>Sabado</strong></td><td>09:00 - 18:00</td></tr>
            <tr><td><strong>Domingo</strong></td><td>Fechado</td></tr>
        </table>
    </div>

    <!-- Acesso Rapido -->
    <div class="card">
        <h2>Acesso Rapido</h2>
        <a href="produtos.jsp" class="btn btn-verde">Ver Produtos</a>
        <% if (perfilSessao == null) { %>
            <a href="login.jsp" class="btn btn-azul">Fazer Login</a>
            <a href="registo.jsp" class="btn btn-cinza">Registar</a>
        <% } else if ("cliente".equals(perfilSessao)) { %>
            <a href="encomendas.jsp" class="btn btn-azul">As Minhas Encomendas</a>
            <a href="carteira.jsp" class="btn btn-cinza">A Minha Carteira</a>
        <% } %>
    </div>

</div>

<%@ include file="footer.jsp" %>
