-- Tabela: tb_usuario
CREATE TABLE dbo.tb_usuario (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    usuario VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    foto VARCHAR(500)
);

-- Tabela: tb_categoria
CREATE TABLE dbo.tb_categoria (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(255) NOT NULL,
    descricao VARCHAR(500) NOT NULL
);

-- Tabela: tb_produto
CREATE TABLE dbo.tb_produto (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descricao VARCHAR(1000) NOT NULL,
    condicao VARCHAR(100) NOT NULL,
    preco FLOAT NOT NULL,
    foto VARCHAR(500),
    usuario_id BIGINT NOT NULL,
    categoria_id BIGINT NOT NULL,
    CONSTRAINT fk_produto_usuario FOREIGN KEY (usuario_id) 
        REFERENCES dbo.tb_usuario(id) ON DELETE CASCADE,
    CONSTRAINT fk_produto_categoria FOREIGN KEY (categoria_id) 
        REFERENCES dbo.tb_categoria(id) ON DELETE CASCADE
);