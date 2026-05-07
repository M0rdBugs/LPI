<%-- 
    Ficheiro: cancelar_encomenda.jsp
    Descrição: Cancela uma encomenda com estado 'pendente' e efectua o reembolso
    do valor para a carteira do cliente. Regista a operação na auditoria.
    Acessível a clientes (apenas as suas), funcionários e administradores.
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="../basedados/basedados.h" %>
<%
    String _perfil = (String) session.getAttribute("perfil");
    if (_perfil == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
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
        conn = ligarBaseDados();
        conn.setAutoCommit(false);
        
        // Verificar encomenda
        String sqlCheck;
        if ("cliente".equals(_perfil)) {
            sqlCheck = "SELECT * FROM encomendas WHERE id=? AND id_cliente=? AND estado='pendente'";
            stmt = conn.prepareStatement(sqlCheck);
            stmt.setInt(1, idEncomenda);
            stmt.setInt(2, (Integer) session.getAttribute("id_utilizador"));
        } else {
            sqlCheck = "SELECT * FROM encomendas WHERE id=? AND estado='pendente'";
            stmt = conn.prepareStatement(sqlCheck);
            stmt.setInt(1, idEncomenda);
        }
        rs = stmt.executeQuery();
        
        if (rs.next()) {
            double valorTotal = rs.getDouble("valor_total");
            int idCliente = rs.getInt("id_cliente");
            String idUnico = rs.getString("identificador_unico");
            rs.close(); stmt.close();
            
            // Obter carteiras
            stmt = conn.prepareStatement("SELECT id FROM carteiras WHERE id_utilizador=?");
            stmt.setInt(1, idCliente);
            rs = stmt.executeQuery();
            int idCarteiraCliente = 0;
            if (rs.next()) idCarteiraCliente = rs.getInt("id");
            rs.close(); stmt.close();
            
            stmt = conn.prepareStatement("SELECT id FROM carteiras WHERE tipo='loja' LIMIT 1");
            rs = stmt.executeQuery();
            int idCarteiraLoja = 0;
            if (rs.next()) idCarteiraLoja = rs.getInt("id");
            rs.close(); stmt.close();
            
            // Cancelar encomenda
            stmt = conn.prepareStatement("UPDATE encomendas SET estado='cancelada' WHERE id=?");
            stmt.setInt(1, idEncomenda);
            stmt.executeUpdate(); stmt.close();
            
            // Reembolsar cliente
            stmt = conn.prepareStatement("UPDATE carteiras SET saldo = saldo + ? WHERE id=?");
            stmt.setDouble(1, valorTotal);
            stmt.setInt(2, idCarteiraCliente);
            stmt.executeUpdate(); stmt.close();
            
            stmt = conn.prepareStatement("UPDATE carteiras SET saldo = saldo - ? WHERE id=?");
            stmt.setDouble(1, valorTotal);
            stmt.setInt(2, idCarteiraLoja);
            stmt.executeUpdate(); stmt.close();
            
            // Registar auditoria
            stmt = conn.prepareStatement("INSERT INTO auditoria_carteira (id_carteira_origem, id_carteira_destino, valor, tipo_operacao, descricao) VALUES (?,?,?,'reembolso',?)");
            stmt.setInt(1, idCarteiraLoja);
            stmt.setInt(2, idCarteiraCliente);
            stmt.setDouble(3, valorTotal);
            stmt.setString(4, "Reembolso por cancelamento da encomenda " + idUnico);
            stmt.executeUpdate(); stmt.close();
            
            conn.commit();
        }
    } catch (Exception e) {
        try { conn.rollback(); } catch (Exception ex) {}
    } finally {
        desligarBaseDados(conn, stmt, rs);
    }
    
    String redirect = "cliente".equals(_perfil) ? "cliente_encomendas.jsp?msg=cancelada" : ("funcionario".equals(_perfil) ? "func_encomendas.jsp" : "admin_encomendas.jsp");
    response.sendRedirect(redirect);
%>
