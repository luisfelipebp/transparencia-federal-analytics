CREATE TABLE dbo.dim_programa (
    programa_sk BIGINT IDENTITY,

    codigo_programa_governo VARCHAR(50),
    nome_programa_governo VARCHAR(255),

    codigo_funcao VARCHAR(50),
    nome_funcao VARCHAR(255),

    codigo_subfuncao VARCHAR(50),
    nome_subfuncao VARCHAR(255),

    codigo_programa_orcamentario VARCHAR(50),
    nome_programa_orcamentario VARCHAR(255),

    codigo_plano_orcamentario VARCHAR(50),
    plano_orcamentario VARCHAR(255),

    codigo_acao VARCHAR(50),
    nome_acao VARCHAR(255)
);

