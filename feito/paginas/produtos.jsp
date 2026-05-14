<%-- 
    Listagem publica de produtos da mercearia com ordenacao por nome ou preco 
    Clientes autenticados podem encomendar
    Perfil de acesso: visitante, cliente, funcionario, administrador
    Tabelas usadas: produto
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Catalogo de Produtos</h2>

        <form method="get" action="produtos.jsp" style="margin-bottom:15px;">
            <label>Ordenar por:
                <select name="ordem" onchange="this.form.submit()">
                    <option value="nome" <%= "nome".equals(request.getParameter("ordem")) ? "selected" : "" %>>Nome (A-Z)</option>
                    <option value="nome_desc" <%= "nome_desc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Nome (Z-A)</option>
                    <option value="preco" <%= "preco".equals(request.getParameter("ordem")) ? "selected" : "" %>>Preco (Crescente)</option>
                    <option value="preco_desc" <%= "preco_desc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Preco (Decrescente)</option>
                </select>
            </label>
        </form>

        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            try {
                conn = connectBD();

                String ordem = request.getParameter("ordem");
                String orderBy = "nome ASC";
                if ("nome_desc".equals(ordem)) orderBy = "nome DESC";
                else if ("preco".equals(ordem)) orderBy = "preco ASC";
                else if ("preco_desc".equals(ordem)) orderBy = "preco DESC";

                String sql = "SELECT * FROM produto WHERE estado = 'ativo' ORDER BY " + orderBy;
                stmt = conn.prepareStatement(sql);
                rs = stmt.executeQuery();
        %>
        <table>
            <tr>
                <th>Nome</th>
                <th>Descricao</th>
                <th>Preco</th>
                <th>Stock</th>
                <% if ("cliente".equals(perfilSessao)) { %><th>Acao</th><% } %>
            </tr>
            <%
                boolean temProdutos = false;
                while (rs.next()) {
                    temProdutos = true;
            %>
            <tr>
                <td><%= rs.getString("nome") %></td>
                <td><%= rs.getString("descricao") != null ? rs.getString("descricao") : "-" %></td>
                <td><strong><%= String.format("%.2f", rs.getDouble("preco")) %> EUR</strong></td>
                <td><%= rs.getInt("quantidade") %> un.</td>
                <% if ("cliente".equals(perfilSessao)) { %>
                    <td><a href="nova_encomenda.jsp?produto=<%= rs.getInt("id") %>" class="btn btn-verde">Encomendar</a></td>
                <% } %>
            </tr>
            <% } %>
            <% if (!temProdutos) { %>
            <tr><td colspan="5" style="text-align:center;">Nao existem produtos disponiveis.</td></tr>
            <% } %>
        </table>
        <%
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro ao carregar produtos: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception ex) {}
                if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
                if (conn != null) try { conn.close(); } catch (Exception ex) {}
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
