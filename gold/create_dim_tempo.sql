CREATE TABLE dbo.dim_tempo (
    tempo_sk BIGINT IDENTITY,

    ano_mes VARCHAR(6),
    ano INT,
    mes INT
);