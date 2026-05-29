INSERT INTO dbo.dim_natureza_despesa (
    codigo_categoria_economica,
    nome_categoria_economica,
    codigo_grupo_de_despesa,
    nome_grupo_de_despesa,
    codigo_elemento_de_despesa,
    nome_elemento_de_despesa,
    codigo_modalidade_da_despesa,
    modalidade_da_despesa
)
SELECT 
    codigo_categoria_economica,
    MAX(nome_categoria_economica) AS nome_categoria_economica,
    
    codigo_grupo_de_despesa,
    MAX(nome_grupo_de_despesa) AS nome_grupo_de_despesa,
    
    codigo_elemento_de_despesa,
    MAX(nome_elemento_de_despesa) AS nome_elemento_de_despesa,
    
    codigo_modalidade_da_despesa,
    MAX(modalidade_da_despesa) AS modalidade_da_despesa

FROM transparencia_lh.dbo.silver_despesas
GROUP BY 
    codigo_categoria_economica,
    codigo_grupo_de_despesa,
    codigo_elemento_de_despesa,
    codigo_modalidade_da_despesa;