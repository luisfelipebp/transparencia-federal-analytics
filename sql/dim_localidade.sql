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
SELECT 
    MAX(uf) AS uf,
    MAX(municipio) AS municipio,
    
    codigo_subtitulo,
    MAX(nome_subtitulo) AS nome_subtitulo,
    
    codigo_localizador,
    MAX(nome_localizador) AS nome_localizador,
    
    MAX(sigla_localizador) AS sigla_localizador,
    MAX(descricao_complementar_localizador) AS descricao_complementar_localizador

FROM transparencia_lh.dbo.silver_despesas
GROUP BY 
    codigo_subtitulo,
    codigo_localizador;