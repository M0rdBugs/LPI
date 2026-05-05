<%@ include file="../basedados/basedados.h" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("utilizador_id") == null || !"funcionario".equals(session.getAttribute("tipo_util"))) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles.css">
        <title>Funcionário</title>
    </head>
    <body>
        <header>
            <div class="logo">
                <img src="logo.png" alt="FelixUberShop Logo">
                <h1>FelixUberShop</h1>
            </div>
            <nav>
                <a href="home.jsp">Home</a>
                <a href="produtos.jsp">Produtos</a>
                <a href="contactos.html">Contactos</a>
                <a href="logout.jsp">Logout</a>
            </nav>
        </header>

        <div class="container">
            <h2>Bem-vindo, Funcionário!</h2>
            <p>Aqui você pode gerenciar os produtos e usuários do sistema.</p>
        </div>

        <footer>
            &copy; 2026 FelixUberShop. Todos os direitos reservados.
        </footer>
    </body>    
</html>