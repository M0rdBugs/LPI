<%-- 
    Ficheiro: cliente_encomendas.jsp
    Descrição: Gestão de encomendas do cliente. Lista todas as encomendas do cliente,
    com opção de ver detalhe, editar (se pendente) ou cancelar.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_cliente.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>As Minhas Encomendas</h2>

        <%
            String mensagem = request.getParameter("msg") != null ? request.getParameter("msg") : "";
            int idUtilizador = (Integer) session.getAttribute("id_utilizador");
        %>

        <% if ("cancelada".equals(mensagem)) { %>
            <div class="msg-sucesso">Encomenda cancelada com sucesso. O saldo foi reembolsado.</div>
        <% } else if ("criada".equals(mensagem)) { %>
            <div class="msg-sucesso">Encomenda criada com sucesso.</div>
        <% } %>

        <a href="nova_encomenda.jsp" class="btn btn-verde" style="margin-bottom:15px; display:inline-block;">+ Nova Encomenda</a>

        <%
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            try {
                conn = ligarBaseDados();
                stmt = conn.prepareStatement(
                    "SELECT * FROM encomendas WHERE id_cliente = ? ORDER BY data_encomenda DESC"
                );
                stmt.setInt(1, idUtilizador);
                rs = stmt.executeQuery();
        %>
        <table>
            <tr>
                <th>Identificador</th>
                <th>Data</th>
                <th>Valor Total</th>
                <th>Estado</th>
                <th>Ações</th>
            </tr>
            <%
                boolean temEncomendas = false;
                while (rs.next()) {
                    temEncomendas = true;
                    String estado = rs.getString("estado");
            %>
            <tr>
                <td><strong><%= rs.getString("identificador_unico") %></strong></td>
                <td><%= rs.getString("data_encomenda") %></td>
                <td><%= String.format("%.2f", rs.getDouble("valor_total")) %> €</td>
                <td>
                    <% if ("pendente".equals(estado)) { %>
                        <span style="color:#e67e22;">Pendente</span>
                    <% } else if ("processamento".equals(estado)) { %>
                        <span style="color:#2980b9;">Em Processamento</span>
                    <% } else if ("concluida".equals(estado)) { %>
                        <span style="color:#27ae60;">Concluída</span>
                    <% } else { %>
                        <span style="color:#c0392b;">Cancelada</span>
                    <% } %>
                </td>
                <td>
                    <a href="detalhe_encomenda.jsp?id=<%= rs.getInt("id") %>" class="btn btn-azul">Ver</a>
                    <% if ("pendente".equals(estado)) { %>
                        <a href="editar_encomenda.jsp?id=<%= rs.getInt("id") %>" class="btn btn-cinza">Editar</a>
                        <a href="cancelar_encomenda.jsp?id=<%= rs.getInt("id") %>" class="btn btn-vermelho" onclick="return confirm('Confirma o cancelamento desta encomenda?')">Cancelar</a>
                    <% } %>
                </td>
            </tr>
            <%
                }
                if (!temEncomendas) {
            %>
            <tr><td colspan="5" style="text-align:center;">Não tem encomendas registadas.</td></tr>
            <%
                }
            %>
        </table>
        <%
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro ao carregar encomendas: " + e.getMessage() + "</div>");
            } finally {
                desligarBaseDados(conn, stmt, rs);
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
