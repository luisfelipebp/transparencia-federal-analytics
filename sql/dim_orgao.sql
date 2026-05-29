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
SELECT 
    codigo_orgao_superior,
    MAX(nome_orgao_superior) AS nome_orgao_superior,
    
    codigo_orgao_subordinado,
    MAX(nome_orgao_subordinado) AS nome_orgao_subordinado,
    
    codigo_unidade_gestora,
    MAX(nome_unidade_gestora) AS nome_unidade_gestora,
    
    codigo_gestao,
    MAX(nome_gestao) AS nome_gestao,
    
    codigo_unidade_orcamentaria,
    MAX(nome_unidade_orcamentaria) AS nome_unidade_orcamentaria

FROM transparencia_lh.dbo.silver_despesas
GROUP BY 
    codigo_orgao_superior,
    codigo_orgao_subordinado,
    codigo_unidade_gestora,
    codigo_gestao,
    codigo_unidade_orcamentaria;