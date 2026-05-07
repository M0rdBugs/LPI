<%-- 
    Ficheiro: func_perfil.jsp
    Descrição: Página de consulta e edição dos dados pessoais do funcionário.
    Acessível apenas a funcionários e administradores.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_funcionario.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>O Meu Perfil</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            int idUtilizador = (Integer) session.getAttribute("id_utilizador");
            
            if ("POST".equals(request.getMethod())) {
                String nome = sanitize(request.getParameter("nome"));
                String email = sanitize(request.getParameter("email"));
                String telefone = sanitize(request.getParameter("telefone"));
                String morada = sanitize(request.getParameter("morada"));
                String novaPassword = sanitize(request.getParameter("nova_password"));
                
                Connection conn = null;
                PreparedStatement stmt = null;
                try {
                    conn = ligarBaseDados();
                    if (!novaPassword.isEmpty()) {
                        stmt = conn.prepareStatement("UPDATE utilizadores SET nome=?, email=?, telefone=?, morada=?, password=SHA2(?,256) WHERE id=?");
                        stmt.setString(1, nome); stmt.setString(2, email); stmt.setString(3, telefone);
                        stmt.setString(4, morada); stmt.setString(5, novaPassword); stmt.setInt(6, idUtilizador);
                    } else {
                        stmt = conn.prepareStatement("UPDATE utilizadores SET nome=?, email=?, telefone=?, morada=? WHERE id=?");
                        stmt.setString(1, nome); stmt.setString(2, email); stmt.setString(3, telefone);
                        stmt.setString(4, morada); stmt.setInt(5, idUtilizador);
                    }
                    stmt.executeUpdate();
                    session.setAttribute("nome", nome);
                    mensagem = "Dados actualizados com sucesso.";
                    tipoMsg = "sucesso";
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage();
                    tipoMsg = "erro";
                } finally {
                    desligarBaseDados(conn, stmt, null);
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %><div class="msg-<%= tipoMsg %>"><%= mensagem %></div><% } %>

        <%
            Connection conn2 = null; PreparedStatement stmt2 = null; ResultSet rs2 = null;
            try {
                conn2 = ligarBaseDados();
                stmt2 = conn2.prepareStatement("SELECT * FROM utilizadores WHERE id=?");
                stmt2.setInt(1, idUtilizador);
                rs2 = stmt2.executeQuery();
                if (rs2.next()) {
        %>
        <form method="post" action="func_perfil.jsp">
            <div class="form-grupo"><label>Username:</label><input type="text" value="<%= rs2.getString("username") %>" disabled style="background:#eee;"></div>
            <div class="form-grupo"><label for="nome">Nome:</label><input type="text" id="nome" name="nome" value="<%= rs2.getString("nome") != null ? rs2.getString("nome") : "" %>" required></div>
            <div class="form-grupo"><label for="email">Email:</label><input type="email" id="email" name="email" value="<%= rs2.getString("email") != null ? rs2.getString("email") : "" %>"></div>
            <div class="form-grupo"><label for="telefone">Telefone:</label><input type="text" id="telefone" name="telefone" value="<%= rs2.getString("telefone") != null ? rs2.getString("telefone") : "" %>"></div>
            <div class="form-grupo"><label for="morada">Morada:</label><textarea id="morada" name="morada"><%= rs2.getString("morada") != null ? rs2.getString("morada") : "" %></textarea></div>
            <div class="form-grupo"><label for="nova_password">Nova Password (deixar em branco para não alterar):</label><input type="password" id="nova_password" name="nova_password"></div>
            <button type="submit" class="btn btn-verde">Guardar</button>
        </form>
        <%
                }
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
            } finally {
                desligarBaseDados(conn2, stmt2, rs2);
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
