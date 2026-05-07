<%-- 
    Ficheiro: admin_produtos.jsp
    Descrição: Gestão completa de produtos pelo administrador.
    Permite criar, editar, inactivar/activar e consultar produtos.
    Inclui filtros por nome e ordenação por nome/preço.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_admin.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Gestão de Produtos</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            String acao = request.getParameter("acao") != null ? request.getParameter("acao") : "";
            
            if ("POST".equals(request.getMethod())) {
                String nome = sanitize(request.getParameter("nome"));
                String descricao = sanitize(request.getParameter("descricao"));
                String precoStr = sanitize(request.getParameter("preco"));
                String stockStr = sanitize(request.getParameter("stock"));
                String idEditStr = sanitize(request.getParameter("id_edit"));
                
                try {
                    double preco = Double.parseDouble(precoStr);
                    int stock = Integer.parseInt(stockStr);
                    
                    Connection conn = null; PreparedStatement stmt = null;
                    try {
                        conn = ligarBaseDados();
                        if ("criar".equals(acao)) {
                            stmt = conn.prepareStatement("INSERT INTO produtos (nome, descricao, preco, stock) VALUES (?,?,?,?)");
                            stmt.setString(1, nome); stmt.setString(2, descricao); stmt.setDouble(3, preco); stmt.setInt(4, stock);
                            stmt.executeUpdate();
                            mensagem = "Produto criado com sucesso."; tipoMsg = "sucesso";
                        } else if ("editar".equals(acao) && idEditStr != null) {
                            int idEdit = Integer.parseInt(idEditStr);
                            stmt = conn.prepareStatement("UPDATE produtos SET nome=?, descricao=?, preco=?, stock=? WHERE id=?");
                            stmt.setString(1, nome); stmt.setString(2, descricao); stmt.setDouble(3, preco); stmt.setInt(4, stock); stmt.setInt(5, idEdit);
                            stmt.executeUpdate();
                            mensagem = "Produto actualizado."; tipoMsg = "sucesso";
                        }
                    } catch (Exception e) {
                        mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                    } finally {
                        desligarBaseDados(conn, stmt, null);
                    }
                } catch (NumberFormatException e) {
                    mensagem = "Preço ou stock inválido."; tipoMsg = "erro";
                }
            } else if ("inativar".equals(acao) || "ativar".equals(acao)) {
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Connection conn = ligarBaseDados();
                    PreparedStatement stmt = conn.prepareStatement("UPDATE produtos SET estado=? WHERE id=?");
                    stmt.setString(1, "inativar".equals(acao) ? "inativo" : "ativo");
                    stmt.setInt(2, id);
                    stmt.executeUpdate();
                    desligarBaseDados(conn, stmt, null);
                    mensagem = "Estado do produto actualizado."; tipoMsg = "sucesso";
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %><div class="msg-<%= tipoMsg %>"><%= mensagem %></div><% } %>

        <!-- Formulário de criação -->
        <details style="margin-bottom:20px;">
            <summary class="btn btn-verde" style="cursor:pointer; display:inline-block; margin-bottom:10px;">+ Criar Novo Produto</summary>
            <form method="post" action="admin_produtos.jsp?acao=criar" style="margin-top:10px;">
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                    <div class="form-grupo"><label>Nome *:</label><input type="text" name="nome" required></div>
                    <div class="form-grupo"><label>Preço (€) *:</label><input type="number" name="preco" min="0.01" step="0.01" required></div>
                    <div class="form-grupo"><label>Stock:</label><input type="number" name="stock" min="0" value="0"></div>
                </div>
                <div class="form-grupo"><label>Descrição:</label><textarea name="descricao"></textarea></div>
                <button type="submit" class="btn btn-verde">Criar</button>
            </form>
        </details>

        <!-- Filtros e ordenação -->
        <form method="get" action="admin_produtos.jsp" style="margin-bottom:15px; display:flex; gap:10px; align-items:flex-end;">
            <div class="form-grupo" style="margin:0;">
                <label>Pesquisar por nome:</label>
                <input type="text" name="pesquisa" value="<%= request.getParameter("pesquisa") != null ? request.getParameter("pesquisa") : "" %>" style="width:200px;">
            </div>
            <div class="form-grupo" style="margin:0;">
                <label>Ordenar por:</label>
                <select name="ordem">
                    <option value="nome" <%= "nome".equals(request.getParameter("ordem")) ? "selected" : "" %>>Nome A-Z</option>
                    <option value="nome_desc" <%= "nome_desc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Nome Z-A</option>
                    <option value="preco" <%= "preco".equals(request.getParameter("ordem")) ? "selected" : "" %>>Preço ↑</option>
                    <option value="preco_desc" <%= "preco_desc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Preço ↓</option>
                </select>
            </div>
            <button type="submit" class="btn btn-azul">Filtrar</button>
        </form>

        <%
            Connection connL = null; PreparedStatement stmtL = null; ResultSet rsL = null;
            try {
                connL = ligarBaseDados();
                String pesquisa = request.getParameter("pesquisa") != null ? request.getParameter("pesquisa").trim() : "";
                String ordem = request.getParameter("ordem") != null ? request.getParameter("ordem") : "nome";
                String orderBy = "nome ASC";
                if ("nome_desc".equals(ordem)) orderBy = "nome DESC";
                else if ("preco".equals(ordem)) orderBy = "preco ASC";
                else if ("preco_desc".equals(ordem)) orderBy = "preco DESC";
                
                String sql = "SELECT * FROM produtos WHERE nome LIKE ? ORDER BY " + orderBy;
                stmtL = connL.prepareStatement(sql);
                stmtL.setString(1, "%" + pesquisa + "%");
                rsL = stmtL.executeQuery();
        %>
        <table>
            <tr><th>Nome</th><th>Descrição</th><th>Preço</th><th>Stock</th><th>Estado</th><th>Ações</th></tr>
            <% while (rsL.next()) { %>
            <tr>
                <td><%= rsL.getString("nome") %></td>
                <td><%= rsL.getString("descricao") != null ? rsL.getString("descricao") : "-" %></td>
                <td><%= String.format("%.2f", rsL.getDouble("preco")) %> €</td>
                <td><%= rsL.getInt("stock") %></td>
                <td><%= rsL.getString("estado") %></td>
                <td>
                    <a href="admin_editar_produto.jsp?id=<%= rsL.getInt("id") %>" class="btn btn-azul">Editar</a>
                    <% if ("ativo".equals(rsL.getString("estado"))) { %>
                        <a href="admin_produtos.jsp?acao=inativar&id=<%= rsL.getInt("id") %>" class="btn btn-vermelho" onclick="return confirm('Inactivar este produto?')">Inactivar</a>
                    <% } else { %>
                        <a href="admin_produtos.jsp?acao=ativar&id=<%= rsL.getInt("id") %>" class="btn btn-verde">Activar</a>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </table>
        <%
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
            } finally {
                desligarBaseDados(connL, stmtL, rsL);
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
