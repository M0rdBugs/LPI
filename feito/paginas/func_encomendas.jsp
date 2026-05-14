<%-- 
    Gestao de encomendas de qualquer cliente pelo funcionario.
    Lista todas as encomendas com JOIN produto 
    Permite editar, cancelar e marcar como entregue
    Tabelas usadas: encomenda, produto
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
    String _perfil = (String) session.getAttribute("tipo_util");
    if (_perfil == null || !_perfil.equals("funcionario")) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Gestao de Encomendas (Funcionario)</h2>

        <%
            /* Marcar como entregue */
            String acao = request.getParameter("acao");
            if ("entregar".equals(acao)) {
                try {
                    int idEnc = Integer.parseInt(request.getParameter("id"));
                    Connection connU = connectBD();
                    PreparedStatement stmtU = connU.prepareStatement(
                        "UPDATE encomenda SET estado = 'entregue' WHERE id = ? AND estado = 'ativo'");
                    stmtU.setInt(1, idEnc);
                    stmtU.executeUpdate();
                    stmtU.close();
                    connU.close();
                } catch (Exception e) {}
            }
        %>

        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            try {
                conn = connectBD();
                String sql = "SELECT e.*, u.nome AS cliente_nome, p.nome AS produto_nome " +
                             "FROM encomenda e " +
                             "JOIN utilizador u ON e.utilizador_id = u.id " +
                             "JOIN produto p ON e.produto_id = p.id " +
                             "ORDER BY e.data DESC";
                stmt = conn.prepareStatement(sql);
                rs = stmt.executeQuery();
        %>
        <table>
            <tr>
                <th>Codigo</th><th>Cliente</th><th>Produto</th><th>Qtd</th><th>Valor</th><th>Data</th><th>Estado</th><th>Acoes</th>
            </tr>
            <%
                boolean tem = false;
                while (rs.next()) {
                    tem = true;
                    String estado = rs.getString("estado");
                    int eid = rs.getInt("id");
            %>
            <tr>
                <td><strong><%= rs.getString("codigo_unico") %></strong></td>
                <td><%= rs.getString("cliente_nome") %></td>
                <td><%= rs.getString("produto_nome") %></td>
                <td><%= rs.getInt("quantidade") %></td>
                <td><%= String.format("%.2f", rs.getDouble("valor_total")) %> EUR</td>
                <td><%= rs.getString("data") %></td>
                <td><%= estado %></td>
                <td>
                    <% if ("ativo".equals(estado)) { %>
                        <a href="editar_encomenda.jsp?id=<%= eid %>" class="btn btn-azul" style="font-size:0.8em;">Editar</a>
                        <a href="cancelar_encomenda.jsp?id=<%= eid %>" class="btn btn-vermelho" style="font-size:0.8em;" onclick="return confirm('Cancelar esta encomenda?')">Cancelar</a>
                        <a href="func_encomendas.jsp?acao=entregar&id=<%= eid %>" class="btn btn-verde" style="font-size:0.8em;">Entregue</a>
                    <% } else { %>
                        -
                    <% } %>
                </td>
            </tr>
            <% } %>
            <% if (!tem) { %>
            <tr><td colspan="8" style="text-align:center;">Nao existem encomendas.</td></tr>
            <% } %>
        </table>
        <%
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (Exception ex) {}
                if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
                if (conn != null) try { conn.close(); } catch (Exception ex) {}
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
