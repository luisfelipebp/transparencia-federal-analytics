INSERT INTO dbo.dim_orgao (
    codigo_orgao_superior,
    nome_orgao_superior,
    codigo_orgao_subordinado,
    nome_orgao_subordinado,
    codigo_unidade_gestora,
    nome_unidade_gestora,
    codigo_gestao,
    nome_gestao,
    codigo_unidade_orcamentaria,
    nome_unidade_orcamentaria
)
SELECT DISTINCT
    s.codigo_orgao_superior,
    s.nome_orgao_superior,
    s.codigo_orgao_subordinado,
    s.nome_orgao_subordinado,
    s.codigo_unidade_gestora,
    s.nome_unidade_gestora,
    s.codigo_gestao,
    s.nome_gestao,
    s.codigo_unidade_orcamentaria,
    s.nome_unidade_orcamentaria
FROM transparencia_lh.dbo.silver_despesas s
LEFT JOIN dbo.dim_orgao d
    ON s.codigo_orgao_superior = d.codigo_orgao_superior
    AND s.codigo_orgao_subordinado = d.codigo_orgao_subordinado
    AND s.codigo_unidade_gestora = d.codigo_unidade_gestora
    AND s.codigo_gestao = d.codigo_gestao
    AND s.codigo_unidade_orcamentaria = d.codigo_unidade_orcamentaria
    AND s.codigo_unidade_orcamentaria = d.codigo_unidade_orcamentaria
WHERE d.orgao_sk IS NULL;


