<%-- 
    Ficheiro: registo.jsp
    Descrição: Página de registo de novos clientes. Cria o utilizador com perfil 'cliente'
    e cria automaticamente uma carteira com saldo inicial de 0.00 €.
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
                // Sanitização e validação dos dados de entrada
                String nome = sanitize(request.getParameter("nome"));
                String username = sanitize(request.getParameter("username"));
                String password = sanitize(request.getParameter("password"));
                String email = sanitize(request.getParameter("email"));
                String telefone = sanitize(request.getParameter("telefone"));
                String morada = sanitize(request.getParameter("morada"));
                
                if (nome.isEmpty() || username.isEmpty() || password.isEmpty()) {
                    erro = "Nome, username e password são obrigatórios.";
                } else {
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = connectBD();
                        
                        // Verificar se o username já existe
                        stmt = conn.prepareStatement("SELECT id FROM utilizadores WHERE username = ?");
                        stmt.setString(1, username);
                        rs = stmt.executeQuery();
                        if (rs.next()) {
                            erro = "Este nome de utilizador já está em uso. Escolha outro.";
                        } else {
                            // Inserir o novo utilizador com password em SHA-256
                            String sqlInsert = "INSERT INTO utilizadores (nome, username, password, perfil, email, telefone, morada) VALUES (?, ?, SHA2(?, 256), 'cliente', ?, ?, ?)";
                            PreparedStatement stmtInsert = conn.prepareStatement(sqlInsert, Statement.RETURN_GENERATED_KEYS);
                            stmtInsert.setString(1, nome);
                            stmtInsert.setString(2, username);
                            stmtInsert.setString(3, password);
                            stmtInsert.setString(4, email);
                            stmtInsert.setString(5, telefone);
                            stmtInsert.setString(6, morada);
                            stmtInsert.executeUpdate();
                            
                            // Obter o ID do novo utilizador para criar a carteira
                            ResultSet rsKeys = stmtInsert.getGeneratedKeys();
                            if (rsKeys.next()) {
                                int idNovoUtilizador = rsKeys.getInt(1);
                                // Criar carteira com saldo inicial 0
                                PreparedStatement stmtCarteira = conn.prepareStatement("INSERT INTO carteiras (id_utilizador, saldo, tipo) VALUES (?, 0.00, 'cliente')");
                                stmtCarteira.setInt(1, idNovoUtilizador);
                                stmtCarteira.executeUpdate();
                                stmtCarteira.close();
                            }
                            rsKeys.close();
                            stmtInsert.close();
                            
                            // Redirecionar para login com mensagem de sucesso
                            response.sendRedirect("login.jsp?msg=registo");
                            return;
                        }
                    } catch (Exception e) {
                        erro = "Erro ao registar: " + e.getMessage();
                    } finally {
                        if (conn != null) conn.close();
                        if (stmt != null) stmt.close();
                    }
                }
            }
        %>

        <% if (!erro.isEmpty()) { %>
            <div class="msg-erro"><%= erro %></div>
        <% } %>

        <form method="post" action="registo.jsp">
            <div class="form-grupo">
                <label for="nome">Nome Completo *:</label>
                <input type="text" id="nome" name="nome" required maxlength="100">
            </div>
            <div class="form-grupo">
                <label for="username">Nome de Utilizador *:</label>
                <input type="text" id="username" name="username" required maxlength="50">
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
            &nbsp;<a href="login.jsp" class="btn btn-cinza">Já tenho conta</a>
        </form>
    </div>
</div>

<%@ include file="footer.jsp" %>
