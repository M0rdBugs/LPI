<%-- 
    Registo de auditoria de todas as operacoes de carteira
    Permite consultar, filtrar por tipo de operacao, intervalo de datas,
    utilizador e ordenar por data ou valor
    Tabelas usadas: auditoria, utilizador, carteira
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
    String _perfil = (String) session.getAttribute("tipo_util");
    // Funcionarios e administradores podem aceder
    if (_perfil == null || (!_perfil.equals("funcionario") && !_perfil.equals("administrador"))) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Registo de Auditoria</h2>
        
        <!-- Filtros -->
        <form method="get" action="auditoria.jsp" class="filtros">
            <div class="form-grupo">
                <label>Tipo de Operacao:</label>
                <select name="tipo">
                    <option value="" <%= "".equals(request.getParameter("tipo") != null ? request.getParameter("tipo") : "") ? "selected" : "" %>>Todos</option>
                    <option value="deposito" <%= "deposito".equals(request.getParameter("tipo")) ? "selected" : "" %>>Deposito</option>
                    <option value="levantamento" <%= "levantamento".equals(request.getParameter("tipo")) ? "selected" : "" %>>Levantamento</option>
                    <option value="pagamento" <%= "pagamento".equals(request.getParameter("tipo")) ? "selected" : "" %>>Pagamento</option>
                    <option value="reembolso" <%= "reembolso".equals(request.getParameter("tipo")) ? "selected" : "" %>>Reembolso</option>
                </select>
            </div>
            <div class="form-grupo">
                <label>Utilizador:</label>
                <input type="text" name="utilizador" value="<%= request.getParameter("utilizador") != null ? request.getParameter("utilizador") : "" %>">
            </div>
            <div class="form-grupo">
                <label>Data inicio:</label>
                <input type="date" name="data_inicio" value="<%= request.getParameter("data_inicio") != null ? request.getParameter("data_inicio") : "" %>">
            </div>
            <div class="form-grupo">
                <label>Data fim:</label>
                <input type="date" name="data_fim" value="<%= request.getParameter("data_fim") != null ? request.getParameter("data_fim") : "" %>">
            </div>
            <div class="form-grupo">
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
            Connection conn = null;
            PreparedStatement stmt = null;
            ResultSet rs = null;
            try {
                conn = connectBD();

                String tipo = request.getParameter("tipo") != null ? request.getParameter("tipo").trim() : "";
                String utilizador = request.getParameter("utilizador") != null ? request.getParameter("utilizador").trim() : "";
                String dataInicio = request.getParameter("data_inicio") != null ? request.getParameter("data_inicio").trim() : "";
                String dataFim = request.getParameter("data_fim") != null ? request.getParameter("data_fim").trim() : "";
                String ordem = request.getParameter("ordem") != null ? request.getParameter("ordem") : "data_desc";

                String orderBy = "a.data DESC";
                if ("data_asc".equals(ordem)) orderBy = "a.data ASC";
                else if ("valor_desc".equals(ordem)) orderBy = "a.valor DESC";
                else if ("valor_asc".equals(ordem)) orderBy = "a.valor ASC";

                StringBuilder sql = new StringBuilder(
                    "SELECT a.*, u.nome AS nome_utilizador " +
                    "FROM auditoria a " +
                    "JOIN utilizador u ON a.utilizador_id = u.id " +
                    "WHERE 1=1 "
                );
                if (!tipo.isEmpty()) sql.append("AND a.tipo_operacao = ? ");
                if (!utilizador.isEmpty()) sql.append("AND u.nome LIKE ? ");
                if (!dataInicio.isEmpty()) sql.append("AND a.data >= ? ");
                if (!dataFim.isEmpty()) sql.append("AND a.data <= DATE_ADD(?, INTERVAL 1 DAY) ");
                sql.append("ORDER BY ").append(orderBy);

                stmt = conn.prepareStatement(sql.toString());
                int idx = 1;
                if (!tipo.isEmpty()) stmt.setString(idx++, tipo);
                if (!utilizador.isEmpty()) stmt.setString(idx++, "%" + utilizador + "%");
                if (!dataInicio.isEmpty()) stmt.setString(idx++, dataInicio);
                if (!dataFim.isEmpty()) stmt.setString(idx++, dataFim);
                rs = stmt.executeQuery();
        %>
        <table>
            <tr>
                <th>Data/Hora</th><th>Utilizador</th><th>Tipo</th><th>Valor</th><th>Carteira Origem</th><th>Carteira Destino</th><th>Descricao</th>
            </tr>
            <%
                boolean tem = false;
                while (rs.next()) {
                    tem = true;
                    String tipoOp = rs.getString("tipo_operacao");
                    Integer co = (Integer) rs.getObject("carteira_origem");
                    Integer cd = (Integer) rs.getObject("carteira_destino");
            %>
            <tr>
                <td><%= rs.getString("data") %></td>
                <td><%= rs.getString("nome_utilizador") %></td>
                <td>
                    <% if ("deposito".equals(tipoOp)) { %><span style="color:#27ae60;">Deposito</span>
                    <% } else if ("levantamento".equals(tipoOp)) { %><span style="color:#e74c3c;">Levantamento</span>
                    <% } else if ("pagamento".equals(tipoOp)) { %><span style="color:#2980b9;">Pagamento</span>
                    <% } else { %><span style="color:#e67e22;">Reembolso</span><% } %>
                </td>
                <td><strong><%= String.format("%.2f", rs.getDouble("valor")) %> EUR</strong></td>
                <td><%= co != null ? "ID " + co : "-" %></td>
                <td><%= cd != null ? "ID " + cd : "-" %></td>
                <td><%= rs.getString("descricao") != null ? rs.getString("descricao") : "-" %></td>
            </tr>
            <%
                }
                if (!tem) {
            %>
            <tr><td colspan="7" style="text-align:center;">Sem registos de auditoria.</td></tr>
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
