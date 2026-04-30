<%@ include file="../basedados/basedados.h" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<%
    if (session.getAttribute("utilizador_id") == null) {
        response.sendRedirect("login.html");
        return;
    }
%>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles.css">
        <title>FelixUberShop</title>
        <style>


        </style>
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
                    <a href="login.html" class="btn"><i class="fas fa-sign-in-alt"></i> Login | Registo</a>
                </nav>
            </header>
        </div>
        <Main>
        Pagina inicial que os utilizadores veem após fazer login. Pode exibir conteúdo diferente com base no papel do usuário (admin, funcionário ou cliente)    
        </Main>

        <footer>
            <p>&copy; 2026 FelixUberShop. Todos os direitos reservados.</p>
        </footer>
    </body>
</html>