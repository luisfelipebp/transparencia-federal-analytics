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
SELECT DISTINCT
    s.codigo_categoria_economica,
    s.nome_categoria_economica,
    s.codigo_grupo_de_despesa,
    s.nome_grupo_de_despesa,
    s.codigo_elemento_de_despesa,
    s.nome_elemento_de_despesa,
    s.codigo_modalidade_da_despesa,
    s.modalidade_da_despesa
FROM transparencia_lh.dbo.silver_despesas s
LEFT JOIN dbo.dim_natureza_despesa d
    ON s.codigo_categoria_economica = d.codigo_categoria_economica
    AND s.codigo_grupo_de_despesa = d.codigo_grupo_de_despesa
    AND s.codigo_elemento_de_despesa = d.codigo_elemento_de_despesa
    AND s.codigo_modalidade_da_despesa = d.codigo_modalidade_da_despesa
WHERE d.natureza_despesa_sk IS NULL;


