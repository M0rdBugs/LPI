<%-- 
    Gestão da carteira do cliente
    Permite consultar, adicionar e levantar saldo
    Todas as operações são registadas na auditoria
    Tabelas usadas: carteira, auditoria
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%
    /* Verificacao de sessao: apenas cliente */
    String _perfil = (String) session.getAttribute("tipo_util");
    Integer _idUtil = (Integer) session.getAttribute("id");
    if (_perfil == null || !_perfil.equals("cliente")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>A Minha Carteira</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";

            /* Processar deposito ou levantamento */
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
                            conn = connectBD();

                            /* Obter carteira do cliente */
                            stmt = conn.prepareStatement(
                                "SELECT id, saldo FROM carteira WHERE utilizador_id = ?");
                            stmt.setInt(1, _idUtil);
                            rs = stmt.executeQuery();

                            if (rs.next()) {
                                int idCarteira = rs.getInt("id");
                                double saldoActual = rs.getDouble("saldo");
                                rs.close();
                                stmt.close();

                                if ("levantar".equals(operacao) && valor > saldoActual) {
                                    mensagem = "Saldo insuficiente para levantamento.";
                                    tipoMsg = "erro";
                                } else {
                                    String sqlUpdate = "UPDATE carteira SET saldo = saldo + ? WHERE id = ?";
                                    String tipoOperacao = "deposito";
                                    String descricao = "Deposito de " + String.format("%.2f", valor) + " EUR";

                                    if ("levantar".equals(operacao)) {
                                        sqlUpdate = "UPDATE carteira SET saldo = saldo - ? WHERE id = ?";
                                        tipoOperacao = "levantamento";
                                        descricao = "Levantamento de " + String.format("%.2f", valor) + " EUR";
                                    }

                                    /* Actualizar saldo */
                                    stmt = conn.prepareStatement(sqlUpdate);
                                    stmt.setDouble(1, valor);
                                    stmt.setInt(2, idCarteira);
                                    stmt.executeUpdate();
                                    stmt.close();

                                    /* Registar na auditoria */
                                    stmt = conn.prepareStatement(
                                        "INSERT INTO auditoria (utilizador_id, tipo_operacao, valor, descricao, carteira_origem, carteira_destino) VALUES (?, ?, ?, ?, ?, ?)");
                                    stmt.setInt(1, _idUtil);
                                    stmt.setString(2, tipoOperacao);
                                    stmt.setDouble(3, valor);
                                    stmt.setString(4, descricao);
                                    if ("deposito".equals(operacao)) {
                                        stmt.setNull(5, java.sql.Types.INTEGER);
                                        stmt.setInt(6, idCarteira);
                                    } else {
                                        stmt.setInt(5, idCarteira);
                                        stmt.setNull(6, java.sql.Types.INTEGER);
                                    }
                                    stmt.executeUpdate();
                                    stmt.close();

                                    mensagem = "Operacao realizada com sucesso.";
                                    tipoMsg = "sucesso";
                                }
                            }
                        } catch (Exception e) {
                            mensagem = "Erro na operacao: " + e.getMessage();
                            tipoMsg = "erro";
                        } finally {
                            if (rs != null) try { rs.close(); } catch (Exception ex) {}
                            if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
                            if (conn != null) try { conn.close(); } catch (Exception ex) {}
                        }
                    }
                } catch (NumberFormatException e) {
                    mensagem = "Valor invalido.";
                    tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %>
            <div class="msg-<%= tipoMsg %>"><%= mensagem %></div>
        <% } %>

        <%
            /* Mostrar saldo actual */
            Connection connS = null;
            PreparedStatement stmtS = null;
            ResultSet rsS = null;
            try {
                connS = connectBD();
                stmtS = connS.prepareStatement(
                    "SELECT saldo FROM carteira WHERE utilizador_id = ?");
                stmtS.setInt(1, _idUtil);
                rsS = stmtS.executeQuery();
                if (rsS.next()) {
        %>
        <div class="saldo-card">
            <strong>Saldo Actual: <%= String.format("%.2f", rsS.getDouble("saldo")) %> EUR</strong>
        </div>
        <%
                }
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro ao carregar saldo: " + e.getMessage() + "</div>");
            } finally {
                if (rsS != null) try { rsS.close(); } catch (Exception ex) {}
                if (stmtS != null) try { stmtS.close(); } catch (Exception ex) {}
                if (connS != null) try { connS.close(); } catch (Exception ex) {}
            }
        %>

        <h3>Adicionar Saldo</h3>
        <form method="post" action="carteira.jsp" style="margin-bottom:20px;">
            <input type="hidden" name="operacao" value="depositar">
            <div class="form-grupo">
                <label>Valor a Adicionar (EUR):</label>
                <input type="number" name="valor" min="0.01" step="0.01" required style="width:200px;">
            </div>
            <button type="submit" class="btn btn-verde">Adicionar</button>
        </form>

        <h3>Levantar Saldo</h3>
        <form method="post" action="carteira.jsp">
            <input type="hidden" name="operacao" value="levantar">
            <div class="form-grupo">
                <label>Valor a Levantar (EUR):</label>
                <input type="number" name="valor" min="0.01" step="0.01" required style="width:200px;">
            </div>
            <button type="submit" class="btn btn-vermelho">Levantar</button>
        </form>
    </div>
</div>

<%@ include file="footer.jsp" %>
