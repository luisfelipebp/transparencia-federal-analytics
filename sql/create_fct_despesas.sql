CREATE TABLE dbo.fct_despesas (
    despesa_sk BIGINT IDENTITY,

    orgao_sk BIGINT,
    programa_sk BIGINT,
    localidade_sk BIGINT,
    natureza_despesa_sk BIGINT,
    tempo_sk BIGINT,

    valor_empenhado_reais DECIMAL(18,2),
    valor_liquidado_reais DECIMAL(18,2),
    valor_pago_reais DECIMAL(18,2),

    valor_restos_a_pagar_inscritos_reais DECIMAL(18,2),
    valor_restos_a_pagar_cancelado_reais DECIMAL(18,2),
    valor_restos_a_pagar_pagos_reais DECIMAL(18,2)
);
