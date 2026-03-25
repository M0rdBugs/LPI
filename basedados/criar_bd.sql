CREATE DATABASE IF NOT EXISTS trabalho1 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE trabalho1;

-- O utilizador em si não se usa logo para o visitante, por mais que assume visitante na base de dados. 
-- Na questão de proteção talvez seja necessário usar as mesmas páginas para utilizadores diferentes 
CREATE TABLE IF NOT EXISTS utilizador (
    utilizador_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    password_hash VARCHAR(255) NOT NULL,
    saldo DECIMAL(10,2),
    tipo_util ENUM('visitante', 'cliente', 'funcionario', 'administrador') NOT NULL DEFAULT 'visitante'
);


INSERT INTO utilizador (nome, email, password_hash, saldo, tipo_util)
VALUES
('cliente', 'cliente@email.pt', SHA2('cliente', 256), 100.00, 'cliente'),
('funcionario', 'funcionario@empresa.pt', SHA2('funcionario', 256), NULL, 'funcionario'),
('admin', 'admin@empresa.pt', SHA2('admin', 256), NULL, 'administrador');

-- Carteira talvez assuma o valor total que a empresa faturou, senão, assume-se outra carteira que pegue nesse valor (?)
CREATE TABLE IF NOT EXISTS carteira (
    carteira_id INT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id INT UNIQUE,
    nome VARCHAR(50) NOT NULL,
    saldo DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_carteira_utilizador
    FOREIGN KEY (utilizador_id) REFERENCES utilizador(utilizador_id) 
);

-- Carteira da FelixUberShop (sem utilizador associado) e carteiras dos utilizadores iniciais
INSERT INTO carteira (utilizador_id, nome, saldo) VALUES
(NULL,'FelixUberShop',  0.00);  -- carteira especial da loja

CREATE TABLE IF NOT EXISTS produto (
    produto_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255),
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    quantidade INT NOT NULL DEFAULT 1,
    estado ENUM ('ativo', 'inativo') DEFAULT 'ativo'
);

-- Produtos de exemplo
INSERT INTO produto (nome, descricao, preco, quantidade, estado) 
VALUES
('Azeite Extra Virgem 750ml', 'Azeite português', 6.99, 100, 'ativo'),
('Arroz Agulha 1kg','Arroz agulha nacional', 1.49, 50, 'ativo'),
('Massa Esparguete 500g','Massa de trigo duro', 0.99, 200, 'ativo'),
('Leite UHT Meio-Gordo 1L','Leite meio-gordo', 0.79, 100, 'ativo'),
('Café Moído 250g', 'Blend de arábica e robusta', 3.49, 50, 'ativo');

-- Promoções que só o administrador pode criar, editar ou eliminar. Apenas os produtos ativos podem estar associados a promoções ativas
CREATE TABLE IF NOT EXISTS promocao (
    promocao_id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    conteudo TEXT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    estado ENUM ('ativo', 'inativo') DEFAULT 'inativo'
);

-- Regista cada encomenda feita por um cliente.
-- O identificador único é o encomenda_id (gerado automaticamente).
CREATE TABLE IF NOT EXISTS encomenda (
    encomenda_id INT PRIMARY KEY AUTO_INCREMENT,
<<<<<<< Updated upstream
    utilizador_id INT,
    produto_id INT,
    CONSTRAINT fk_encomenda_utilizador
    FOREIGN KEY (utilizador_id) REFERENCES utilizador(utilizador_id),
    data DATETIME,
    estado ENUM ('ativo','alterada','anulada') DEFAULT 'ativo',
    CONSTRAINT fk_produto_encomenda FOREIGN KEY (produto_id) REFERENCES produto(produto_id), valor DECIMAL(10, 2) NOT NULL DEFAULT 0.00
=======
    utilizador_id INT NOT NULL,
    codigo_unico VARCHAR(30) UNIQUE,
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado ENUM ('ativa','alterada','anulada') DEFAULT 'ativa',
    valor_total DECIMAL(10,2),
    CONSTRAINT fk_encomenda_utilizador
    FOREIGN KEY (utilizador_id) REFERENCES utilizador(utilizador_id)
>>>>>>> Stashed changes
);

-- Registo de todas as operações relevantes do sistema para
-- efeitos de rastreabilidade (quem fez o quê e quando)
<<<<<<< Updated upstream
=======
-- Valor total da auditoria talvez é bom ter
-- Em vez de ter carteira ID so, mais vale ter onde começa e para onde vai
>>>>>>> Stashed changes
CREATE TABLE IF NOT EXISTS auditoria (
    auditoria_id INT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id INT,
    operacao ENUM ('Compra', 'Reembolso', 'Carga') NOT NULL,
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    carteira_origem INT,
    carteira_destino INT,
    FOREIGN KEY (utilizador_id) REFERENCES utilizador(utilizador_id),
    FOREIGN KEY (carteira_origem) REFERENCES carteira(carteira_id),
    FOREIGN KEY (carteira_destino) REFERENCES carteira(carteira_id)
);
 

-- Parte do Miguel, território não testado por mim
-- tabela intermédia entre encomenda e produto
-- Guarda os produtos de cada encomenda e o preço na altura da compra
CREATE TABLE IF NOT EXISTS encomenda_item (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    encomenda_id INT NOT NULL,
    produto_id INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unit DECIMAL(10, 2) NOT NULL,
    CONSTRAINT fk_encomenda_item
    FOREIGN KEY (encomenda_id) REFERENCES encomenda(encomenda_id),
    CONSTRAINT fk_produto_item
    FOREIGN KEY (produto_id) REFERENCES produto(produto_id)
);
<<<<<<< Updated upstream

-- Regista movimentos de saldo nas carteiras (carga, compra, reembolso)
-- Serve também de base de auditoria financeira

CREATE TABLE IF NOT EXISTS transacoes (
    transacoes_id INT PRIMARY KEY AUTO_INCREMENT ,
    utilizador_id INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    tipo ENUM('CARGA', 'COMPRA', 'REEMBOLSO') NOT NULL,
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (utilizador_id) REFERENCES utilizador(utilizador_id)
);
=======
>>>>>>> Stashed changes
