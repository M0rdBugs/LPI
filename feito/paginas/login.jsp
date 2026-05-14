<%-- 
    Ficheiro: login.jsp
    Descricao: Pagina de autenticacao. Valida nome e password com hash SHA2-256.
    Cria sessao com id, nome e tipo_util. Redirecciona para o dashboard
    correspondente ao perfil.
    Perfil de acesso: visitante (publico)
    Tabelas usadas: utilizador
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
            String msg = request.getParameter("msg");
            if ("logout".equals(msg)) {
        %>
            <div class="msg-sucesso">Sessao terminada com sucesso.</div>
        <%
            }
            if ("registo".equals(msg)) {
        %>
            <div class="msg-sucesso">Registo efectuado com sucesso. Pode agora fazer login.</div>
        <%
            }
        %>

        <%
            String erro = "";
            if ("POST".equals(request.getMethod())) {
                String nome = sanitize(request.getParameter("nome"));
                String password = sanitize(request.getParameter("password"));

                if (nome.isEmpty() || password.isEmpty()) {
                    erro = "Por favor, preencha todos os campos.";
                } else {
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = connectBD();
                        String sql = "SELECT * FROM utilizador WHERE nome = ? AND password = SHA2(?, 256) AND estado = 'ativo'";
                        stmt = conn.prepareStatement(sql);
                        stmt.setString(1, nome);
                        stmt.setString(2, password);
                        rs = stmt.executeQuery();

                        if (rs.next()) {
                            session.setAttribute("id", rs.getInt("id"));
                            session.setAttribute("nome", rs.getString("nome"));
                            session.setAttribute("tipo_util", rs.getString("tipo_util"));

                            String perfil = rs.getString("tipo_util");
                            if ("administrador".equals(perfil)) {
                                response.sendRedirect("admin_dashboard.jsp");
                            } else if ("funcionario".equals(perfil)) {
                                response.sendRedirect("funcionario_dashboard.jsp");
                            } else {
                                response.sendRedirect("cliente_dashboard.jsp");
                            }
                            return;
                        } else {
                            erro = "Utilizador ou password incorrectos, ou conta inactiva.";
                        }
                    } catch (Exception e) {
                        erro = "Erro ao efectuar login: " + e.getMessage();
                    } finally {
                        if (rs != null) try { rs.close(); } catch (Exception ex) {}
                        if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
                        if (conn != null) try { conn.close(); } catch (Exception ex) {}
                    }
                }
            }
        %>

        <% if (!erro.isEmpty()) { %>
            <div class="msg-erro"><%= erro %></div>
        <% } %>

        <form method="post" action="login.jsp">
            <div class="form-grupo">
                <label for="nome">Nome de Utilizador:</label>
                <input type="text" id="nome" name="nome" required maxlength="100">
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
