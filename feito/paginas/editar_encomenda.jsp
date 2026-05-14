<%--
    Permite editar a quantidade de uma encomenda com estado 'ativo'
    Recalcula o valor total e ajusta o saldo das carteiras e o stock
    O cliente edita as proprias encomendas
    O funcionario e o administrador editam qualquer encomenda
    Regista as alterações na tabela de auditoria
    Tabelas usadas: encomenda, carteira, produto, auditoria
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%
    // Verifica a autenticação
    String _perfil = (String) session.getAttribute("tipo_util");
    Integer _idUtil = (Integer) session.getAttribute("id");
    if (_perfil == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Editar Encomenda</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            int idEncomenda = 0;
            try {
                idEncomenda = Integer.parseInt(request.getParameter("id"));
            } catch (Exception e) {
                mensagem = "Encomenda invalida.";
                tipoMsg = "erro";
            }

            if ("POST".equals(request.getMethod()) && idEncomenda > 0) {
                String qtdStr = sanitize(request.getParameter("quantidade"));

                try {
                    int novaQtd = Integer.parseInt(qtdStr);
                    if (novaQtd <= 0) {
                        mensagem = "Quantidade invalida.";
                        tipoMsg = "erro";
                    } else {
                        Connection conn = null;
                        PreparedStatement stmt = null;
                        ResultSet rs = null;
                        try {
                            conn = connectBD();
                            conn.setAutoCommit(false);

                            /* Verificar encomenda */
                            String sqlCheck;
                            if ("cliente".equals(_perfil)) {
                                sqlCheck = "SELECT e.*, p.preco AS preco_unit, p.quantidade AS stock FROM encomenda e JOIN produto p ON e.produto_id = p.id WHERE e.id = ? AND e.utilizador_id = ? AND e.estado = 'ativo'";
                                stmt = conn.prepareStatement(sqlCheck);
                                stmt.setInt(1, idEncomenda);
                                stmt.setInt(2, _idUtil);
                            } else {
                                sqlCheck = "SELECT e.*, p.preco AS preco_unit, p.quantidade AS stock FROM encomenda e JOIN produto p ON e.produto_id = p.id WHERE e.id = ? AND e.estado = 'ativo'";
                                stmt = conn.prepareStatement(sqlCheck);
                                stmt.setInt(1, idEncomenda);
                            }
                            rs = stmt.executeQuery();

                            if (!rs.next()) {
                                mensagem = "Encomenda nao encontrada ou nao pode ser alterada.";
                                tipoMsg = "erro";
                                conn.rollback();
                            } else {
                                int idCliente = rs.getInt("utilizador_id");
                                int produtoId = rs.getInt("produto_id");
                                int qtdAntiga = rs.getInt("quantidade");
                                double precoUnit = rs.getDouble("preco_unit");
                                double valorAntigo = rs.getDouble("valor_total");
                                int stock = rs.getInt("stock");
                                String codigoUnico = rs.getString("codigo_unico");
                                rs.close();
                                stmt.close();

                                int diffStock = qtdAntiga - novaQtd;
                                if (novaQtd > (stock + qtdAntiga)) {
                                    mensagem = "Stock insuficiente. Stock actual: " + stock + " + devolvido: " + qtdAntiga + " = " + (stock + qtdAntiga);
                                    tipoMsg = "erro";
                                    conn.rollback();
                                } else {
                                    double valorNovo = novaQtd * precoUnit;
                                    double diffValor = valorNovo - valorAntigo;

                                    /* Obter carteira do cliente */
                                    stmt = conn.prepareStatement("SELECT id, saldo FROM carteira WHERE utilizador_id = ?");
                                    stmt.setInt(1, idCliente);
                                    rs = stmt.executeQuery();
                                    int idCarteiraCliente = 0;
                                    double saldoCliente = 0;
                                    if (rs.next()) {
                                        idCarteiraCliente = rs.getInt("id");
                                        saldoCliente = rs.getDouble("saldo");
                                    }
                                    rs.close();
                                    stmt.close();

                                    /* Obter carteira da loja */
                                    stmt = conn.prepareStatement("SELECT id FROM carteira WHERE utilizador_id IS NULL LIMIT 1");
                                    rs = stmt.executeQuery();
                                    int idCarteiraLoja = 0;
                                    if (rs.next()) idCarteiraLoja = rs.getInt("id");
                                    rs.close();
                                    stmt.close();

                                    if (diffValor > 0 && saldoCliente < diffValor) {
                                        mensagem = "Saldo insuficiente para o ajuste. Necessario: " + String.format("%.2f", diffValor) + " EUR. Saldo: " + String.format("%.2f", saldoCliente) + " EUR.";
                                        tipoMsg = "erro";
                                        conn.rollback();
                                    } else {
                                        /* Ajustar stock */
                                        stmt = conn.prepareStatement("UPDATE produto SET quantidade = quantidade + ? WHERE id = ?");
                                        stmt.setInt(1, diffStock);
                                        stmt.setInt(2, produtoId);
                                        stmt.executeUpdate();
                                        stmt.close();

                                        /* Ajustar saldo cliente */
                                        stmt = conn.prepareStatement("UPDATE carteira SET saldo = saldo - ? WHERE id = ?");
                                        stmt.setDouble(1, diffValor);
                                        stmt.setInt(2, idCarteiraCliente);
                                        stmt.executeUpdate();
                                        stmt.close();

                                        /* Ajustar saldo loja */
                                        stmt = conn.prepareStatement("UPDATE carteira SET saldo = saldo + ? WHERE id = ?");
                                        stmt.setDouble(1, diffValor);
                                        stmt.setInt(2, idCarteiraLoja);
                                        stmt.executeUpdate();
                                        stmt.close();

                                        /* Actualizar encomenda */
                                        stmt = conn.prepareStatement(
                                            "UPDATE encomenda SET quantidade = ?, valor_total = ?, estado = 'alterada' WHERE id = ?");
                                        stmt.setInt(1, novaQtd);
                                        stmt.setDouble(2, valorNovo);
                                        stmt.setInt(3, idEncomenda);
                                        stmt.executeUpdate();
                                        stmt.close();

                                        if (diffValor != 0) {
                                            /* Registar auditoria */
                                            stmt = conn.prepareStatement(
                                                "INSERT INTO auditoria (utilizador_id, tipo_operacao, valor, descricao, carteira_origem, carteira_destino) VALUES (?, ?, ?, ?, ?, ?)");
                                            stmt.setInt(1, _idUtil);
                                            if (diffValor > 0) {
                                                stmt.setString(2, "pagamento");
                                                stmt.setDouble(3, diffValor);
                                                stmt.setString(4, "Ajuste de encomenda " + codigoUnico + " (aumento)");
                                                stmt.setInt(5, idCarteiraCliente);
                                                stmt.setInt(6, idCarteiraLoja);
                                            } else {
                                                stmt.setString(2, "reembolso");
                                                stmt.setDouble(3, Math.abs(diffValor));
                                                stmt.setString(4, "Ajuste de encomenda " + codigoUnico + " (reducao)");
                                                stmt.setInt(5, idCarteiraLoja);
                                                stmt.setInt(6, idCarteiraCliente);
                                            }
                                            stmt.executeUpdate();
                                            stmt.close();
                                        }

                                        conn.commit();
                                        String redirect = "cliente".equals(_perfil) ? "encomendas.jsp?msg=editada" : ("funcionario".equals(_perfil) ? "func_encomendas.jsp" : "admin_encomendas.jsp");
                                        response.sendRedirect(redirect);
                                        return;
                                    }
                                }
                            }
                        } catch (Exception e) {
                            try { conn.rollback(); } catch (Exception ex) {}
                            mensagem = "Erro ao editar encomenda: " + e.getMessage();
                            tipoMsg = "erro";
                        } finally {
                            if (rs != null) try { rs.close(); } catch (Exception ex) {}
                            if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
                            if (conn != null) try { conn.close(); } catch (Exception ex) {}
                        }
                    }
                } catch (NumberFormatException e) {
                    mensagem = "Quantidade invalida.";
                    tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %>
            <div class="msg-<%= tipoMsg %>"><%= mensagem %></div>
        <% } %>

        <%
            /* Carregar dados actuais da encomenda para o formulario */
            if (idEncomenda > 0) {
                Connection connE = null;
                PreparedStatement stmtE = null;
                ResultSet rsE = null;
                try {
                    connE = connectBD();
                    String sqlE = "SELECT e.*, p.nome AS nome_produto, p.preco AS preco_unit, p.quantidade AS stock " +
                                  "FROM encomenda e JOIN produto p ON e.produto_id = p.id WHERE e.id = ?";
                    stmtE = connE.prepareStatement(sqlE);
                    stmtE.setInt(1, idEncomenda);
                    rsE = stmtE.executeQuery();
                    if (rsE.next()) {
        %>
        <form method="post" action="editar_encomenda.jsp?id=<%= idEncomenda %>">
            <div class="form-grupo">
                <label>Codigo:</label>
                <input type="text" value="<%= rsE.getString("codigo_unico") %>" disabled>
            </div>
            <div class="form-grupo">
                <label>Produto:</label>
                <input type="text" value="<%= rsE.getString("nome_produto") %>" disabled>
            </div>
            <div class="form-grupo">
                <label>Preco Unitario:</label>
                <input type="text" value="<%= String.format("%.2f", rsE.getDouble("preco_unit")) %> EUR" disabled>
            </div>
            <div class="form-grupo">
                <label>Quantidade:</label>
                <input type="number" name="quantidade" value="<%= rsE.getInt("quantidade") %>" min="1" max="<%= rsE.getInt("stock") + rsE.getInt("quantidade") %>" required>
            </div>
            <div class="form-grupo">
                <label>Valor Actual:</label>
                <input type="text" value="<%= String.format("%.2f", rsE.getDouble("valor_total")) %> EUR" disabled>
            </div>
            <button type="submit" class="btn btn-verde">Guardar Alteracoes</button>
            <%
                String voltar = "cliente".equals(_perfil) ? "encomendas.jsp" : ("funcionario".equals(_perfil) ? "func_encomendas.jsp" : "admin_encomendas.jsp");
            %>
            <a href="<%= voltar %>" class="btn btn-cinza">Cancelar</a>
        </form>
        <%
                    }
                } catch (Exception e) {
                    out.println("<div class='msg-erro'>Erro ao carregar encomenda: " + e.getMessage() + "</div>");
                } finally {
                    if (rsE != null) try { rsE.close(); } catch (Exception ex) {}
                    if (stmtE != null) try { stmtE.close(); } catch (Exception ex) {}
                    if (connE != null) try { connE.close(); } catch (Exception ex) {}
                }
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
