<%-- 
    Ficheiro: admin_editar_promocao.jsp
    Descrição: Formulário de edição de uma promoção específica pelo administrador.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_admin.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Editar Promoção</h2>

        <%
            int idEdit = 0;
            try { idEdit = Integer.parseInt(request.getParameter("id")); } catch (Exception e) {}
            
            if ("POST".equals(request.getMethod()) && idEdit > 0) {
                String titulo = sanitize(request.getParameter("titulo"));
                String descricao = sanitize(request.getParameter("descricao"));
                String dataInicio = sanitize(request.getParameter("data_inicio"));
                String dataFim = sanitize(request.getParameter("data_fim"));
                
                try {
                    Connection conn = ligarBaseDados();
                    PreparedStatement stmt = conn.prepareStatement("UPDATE promocoes SET titulo=?, descricao=?, data_inicio=?, data_fim=? WHERE id=?");
                    stmt.setString(1, titulo); stmt.setString(2, descricao);
                    stmt.setString(3, dataInicio.isEmpty() ? null : dataInicio);
                    stmt.setString(4, dataFim.isEmpty() ? null : dataFim);
                    stmt.setInt(5, idEdit);
                    stmt.executeUpdate();
                    desligarBaseDados(conn, stmt, null);
                    response.sendRedirect("admin_promocoes.jsp");
                    return;
                } catch (Exception e) {
                    out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
                }
            }
            
            if (idEdit > 0) {
                Connection conn2 = null; PreparedStatement stmt2 = null; ResultSet rs2 = null;
                try {
                    conn2 = ligarBaseDados();
                    stmt2 = conn2.prepareStatement("SELECT * FROM promocoes WHERE id=?");
                    stmt2.setInt(1, idEdit);
                    rs2 = stmt2.executeQuery();
                    if (rs2.next()) {
        %>
        <form method="post" action="admin_editar_promocao.jsp?id=<%= idEdit %>">
            <div class="form-grupo"><label for="titulo">Título *:</label><input type="text" id="titulo" name="titulo" value="<%= rs2.getString("titulo") %>" required></div>
            <div class="form-grupo"><label for="descricao">Descrição *:</label><textarea id="descricao" name="descricao" required><%= rs2.getString("descricao") %></textarea></div>
            <div class="form-grupo"><label for="data_inicio">Data Início:</label><input type="date" id="data_inicio" name="data_inicio" value="<%= rs2.getString("data_inicio") != null ? rs2.getString("data_inicio") : "" %>"></div>
            <div class="form-grupo"><label for="data_fim">Data Fim:</label><input type="date" id="data_fim" name="data_fim" value="<%= rs2.getString("data_fim") != null ? rs2.getString("data_fim") : "" %>"></div>
            <button type="submit" class="btn btn-verde">Guardar</button>
            <a href="admin_promocoes.jsp" class="btn btn-cinza">Cancelar</a>
        </form>
        <%
                    }
                } catch (Exception e) {
                    out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
                } finally {
                    desligarBaseDados(conn2, stmt2, rs2);
                }
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
