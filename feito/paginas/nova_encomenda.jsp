<%-- 
    Formulario para criação de uma nova encomenda pelo cliente
    Verifica o saldo do cliente e o stock do produto 
    Debita do cliente e credita a loja
    Decrementa o stock, gera o codigo único e regista o processo na auditoria
    Tudo dentro de uma transacao SQL
    Tabelas usadas: produto, carteira, encomenda, auditoria
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%
    // Apenas para clientes
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
        <h2>Nova Encomenda</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";

            if ("POST".equals(request.getMethod())) {
                String produtoIdStr = sanitize(request.getParameter("produto_id"));
                String qtdStr = sanitize(request.getParameter("quantidade"));

                if (produtoIdStr.isEmpty() || qtdStr.isEmpty()) {
                    mensagem = "Seleccione um produto e uma quantidade.";
                    tipoMsg = "erro";
                } else {
                    try {
                        int produtoId = Integer.parseInt(produtoIdStr);
                        int quantidade = Integer.parseInt(qtdStr);
                        if (quantidade <= 0) {
                            mensagem = "A quantidade deve ser superior a 0.";
                            tipoMsg = "erro";
                        } else {
                            Connection conn = null;
                            PreparedStatement stmt = null;
                            ResultSet rs = null;
                            try {
                                conn = connectBD();
                                conn.setAutoCommit(false);

                                /* Verificar produto e stock */
                                stmt = conn.prepareStatement(
                                    "SELECT nome, preco, quantidade FROM produto WHERE id = ? AND estado = 'ativo'");
                                stmt.setInt(1, produtoId);
                                rs = stmt.executeQuery();

                                if (!rs.next()) {
                                    mensagem = "Produto nao encontrado ou inactivo.";
                                    tipoMsg = "erro";
                                    conn.rollback();
                                } else {
                                    String nomeProduto = rs.getString("nome");
                                    double preco = rs.getDouble("preco");
                                    int stock = rs.getInt("quantidade");
                                    rs.close();
                                    stmt.close();

                                    if (quantidade > stock) {
                                        mensagem = "Stock insuficiente. Disponivel: " + stock + " unidades.";
                                        tipoMsg = "erro";
                                        conn.rollback();
                                    } else {
                                        double valorTotal = preco * quantidade;

                                        /* Verificar saldo do cliente */
                                        stmt = conn.prepareStatement(
                                            "SELECT id, saldo FROM carteira WHERE utilizador_id = ?");
                                        stmt.setInt(1, _idUtil);
                                        rs = stmt.executeQuery();

                                        if (!rs.next()) {
                                            mensagem = "Carteira nao encontrada.";
                                            tipoMsg = "erro";
                                            conn.rollback();
                                        } else {
                                            int idCarteiraCliente = rs.getInt("id");
                                            double saldoCliente = rs.getDouble("saldo");
                                            rs.close();
                                            stmt.close();

                                            if (saldoCliente < valorTotal) {
                                                mensagem = "Saldo insuficiente. Saldo: " + String.format("%.2f", saldoCliente) + " EUR. Valor: " + String.format("%.2f", valorTotal) + " EUR.";
                                                tipoMsg = "erro";
                                                conn.rollback();
                                            } else {
                                                /* Obter carteira da loja */
                                                stmt = conn.prepareStatement(
                                                    "SELECT id FROM carteira WHERE utilizador_id IS NULL LIMIT 1");
                                                rs = stmt.executeQuery();
                                                int idCarteiraLoja = 0;
                                                if (rs.next()) idCarteiraLoja = rs.getInt("id");
                                                rs.close();
                                                stmt.close();

                                                /* Gerar codigo unico */
                                                String codigoUnico = "ENC-" + System.currentTimeMillis();

                                                /* Debitar cliente */
                                                stmt = conn.prepareStatement(
                                                    "UPDATE carteira SET saldo = saldo - ? WHERE id = ?");
                                                stmt.setDouble(1, valorTotal);
                                                stmt.setInt(2, idCarteiraCliente);
                                                stmt.executeUpdate();
                                                stmt.close();

                                                /* Creditar loja */
                                                stmt = conn.prepareStatement(
                                                    "UPDATE carteira SET saldo = saldo + ? WHERE id = ?");
                                                stmt.setDouble(1, valorTotal);
                                                stmt.setInt(2, idCarteiraLoja);
                                                stmt.executeUpdate();
                                                stmt.close();

                                                /* Decrementar stock */
                                                stmt = conn.prepareStatement(
                                                    "UPDATE produto SET quantidade = quantidade - ? WHERE id = ?");
                                                stmt.setInt(1, quantidade);
                                                stmt.setInt(2, produtoId);
                                                stmt.executeUpdate();
                                                stmt.close();

                                                /* Criar encomenda */
                                                stmt = conn.prepareStatement(
                                                    "INSERT INTO encomenda (utilizador_id, produto_id, quantidade, valor_total, codigo_unico) VALUES (?, ?, ?, ?, ?)");
                                                stmt.setInt(1, _idUtil);
                                                stmt.setInt(2, produtoId);
                                                stmt.setInt(3, quantidade);
                                                stmt.setDouble(4, valorTotal);
                                                stmt.setString(5, codigoUnico);
                                                stmt.executeUpdate();
                                                stmt.close();

                                                /* Registar auditoria */
                                                stmt = conn.prepareStatement(
                                                    "INSERT INTO auditoria (utilizador_id, tipo_operacao, valor, descricao, carteira_origem, carteira_destino) VALUES (?, 'pagamento', ?, ?, ?, ?)");
                                                stmt.setInt(1, _idUtil);
                                                stmt.setDouble(2, valorTotal);
                                                stmt.setString(3, "Pagamento da encomenda " + codigoUnico + " (" + nomeProduto + " x" + quantidade + ")");
                                                stmt.setInt(4, idCarteiraCliente);
                                                stmt.setInt(5, idCarteiraLoja);
                                                stmt.executeUpdate();
                                                stmt.close();

                                                conn.commit();
                                                response.sendRedirect("encomendas.jsp?msg=criada");
                                                return;
                                            }
                                        }
                                    }
                                }
                            } catch (Exception e) {
                                try { conn.rollback(); } catch (Exception ex) {}
                                mensagem = "Erro ao criar encomenda: " + e.getMessage();
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
            }
        %>

        <% if (!mensagem.isEmpty()) { %>
            <div class="msg-<%= tipoMsg %>"><%= mensagem %></div>
        <% } %>

        <%
            /* Mostrar saldo disponivel */
            Connection connSaldo = null;
            PreparedStatement stmtSaldo = null;
            ResultSet rsSaldo = null;
            try {
                connSaldo = connectBD();
                stmtSaldo = connSaldo.prepareStatement(
                    "SELECT saldo FROM carteira WHERE utilizador_id = ?");
                stmtSaldo.setInt(1, _idUtil);
                rsSaldo = stmtSaldo.executeQuery();
                if (rsSaldo.next()) {
        %>
        <div class="msg-info">Saldo disponivel: <strong><%= String.format("%.2f", rsSaldo.getDouble("saldo")) %> EUR</strong></div>
        <%
                }
            } catch (Exception e) {} finally {
                if (rsSaldo != null) try { rsSaldo.close(); } catch (Exception ex) {}
                if (stmtSaldo != null) try { stmtSaldo.close(); } catch (Exception ex) {}
                if (connSaldo != null) try { connSaldo.close(); } catch (Exception ex) {}
            }
        %>

        <form method="post" action="nova_encomenda.jsp">
            <h3>Seleccionar Produto</h3>
            <div class="form-grupo">
                <label>Produto *:</label>
                <select name="produto_id" required onchange="this.form.querySelector('input[name=quantidade]').max = this.options[this.selectedIndex].getAttribute('data-stock')">
                    <option value="">-- Seleccione um produto --</option>
                    <%
                        Connection connP = null;
                        PreparedStatement stmtP = null;
                        ResultSet rsP = null;
                        try {
                            connP = connectBD();
                            stmtP = connP.prepareStatement(
                                "SELECT * FROM produto WHERE estado = 'ativo' AND quantidade > 0 ORDER BY nome");
                            rsP = stmtP.executeQuery();
                            String presel = request.getParameter("produto");
                            while (rsP.next()) {
                                String sel = presel != null && presel.equals(String.valueOf(rsP.getInt("id"))) ? "selected" : "";
                    %>
                    <option value="<%= rsP.getInt("id") %>" data-stock="<%= rsP.getInt("quantidade") %>" <%= sel %>>
                        <%= rsP.getString("nome") %> — <%= String.format("%.2f", rsP.getDouble("preco")) %> EUR (Stock: <%= rsP.getInt("quantidade") %>)
                    </option>
                    <%
                            }
                        } catch (Exception e) {
                            out.println("<option value=''>Erro ao carregar produtos</option>");
                        } finally {
                            if (rsP != null) try { rsP.close(); } catch (Exception ex) {}
                            if (stmtP != null) try { stmtP.close(); } catch (Exception ex) {}
                            if (connP != null) try { connP.close(); } catch (Exception ex) {}
                        }
                    %>
                </select>
            </div>
            <div class="form-grupo">
                <label>Quantidade *:</label>
                <input type="number" name="quantidade" min="1" value="1" required style="width:150px;">
            </div>
            <button type="submit" class="btn btn-verde">Confirmar Encomenda</button>
            <a href="produtos.jsp" class="btn btn-cinza">Cancelar</a>
        </form>
    </div>
</div>

<%@ include file="footer.jsp" %>
