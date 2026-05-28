CREATE TABLE dbo.dim_orgao (
    orgao_sk BIGINT IDENTITY,

    codigo_orgao_superior VARCHAR(50),
    nome_orgao_superior VARCHAR(255),

    codigo_orgao_subordinado VARCHAR(50),
    nome_orgao_subordinado VARCHAR(255),

    codigo_unidade_gestora VARCHAR(50),
    nome_unidade_gestora VARCHAR(255),

    codigo_gestao VARCHAR(50),
    nome_gestao VARCHAR(255),

    codigo_unidade_orcamentaria VARCHAR(50),
    nome_unidade_orcamentaria VARCHAR(255)
);