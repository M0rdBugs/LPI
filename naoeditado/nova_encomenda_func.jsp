<%-- 
    Ficheiro: nova_encomenda_func.jsp
    Descrição: Permite ao funcionário ou administrador criar uma encomenda para qualquer
    cliente. Selecciona o cliente, os produtos e a morada de entrega.
    O pagamento é efectuado via carteira do cliente seleccionado.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_funcionario.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Nova Encomenda para Cliente</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            
            if ("POST".equals(request.getMethod())) {
                String idClienteStr = request.getParameter("id_cliente");
                String[] produtosIds = request.getParameterValues("produto_id");
                String[] quantidades = request.getParameterValues("quantidade");
                String moradaEntrega = sanitize(request.getParameter("morada_entrega"));
                
                try {
                    int idCliente = Integer.parseInt(idClienteStr);
                    
                    Connection conn = null; PreparedStatement stmt = null; ResultSet rs = null;
                    try {
                        conn = ligarBaseDados();
                        conn.setAutoCommit(false);
                        
                        double valorTotal = 0;
                        double[] precos = new double[produtosIds.length];
                        int[] qtds = new int[produtosIds.length];
                        
                        for (int i = 0; i < produtosIds.length; i++) {
                            qtds[i] = Integer.parseInt(quantidades[i]);
                            if (qtds[i] <= 0) continue;
                            stmt = conn.prepareStatement("SELECT preco FROM produtos WHERE id=? AND estado='ativo'");
                            stmt.setInt(1, Integer.parseInt(produtosIds[i]));
                            rs = stmt.executeQuery();
                            if (rs.next()) { precos[i] = rs.getDouble("preco"); valorTotal += precos[i] * qtds[i]; }
                            rs.close(); stmt.close();
                        }
                        
                        if (valorTotal <= 0) {
                            mensagem = "Seleccione pelo menos um produto.";
                            tipoMsg = "erro";
                            conn.rollback();
                        } else {
                            stmt = conn.prepareStatement("SELECT id, saldo FROM carteiras WHERE id_utilizador=?");
                            stmt.setInt(1, idCliente);
                            rs = stmt.executeQuery();
                            int idCarteiraCliente = 0; double saldo = 0;
                            if (rs.next()) { idCarteiraCliente = rs.getInt("id"); saldo = rs.getDouble("saldo"); }
                            rs.close(); stmt.close();
                            
                            if (saldo < valorTotal) {
                                mensagem = "Saldo insuficiente do cliente (" + String.format("%.2f", saldo) + " €).";
                                tipoMsg = "erro";
                                conn.rollback();
                            } else {
                                stmt = conn.prepareStatement("SELECT id FROM carteiras WHERE tipo='loja' LIMIT 1");
                                rs = stmt.executeQuery();
                                int idCarteiraLoja = 0;
                                if (rs.next()) idCarteiraLoja = rs.getInt("id");
                                rs.close(); stmt.close();
                                
                                String idUnico = "ENC-" + java.lang.System.currentTimeMillis();
                                stmt = conn.prepareStatement("INSERT INTO encomendas (identificador_unico, id_cliente, valor_total, morada_entrega) VALUES (?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
                                stmt.setString(1, idUnico); stmt.setInt(2, idCliente); stmt.setDouble(3, valorTotal); stmt.setString(4, moradaEntrega);
                                stmt.executeUpdate();
                                rs = stmt.getGeneratedKeys();
                                int idEncomenda = 0;
                                if (rs.next()) idEncomenda = rs.getInt(1);
                                rs.close(); stmt.close();
                                
                                for (int i = 0; i < produtosIds.length; i++) {
                                    if (qtds[i] <= 0) continue;
                                    stmt = conn.prepareStatement("INSERT INTO linhas_encomenda (id_encomenda, id_produto, quantidade, preco_unitario) VALUES (?,?,?,?)");
                                    stmt.setInt(1, idEncomenda); stmt.setInt(2, Integer.parseInt(produtosIds[i])); stmt.setInt(3, qtds[i]); stmt.setDouble(4, precos[i]);
                                    stmt.executeUpdate(); stmt.close();
                                }
                                
                                stmt = conn.prepareStatement("UPDATE carteiras SET saldo = saldo - ? WHERE id=?");
                                stmt.setDouble(1, valorTotal); stmt.setInt(2, idCarteiraCliente); stmt.executeUpdate(); stmt.close();
                                stmt = conn.prepareStatement("UPDATE carteiras SET saldo = saldo + ? WHERE id=?");
                                stmt.setDouble(1, valorTotal); stmt.setInt(2, idCarteiraLoja); stmt.executeUpdate(); stmt.close();
                                
                                stmt = conn.prepareStatement("INSERT INTO auditoria_carteira (id_carteira_origem, id_carteira_destino, valor, tipo_operacao, descricao) VALUES (?,?,?,'pagamento',?)");
                                stmt.setInt(1, idCarteiraCliente); stmt.setInt(2, idCarteiraLoja); stmt.setDouble(3, valorTotal);
                                stmt.setString(4, "Encomenda " + idUnico + " criada pelo funcionário " + session.getAttribute("username"));
                                stmt.executeUpdate(); stmt.close();
                                
                                conn.commit();
                                response.sendRedirect("func_encomendas.jsp");
                                return;
                            }
                        }
                    } catch (Exception e) {
                        try { conn.rollback(); } catch (Exception ex) {}
                        mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                    } finally {
                        desligarBaseDados(conn, stmt, rs);
                    }
                } catch (NumberFormatException e) {
                    mensagem = "Dados inválidos."; tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %><div class="msg-<%= tipoMsg %>"><%= mensagem %></div><% } %>

        <form method="post" action="nova_encomenda_func.jsp">
            <div class="form-grupo">
                <label for="id_cliente">Cliente:</label>
                <select id="id_cliente" name="id_cliente" required>
                    <option value="">-- Seleccionar Cliente --</option>
                    <%
                        Connection connC = null; PreparedStatement stmtC = null; ResultSet rsC = null;
                        try {
                            connC = ligarBaseDados();
                            stmtC = connC.prepareStatement("SELECT u.id, u.nome, c.saldo FROM utilizadores u JOIN carteiras c ON u.id=c.id_utilizador WHERE u.perfil='cliente' AND u.estado='ativo' ORDER BY u.nome");
                            rsC = stmtC.executeQuery();
                            while (rsC.next()) {
                    %>
                    <option value="<%= rsC.getInt("id") %>"><%= rsC.getString("nome") %> (Saldo: <%= String.format("%.2f", rsC.getDouble("saldo")) %> €)</option>
                    <%
                            }
                        } catch (Exception e) {} finally {
                            desligarBaseDados(connC, stmtC, rsC);
                        }
                    %>
                </select>
            </div>

            <h3>Produtos</h3>
            <%
                Connection connP = null; PreparedStatement stmtP = null; ResultSet rsP = null;
                try {
                    connP = ligarBaseDados();
                    stmtP = connP.prepareStatement("SELECT * FROM produtos WHERE estado='ativo' AND stock > 0 ORDER BY nome");
                    rsP = stmtP.executeQuery();
            %>
            <table>
                <tr><th>Produto</th><th>Preço</th><th>Quantidade</th></tr>
                <% while (rsP.next()) { %>
                <tr>
                    <td><%= rsP.getString("nome") %></td>
                    <td><%= String.format("%.2f", rsP.getDouble("preco")) %> €</td>
                    <td>
                        <input type="hidden" name="produto_id" value="<%= rsP.getInt("id") %>">
                        <input type="number" name="quantidade" value="0" min="0" style="width:70px;">
                    </td>
                </tr>
                <% } %>
            </table>
            <%
                } catch (Exception e) {
                    out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
                } finally {
                    desligarBaseDados(connP, stmtP, rsP);
                }
            %>

            <div class="form-grupo" style="margin-top:15px;">
                <label for="morada_entrega">Morada de Entrega:</label>
                <textarea id="morada_entrega" name="morada_entrega"></textarea>
            </div>
            <button type="submit" class="btn btn-verde">Criar Encomenda</button>
            <a href="func_encomendas.jsp" class="btn btn-cinza">Cancelar</a>
        </form>
    </div>
</div>

<%@ include file="footer.jsp" %>
