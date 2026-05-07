<%-- 
    Ficheiro: detalhe_encomenda.jsp
    Descrição: Apresenta o detalhe completo de uma encomenda, incluindo os produtos,
    quantidades, preços e o identificador único. Acessível a clientes (apenas as suas
    encomendas), funcionários e administradores.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
    // Verificar sessão: cliente, funcionário ou admin
    String _perfil = (String) session.getAttribute("perfil");
    if (_perfil == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Detalhe da Encomenda</h2>

        <%
            int idEncomenda = 0;
            try {
                idEncomenda = Integer.parseInt(request.getParameter("id"));
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Encomenda inválida.</div>");
            }
            
            if (idEncomenda > 0) {
                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;
                try {
                    conn = ligarBaseDados();
                    
                    // Carregar encomenda (para clientes, verificar que é a sua)
                    String sqlEnc;
                    if ("cliente".equals(_perfil)) {
                        sqlEnc = "SELECT e.*, u.nome as nome_cliente FROM encomendas e JOIN utilizadores u ON e.id_cliente=u.id WHERE e.id=? AND e.id_cliente=?";
                        stmt = conn.prepareStatement(sqlEnc);
                        stmt.setInt(1, idEncomenda);
                        stmt.setInt(2, (Integer) session.getAttribute("id_utilizador"));
                    } else {
                        sqlEnc = "SELECT e.*, u.nome as nome_cliente FROM encomendas e JOIN utilizadores u ON e.id_cliente=u.id WHERE e.id=?";
                        stmt = conn.prepareStatement(sqlEnc);
                        stmt.setInt(1, idEncomenda);
                    }
                    rs = stmt.executeQuery();
                    
                    if (rs.next()) {
        %>
        <table>
            <tr><th colspan="2">Informações da Encomenda</th></tr>
            <tr><td><strong>Identificador Único</strong></td><td><%= rs.getString("identificador_unico") %></td></tr>
            <tr><td><strong>Cliente</strong></td><td><%= rs.getString("nome_cliente") %></td></tr>
            <tr><td><strong>Data</strong></td><td><%= rs.getString("data_encomenda") %></td></tr>
            <tr><td><strong>Valor Total</strong></td><td><%= String.format("%.2f", rs.getDouble("valor_total")) %> €</td></tr>
            <tr><td><strong>Estado</strong></td><td><%= rs.getString("estado") %></td></tr>
            <tr><td><strong>Morada de Entrega</strong></td><td><%= rs.getString("morada_entrega") != null ? rs.getString("morada_entrega") : "-" %></td></tr>
        </table>
        <br>
        <h3>Produtos da Encomenda</h3>
        <%
                        int idEncAtual = rs.getInt("id");
                        rs.close(); stmt.close();
                        
                        stmt = conn.prepareStatement(
                            "SELECT le.*, p.nome FROM linhas_encomenda le JOIN produtos p ON le.id_produto=p.id WHERE le.id_encomenda=?"
                        );
                        stmt.setInt(1, idEncAtual);
                        rs = stmt.executeQuery();
        %>
        <table>
            <tr><th>Produto</th><th>Quantidade</th><th>Preço Unit.</th><th>Subtotal</th></tr>
            <%
                while (rs.next()) {
                    double subtotal = rs.getInt("quantidade") * rs.getDouble("preco_unitario");
            %>
            <tr>
                <td><%= rs.getString("nome") %></td>
                <td><%= rs.getInt("quantidade") %></td>
                <td><%= String.format("%.2f", rs.getDouble("preco_unitario")) %> €</td>
                <td><%= String.format("%.2f", subtotal) %> €</td>
            </tr>
            <% } %>
        </table>
        <%
                    } else {
                        out.println("<div class='msg-erro'>Encomenda não encontrada ou sem permissão de acesso.</div>");
                    }
                } catch (Exception e) {
                    out.println("<div class='msg-erro'>Erro ao carregar encomenda: " + e.getMessage() + "</div>");
                } finally {
                    desligarBaseDados(conn, stmt, rs);
                }
            }
        %>
        <br>
        <% if ("cliente".equals(_perfil)) { %>
            <a href="cliente_encomendas.jsp" class="btn btn-cinza">Voltar</a>
        <% } else if ("funcionario".equals(_perfil)) { %>
            <a href="func_encomendas.jsp" class="btn btn-cinza">Voltar</a>
        <% } else { %>
            <a href="admin_encomendas.jsp" class="btn btn-cinza">Voltar</a>
        <% } %>
    </div>
</div>

<%@ include file="footer.jsp" %>
