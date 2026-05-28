INSERT INTO dbo.dim_tempo (
    ano_mes,
    ano,
    mes
)

SELECT DISTINCT
    s.ano_mes,

    YEAR(s.ano_e_mes_do_lancamento) AS ano,

    MONTH(s.ano_e_mes_do_lancamento) AS mes

FROM transparencia_lh.dbo.silver_despesas s

LEFT JOIN dbo.dim_tempo d
    ON s.ano_mes = d.ano_mes

WHERE d.tempo_sk IS NULL;