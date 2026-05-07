<%-- 
    Ficheiro: func_encomendas.jsp
    Descrição: Gestão de encomendas pelo funcionário. Lista todas as encomendas de todos
    os clientes, com opção de ver detalhe, editar, cancelar ou criar nova encomenda
    para qualquer cliente.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_funcionario.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Gestão de Encomendas</h2>

        <a href="nova_encomenda_func.jsp" class="btn btn-verde" style="margin-bottom:15px; display:inline-block;">+ Nova Encomenda para Cliente</a>

        <%
            Connection conn = null; PreparedStatement stmt = null; ResultSet rs = null;
            try {
                conn = ligarBaseDados();
                stmt = conn.prepareStatement(
                    "SELECT e.*, u.nome as nome_cliente FROM encomendas e JOIN utilizadores u ON e.id_cliente=u.id ORDER BY e.data_encomenda DESC"
                );
                rs = stmt.executeQuery();
        %>
        <table>
            <tr><th>Identificador</th><th>Cliente</th><th>Data</th><th>Valor</th><th>Estado</th><th>Ações</th></tr>
            <%
                boolean tem = false;
                while (rs.next()) {
                    tem = true;
                    String estado = rs.getString("estado");
            %>
            <tr>
                <td><%= rs.getString("identificador_unico") %></td>
                <td><%= rs.getString("nome_cliente") %></td>
                <td><%= rs.getString("data_encomenda") %></td>
                <td><%= String.format("%.2f", rs.getDouble("valor_total")) %> €</td>
                <td><%= estado %></td>
                <td>
                    <a href="detalhe_encomenda.jsp?id=<%= rs.getInt("id") %>" class="btn btn-azul">Ver</a>
                    <% if ("pendente".equals(estado)) { %>
                        <a href="editar_encomenda.jsp?id=<%= rs.getInt("id") %>" class="btn btn-cinza">Editar</a>
                        <a href="cancelar_encomenda.jsp?id=<%= rs.getInt("id") %>" class="btn btn-vermelho" onclick="return confirm('Cancelar esta encomenda?')">Cancelar</a>
                    <% } %>
                </td>
            </tr>
            <%
                }
                if (!tem) {
            %>
            <tr><td colspan="6" style="text-align:center;">Sem encomendas.</td></tr>
            <% } %>
        </table>
        <%
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
            } finally {
                desligarBaseDados(conn, stmt, rs);
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
