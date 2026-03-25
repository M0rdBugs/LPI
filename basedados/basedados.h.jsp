<%@ page import="java.sql.*, javax.sql.*" %>
<%
    String dbURL = "jdbc:mysql://localhost:3306/trabalho1";
    String dbUser = "root";
    String dbPassword = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPassword);
        application.setAttribute("conn", conn);
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
