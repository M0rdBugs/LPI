<%-- 
    Página de autenticação dos utilizadores. Valida username, password (com hash SHA-256) e estado da conta.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card" style="max-width:450px; margin:0 auto;">
        <h2>Login</h2>

        <%
            String erro = "";
            String msg = request.getParameter("msg");
            if ("logout".equals(msg)) {
        %>
            <div class="msg-sucesso">Sessão terminada com sucesso.</div>
        <%
            }
            if ("registo".equals(msg)) {
        %>
            <div class="msg-sucesso">Registo efectuado com sucesso. Pode agora fazer login.</div>
        <%
            }
        %>

        <%
            // Processar o formulário de login quando submetido via POST
            if ("POST".equals(request.getMethod())) {
                // Sanitização dos dados de entrada
                String username = sanitize(request.getParameter("username"));
                String password = sanitize(request.getParameter("password"));
                
                if (username.isEmpty() || password.isEmpty()) {
                    erro = "Por favor, preencha todos os campos.";
                } else {
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = connectBD();
                        // Verificar username e password com hash SHA-256
                        String sql = "SELECT * FROM utilizadores WHERE username = ? AND password = SHA2(?, 256) AND estado = 'ativo'";
                        stmt = conn.prepareStatement(sql);
                        stmt.setString(1, username);
                        stmt.setString(2, password);
                        rs = stmt.executeQuery();
                        
                        if (rs.next()) {
                            // Autenticação bem sucedida - criar sessão
                            session.setAttribute("id_utilizador", rs.getInt("id"));
                            session.setAttribute("nome", rs.getString("nome"));
                            session.setAttribute("username", rs.getString("username"));
                            session.setAttribute("perfil", rs.getString("perfil"));
                            
                            // Redirecionar conforme o perfil
                            String perfil = rs.getString("perfil");
                            if ("admin".equals(perfil)) {
                                response.sendRedirect("adminDashboard.jsp");
                            } else if ("funcionario".equals(perfil)) {
                                response.sendRedirect("funcionarioDashboard.jsp");
                            } else {
                                response.sendRedirect("clienteDashboard.jsp");
                            }
                            return;
                        } else {
                            erro = "Utilizador ou password incorrectos, ou conta inactiva.";
                        }
                    } catch (Exception e) {
                        erro = "Erro ao efectuar login: " + e.getMessage();
                    } finally {
                        if (rs != null) rs.close();
                        if (stmt != null) stmt.close();
                        if (conn != null) conn.close();
                    }
                }
            }
        %>

        <% if (!erro.isEmpty()) { %>
            <div class="msg-erro"><%= erro %></div>
        <% } %>

        <form method="post" action="login.jsp">
            <div class="form-grupo">
                <label for="username">Nome de Utilizador:</label>
                <input type="text" id="username" name="username" required maxlength="50">
            </div>
            <div class="form-grupo">
                <label for="password">Password:</label>
                <input type="password" id="password" name="password" required maxlength="100">
            </div>
            <button type="submit" class="btn btn-verde">Entrar</button>
            &nbsp;<a href="registo.jsp" class="btn btn-cinza">Registar</a>
        </form>
    </div>
</div>

<%@ include file="footer.jsp" %>
