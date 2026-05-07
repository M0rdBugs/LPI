<%-- 
    Ficheiro: admin_promocoes.jsp
    Descrição: Gestão de informações e promoções dinâmicas pelo administrador.
    Permite criar, editar, inactivar/activar e consultar promoções.
    As promoções activas são apresentadas na página inicial.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessao_admin.jsp" %>
<%@ include file="../basedados/basedados.h" %>
<%@ include file="util.jsp" %>
<%@ include file="header.jsp" %>

<div class="container">
    <div class="card">
        <h2>Gestão de Informações e Promoções</h2>

        <%
            String mensagem = "";
            String tipoMsg = "";
            String acao = request.getParameter("acao") != null ? request.getParameter("acao") : "";
            
            if ("POST".equals(request.getMethod())) {
                String titulo = sanitize(request.getParameter("titulo"));
                String descricao = sanitize(request.getParameter("descricao"));
                String dataInicio = sanitize(request.getParameter("data_inicio"));
                String dataFim = sanitize(request.getParameter("data_fim"));
                String idEditStr = sanitize(request.getParameter("id_edit"));
                
                Connection conn = null; PreparedStatement stmt = null;
                try {
                    conn = ligarBaseDados();
                    if ("criar".equals(acao)) {
                        stmt = conn.prepareStatement("INSERT INTO promocoes (titulo, descricao, data_inicio, data_fim) VALUES (?,?,?,?)");
                        stmt.setString(1, titulo); stmt.setString(2, descricao);
                        stmt.setString(3, dataInicio.isEmpty() ? null : dataInicio);
                        stmt.setString(4, dataFim.isEmpty() ? null : dataFim);
                        stmt.executeUpdate();
                        mensagem = "Promoção criada com sucesso."; tipoMsg = "sucesso";
                    } else if ("editar".equals(acao) && idEditStr != null) {
                        int idEdit = Integer.parseInt(idEditStr);
                        stmt = conn.prepareStatement("UPDATE promocoes SET titulo=?, descricao=?, data_inicio=?, data_fim=? WHERE id=?");
                        stmt.setString(1, titulo); stmt.setString(2, descricao);
                        stmt.setString(3, dataInicio.isEmpty() ? null : dataInicio);
                        stmt.setString(4, dataFim.isEmpty() ? null : dataFim);
                        stmt.setInt(5, idEdit);
                        stmt.executeUpdate();
                        mensagem = "Promoção actualizada."; tipoMsg = "sucesso";
                    }
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                } finally {
                    desligarBaseDados(conn, stmt, null);
                }
            } else if ("inativar".equals(acao) || "ativar".equals(acao)) {
                try {
                    int id = Integer.parseInt(request.getParameter("id"));
                    Connection conn = ligarBaseDados();
                    PreparedStatement stmt = conn.prepareStatement("UPDATE promocoes SET estado=? WHERE id=?");
                    stmt.setString(1, "inativar".equals(acao) ? "inativo" : "ativo");
                    stmt.setInt(2, id);
                    stmt.executeUpdate();
                    desligarBaseDados(conn, stmt, null);
                    mensagem = "Estado actualizado."; tipoMsg = "sucesso";
                } catch (Exception e) {
                    mensagem = "Erro: " + e.getMessage(); tipoMsg = "erro";
                }
            }
        %>

        <% if (!mensagem.isEmpty()) { %><div class="msg-<%= tipoMsg %>"><%= mensagem %></div><% } %>

        <!-- Formulário de criação -->
        <details style="margin-bottom:20px;">
            <summary class="btn btn-verde" style="cursor:pointer; display:inline-block; margin-bottom:10px;">+ Criar Nova Promoção</summary>
            <form method="post" action="admin_promocoes.jsp?acao=criar" style="margin-top:10px;">
                <div class="form-grupo"><label>Título *:</label><input type="text" name="titulo" required></div>
                <div class="form-grupo"><label>Descrição *:</label><textarea name="descricao" required></textarea></div>
                <div style="display:grid; grid-template-columns:1fr 1fr; gap:10px;">
                    <div class="form-grupo"><label>Data Início:</label><input type="date" name="data_inicio"></div>
                    <div class="form-grupo"><label>Data Fim:</label><input type="date" name="data_fim"></div>
                </div>
                <button type="submit" class="btn btn-verde">Criar</button>
            </form>
        </details>

        <!-- Listagem -->
        <%
            Connection connL = null; PreparedStatement stmtL = null; ResultSet rsL = null;
            try {
                connL = ligarBaseDados();
                stmtL = connL.prepareStatement("SELECT * FROM promocoes ORDER BY id DESC");
                rsL = stmtL.executeQuery();
        %>
        <table>
            <tr><th>Título</th><th>Descrição</th><th>Início</th><th>Fim</th><th>Estado</th><th>Ações</th></tr>
            <% while (rsL.next()) { %>
            <tr>
                <td><%= rsL.getString("titulo") %></td>
                <td><%= rsL.getString("descricao") %></td>
                <td><%= rsL.getString("data_inicio") != null ? rsL.getString("data_inicio") : "-" %></td>
                <td><%= rsL.getString("data_fim") != null ? rsL.getString("data_fim") : "-" %></td>
                <td><%= rsL.getString("estado") %></td>
                <td>
                    <a href="admin_editar_promocao.jsp?id=<%= rsL.getInt("id") %>" class="btn btn-azul">Editar</a>
                    <% if ("ativo".equals(rsL.getString("estado"))) { %>
                        <a href="admin_promocoes.jsp?acao=inativar&id=<%= rsL.getInt("id") %>" class="btn btn-vermelho">Inactivar</a>
                    <% } else { %>
                        <a href="admin_promocoes.jsp?acao=ativar&id=<%= rsL.getInt("id") %>" class="btn btn-verde">Activar</a>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </table>
        <%
            } catch (Exception e) {
                out.println("<div class='msg-erro'>Erro: " + e.getMessage() + "</div>");
            } finally {
                desligarBaseDados(connL, stmtL, rsL);
            }
        %>
    </div>
</div>

<%@ include file="footer.jsp" %>
