<%@ page import="java.sql.*, javax.sql.*" %>
<%
    String dbURL = "jdbc:mysql://localhost:3306/trabalho1";
    String dbUser = "root";
    String dbPassword = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        application.setAttribute("conn", conn);
        out.println("Conexão com o banco de dados estabelecida com sucesso!");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("Erro ao conectar ao banco de dados: " + e.getMessage());
    }
%>
