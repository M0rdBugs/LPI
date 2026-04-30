<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="styles.css">
        <title>Produtos</title>
        <style>
            .container-products {
                background-color: white;
                padding: 40px;
                border-radius: 15px;
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
                text-align: center;
                max-width: 1500px;
                margin: 0 auto;
            }
            .container-products h2 {
                font-size: 2.5em;
                margin-bottom: 30px;
            }
            .product-list {
                margin-top: 50px;
                display: grid;
                grid-template-columns: 500px 500px 500px;  
                flex-wrap: wrap;
                align-items:center;
                justify-content: center;
                row-gap: 30px;
            }
            .product-item {
                background-color: #f4f8fffb;
                padding: 20px;
                border-radius: 10px;
                transition: transform 0.3s, box-shadow 0.3s;
                margin-inline: 20px;
                
            }
            .product-item:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
            }
            .product-item img {
                max-width: 50%;
                height: auto;
                border-radius: 10px;
                margin-bottom: 15px;
                box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
                background-color: white;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <header>
                <div class="logo">
                    <a href="index.html">
                        <img src="logo.png" alt="FelixUberShop Logo">
                    </a>
                    <h1>Produtos</h1>
                </div>
                <nav>
                    <a href="produtos.html"><i class="fas fa-product-hunt"></i> Produtos</a>
                    <a href="contactos.html"><i class="fas fa-contact-card"></i> Contacto</a>
                    <a href="login.html" class="btn"><i class="fas fa-sign-in-alt"></i> Login | Registo</a>
                </nav>
            </header>
        </div>

        <div class="container-products">
                <h2>Catalogo de Produtos</h2>
                <div class="product-list">
                    <div class="product-item">
                        <img src="logo.png" alt="Produto 1">
                        <h3>Produto 1</h3>
                        <p>Descrição do Produto 1</p>
                        <p>Preço: FUNCAO DE PRECO</p>
                    </div>
                    <div class="product-item">
                        <img src="produto2.jpg" alt="Produto 2">
                        <h3>Produto 2</h3>
                        <p>Descrição do Produto 2</p>
                        <p>Preço: FUNCAO DE PRECO</p>
                    </div>
                    <div class="product-item">
                        <img src="produto3.jpg" alt="Produto 3">
                        <h3>Produto 3</h3>
                        <p>Descrição do Produto 3</p>
                        <p>Preço: FUNCAO DE PRECO</p>
                    </div>
                    <div class="product-item">
                        <img src="produto4.jpg" alt="Produto 4">
                        <h3>Produto 4</h3>
                        <p>Descrição do Produto 4</p>
                        <p>Preço: FUNCAO DE PRECO</p>
                    </div>
                    <div class="product-item">
                        <img src="produto5.jpg" alt="Produto 5">
                        <h3>Produto 5</h3>
                        <p>Descrição do Produto 5</p>
                        <p>Preço: FUNCAO DE PRECO</p>
                    </div>
                    <div class="product-item">
                        <img src="produto6.jpg" alt="Produto 6">
                        <h3>Produto 6</h3>
                        <p>Descrição do Produto 6</p>
                        <p>Preço: FUNCAO DE PRECO</p>
                    </div>

                </div>  

        </div>
        <footer>
            <p>&copy; 2026 FelixUberShop. Todos os direitos reservados.</p>
        </footer>
    </body>
</html>