
-- Cria a base de dados felixubershop com todas as tabelas

CREATE DATABASE IF NOT EXISTS felixubershop
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE felixubershop;

-- -----------------------------------------------------------
-- Tabela do utilizador
-- Armazena todos os utilizadores do sistema (clientes, funcionarios e admins)
-- A autenticacao é feita pelo nome (login) e a password (utilizando o hash SHA2-256)

CREATE TABLE IF NOT EXISTS utilizador (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE,
    email VARCHAR(255) UNIQUE,
    telefone VARCHAR(20),
    morada TEXT,
    password VARCHAR(255) NOT NULL,
    tipo_util ENUM('cliente','funcionario','administrador') NOT NULL DEFAULT 'cliente',
    estado ENUM('ativo','inativo') NOT NULL DEFAULT 'ativo',
    data_registo DATE DEFAULT (CURRENT_DATE)
);

-- Utilizadores  iniciais: um cliente, um funcionario e um administrador
INSERT INTO utilizador (nome, email, telefone, morada, password, tipo_util) VALUES
('cliente', 'cliente@email.pt', NULL, NULL, SHA2('cliente',256), 'cliente'),
('funcionario', 'funcionario@empresa.pt', NULL, NULL, SHA2('funcionario',256), 'funcionario'),
('admin', 'admin@empresa.pt', NULL, NULL, SHA2('admin',256), 'administrador');

-- -----------------------------------------------------------
-- Tabela da carteira
-- Cada cliente tem uma carteira pessoal. 
-- A carteira da loja não terá algum ID (será somente usada em auditoria)

CREATE TABLE IF NOT EXISTS carteira (
    id INT AUTO_INCREMENT PRIMARY KEY,
    utilizador_id INT UNIQUE NULL,
    nome VARCHAR(50) NOT NULL,
    saldo DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_carteira_utilizador
    FOREIGN KEY (utilizador_id) REFERENCES utilizador(id)
);

-- Carteira do cliente inicial e da loja
INSERT INTO carteira (utilizador_id, nome, saldo) VALUES
(1, 'Carteira do cliente', 100.00),
(NULL, 'FelixUberShop', 0.00);

-- -----------------------------------------------------------
-- Tabela de produtos
-- Produtos disponiveis na mercearia
CREATE TABLE IF NOT EXISTS produto (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    nome        VARCHAR(255) NOT NULL,
    descricao   TEXT,
    preco       DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    quantidade  INT NOT NULL DEFAULT 0,
    estado      ENUM('ativo','inativo') NOT NULL DEFAULT 'ativo'
);

-- Produtos de exemplo
INSERT INTO produto (nome, descricao, preco, quantidade) VALUES
('Azeite Extra Virgem 750ml', 'Azeite portugues', 6.99, 100),
('Arroz Agulha 1kg', 'Arroz agulha nacional', 1.49,  50),
('Massa Esparguete 500g', 'Massa de trigo duro', 0.99, 200),
('Leite UHT Meio-Gordo 1L', 'Leite meio-gordo fresco', 0.79, 100),
('Cafe Moido 250g', 'Blend arabica robusta', 3.49,  50);

-- -----------------------------------------------------------
-- Tabela de promoções
-- Promoções e alertas geridos pelo administrador
CREATE TABLE IF NOT EXISTS promocao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    conteudo TEXT NOT NULL,
    data_inicio DATE NOT NULL,
    data_fim DATE NOT NULL,
    estado ENUM('ativo','inativo') NOT NULL DEFAULT 'inativo'
);

-- Promocoes de exemplo
INSERT INTO promocao (titulo, conteudo, data_inicio, data_fim, estado) VALUES
('Promoção de Abertura', '10% de desconto na primeira encomenda! Aproveite já.', '2025-01-01', '2026-12-31', 'ativo'),
('Entrega Grátis', 'Encomendas acima de 20 EUR têm entrega grátis em Castelo Branco.', '2025-06-01', '2026-12-31', 'ativo');

-- -----------------------------------------------------------
-- Tabela de encomendas
-- O "codigo_unico" é gerado pela aplicacao no momento da criação de pedido
CREATE TABLE IF NOT EXISTS encomenda (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    utilizador_id INT NOT NULL,
    produto_id    INT NOT NULL,
    quantidade    INT NOT NULL DEFAULT 1,
    valor_total   DECIMAL(10,2) NOT NULL,
    codigo_unico  VARCHAR(30) UNIQUE NOT NULL,
    data          DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado        ENUM('ativo','alterada','anulada','entregue') NOT NULL DEFAULT 'ativo',
    CONSTRAINT fk_encomenda_utilizador
        FOREIGN KEY (utilizador_id) REFERENCES utilizador(id),
    CONSTRAINT fk_encomenda_produto
        FOREIGN KEY (produto_id) REFERENCES produto(id)
);

-- -----------------------------------------------------------
-- Tabela da auditoria
-- Registo de todas as operacoes de carteira: 
-- depositos, levantamentos, pagamentos e reembolsos
CREATE TABLE IF NOT EXISTS auditoria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    utilizador_id INT NOT NULL,
    tipo_operacao VARCHAR(30) NOT NULL,
    valor DECIMAL(10,2) DEFAULT 0.00,
    descricao TEXT,
    carteira_origem  INT NULL,
    carteira_destino INT NULL,
    data DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_auditoria_utilizador
        FOREIGN KEY (utilizador_id) REFERENCES utilizador(id),
    CONSTRAINT fk_auditoria_carteira_origem
        FOREIGN KEY (carteira_origem) REFERENCES carteira(id),
    CONSTRAINT fk_auditoria_carteira_destino
        FOREIGN KEY (carteira_destino) REFERENCES carteira(id)
);
