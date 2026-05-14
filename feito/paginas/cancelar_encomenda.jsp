<%-- 
    Cancela uma encomenda com estado 'ativo' e efetua o reembolso do valor para a carteira do cliente 
    Devolve o stock ao produto
    Regista a operacao na auditoria
    O cliente pode ver as próprias encomendas
    O funcionario e administrador podem ver todas as encomendas
    O funcionario apenas pode cancelar, o administrador pode editar, cancelar e marcar como entregue
    Tabelas usadas: encomenda, carteira, produto, auditoria
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
    String _perfil = (String) session.getAttribute("tipo_util");
    Integer _idUtil = (Integer) session.getAttribute("id");
    if (_perfil == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    // Verifica se há encomendas
    int idEncomenda = 0;
    try {
        idEncomenda = Integer.parseInt(request.getParameter("id"));
    } catch (Exception e) {
        response.sendRedirect("index.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement stmt = null;
    ResultSet rs = null;
    try {
        conn = connectBD();
        conn.setAutoCommit(false); /* Inicio da transação */

        /* Verificar a encomenda */
        String sqlCheck;
        if ("cliente".equals(_perfil)) {
            sqlCheck = "SELECT e.*, p.quantidade AS stock FROM encomenda e JOIN produto p ON e.produto_id = p.id WHERE e.id = ? AND e.utilizador_id = ? AND e.estado = 'ativo'";
            stmt = conn.prepareStatement(sqlCheck);
            stmt.setInt(1, idEncomenda);
            stmt.setInt(2, _idUtil);
        } else {
            sqlCheck = "SELECT e.*, p.quantidade AS stock FROM encomenda e JOIN produto p ON e.produto_id = p.id WHERE e.id = ? AND e.estado = 'ativo'";
            stmt = conn.prepareStatement(sqlCheck);
            stmt.setInt(1, idEncomenda);
        }
        rs = stmt.executeQuery();

        if (rs.next()) {
            double valorTotal = rs.getDouble("valor_total");
            int idCliente = rs.getInt("utilizador_id");
            int produtoId = rs.getInt("produto_id");
            int qtd = rs.getInt("quantidade");
            String codigoUnico = rs.getString("codigo_unico");
            rs.close();
            stmt.close();

            /* Obter carteira do cliente */
            stmt = conn.prepareStatement("SELECT id FROM carteira WHERE utilizador_id = ?");
            stmt.setInt(1, idCliente);
            rs = stmt.executeQuery();
            int idCarteiraCliente = 0;
            if (rs.next()) idCarteiraCliente = rs.getInt("id");
            rs.close();
            stmt.close();

            /* Obter carteira da loja */
            stmt = conn.prepareStatement("SELECT id FROM carteira WHERE utilizador_id IS NULL LIMIT 1");
            rs = stmt.executeQuery();
            int idCarteiraLoja = 0;
            if (rs.next()) idCarteiraLoja = rs.getInt("id");
            rs.close();
            stmt.close();

            /* Marcar encomenda como anulada */
            stmt = conn.prepareStatement("UPDATE encomenda SET estado = 'anulada' WHERE id = ?");
            stmt.setInt(1, idEncomenda);
            stmt.executeUpdate();
            stmt.close();

            /* Reembolsar cliente */
            stmt = conn.prepareStatement("UPDATE carteira SET saldo = saldo + ? WHERE id = ?");
            stmt.setDouble(1, valorTotal);
            stmt.setInt(2, idCarteiraCliente);
            stmt.executeUpdate();
            stmt.close();

            /* Debitar loja */
            stmt = conn.prepareStatement("UPDATE carteira SET saldo = saldo - ? WHERE id = ?");
            stmt.setDouble(1, valorTotal);
            stmt.setInt(2, idCarteiraLoja);
            stmt.executeUpdate();
            stmt.close();

            /* Devolver stock */
            stmt = conn.prepareStatement("UPDATE produto SET quantidade = quantidade + ? WHERE id = ?");
            stmt.setInt(1, qtd);
            stmt.setInt(2, produtoId);
            stmt.executeUpdate();
            stmt.close();

            /* Registar auditoria */
            stmt = conn.prepareStatement(
                "INSERT INTO auditoria (utilizador_id, tipo_operacao, valor, descricao, carteira_origem, carteira_destino) VALUES (?, 'reembolso', ?, ?, ?, ?)");
            stmt.setInt(1, _idUtil);
            stmt.setDouble(2, valorTotal);
            stmt.setString(3, "Reembolso por cancelamento da encomenda " + codigoUnico);
            stmt.setInt(4, idCarteiraLoja);
            stmt.setInt(5, idCarteiraCliente);
            stmt.executeUpdate();
            stmt.close();

            conn.commit(); /* Confirmar transacao */
        }
    } catch (Exception e) {
        try { conn.rollback(); } catch (Exception ex) {}
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ex) {}
        if (stmt != null) try { stmt.close(); } catch (Exception ex) {}
        if (conn != null) try { conn.close(); } catch (Exception ex) {}
    }

    String redirect = "cliente".equals(_perfil) ? "encomendas.jsp?msg=cancelada" : ("funcionario".equals(_perfil) ? "func_encomendas.jsp" : "admin_encomendas.jsp");
    response.sendRedirect(redirect);
%>
