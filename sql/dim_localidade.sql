INSERT INTO dbo.dim_localidade (
    uf,
    municipio,
    codigo_subtitulo,
    nome_subtitulo,
    codigo_localizador,
    nome_localizador,
    sigla_localizador,
    descricao_complementar_localizador
)
SELECT DISTINCT
    s.uf,
    s.municipio,
    s.codigo_subtitulo,
    s.nome_subtitulo,
    s.codigo_localizador,
    s.nome_localizador,
    s.sigla_localizador,
    s.descricao_complementar_localizador
FROM transparencia_lh.dbo.silver_despesas s
LEFT JOIN dbo.dim_localidade d
    ON s.codigo_subtitulo = d.codigo_subtitulo
    AND s.codigo_localizador = d.codigo_localizador
WHERE d.localidade_sk IS NULL;


