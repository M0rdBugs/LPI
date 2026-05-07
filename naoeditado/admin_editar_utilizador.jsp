<%-- 
    Ficheiro: admin_editar_utilizador.jsp
    Descrição: Formulário de edição de um utilizador específico pelo administrador.
    Permite alterar nome, email, telefone, morada, perfil e password.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_admin.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Editar Utilizador</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            int idEdit = 0;
            try { idEdit = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
            
            if ("POST".equals(request.getMethod()) && idEdit > 0) {
                String nome = sanitize(request.getParameter("nome"));
                String email = sanitize(request.getParameter("email"));
                String telefone = sanitize(request.getParameter("telefone"));
                String morada = sanitize(request.getParameter("morada"));
                String perfil = sanitize(request.getParameter("perfil"));
                String password = sanitize(request.getParameter("password"));
                
                Connection conn = null; PreparedStatement stmt = null;
                try {
                    conn = ligarBaseDados();
                    if (!password.isEmpty()) {
                        stmt = conn.prepareStatement("UPDATE utilizadores SET nome=?, email=?, telefone=?, morada=?, perfil=?, password=SHA2(?,256) WHERE id=?");
                        stmt.setString(1, nome); stmt.setString(2, email); stmt.setString(3, telefone);
                        stmt.setString(4, morada); stmt.setString(5, perfil); stmt.setString(6, password); stmt.setInt(7, idEdit);
                    } else {
                        stmt = conn.prepareStatement("UPDATE utilizadores SET nome=?, email=?, telefone=?, morada=?, perfil=? WHERE id=?");
                        stmt.setString(1, nome); stmt.setString(2, email); stmt.setString(3, telefone);
                        stmt.setString(4, morada); stmt.setString(5, perfil); stmt.setInt(6, idEdit);
                    }
                    stmt.executeUpdate();
                    response.sendRedirect("admin_utilizadores.jsp");
                    return;
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                } finally {
                    desligarBaseDados(conn, stmt, null);
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %><div class="msg-<%= tipoMsg %>"><%= mensagem %></div><% } %>

        <%
            if (idEdit > 0) {
                Connection conn2 = null; PreparedStatement stmt2 = null; ResultSet rs2 = null;
                try {
                    conn2 = ligarBaseDados();
                    stmt2 = conn2.prepareStatement("SELECT * FROM utilizadores WHERE id=?");
                    stmt2.setInt(1, idEdit);
                    rs2 = stmt2.executeQuery();
                    if (rs2.next()) {
        %>
        <form method="post" action="admin_editar_utilizador.jsp?id=<%= idEdit %>">
            <div class="form-grupo"><label>Username:</label><input type="text" value="<%= rs2.getString("username") %>" disabled style="background:#eee;"></div>
            <div class="form-grupo"><label for="nome">Nome *:</label><input type="text" id="nome" name="nome" value="<%= rs2.getString("nome") != null ? rs2.getString("nome") : "" %>" required></div>
            <div class="form-grupo"><label for="email">Email:</label><input type="email" id="email" name="email" value="<%= rs2.getString("email") != null ? rs2.getString("email") : "" %>"></div>
            <div class="form-grupo"><label for="telefone">Telefone:</label><input type="text" id="telefone" name="telefone" value="<%= rs2.getString("telefone") != null ? rs2.getString("telefone") : "" %>"></div>
            <div class="form-grupo"><label for="morada">Morada:</label><textarea id="morada" name="morada"><%= rs2.getString("morada") != null ? rs2.getString("morada") : "" %></textarea></div>
            <div class="form-grupo"><label for="perfil">Perfil:</label>
                <select id="perfil" name="perfil">
                    <option value="cliente" <%= "cliente".equals(rs2.getString("perfil")) ? "selected" : "" %>>Cliente</option>
                    <option value="funcionario" <%= "funcionario".equals(rs2.getString("perfil")) ? "selected" : "" %>>Funcionário</option>
                    <option value="admin" <%= "admin".equals(rs2.getString("perfil")) ? "selected" : "" %>>Administrador</option>
                </select>
            </div>
            <div class="form-grupo"><label for="password">Nova Password (deixar em branco para não alterar):</label><input type="password" id="password" name="password"></div>
            <button type="submit" class="btn btn-verde">Guardar</button>
            <a href="admin_utilizadores.jsp" class="btn btn-cinza">Cancelar</a>
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
