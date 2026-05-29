CREATE TABLE dbo.dim_natureza_despesa (
    natureza_despesa_sk BIGINT IDENTITY,

    codigo_categoria_economica VARCHAR(50),
    nome_categoria_economica VARCHAR(255),

    codigo_grupo_de_despesa VARCHAR(50),
    nome_grupo_de_despesa VARCHAR(255),

    codigo_elemento_de_despesa VARCHAR(50),
    nome_elemento_de_despesa VARCHAR(255),

    codigo_modalidade_da_despesa VARCHAR(50),
    modalidade_da_despesa VARCHAR(255)

);