<%-- 
    Ficheiro: editar_encomenda.jsp
    Descrição: Permite editar uma encomenda com estado 'pendente'. Actualiza os produtos,
    quantidades e morada de entrega. Recalcula o valor total e ajusta o saldo das carteiras.
    Acessível a clientes (apenas as suas), funcionários e administradores.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%
    String _perfil = (String) session.getAttribute("perfil");
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
                mensagem = "Encomenda inválida.";
                tipoMsg = "erro";
            }
            
            if ("POST".equals(request.getMethod()) && idEncomenda > 0) {
                String[] produtosIds = request.getParameterValues("produto_id");
                String[] quantidades = request.getParameterValues("quantidade");
                String moradaEntrega = sanitize(request.getParameter("morada_entrega"));
                
                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;
                try {
                    conn = ligarBaseDados();
                    conn.setAutoCommit(false);
                    
                    // Verificar que a encomenda é 'pendente' e pertence ao utilizador (se cliente)
                    String sqlCheck;
                    if ("cliente".equals(_perfil)) {
                        sqlCheck = "SELECT * FROM encomendas WHERE id=? AND id_cliente=? AND estado='pendente'";
                        stmt = conn.prepareStatement(sqlCheck);
                        stmt.setInt(1, idEncomenda);
                        stmt.setInt(2, (Integer) session.getAttribute("id_utilizador"));
                    } else {
                        sqlCheck = "SELECT * FROM encomendas WHERE id=? AND estado='pendente'";
                        stmt = conn.prepareStatement(sqlCheck);
                        stmt.setInt(1, idEncomenda);
                    }
                    rs = stmt.executeQuery();
                    
                    if (rs.next()) {
                        double valorAntigo = rs.getDouble("valor_total");
                        int idCliente = rs.getInt("id_cliente");
                        rs.close(); stmt.close();
                        
                        // Calcular novo valor total
                        double novoValor = 0;
                        double[] precos = new double[produtosIds.length];
                        int[] qtds = new int[produtosIds.length];
                        for (int i = 0; i < produtosIds.length; i++) {
                            qtds[i] = Integer.parseInt(quantidades[i]);
                            if (qtds[i] <= 0) continue;
                            stmt = conn.prepareStatement("SELECT preco FROM produtos WHERE id=?");
                            stmt.setInt(1, Integer.parseInt(produtosIds[i]));
                            rs = stmt.executeQuery();
                            if (rs.next()) {
                                precos[i] = rs.getDouble("preco");
                                novoValor += precos[i] * qtds[i];
                            }
                            rs.close(); stmt.close();
                        }
                        
                        // Verificar saldo do cliente para diferença
                        stmt = conn.prepareStatement("SELECT id, saldo FROM carteiras WHERE id_utilizador=?");
                        stmt.setInt(1, idCliente);
                        rs = stmt.executeQuery();
                        int idCarteiraCliente = 0;
                        double saldoCliente = 0;
                        if (rs.next()) {
                            idCarteiraCliente = rs.getInt("id");
                            saldoCliente = rs.getDouble("saldo");
                        }
                        rs.close(); stmt.close();
                        
                        double diferenca = novoValor - valorAntigo;
                        if (diferenca > 0 && saldoCliente < diferenca) {
                            mensagem = "Saldo insuficiente para actualizar a encomenda.";
                            tipoMsg = "erro";
                            conn.rollback();
                        } else {
                            // Obter carteira da loja
                            stmt = conn.prepareStatement("SELECT id FROM carteiras WHERE tipo='loja' LIMIT 1");
                            rs = stmt.executeQuery();
                            int idCarteiraLoja = 0;
                            if (rs.next()) idCarteiraLoja = rs.getInt("id");
                            rs.close(); stmt.close();
                            
                            // Apagar linhas antigas e inserir novas
                            stmt = conn.prepareStatement("DELETE FROM linhas_encomenda WHERE id_encomenda=?");
                            stmt.setInt(1, idEncomenda);
                            stmt.executeUpdate(); stmt.close();
                            
                            for (int i = 0; i < produtosIds.length; i++) {
                                if (qtds[i] <= 0) continue;
                                stmt = conn.prepareStatement("INSERT INTO linhas_encomenda (id_encomenda, id_produto, quantidade, preco_unitario) VALUES (?,?,?,?)");
                                stmt.setInt(1, idEncomenda);
                                stmt.setInt(2, Integer.parseInt(produtosIds[i]));
                                stmt.setInt(3, qtds[i]);
                                stmt.setDouble(4, precos[i]);
                                stmt.executeUpdate(); stmt.close();
                            }
                            
                            // Actualizar encomenda
                            stmt = conn.prepareStatement("UPDATE encomendas SET valor_total=?, morada_entrega=? WHERE id=?");
                            stmt.setDouble(1, novoValor);
                            stmt.setString(2, moradaEntrega);
                            stmt.setInt(3, idEncomenda);
                            stmt.executeUpdate(); stmt.close();
                            
                            // Ajustar saldos das carteiras
                            if (diferenca != 0) {
                                stmt = conn.prepareStatement("UPDATE carteiras SET saldo = saldo - ? WHERE id=?");
                                stmt.setDouble(1, diferenca);
                                stmt.setInt(2, idCarteiraCliente);
                                stmt.executeUpdate(); stmt.close();
                                
                                stmt = conn.prepareStatement("UPDATE carteiras SET saldo = saldo + ? WHERE id=?");
                                stmt.setDouble(1, diferenca);
                                stmt.setInt(2, idCarteiraLoja);
                                stmt.executeUpdate(); stmt.close();
                                
                                // Registar auditoria
                                stmt = conn.prepareStatement("INSERT INTO auditoria_carteira (id_carteira_origem, id_carteira_destino, valor, tipo_operacao, descricao) VALUES (?,?,?,?,?)");
                                if (diferenca > 0) {
                                    stmt.setInt(1, idCarteiraCliente);
                                    stmt.setInt(2, idCarteiraLoja);
                                    stmt.setDouble(3, diferenca);
                                    stmt.setString(4, "pagamento");
                                    stmt.setString(5, "Ajuste de encomenda ID " + idEncomenda + " (acréscimo)");
                                } else {
                                    stmt.setInt(1, idCarteiraLoja);
                                    stmt.setInt(2, idCarteiraCliente);
                                    stmt.setDouble(3, Math.abs(diferenca));
                                    stmt.setString(4, "reembolso");
                                    stmt.setString(5, "Ajuste de encomenda ID " + idEncomenda + " (redução)");
                                }
                                stmt.executeUpdate(); stmt.close();
                            }
                            
                            conn.commit();
                            String redirect = "cliente".equals(_perfil) ? "cliente_encomendas.jsp" : ("funcionario".equals(_perfil) ? "func_encomendas.jsp" : "admin_encomendas.jsp");
                            response.sendRedirect(redirect);
                            return;
                        }
                    } else {
                        mensagem = "Encomenda não encontrada ou não editável.";
                        tipoMsg = "erro";
                        conn.rollback();
                    }
                } catch (Exception e) {
                    try { conn.rollback(); } catch (Exception ex) {}
                    mensagem = "Erro ao editar encomenda: " + e.getMessage();
                    tipoMsg = "erro";
                } finally {
                    desligarBaseDados(conn, stmt, rs);
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %>
            <div class="msg-<%= tipoMsg %>"><%= mensagem %></div>
        <% } %>

        <%
            if (idEncomenda > 0) {
                Connection connE = null;
                PreparedStatement stmtE = null;
                ResultSet rsE = null;
                try {
                    connE = ligarBaseDados();
                    stmtE = connE.prepareStatement("SELECT * FROM encomendas WHERE id=?");
                    stmtE.setInt(1, idEncomenda);
                    rsE = stmtE.executeQuery();
                    if (rsE.next()) {
                        String moradaAtual = rsE.getString("morada_entrega");
        %>
        <form method="post" action="editar_encomenda.jsp?id=<%= idEncomenda %>">
            <h3>Produtos</h3>
            <%
                rsE.close(); stmtE.close();
                // Carregar quantidades actuais
                java.util.Map<Integer, Integer> qtdsActuais = new java.util.HashMap<>();
                stmtE = connE.prepareStatement("SELECT id_produto, quantidade FROM linhas_encomenda WHERE id_encomenda=?");
                stmtE.setInt(1, idEncomenda);
                rsE = stmtE.executeQuery();
                while (rsE.next()) {
                    qtdsActuais.put(rsE.getInt("id_produto"), rsE.getInt("quantidade"));
                }
                rsE.close(); stmtE.close();
                
                stmtE = connE.prepareStatement("SELECT * FROM produtos WHERE estado='ativo' ORDER BY nome");
                rsE = stmtE.executeQuery();
            %>
            <table>
                <tr><th>Produto</th><th>Preço</th><th>Quantidade</th></tr>
                <% while (rsE.next()) {
                    int qtdActual = qtdsActuais.getOrDefault(rsE.getInt("id"), 0);
                %>
                <tr>
                    <td><%= rsE.getString("nome") %></td>
                    <td><%= String.format("%.2f", rsE.getDouble("preco")) %> €</td>
                    <td>
                        <input type="hidden" name="produto_id" value="<%= rsE.getInt("id") %>">
                        <input type="number" name="quantidade" value="<%= qtdActual %>" min="0" style="width:70px;">
                    </td>
                </tr>
                <% } %>
            </table>
            <div class="form-grupo" style="margin-top:15px;">
                <label for="morada_entrega">Morada de Entrega:</label>
                <textarea id="morada_entrega" name="morada_entrega"><%= moradaAtual != null ? moradaAtual : "" %></textarea>
            </div>
            <button type="submit" class="btn btn-verde">Guardar Alterações</button>
            <a href="<%= "cliente".equals(_perfil) ? "cliente_encomendas.jsp" : ("funcionario".equals(_perfil) ? "func_encomendas.jsp" : "admin_encomendas.jsp") %>" class="btn btn-cinza">Cancelar</a>
        </form>
        <%
                    }
                } catch (Exception e) {
                    out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
                } finally {
                    desligarBaseDados(connE, stmtE, rsE);
                }
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
