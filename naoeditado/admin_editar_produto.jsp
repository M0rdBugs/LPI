<%-- 
    Ficheiro: admin_editar_produto.jsp
    Descrição: Formulário de edição de um produto específico pelo administrador.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_admin.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Editar Produto</h2>

        <%
            int idEdit = 0;
            try { idEdit = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
            String mensagem = "";
            String tipoMsg = "";
            
            if ("POST".equals(request.getMethod()) && idEdit > 0) {
                String nome = sanitize(request.getParameter("nome"));
                String descricao = sanitize(request.getParameter("descricao"));
                String precoStr = sanitize(request.getParameter("preco"));
                String stockStr = sanitize(request.getParameter("stock"));
                
                try {
                    double preco = Double.parseDouble(precoStr);
                    int stock = Integer.parseInt(stockStr);
                    Connection conn = ligarBaseDados();
                    PreparedStatement stmt = conn.prepareStatement("UPDATE produtos SET nome=?, descricao=?, preco=?, stock=? WHERE id=?");
                    stmt.setString(1, nome); stmt.setString(2, descricao); stmt.setDouble(3, preco); stmt.setInt(4, stock); stmt.setInt(5, idEdit);
                    stmt.executeUpdate();
                    desligarBaseDados(conn, stmt, null);
                    response.sendRedirect("admin_produtos.jsp");
                    return;
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %><div class="msg-<%= tipoMsg %>"><%= mensagem %></div><% } %>

        <%
            if (idEdit > 0) {
                Connection conn2 = null; PreparedStatement stmt2 = null; ResultSet rs2 = null;
                try {
                    conn2 = ligarBaseDados();
                    stmt2 = conn2.prepareStatement("SELECT * FROM produtos WHERE id=?");
                    stmt2.setInt(1, idEdit);
                    rs2 = stmt2.executeQuery();
                    if (rs2.next()) {
        %>
        <form method="post" action="admin_editar_produto.jsp?id=<%= idEdit %>">
            <div class="form-grupo"><label for="nome">Nome *:</label><input type="text" id="nome" name="nome" value="<%= rs2.getString("nome") %>" required></div>
            <div class="form-grupo"><label for="descricao">Descrição:</label><textarea id="descricao" name="descricao"><%= rs2.getString("descricao") != null ? rs2.getString("descricao") : "" %></textarea></div>
            <div class="form-grupo"><label for="preco">Preço (€) *:</label><input type="number" id="preco" name="preco" value="<%= rs2.getDouble("preco") %>" min="0.01" step="0.01" required></div>
            <div class="form-grupo"><label for="stock">Stock:</label><input type="number" id="stock" name="stock" value="<%= rs2.getInt("stock") %>" min="0"></div>
            <button type="submit" class="btn btn-verde">Guardar</button>
            <a href="admin_produtos.jsp" class="btn btn-cinza">Cancelar</a>
        </form>
        <%
                    }
                } catch (Exception e) {
                    out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
                } finally {
                    desligarBaseDados(conn2, stmt2, rs2);
                }
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
