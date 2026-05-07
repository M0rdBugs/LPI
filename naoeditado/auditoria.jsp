<%--
    Ficheiro: auditoria.jsp
    Descricao: Registo de auditoria de todas as operacoes da carteira.
    Permite consultar, filtrar por tipo de operacao, pesquisar por descricao
    e ordenar por data ou valor. Acessivel a administradores e funcionarios.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_funcionario.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Registo de Auditoria</h2>

        <!-- Filtros -->
        <form method="get" action="auditoria.jsp" style="display:flex; flex-wrap:wrap; gap:10px; margin-bottom:15px; align-items:flex-end;">
            <div class="form-grupo" style="margin:0;">
                <label>Tipo de Operacao:</label>
                <select name="tipo">
                    <option value="">Todos</option>
                    <option value="deposito" <%= "deposito".equals(request.getParameter("tipo")) ? "selected" : "" %>>Deposito</option>
                    <option value="levantamento" <%= "levantamento".equals(request.getParameter("tipo")) ? "selected" : "" %>>Levantamento</option>
                    <option value="pagamento" <%= "pagamento".equals(request.getParameter("tipo")) ? "selected" : "" %>>Pagamento</option>
                    <option value="reembolso" <%= "reembolso".equals(request.getParameter("tipo")) ? "selected" : "" %>>Reembolso</option>
                </select>
            </div>
            <div class="form-grupo" style="margin:0;">
                <label>Pesquisar (descricao):</label>
                <input type="text" name="pesquisa" value="<%= request.getParameter("pesquisa") != null ? request.getParameter("pesquisa") : "" %>" style="width:200px;">
            </div>
            <div class="form-grupo" style="margin:0;">
                <label>Ordenar por:</label>
                <select name="ordem">
                    <option value="data_desc" <%= "data_desc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Data (Recente)</option>
                    <option value="data_asc" <%= "data_asc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Data (Antiga)</option>
                    <option value="valor_desc" <%= "valor_desc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Valor (Maior)</option>
                    <option value="valor_asc" <%= "valor_asc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Valor (Menor)</option>
                </select>
            </div>
            <button type="submit" class="btn btn-azul">Filtrar</button>
            <a href="auditoria.jsp" class="btn btn-cinza">Limpar</a>
        </form>

        <%
            Connection conn = null; PreparedStatement stmt = null; ResultSet rs = null;
            try {
                conn = ligarBaseDados();

                String tipo = request.getParameter("tipo") != null ? request.getParameter("tipo").trim() : "";
                String pesquisa = request.getParameter("pesquisa") != null ? request.getParameter("pesquisa").trim() : "";
                String ordem = request.getParameter("ordem") != null ? request.getParameter("ordem") : "data_desc";

                String orderBy = "a.data_operacao DESC";
                if ("data_asc".equals(ordem)) orderBy = "a.data_operacao ASC";
                else if ("valor_desc".equals(ordem)) orderBy = "a.valor DESC";
                else if ("valor_asc".equals(ordem)) orderBy = "a.valor ASC";

                String sql = "SELECT a.*, " +
                    "co.id_utilizador as id_orig, co.tipo as tipo_orig, " +
                    "cd.id_utilizador as id_dest, cd.tipo as tipo_dest " +
                    "FROM auditoria_carteira a " +
                    "LEFT JOIN carteiras co ON a.id_carteira_origem = co.id " +
                    "LEFT JOIN carteiras cd ON a.id_carteira_destino = cd.id " +
                    "WHERE (? = '' OR a.tipo_operacao = ?) " +
                    "AND (? = '' OR a.descricao LIKE ?) " +
                    "ORDER BY " + orderBy;

                stmt = conn.prepareStatement(sql);
                stmt.setString(1, tipo); stmt.setString(2, tipo);
                stmt.setString(3, pesquisa); stmt.setString(4, "%" + pesquisa + "%");
                rs = stmt.executeQuery();
        %>
        <table>
            <tr>
                <th>Data/Hora</th>
                <th>Tipo</th>
                <th>Valor</th>
                <th>Carteira Origem</th>
                <th>Carteira Destino</th>
                <th>Descricao</th>
            </tr>
            <%
                boolean tem = false;
                while (rs.next()) {
                    tem = true;
                    String tipoOrig = rs.getString("tipo_orig");
                    String tipoDest = rs.getString("tipo_dest");
            %>
            <tr>
                <td><%= rs.getString("data_operacao") %></td>
                <td>
                    <% String tipoOp = rs.getString("tipo_operacao"); %>
                    <% if ("deposito".equals(tipoOp)) { %><span style="color:#27ae60;">Deposito</span>
                    <% } else if ("levantamento".equals(tipoOp)) { %><span style="color:#e74c3c;">Levantamento</span>
                    <% } else if ("pagamento".equals(tipoOp)) { %><span style="color:#2980b9;">Pagamento</span>
                    <% } else { %><span style="color:#e67e22;">Reembolso</span><% } %>
                </td>
                <td><strong><%= String.format("%.2f", rs.getDouble("valor")) %> &euro;</strong></td>
                <td><%= tipoOrig != null ? ("loja".equals(tipoOrig) ? "FelixUberShop" : "Cliente ID " + rs.getInt("id_orig")) : "-" %></td>
                <td><%= tipoDest != null ? ("loja".equals(tipoDest) ? "FelixUberShop" : "Cliente ID " + rs.getInt("id_dest")) : "-" %></td>
                <td><%= rs.getString("descricao") != null ? rs.getString("descricao") : "-" %></td>
            </tr>
            <%
                }
                if (!tem) {
            %>
            <tr><td colspan="6" style="text-align:center;">Sem registos de auditoria.</td></tr>
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