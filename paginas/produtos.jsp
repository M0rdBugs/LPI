<%@ include file="../basedados/basedados.h" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles.css">
        <title>Produtos</title>
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
                    <a href="login.html" class="btn"><i class="fas fa-user"></i> Conta</a>
                </nav>
            </header>
        </div>
        <div class="container">
            <div class="card">
                <h2>Catálogo de Produtos</h2>

                <!-- Formulário de ordenação -->
                <form method="get" action="produtos.jsp" style="margin-bottom:15px;">
                    <label>Ordenar por:
                        <select name="ordem" onchange="this.form.submit()">
                            <option value="nome" <%= "nome".equals(request.getParameter("ordem")) ? "selected" : "" %>>Nome (A-Z)</option>
                            <option value="nome_desc" <%= "nome_desc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Nome (Z-A)</option>
                            <option value="preco" <%= "preco".equals(request.getParameter("ordem")) ? "selected" : "" %>>Preço (Crescente)</option>
                            <option value="preco_desc" <%= "preco_desc".equals(request.getParameter("ordem")) ? "selected" : "" %>>Preço (Decrescente)</option>
                        </select>
                    </label>
                </form>

                <%
                    Connection conn = null;
                    PreparedStatement stmt = null;
                    ResultSet rs = null;
                    try {
                        conn = connectBD();
                        String ordem = request.getParameter("ordem");
                        String orderBy = "nome ASC"; // Ordenação padrão
                        if ("nome_desc".equals(ordem)) orderBy = "nome DESC";
                        else if ("preco".equals(ordem)) orderBy = "preco ASC";
                        else if ("preco_desc".equals(ordem)) orderBy = "preco DESC";
                        
                        String sql = "SELECT * FROM produtos WHERE estado = 'ativo' ORDER BY " + orderBy;
                        stmt = conn.prepareStatement(sql);
                        rs = stmt.executeQuery();
                %>
                <table>
                    <tr>
                        <th>Nome</th>
                        <th>Descrição</th>
                        <th>Preço</th>
                        <th>Stock</th>
                        <% if ("cliente".equals(session.getAttribute("perfil"))) { %><th>Ação</th><% } %>
                    </tr>
                    <% 
                        boolean temProdutos = false;
                        while (rs.next()) {
                            temProdutos = true;
                    %>
                    <tr>
                        <td><%= rs.getString("nome") %></td>
                        <td><%= rs.getString("descricao") %></td>
                        <td><strong><%= String.format("%.2f", rs.getDouble("preco")) %> €</strong></td>
                        <td><%= rs.getInt("stock") %> un.</td>
                        <% if ("cliente".equals(session.getAttribute("perfil"))) { %>
                            <td><a href="nova_encomenda.jsp?produto=<%= rs.getInt("id") %>" class="btn btn-verde">Encomendar</a></td>
                        <% } %>
                    </tr>
                    <% } %>
                    <% if (!temProdutos) { %>
                    <tr><td colspan="5" style="text-align:center;">Não existem produtos disponíveis.</td></tr>
                    <% } %>
                </table>
                <%
                    } catch (Exception e) {
                        out.println("<div class='msg-erro'>Erro ao carregar produtos: " + e.getMessage() + "</div>");
                    } finally {
                        conn.close();
                    }
                %>
            </div>
        </div>

        <footer>
            <p>&copy; 2026 FelixUberShop. Todos os direitos reservados.</p>
        </footer>
    </body>
</html>