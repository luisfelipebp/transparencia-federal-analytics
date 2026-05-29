INSERT INTO dbo.dim_programa (
    codigo_programa_governo, nome_programa_governo,
    codigo_funcao, nome_funcao,
    codigo_subfuncao, nome_subfuncao,
    codigo_programa_orcamentario, nome_programa_orcamentario,
    codigo_plano_orcamentario, plano_orcamentario,
    codigo_acao, nome_acao
)
SELECT 
    codigo_programa_governo, 
    MAX(nome_programa_governo) AS nome_programa_governo,
    
    codigo_funcao, 
    MAX(nome_funcao) AS nome_funcao,
    
    codigo_subfuncao, 
    MAX(nome_subfuncao) AS nome_subfuncao,
    
    codigo_programa_orcamentario, 
    MAX(nome_programa_orcamentario) AS nome_programa_orcamentario,
    
    codigo_plano_orcamentario, 
    MAX(plano_orcamentario) AS plano_orcamentario,
    
    codigo_acao, 
    MAX(nome_acao) AS nome_acao

FROM transparencia_lh.dbo.silver_despesas
GROUP BY 
    codigo_programa_governo,
    codigo_funcao,
    codigo_subfuncao,
    codigo_programa_orcamentario,
    codigo_plano_orcamentario,
    codigo_acao;