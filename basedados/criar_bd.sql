CREATE DATABASE IF NOT EXISTS trabalho1 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE trabalho1;

CREATE TABLE IF NOT EXISTS utilizador (
    utilizador_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    password_hash VARCHAR(255) NOT NULL,
    tipo_util ENUM('visitante', 'cliente', 'funcionario', 'administrador') NOT NULL DEFAULT 'visitante',
    morada VARCHAR(255),
    telefone VARCHAR(20),
    estado ENUM ('ativo', 'inativo')

);

INSERT INTO utilizador (nome, email, password_hash, tipo_util, morada, telefone, estado)
VALUES
('cliente', 'cliente@gmail.pt', SHA2('cliente', 256), 'cliente', 'Rua do Comércio, 123, Lisboa', '963666999', 'ativo'),
('funcionario', 'funcionario@gmail.pt', SHA2('funcionario', 256), 'funcionario', 'Rua do Brito, 213, Lisboa', '963666777', 'ativo'),
('admin', 'admin@gmail.pt', SHA2('admin', 256), 'administrador', 'Rua Da Madalena, 321, Lisboa', '963666555', 'ativo');


CREATE TABLE IF NOT EXISTS carteira (
    carteira_id INT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id INT,
    CONSTRAINT fk_carteira_utilizador
         FOREIGN KEY (utilizador_id) REFERENCES (utilizador_id)
    nome VARCHAR(50) NOT NULL,
    saldo DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
);

-- Carteira da FelixUberShop (sem utilizador associado) e carteiras dos utilizadores iniciais
INSERT INTO carteira (utilizador_id, nome, saldo) VALUES
(NULL,'FelixUberShop',0.00),   -- carteira especial da loja
(1,'Carteira cliente',50.00),  -- carteira do utilizador cliente
(3,'Carteira admin',0.00);  -- carteira do administrador 


CREATE TABLE IF NOT EXISTS produto(
    produto_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255),
    descricao TEXT,
    preco DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    estado ENUM ('ativo', 'inativo') DEFAULT 'ativo'
);

-- Produtos de exemplo
INSERT INTO produto (nome, descricao, preco, estado) VALUES
('Azeite Extra Virgem 750ml', 'Azeite português', 6.99, 'ativo'),
('Arroz Agulha 1kg',          'Arroz agulha nacional',                  1.49, 'ativo'),
('Massa Esparguete 500g',     'Massa de trigo duro',                    0.99, 'ativo'),
('Leite UHT Meio-Gordo 1L',   'Leite meio-gordo',         0.79, 'ativo'),
('Café Moído 250g', 'Blend de arábica e robusta',             3.49, 'ativo');





--Informações e promoções dinâmicas geridas pelos administradores

CREATE TABLE IF NOT EXISTS promocao(
    promocao_id INT PRIMARY KEY AUTO_INCREMENT,
    titulo VARCHAR(255) NOT NULL,
    conteudo TEXT,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    estado ENUM ('ativo', 'inativo'),
    utilizador_id INT,
    CONSTRAINT fk_promocao_utilizador
         FOREIGN KEY (utilizador_id) REFERENCES utilizador(utilizador_id)
);


-- Promoção de exemplo
INSERT INTO promocao (titulo, conteudo, data_inicio, data_fim, estado, utilizador_id) VALUES
    ('Promoção de Abertura', 'Desconto de 10% em todos os produtos esta semana!', '2025-09-01', '2025-09-30', 'ativo', 3);




-- Regista cada encomenda feita por um cliente.
-- O identificador único é o encomenda_id (gerado automaticamente).

CREATE TABLE IF NOT EXISTS encomenda(
    encomenda_id INT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id INT,
    CONSTRAINT fk_encomenda_utilizador
         FOREIGN KEY (utilizador_id) REFERENCES utilizador(utilizador_id),
    data DATETIME,
    estado ENUM ('ativo','alterada','anulada') DEFAULT 'ativo',
    valor DECIMAL(10, 2) NOT NULL DEFAULT 0.00    
);

-- tabela intermédia entre encomenda e produto
-- Guarda os produtos de cada encomenda e o preço na altura da compra

CREATE TABLE IF NOT EXISTS encomenda_item(
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


-- Registo de todas as operações relevantes do sistema para
-- efeitos de rastreabilidade (quem fez o quê e quando)

CREATE TABLE IF NOT EXISTS auditoria (
    auditoria_id INT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id INT, ---QUEM REALIZOU A OPERACAO 
    operacao VARCHAR(100) NOT NULL
    carteira_origem_id INT NOT NULL,
    operacao 
);
 
