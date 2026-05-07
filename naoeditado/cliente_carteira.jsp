<%-- 
    Ficheiro: cliente_carteira.jsp
    Descrição: Gestão da carteira do cliente. Permite consultar o saldo actual,
    adicionar saldo e levantar saldo. Todas as operações são registadas na tabela
    de auditoria para rastreabilidade.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_cliente.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>A Minha Carteira</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            int idUtilizador = (Integer) session.getAttribute("id_utilizador");
            
            // Processar operação de saldo
            if ("POST".equals(request.getMethod())) {
                String operacao = sanitize(request.getParameter("operacao"));
                String valorStr = sanitize(request.getParameter("valor"));
                
                try {
                    double valor = Double.parseDouble(valorStr);
                    if (valor <= 0) {
                        mensagem = "O valor tem de ser superior a 0.";
                        tipoMsg = "erro";
                    } else {
                        Connection conn = null;
                        PreparedStatement stmt = null;
                        ResultSet rs = null;
                        try {
                            conn = ligarBaseDados();
                            
                            // Obter carteira do cliente
                            stmt = conn.prepareStatement("SELECT * FROM carteiras WHERE id_utilizador = ?");
                            stmt.setInt(1, idUtilizador);
                            rs = stmt.executeQuery();
                            
                            if (rs.next()) {
                                int idCarteira = rs.getInt("id");
                                double saldoActual = rs.getDouble("saldo");
                                
                                if ("levantar".equals(operacao) && valor > saldoActual) {
                                    mensagem = "Saldo insuficiente para levantamento.";
                                    tipoMsg = "erro";
                                } else {
                                    // Actualizar saldo
                                    String sqlUpdate;
                                    String tipoOperacao;
                                    String descricao;
                                    if ("depositar".equals(operacao)) {
                                        sqlUpdate = "UPDATE carteiras SET saldo = saldo + ? WHERE id = ?";
                                        tipoOperacao = "deposito";
                                        descricao = "Depósito de " + String.format("%.2f", valor) + " € na carteira do cliente " + session.getAttribute("username");
                                    } else {
                                        sqlUpdate = "UPDATE carteiras SET saldo = saldo - ? WHERE id = ?";
                                        tipoOperacao = "levantamento";
                                        descricao = "Levantamento de " + String.format("%.2f", valor) + " € da carteira do cliente " + session.getAttribute("username");
                                    }
                                    
                                    PreparedStatement stmtUpdate = conn.prepareStatement(sqlUpdate);
                                    stmtUpdate.setDouble(1, valor);
                                    stmtUpdate.setInt(2, idCarteira);
                                    stmtUpdate.executeUpdate();
                                    stmtUpdate.close();
                                    
                                    // Registar na auditoria
                                    PreparedStatement stmtAudit = conn.prepareStatement(
                                        "INSERT INTO auditoria_carteira (id_carteira_origem, id_carteira_destino, valor, tipo_operacao, descricao) VALUES (?, ?, ?, ?, ?)"
                                    );
                                    if ("depositar".equals(operacao)) {
                                        stmtAudit.setNull(1, java.sql.Types.INTEGER);
                                        stmtAudit.setInt(2, idCarteira);
                                    } else {
                                        stmtAudit.setInt(1, idCarteira);
                                        stmtAudit.setNull(2, java.sql.Types.INTEGER);
                                    }
                                    stmtAudit.setDouble(3, valor);
                                    stmtAudit.setString(4, tipoOperacao);
                                    stmtAudit.setString(5, descricao);
                                    stmtAudit.executeUpdate();
                                    stmtAudit.close();
                                    
                                    mensagem = "Operação realizada com sucesso.";
                                    tipoMsg = "sucesso";
                                }
                            }
                        } catch (Exception e) {
                            mensagem = "Erro na operação: " + e.getMessage();
                            tipoMsg = "erro";
                        } finally {
                            desligarBaseDados(conn, stmt, rs);
                        }
                    }
                } catch (NumberFormatException e) {
                    mensagem = "Valor inválido.";
                    tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %>
            <div class="msg-<%= tipoMsg %>"><%= mensagem %></div>
        <% } %>

        <%
            // Mostrar saldo actual
            Connection conn3 = null;
            PreparedStatement stmt3 = null;
            ResultSet rs3 = null;
            try {
                conn3 = ligarBaseDados();
                stmt3 = conn3.prepareStatement("SELECT saldo FROM carteiras WHERE id_utilizador = ?");
                stmt3.setInt(1, idUtilizador);
                rs3 = stmt3.executeQuery();
                if (rs3.next()) {
        %>
        <div class="msg-info" style="font-size:1.2em;">
            <strong>Saldo Actual: <%= String.format("%.2f", rs3.getDouble("saldo")) %> €</strong>
        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro ao carregar saldo: " + e.getMessage() + "</div>");
            } finally {
                desligarBaseDados(conn3, stmt3, rs3);
            }
        %>

        <br>
        <h3>Adicionar Saldo</h3>
        <form method="post" action="cliente_carteira.jsp" style="display:inline-block; margin-right:20px;">
            <input type="hidden" name="operacao" value="depositar">
            <div class="form-grupo">
                <label>Valor a Adicionar (€):</label>
                <input type="number" name="valor" min="0.01" step="0.01" required style="width:150px;">
            </div>
            <button type="submit" class="btn btn-verde">Adicionar</button>
        </form>

        <h3 style="margin-top:20px;">Levantar Saldo</h3>
        <form method="post" action="cliente_carteira.jsp">
            <input type="hidden" name="operacao" value="levantar">
            <div class="form-grupo">
                <label>Valor a Levantar (€):</label>
                <input type="number" name="valor" min="0.01" step="0.01" required style="width:150px;">
            </div>
            <button type="submit" class="btn btn-vermelho">Levantar</button>
        </form>
    </div>
</div>

<%@ include file="footer.jsp" %>
