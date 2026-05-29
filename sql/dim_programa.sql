INSERT INTO dbo.dim_programa (
    codigo_funcao,
    nome_funcao,
    codigo_subfuncao,
    nome_subfuncao,
    codigo_programa_orcamentario,
    nome_programa_orcamentario,
    codigo_acao,
    nome_acao,
    codigo_plano_orcamentario,
    plano_orcamentario,
    codigo_programa_governo,
    nome_programa_governo
)
SELECT DISTINCT
    s.codigo_funcao,
    s.nome_funcao,
    s.codigo_subfuncao,
    s.nome_subfuncao,
    s.codigo_programa_orcamentario,
    s.nome_programa_orcamentario,
    s.codigo_acao,
    s.nome_acao,
    s.codigo_plano_orcamentario,
    s.plano_orcamentario,
    s.codigo_programa_governo,
    s.nome_programa_governo
FROM transparencia_lh.dbo.silver_despesas s
LEFT JOIN dbo.dim_programa d
    ON s.codigo_funcao = d.codigo_funcao
    AND s.codigo_subfuncao = d.codigo_subfuncao
    AND s.codigo_programa_orcamentario = d.codigo_programa_orcamentario
    AND s.codigo_acao = d.codigo_acao
    AND s.codigo_plano_orcamentario = d.codigo_plano_orcamentario
    AND s.codigo_programa_governo = d.codigo_programa_governo
WHERE d.programa_sk IS NULL;


