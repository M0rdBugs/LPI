<%@ include file="../basedados/basedados.h" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("utilizador_id") == null) {
        response.sendRedirect("login.html");
        return;
    }
    String tipoUtilizador = (String) session.getAttribute("tipo_util");
%>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles.css">
        <title>FelixUberShop</title>
    </head>
  
    <body>
        <div class="container">
            <header>
                <div class="logo">
                    <a href="index.html">
                        <img src="logo.png" alt="FelixUberShop Logo">
                    </a>
                    <h1>FelixUberShop</h1>
                </div>
                <nav>
                    <a href="produtos.jsp"><i class="fas fa-product-hunt"></i> Produtos</a>
                    <a href="contactos.html"><i class="fas fa-contact-card"></i> Contacto</a>
                    <a href="login.html" class="btn"><i class="fas fa-sign-in-alt"></i> Conta</a>
                </nav>
            </header>
        </div>
        <main>
        Conteúdo em base do tipo de utilizador a ser feito ainda
        </main>

        <footer>
            <p>&copy; 2026 FelixUberShop. Todos os direitos reservados.</p>
        </footer>
    </body>
</html>