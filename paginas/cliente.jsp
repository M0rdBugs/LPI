<%@ include file="../basedados/basedados.h.jsp" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%
    HttpSession currentSession = request.getSession(false);
    if (!"cliente".equals(currentSession.getAttribute("tipo_utilizador"))) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cliente</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                color: var(--dark);
                margin: 0;
                padding: 0;
            }

            .container {
                max-width: 1200px;
                margin: 0 auto;
                padding: 20px;
            }
        </style>
    </head>
    <body>
        <header>
            <div class="logo">
                <img src="logo.png" alt="FelixUberShop Logo">
                <h1>FelixUberShop</h1>
            </div>
            <nav>
                <a href="home.jsp">Home</a>
                <a href="produtos.html">Produtos</a>
                <a href="contactos.html">Contactos</a>
                <a href="logout.jsp">Logout</a>
            </nav>
        </header>

        <div class="container">
            <h2>Bem-vindo, Cliente!</h2>
            <p>Aqui você pode explorar nossos produtos e fazer suas compras.</p>
        </div>

        <footer>
            &copy; 2026 FelixUberShop. Todos os direitos reservados.
        </footer>
    </body>    
</html>