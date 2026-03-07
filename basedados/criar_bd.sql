CREATE DATABASE IF NOT EXISTS FelixUberShop 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE trabaFelixUberShop;

--tabela de utilizador 

CREATE TABLE IF NOT EXISTS utilizador (
    utilizador_id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    perfil ENUM('visitante', 'cliente', 'funcionario', 'administrador') NOT NULL DEFAULT 'visitante',
    saldo DECIMAL(10,2) DEFAULT 0.00
    

);


--tablea de carteiras

CREATE TABLE IF NOT EXISTS carteira(
    carteira_id INT PRIMARY KEY AUTO_INCREMENT,
    utilizador_id INT NOT NULL,
    saldo DECIMAL(15, 2) NOT NULL 
)



CREATE TABLE IF NOT EXISTS transacoes (
    transacoes_id INT PRIMARY KEY AUTO_INCREMENT ,
    user_id INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    tipo ENUM('CARGA', 'COMPRA', 'REEMBOLSO') NOT NULL,
    data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES utilizador(utilizador_id)
);

 
INSERT INTO utilizador (nome, email, password, tipo_util, saldo) VALUES
    ('visitante', NULL, NULL, 'visitante', 0.00), 
    ('cliente', 'cliente@email.com', 'cliente', 'cliente', 100.00),
    ('funcionário', 'funcionario@empresa.com', 'funcionario', 'funcionario', 0.00),
    ('admin', 'admin@empresa.com', 'admin', 'administrador', 0.00);
  