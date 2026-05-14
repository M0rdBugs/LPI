<%-- 
    Pagina de registo de novos utilizadores 
    Cria o utilizador com perfil de 'cliente' com saldo 0.00 EUR
    Tabelas usadas: utilizador, carteira
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card" style="max-width:500px; margin:0 auto;">
        <h2>Registar Conta</h2>

        <%
            String erro = "";

            if ("POST".equals(request.getMethod())) {
                String nome = sanitize(request.getParameter("nome"));
                String email = sanitize(request.getParameter("email"));
                String telefone = sanitize(request.getParameter("telefone"));
                String morada = sanitize(request.getParameter("morada"));
                String password = sanitize(request.getParameter("password"));

                if (nome.isEmpty() || password.isEmpty()) {
                    erro = "Nome e password sao obrigatorios.";
                } else {
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = connectBD();

                        /* Verificar se o nome ja existe */
                        stmt = conn.prepareStatement("SELECT id FROM utilizador WHERE nome = ?");
                        stmt.setString(1, nome);
                        rs = stmt.executeQuery();
                        if (rs.next()) {
                            erro = "Este nome de utilizador ja esta em uso. Escolha outro.";
                        } else {
                            rs.close();
                            stmt.close();

                            /* Inserir novo utilizador */
                            stmt = conn.prepareStatement(
                                "INSERT INTO utilizador (nome, email, telefone, morada, password, tipo_util) VALUES (?, ?, ?, ?, SHA2(?, 256), 'cliente')",
                                Statement.RETURN_GENERATED_KEYS);
                            stmt.setString(1, nome);
                            stmt.setString(2, email.isEmpty() ? null : email);
                            stmt.setString(3, telefone.isEmpty() ? null : telefone);
                            stmt.setString(4, morada.isEmpty() ? null : morada);
                            stmt.setString(5, password);
                            stmt.executeUpdate();

                            /* Obter ID gerado */
                            ResultSet rsKeys = stmt.getGeneratedKeys();
                            if (rsKeys.next()) {
                                int novoId = rsKeys.getInt(1);
                                rsKeys.close();
                                stmt.close();

                                /* Criar carteira automatica */
                                stmt = conn.prepareStatement(
                                    "INSERT INTO carteira (utilizador_id, nome, saldo) VALUES (?, ?, 0.00)");
                                stmt.setInt(1, novoId);
                                stmt.setString(2, "Carteira do " + nome);
                                stmt.executeUpdate();
                            }
                            response.sendRedirect("login.jsp?msg=registo");
                            return;
                        }
                    } catch (Exception e) {
                        erro = "Erro ao registar: " + e.getMessage();
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

        <form method="post" action="registo.jsp">
            <div class="form-grupo">
                <label for="nome">Nome de Utilizador *:</label>
                <input type="text" id="nome" name="nome" required maxlength="100">
            </div>
            <div class="form-grupo">
                <label for="password">Password *:</label>
                <input type="password" id="password" name="password" required maxlength="100">
            </div>
            <div class="form-grupo">
                <label for="email">Email:</label>
                <input type="email" id="email" name="email" maxlength="100">
            </div>
            <div class="form-grupo">
                <label for="telefone">Telefone:</label>
                <input type="text" id="telefone" name="telefone" maxlength="20">
            </div>
            <div class="form-grupo">
                <label for="morada">Morada:</label>
                <textarea id="morada" name="morada"></textarea>
            </div>
            <button type="submit" class="btn btn-verde">Registar</button>
            &nbsp;<a href="login.jsp" class="btn btn-cinza">Ja tenho conta</a>
        </form>
    </div>
</div>

<%@ include file="footer.jsp" %>
