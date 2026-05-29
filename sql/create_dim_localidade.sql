CREATE TABLE dbo.dim_localidade (
    localidade_sk BIGINT IDENTITY,

    uf VARCHAR(2),
    municipio VARCHAR(255),

    codigo_subtitulo VARCHAR(50),
    nome_subtitulo VARCHAR(255),

    codigo_localizador VARCHAR(50),
    nome_localizador VARCHAR(255),

    sigla_localizador VARCHAR(50),
    descricao_complementar_localizador VARCHAR(255)

);