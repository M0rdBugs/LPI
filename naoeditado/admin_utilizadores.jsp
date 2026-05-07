<%-- 
    Ficheiro: admin_utilizadores.jsp
    Descrição: Gestão completa de utilizadores pelo administrador.
    Permite criar, editar, inactivar/activar e consultar todos os utilizadores.
    Acessível apenas a administradores.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_admin.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Gestão de Utilizadores</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            String acao = request.getParameter("acao") != null ? request.getParameter("acao") : "";
            
            // Processar acções
            if ("POST".equals(request.getMethod())) {
                String nome = sanitize(request.getParameter("nome"));
                String username = sanitize(request.getParameter("username"));
                String password = sanitize(request.getParameter("password"));
                String perfil = sanitize(request.getParameter("perfil"));
                String email = sanitize(request.getParameter("email"));
                String telefone = sanitize(request.getParameter("telefone"));
                String morada = sanitize(request.getParameter("morada"));
                String idEditStr = sanitize(request.getParameter("id_edit"));
                
                Connection conn = null; PreparedStatement stmt = null; ResultSet rs = null;
                try {
                    conn = ligarBaseDados();
                    
                    if ("criar".equals(acao)) {
                        // Criar novo utilizador
                        stmt = conn.prepareStatement("INSERT INTO utilizadores (nome, username, password, perfil, email, telefone, morada) VALUES (?,?,SHA2(?,256),?,?,?,?)");
                        stmt.setString(1, nome); stmt.setString(2, username); stmt.setString(3, password);
                        stmt.setString(4, perfil); stmt.setString(5, email); stmt.setString(6, telefone); stmt.setString(7, morada);
                        stmt.executeUpdate();
                        
                        // Criar carteira para clientes
                        if ("cliente".equals(perfil)) {
                            rs = stmt.getGeneratedKeys();
                            // Obter ID do novo utilizador
                            PreparedStatement stmtId = conn.prepareStatement("SELECT id FROM utilizadores WHERE username=?");
                            stmtId.setString(1, username);
                            ResultSet rsId = stmtId.executeQuery();
                            if (rsId.next()) {
                                PreparedStatement stmtCart = conn.prepareStatement("INSERT INTO carteiras (id_utilizador, saldo, tipo) VALUES (?,0.00,'cliente')");
                                stmtCart.setInt(1, rsId.getInt("id"));
                                stmtCart.executeUpdate(); stmtCart.close();
                            }
                            rsId.close(); stmtId.close();
                        }
                        mensagem = "Utilizador criado com sucesso."; tipoMsg = "sucesso";
                        
                    } else if ("editar".equals(acao) && idEditStr != null) {
                        int idEdit = Integer.parseInt(idEditStr);
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
                        mensagem = "Utilizador actualizado."; tipoMsg = "sucesso";
                    }
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                } finally {
                    desligarBaseDados(conn, stmt, rs);
                }
            } else if ("inativar".equals(acao) || "ativar".equals(acao)) {
                String idStr = request.getParameter("id");
                try {
                    int id = Integer.parseInt(idStr);
                    Connection conn = ligarBaseDados();
                    PreparedStatement stmt = conn.prepareStatement("UPDATE utilizadores SET estado=? WHERE id=?");
                    stmt.setString(1, "inativar".equals(acao) ? "inativo" : "ativo");
                    stmt.setInt(2, id);
                    stmt.executeUpdate();
                    desligarBaseDados(conn, stmt, null);
                    mensagem = "Estado do utilizador actualizado."; tipoMsg = "sucesso";
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %><div class="msg-<%= tipoMsg %>"><%= mensagem %></div><% } %>

        <!-- Formulário de criação -->
        <details style="margin-bottom:20px;">
            <summary class="btn btn-verde" style="cursor:pointer; display:inline-block; margin-bottom:10px;">+ Criar Novo Utilizador</summary>
            <form method="post" action="admin_utilizadores.jsp?acao=criar" style="margin-top:10px;">
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                    <div class="form-grupo"><label>Nome *:</label><input type="text" name="nome" required></div>
                    <div class="form-grupo"><label>Username *:</label><input type="text" name="username" required></div>
                    <div class="form-grupo"><label>Password *:</label><input type="password" name="password" required></div>
                    <div class="form-grupo"><label>Perfil:</label>
                        <select name="perfil">
                            <option value="cliente">Cliente</option>
                            <option value="funcionario">Funcionário</option>
                            <option value="admin">Administrador</option>
                        </select>
                    </div>
                    <div class="form-grupo"><label>Email:</label><input type="email" name="email"></div>
                    <div class="form-grupo"><label>Telefone:</label><input type="text" name="telefone"></div>
                </div>
                <div class="form-grupo"><label>Morada:</label><textarea name="morada"></textarea></div>
                <button type="submit" class="btn btn-verde">Criar</button>
            </form>
        </details>

        <!-- Listagem de utilizadores -->
        <%
            Connection connL = null; PreparedStatement stmtL = null; ResultSet rsL = null;
            try {
                connL = ligarBaseDados();
                stmtL = connL.prepareStatement("SELECT * FROM utilizadores ORDER BY perfil, nome");
                rsL = stmtL.executeQuery();
        %>
        <table>
            <tr><th>Nome</th><th>Username</th><th>Perfil</th><th>Email</th><th>Estado</th><th>Ações</th></tr>
            <% while (rsL.next()) { %>
            <tr>
                <td><%= rsL.getString("nome") %></td>
                <td><%= rsL.getString("username") %></td>
                <td><%= rsL.getString("perfil") %></td>
                <td><%= rsL.getString("email") != null ? rsL.getString("email") : "-" %></td>
                <td><%= rsL.getString("estado") %></td>
                <td>
                    <a href="admin_editar_utilizador.jsp?id=<%= rsL.getInt("id") %>" class="btn btn-azul">Editar</a>
                    <% if ("ativo".equals(rsL.getString("estado"))) { %>
                        <a href="admin_utilizadores.jsp?acao=inativar&id=<%= rsL.getInt("id") %>" class="btn btn-vermelho" onclick="return confirm('Inactivar este utilizador?')">Inactivar</a>
                    <% } else { %>
                        <a href="admin_utilizadores.jsp?acao=ativar&id=<%= rsL.getInt("id") %>" class="btn btn-verde">Activar</a>
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
