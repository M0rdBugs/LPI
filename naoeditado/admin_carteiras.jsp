<%-- 
    Ficheiro: admin_carteiras.jsp
    Descrição: Gestão de carteiras de clientes pelo administrador.
    Permite consultar e editar o saldo de qualquer cliente,
    bem como ver o saldo da carteira da FelixUberShop.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_admin.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Gestão de Carteiras</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            
            if ("POST".equals(request.getMethod())) {
                String operacao = sanitize(request.getParameter("operacao"));
                String idClienteStr = sanitize(request.getParameter("id_cliente"));
                String valorStr = sanitize(request.getParameter("valor"));
                
                try {
                    int idCliente = Integer.parseInt(idClienteStr);
                    double valor = Double.parseDouble(valorStr);
                    
                    if (valor <= 0) {
                        mensagem = "O valor tem de ser superior a 0."; tipoMsg = "erro";
                    } else {
                        Connection conn = null; PreparedStatement stmt = null; ResultSet rs = null;
                        try {
                            conn = ligarBaseDados();
                            stmt = conn.prepareStatement("SELECT id, saldo FROM carteiras WHERE id_utilizador=?");
                            stmt.setInt(1, idCliente);
                            rs = stmt.executeQuery();
                            
                            if (rs.next()) {
                                int idCarteira = rs.getInt("id");
                                double saldo = rs.getDouble("saldo");
                                rs.close(); stmt.close();
                                
                                if ("levantar".equals(operacao) && valor > saldo) {
                                    mensagem = "Saldo insuficiente."; tipoMsg = "erro";
                                } else {
                                    String sqlUpdate = "depositar".equals(operacao)
                                        ? "UPDATE carteiras SET saldo = saldo + ? WHERE id=?"
                                        : "UPDATE carteiras SET saldo = saldo - ? WHERE id=?";
                                    stmt = conn.prepareStatement(sqlUpdate);
                                    stmt.setDouble(1, valor); stmt.setInt(2, idCarteira); stmt.executeUpdate(); stmt.close();
                                    
                                    String tipoOp = "depositar".equals(operacao) ? "deposito" : "levantamento";
                                    stmt = conn.prepareStatement("INSERT INTO auditoria_carteira (id_carteira_origem, id_carteira_destino, valor, tipo_operacao, descricao) VALUES (?,?,?,?,?)");
                                    if ("depositar".equals(operacao)) { stmt.setNull(1, java.sql.Types.INTEGER); stmt.setInt(2, idCarteira); }
                                    else { stmt.setInt(1, idCarteira); stmt.setNull(2, java.sql.Types.INTEGER); }
                                    stmt.setDouble(3, valor); stmt.setString(4, tipoOp);
                                    stmt.setString(5, "Operação pelo admin " + session.getAttribute("username") + " na carteira do cliente ID " + idCliente);
                                    stmt.executeUpdate(); stmt.close();
                                    
                                    mensagem = "Operação realizada com sucesso."; tipoMsg = "sucesso";
                                }
                            }
                        } catch (Exception e) {
                            mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                        } finally {
                            desligarBaseDados(conn, stmt, rs);
                        }
                    }
                } catch (NumberFormatException e) {
                    mensagem = "Dados inválidos."; tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %><div class="msg-<%= tipoMsg %>"><%= mensagem %></div><% } %>

        <!-- Carteira da Loja -->
        <%
            Connection connLoja = null; PreparedStatement stmtLoja = null; ResultSet rsLoja = null;
            try {
                connLoja = ligarBaseDados();
                stmtLoja = connLoja.prepareStatement("SELECT saldo FROM carteiras WHERE tipo='loja' LIMIT 1");
                rsLoja = stmtLoja.executeQuery();
                if (rsLoja.next()) {
        %>
        <div class="msg-info" style="font-size:1.1em; margin-bottom:20px;">
            <strong>Saldo da Carteira FelixUberShop: <%= String.format("%.2f", rsLoja.getDouble("saldo")) %> €</strong>
        </div>
        <%
                }
            } catch (Exception e) {} finally {
                desligarBaseDados(connLoja, stmtLoja, rsLoja);
            }
        %>

        <h3>Carteiras dos Clientes</h3>
        <%
            Connection connL = null; PreparedStatement stmtL = null; ResultSet rsL = null;
            try {
                connL = ligarBaseDados();
                stmtL = connL.prepareStatement(
                    "SELECT u.id, u.nome, u.username, c.saldo FROM utilizadores u JOIN carteiras c ON u.id=c.id_utilizador WHERE u.perfil='cliente' AND u.estado='ativo' ORDER BY u.nome"
                );
                rsL = stmtL.executeQuery();
        %>
        <table>
            <tr><th>Nome</th><th>Username</th><th>Saldo</th><th>Ação</th></tr>
            <% while (rsL.next()) { %>
            <tr>
                <td><%= rsL.getString("nome") %></td>
                <td><%= rsL.getString("username") %></td>
                <td><strong><%= String.format("%.2f", rsL.getDouble("saldo")) %> €</strong></td>
                <td>
                    <form method="post" action="admin_carteiras.jsp" style="display:inline;">
                        <input type="hidden" name="id_cliente" value="<%= rsL.getInt("id") %>">
                        <input type="number" name="valor" min="0.01" step="0.01" placeholder="Valor" style="width:90px;" required>
                        <button type="submit" name="operacao" value="depositar" class="btn btn-verde">+</button>
                        <button type="submit" name="operacao" value="levantar" class="btn btn-vermelho">-</button>
                    </form>
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
