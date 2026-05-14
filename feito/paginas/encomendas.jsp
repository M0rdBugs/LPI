<%-- 
    Lista as encomendas do cliente autenticado com JOIN ao produto
    Mostra codigo unico, nome do produto, quantidade, valor, data e estado
    Permite editar e cancelar encomendas com estado 'ativo'
    Tabelas usadas: encomenda, produto
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
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
        <h2>As Minhas Encomendas</h2>

        <%
            String msg = request.getParameter("msg");
            if ("criada".equals(msg)) {
        %>
            <div class="msg-sucesso">Encomenda criada com sucesso!</div>
        <%
            } else if ("cancelada".equals(msg)) {
        %>
            <div class="msg-info">Encomenda cancelada com reembolso.</div>
        <%
            } else if ("editada".equals(msg)) {
        %>
            <div class="msg-sucesso">Encomenda actualizada com sucesso.</div>
        <%
            }
        %>

        <div style="margin-bottom:15px;">
            <a href="nova_encomenda.jsp" class="btn btn-verde">Nova Encomenda</a>
        </div>

        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            try {
                conn = connectBD();
                String sql = "SELECT e.*, p.nome AS produto_nome, p.preco " +
                             "FROM encomenda e " +
                             "JOIN produto p ON e.produto_id = p.id " +
                             "WHERE e.utilizador_id = ? " +
                             "ORDER BY e.data DESC";
                stmt = conn.prepareStatement(sql);
                stmt.setInt(1, _idUtil);
                rs = stmt.executeQuery();
        %>
        <table>
            <tr>
                <th>Codigo Unico</th>
                <th>Produto</th>
                <th>Qtd</th>
                <th>Valor</th>
                <th>Data</th>
                <th>Estado</th>
                <th>Acoes</th>
            </tr>
            <%
                boolean tem = false;
                while (rs.next()) {
                    tem = true;
                    String estado = rs.getString("estado");
            %>
            <tr>
                <td><strong><%= rs.getString("codigo_unico") %></strong></td>
                <td><%= rs.getString("produto_nome") %></td>
                <td><%= rs.getInt("quantidade") %></td>
                <td><%= String.format("%.2f", rs.getDouble("valor_total")) %> EUR</td>
                <td><%= rs.getString("data") %></td>
                <td><%= estado %></td>
                <td>
                    <% if ("ativo".equals(estado)) { %>
                        <a href="editar_encomenda.jsp?id=<%= rs.getInt("id") %>" class="btn btn-azul">Editar</a>
                        <a href="cancelar_encomenda.jsp?id=<%= rs.getInt("id") %>" class="btn btn-vermelho" onclick="return confirm('Cancelar esta encomenda? O valor sera reembolsado.')">Cancelar</a>
                    <% } else { %>
                        -
                    <% } %>
                </td>
            </tr>
            <% } %>
            <% if (!tem) { %>
            <tr><td colspan="7" style="text-align:center;">Nao tem encomendas.</td></tr>
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
