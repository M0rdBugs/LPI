<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.DriverManager" %>
<%@ page import="java.sql.SQLException" %>

<%--
    Ficheiro que liga a base de dados a outros ficheiros
--%>
<%!
    private static final String DB_HOST = "localhost:3306";
    private static final String DB_NAME = "felixubershop";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";
    private static final String DB_URL = "jdbc:mysql://" + DB_HOST + "/" + DB_NAME;

    // Estabelece uma ligação à base de dados "felixubershop" criada no "criar_bd.sql"
    public Connection connectBD() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("Driver JDBC do MySQL nao encontrado.");
        }
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }
%>
