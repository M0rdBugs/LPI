<%-- 
    Ficheiro: nova_encomenda.jsp
    Descrição: Formulário para criação de nova encomenda pelo cliente.
    Gera um identificador único para a encomenda e efectua o pagamento
    através da transferência do valor da carteira do cliente para a carteira
    da FelixUberShop. Regista a operação na tabela de auditoria.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.UUID" %>
<%@ include file="sessao_cliente.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Nova Encomenda</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            int idUtilizador = (Integer) session.getAttribute("id_utilizador");
            
            if ("POST".equals(request.getMethod())) {
                String[] produtosIds = request.getParameterValues("produto_id");
                String[] quantidades = request.getParameterValues("quantidade");
                String moradaEntrega = sanitize(request.getParameter("morada_entrega"));
                
                if (produtosIds == null || produtosIds.length == 0) {
                    mensagem = "Seleccione pelo menos um produto.";
                    tipoMsg = "erro";
                } else {
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = ligarBaseDados();
                        conn.setAutoCommit(false); // Transacção
                        
                        // Calcular valor total
                        double valorTotal = 0;
                        double[] precos = new double[produtosIds.length];
                        int[] qtds = new int[produtosIds.length];
                        
                        for (int i = 0; i < produtosIds.length; i++) {
                            int qtd = Integer.parseInt(quantidades[i]);
                            if (qtd <= 0) continue;
                            qtds[i] = qtd;
                            stmt = conn.prepareStatement("SELECT preco FROM produtos WHERE id = ? AND estado = 'ativo'");
                            stmt.setInt(1, Integer.parseInt(produtosIds[i]));
                            rs = stmt.executeQuery();
                            if (rs.next()) {
                                precos[i] = rs.getDouble("preco");
                                valorTotal += precos[i] * qtd;
                            }
                            rs.close(); stmt.close();
                        }
                        
                        if (valorTotal <= 0) {
                            mensagem = "Seleccione pelo menos um produto com quantidade válida.";
                            tipoMsg = "erro";
                            conn.rollback();
                        } else {
                            // Verificar saldo da carteira do cliente
                            stmt = conn.prepareStatement("SELECT id, saldo FROM carteiras WHERE id_utilizador = ?");
                            stmt.setInt(1, idUtilizador);
                            rs = stmt.executeQuery();
                            
                            if (rs.next()) {
                                int idCarteiraCliente = rs.getInt("id");
                                double saldoCliente = rs.getDouble("saldo");
                                rs.close(); stmt.close();
                                
                                if (saldoCliente < valorTotal) {
                                    mensagem = "Saldo insuficiente. Saldo actual: " + String.format("%.2f", saldoCliente) + " €. Valor da encomenda: " + String.format("%.2f", valorTotal) + " €.";
                                    tipoMsg = "erro";
                                    conn.rollback();
                                } else {
                                    // Obter carteira da loja
                                    stmt = conn.prepareStatement("SELECT id FROM carteiras WHERE tipo = 'loja' LIMIT 1");
                                    rs = stmt.executeQuery();
                                    int idCarteiraLoja = 0;
                                    if (rs.next()) idCarteiraLoja = rs.getInt("id");
                                    rs.close(); stmt.close();
                                    
                                    // Gerar identificador único para a encomenda
                                    String idUnico = "ENC-" + java.lang.System.currentTimeMillis();
                                    
                                    // Criar a encomenda
                                    stmt = conn.prepareStatement(
                                        "INSERT INTO encomendas (identificador_unico, id_cliente, valor_total, morada_entrega) VALUES (?, ?, ?, ?)",
                                        Statement.RETURN_GENERATED_KEYS
                                    );
                                    stmt.setString(1, idUnico);
                                    stmt.setInt(2, idUtilizador);
                                    stmt.setDouble(3, valorTotal);
                                    stmt.setString(4, moradaEntrega);
                                    stmt.executeUpdate();
                                    
                                    rs = stmt.getGeneratedKeys();
                                    int idEncomenda = 0;
                                    if (rs.next()) idEncomenda = rs.getInt(1);
                                    rs.close(); stmt.close();
                                    
                                    // Inserir linhas da encomenda
                                    for (int i = 0; i < produtosIds.length; i++) {
                                        if (qtds[i] <= 0) continue;
                                        stmt = conn.prepareStatement(
                                            "INSERT INTO linhas_encomenda (id_encomenda, id_produto, quantidade, preco_unitario) VALUES (?, ?, ?, ?)"
                                        );
                                        stmt.setInt(1, idEncomenda);
                                        stmt.setInt(2, Integer.parseInt(produtosIds[i]));
                                        stmt.setInt(3, qtds[i]);
                                        stmt.setDouble(4, precos[i]);
                                        stmt.executeUpdate();
                                        stmt.close();
                                    }
                                    
                                    // Transferir saldo: debitar cliente, creditar loja
                                    stmt = conn.prepareStatement("UPDATE carteiras SET saldo = saldo - ? WHERE id = ?");
                                    stmt.setDouble(1, valorTotal);
                                    stmt.setInt(2, idCarteiraCliente);
                                    stmt.executeUpdate(); stmt.close();
                                    
                                    stmt = conn.prepareStatement("UPDATE carteiras SET saldo = saldo + ? WHERE id = ?");
                                    stmt.setDouble(1, valorTotal);
                                    stmt.setInt(2, idCarteiraLoja);
                                    stmt.executeUpdate(); stmt.close();
                                    
                                    // Registar na auditoria
                                    stmt = conn.prepareStatement(
                                        "INSERT INTO auditoria_carteira (id_carteira_origem, id_carteira_destino, valor, tipo_operacao, descricao) VALUES (?, ?, ?, 'pagamento', ?)"
                                    );
                                    stmt.setInt(1, idCarteiraCliente);
                                    stmt.setInt(2, idCarteiraLoja);
                                    stmt.setDouble(3, valorTotal);
                                    stmt.setString(4, "Pagamento da encomenda " + idUnico + " pelo cliente " + session.getAttribute("username"));
                                    stmt.executeUpdate(); stmt.close();
                                    
                                    conn.commit();
                                    response.sendRedirect("cliente_encomendas.jsp?msg=criada");
                                    return;
                                }
                            }
                        }
                    } catch (Exception e) {
                        try { conn.rollback(); } catch (Exception ex) {}
                        mensagem = "Erro ao criar encomenda: " + e.getMessage();
                        tipoMsg = "erro";
                    } finally {
                        desligarBaseDados(conn, stmt, rs);
                    }
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %>
            <div class="msg-<%= tipoMsg %>"><%= mensagem %></div>
        <% } %>

        <%
            // Mostrar saldo disponível
            Connection connSaldo = null;
            PreparedStatement stmtSaldo = null;
            ResultSet rsSaldo = null;
            try {
                connSaldo = ligarBaseDados();
                stmtSaldo = connSaldo.prepareStatement("SELECT saldo FROM carteiras WHERE id_utilizador = ?");
                stmtSaldo.setInt(1, idUtilizador);
                rsSaldo = stmtSaldo.executeQuery();
                if (rsSaldo.next()) {
        %>
        <div class="msg-info">Saldo disponível na carteira: <strong><%= String.format("%.2f", rsSaldo.getDouble("saldo")) %> €</strong></div>
        <%
                }
            } catch (Exception e) {} finally {
                desligarBaseDados(connSaldo, stmtSaldo, rsSaldo);
            }
        %>

        <form method="post" action="nova_encomenda.jsp">
            <h3>Seleccionar Produtos</h3>
            <%
                Connection connP = null;
                PreparedStatement stmtP = null;
                ResultSet rsP = null;
                try {
                    connP = ligarBaseDados();
                    stmtP = connP.prepareStatement("SELECT * FROM produtos WHERE estado = 'ativo' AND stock > 0 ORDER BY nome");
                    rsP = stmtP.executeQuery();
            %>
            <table>
                <tr><th>Produto</th><th>Preço</th><th>Stock</th><th>Quantidade</th></tr>
                <%
                    while (rsP.next()) {
                        int preselecao = 0;
                        if (request.getParameter("produto") != null && Integer.parseInt(request.getParameter("produto")) == rsP.getInt("id")) {
                            preselecao = 1;
                        }
                %>
                <tr>
                    <td><%= rsP.getString("nome") %></td>
                    <td><%= String.format("%.2f", rsP.getDouble("preco")) %> €</td>
                    <td><%= rsP.getInt("stock") %></td>
                    <td>
                        <input type="hidden" name="produto_id" value="<%= rsP.getInt("id") %>">
                        <input type="number" name="quantidade" value="<%= preselecao %>" min="0" max="<%= rsP.getInt("stock") %>" style="width:70px;">
                    </td>
                </tr>
                <%
                    }
                %>
            </table>
            <%
                } catch (Exception e) {
                    out.println("<div class='msg-erro'>Erro ao carregar produtos: " + e.getMessage() + "</div>");
                } finally {
                    desligarBaseDados(connP, stmtP, rsP);
                }
            %>

            <div class="form-grupo" style="margin-top:15px;">
                <label for="morada_entrega">Morada de Entrega:</label>
                <textarea id="morada_entrega" name="morada_entrega"></textarea>
            </div>
            <button type="submit" class="btn btn-verde">Confirmar Encomenda</button>
            <a href="cliente_encomendas.jsp" class="btn btn-cinza">Cancelar</a>
        </form>
    </div>
</div>

<%@ include file="footer.jsp" %>
