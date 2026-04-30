<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../basedados/basedados.h" %>
<%@ page import="java.sql.*" %>

<%
    String nome = request.getParameter("nome");
    String pwd = request.getParameter("password");
    String email = request.getParameter("email");

    Connection conn = (Connection) application.getAttribute("conn");

    String sql = "INSERT INTO utilizador(nome, email, password_hash, tipo_util,data_registo) VALUES (?, ?, SHA2(?, 256), 'cliente', CURDATE())";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, nome);
    pstmt.setString(2, email);
    pstmt.setString(3, pwd);
    
    int i = pstmt.executeUpdate();
    if (i > 0) {
        session.setAttribute("utilizador_id", nome);
        out.print("Registro feito!"+"<a href='login.html'>Faça Login</a>");
    } else {
        response.sendRedirect("index.html");
    }
%>