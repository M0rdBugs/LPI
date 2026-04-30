<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    String nome = request.getParameter("nome");
    String password = request.getParameter("password");

    Connection conn = null;
    try {
        conn = connectBD();

        String sql = "SELECT * FROM utilizador WHERE nome = ? AND password_hash = SHA2(?, 256)";
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, nome);
        pstmt.setString(2, password);
        ResultSet resultado = pstmt.executeQuery();

        if (resultado.next()) {
            String tipoUtilizador = resultado.getString("tipo_util");
            HttpSession sessao = request.getSession();
            sessao.setAttribute("utilizador_id", resultado.getInt("utilizador_id"));
            sessao.setAttribute("tipo_util", tipoUtilizador);
            response.sendRedirect("home.jsp");
            return;
        } else {
            resultado.close();
            pstmt.close();
            response.sendRedirect("login.html");
            return;
        }

    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("login.html");
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
%>
