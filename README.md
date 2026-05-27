# Transparência Federal Analytics

> Plataforma de analytics sobre execução orçamentária do governo federal brasileiro, construída integralmente no **Microsoft Fabric** com arquitetura Medallion (Bronze → Silver → Gold), modelagem dimensional Star Schema e processamento em PySpark e T-SQL.

---

## Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Stack](#stack)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Modelo de Dados](#modelo-de-dados)
- [Notebooks](#notebooks)
- [Como Executar](#como-executar)
- [Decisões de Arquitetura](#decisões-de-arquitetura)
- [O que este projeto demonstra](#o-que-este-projeto-demonstra)

---

## Visão Geral

Este projeto implementa uma plataforma de analytics sobre dados públicos de despesas do governo federal brasileiro, do **Portal da Transparência da CGU** (Controladoria-Geral da União). O objetivo é transformar arquivos brutos de execução orçamentária em uma camada analítica confiável e consultável via SQL, com modelagem dimensional pronta para consumo em BI.

**Perguntas de negócio respondidas:**

- Qual a evolução mensal dos valores empenhados, liquidados e pagos por órgão?
- Quais funções e programas governamentais concentram maior volume de despesas?
- Como se distribui a execução orçamentária por natureza de despesa e localidade?
- Qual o volume de Restos a Pagar em aberto por período e unidade gestora?

**Fonte de dados:** Portal da Transparência — CGU  
**Domínio:** Execução orçamentária federal (despesas por empenho, liquidação e pagamento)  
**Periodicidade:** Carga incremental mensal

---

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Microsoft Fabric Workspace                         │
│                                                                             │
│  AQUISIÇÃO (manual)                                                         │
│  ──────────────────────────────────────────────────────────────────────     │
│  [Portal da Transparência]                                                  │
│         │  download manual de arquivos governamentais                       │
│         ▼                                                                   │
│  ┌─────────────────────────────────────┐                                   │
│  │   LAKEHOUSE — transparencia_lh      │                                   │
│  │                                     │                                   │
│  │  Files/                             │                                   │
│  │  └── bronze/                        │  ← arquivos brutos (.csv/.zip)    │
│  │       ├── despesas_2024_01.csv      │                                   │
│  │       ├── despesas_2024_02.csv      │                                   │
│  │       └── ...                       │                                   │
│  └──────────────────┬──────────────────┘                                   │
│                     │                                                       │
│                     ▼  Notebook: bronze_to_silver.ipynb (PySpark)          │
│  ┌─────────────────────────────────────┐                                   │
│  │  Tables/                            │                                   │
│  │  └── silver_despesas                │  ← Delta table, incremental       │
│  └──────────────────┬──────────────────┘                                   │
│                     │                                                       │
│                     ▼  SQL Warehouse: gold_layer.sql (T-SQL)               │
│  ┌─────────────────────────────────────────────────────────────┐           │
│  │   SQL WAREHOUSE — transparencia_wh                          │           │
│  │                                                             │           │
│  │   dim_orgao          dim_programa      dim_natureza_despesa │           │
│  │   dim_localidade     dim_tempo                              │           │
│  │                        ↕                                   │           │
│  │                  fct_despesas                               │           │
│  └──────────────────────────┬──────────────────────────────────┘           │
│                             │                                               │
│                             ▼                                               │
│                    ┌─────────────────┐                                     │
│                    │  Semantic Model │ → Power BI Report                   │
│                    └─────────────────┘                                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

**Fluxo de dados:**

```
[Portal da Transparência]
        │  download manual
        ▼
[Bronze] Files/bronze/*.csv   ← armazenamento histórico, sem transformação
        │
        ▼  PySpark (bronze_to_silver.ipynb)
[Silver] Tables/silver_despesas  ← Delta table, schema padronizado, suporte a cargas incrementais mensais
        │
        ▼  T-SQL (gold_layer.sql no SQL Warehouse)
[Gold]   dim_* + fct_despesas  ← Star Schema, surrogate keys, pronto para BI
        │
        ▼
[Semantic Model → Power BI]
```

---

## Stack

| Camada              | Tecnologia                          | Papel                                              |
|---------------------|-------------------------------------|----------------------------------------------------|
| Armazenamento       | Microsoft Fabric Lakehouse          | OneLake — Bronze (Files) e Silver (Delta Tables)  |
| Processamento       | PySpark (Fabric Notebooks)          | Transformação Bronze → Silver                      |
| Camada analítica    | Fabric SQL Warehouse (T-SQL)        | Star Schema — dimensões e fato (Gold)              |
| Formato de dados    | Delta Lake                          | ACID, time travel, carga incremental               |
| Modelagem           | Star Schema / Kimball               | Dimensional modeling com surrogate keys            |
| Visualização        | Power BI (Semantic Model)           | Relatório analítico sobre camada Gold              |
| Plataforma          | Microsoft Fabric                    | Ambiente unificado de analytics                    |

**Fonte de dados:** [Portal da Transparência — CGU](https://portaldatransparencia.gov.br/download-de-dados/despesas)  
Arquivos CSV mensais de execução de despesas do governo federal.

---

## Estrutura do Projeto

```
transparencia-federal-analytics/
│
├── README.md
│
├── notebooks/
│   ├── 01_bronze_to_silver.ipynb     # PySpark: ingestão, padronização, MERGE incremental
│   └── 02_exploration.ipynb          # EDA exploratória na camada Silver
│
├── sql/
│   ├── gold/
│   │   ├── 01_dim_tempo.sql          # Dimensão calendário
│   │   ├── 02_dim_orgao.sql          # Dimensão estrutura administrativa
│   │   ├── 03_dim_programa.sql       # Dimensão funcional-programática
│   │   ├── 04_dim_natureza_despesa.sql
│   │   ├── 05_dim_localidade.sql
│   │   └── 06_fct_despesas.sql       # Tabela fato principal
│   └── semantic_model/
│       └── measures.md               # Medidas DAX documentadas
│
├── docs/
│   ├── architecture.png              # Diagrama de arquitetura
│   ├── data_model.png                # ERD do Star Schema
│   └── lineage_screenshot.png        # Lineage do Fabric
│
└── data/
    └── README.md                     # Instruções de download dos arquivos
```

---

## Modelo de Dados

O Gold Layer implementa um **Star Schema** no SQL Warehouse do Fabric, seguindo a Metodologia de Kimball. A granularidade da tabela fato é o **empenho individual** — o evento de menor granularidade na execução orçamentária federal.

```
                    ┌─────────────────────┐
                    │     dim_tempo       │
                    │─────────────────────│
                    │ tempo_sk        PK  │
                    │ ano_mes             │
                    │ ano                 │
                    │ mes                 │
                    │ trimestre           │
                    │ nome_mes            │
                    └──────────┬──────────┘
                               │
   ┌──────────────────┐        │        ┌────────────────────────┐
   │    dim_orgao     │        │        │    dim_programa         │
   │──────────────────│        │        │────────────────────────│
   │ orgao_sk     PK  │        │        │ programa_sk        PK  │
   │ codigo_orgao     │        │        │ codigo_funcao          │
   │ nome_orgao_sup   │        ▼        │ nome_funcao            │
   │ nome_unid_gest   ├──►┌────────────────┐◄──┤ codigo_subfuncao      │
   │ nome_unid_orc    │   │ fct_despesas   │   │ nome_subfuncao        │
   └──────────────────┘   │────────────────│   │ codigo_programa       │
                          │ despesa_sk PK  │   │ nome_programa         │
   ┌──────────────────┐   │ orgao_sk   FK  │   │ codigo_acao           │
   │  dim_localidade  │   │ programa_sk FK │   └────────────────────────┘
   │──────────────────│   │ natureza_sk FK │
   │ localidade_sk PK │   │ localidade_sk  │   ┌────────────────────────┐
   │ uf_sigla         ├──►│ tempo_sk    FK │   │  dim_natureza_despesa  │
   │ uf_nome          │   │────────────────│   │────────────────────────│
   │ municipio        │   │ vl_empenhado   │   │ natureza_sk        PK  │
   │ pais             │   │ vl_liquidado   │◄──┤ categoria_econ         │
   │ localizador      │   │ vl_pago        │   │ grupo_desp             │
   └──────────────────┘   │ vl_rp_inscrito │   │ elemento               │
                          │ vl_rp_pago     │   │ subelemento            │
                          └────────────────┘   └────────────────────────┘
```

### Dimensões

**`dim_orgao`** — Estrutura administrativa hierárquica do governo federal.

| Coluna          | Descrição                                      |
|-----------------|------------------------------------------------|
| `orgao_sk`      | Surrogate key (IDENTITY)                       |
| `codigo_orgao`  | Código natural do órgão superior               |
| `nome_orgao_sup`| Nome do órgão superior (ex: Ministério da Saúde)|
| `cod_unid_gest` | Código da unidade gestora                      |
| `nome_unid_gest`| Nome da unidade gestora executora              |
| `cod_unid_orc`  | Código da unidade orçamentária                 |
| `nome_unid_orc` | Nome da unidade orçamentária                   |

**`dim_programa`** — Classificação funcional-programática das despesas.

| Coluna            | Descrição                                    |
|-------------------|----------------------------------------------|
| `programa_sk`     | Surrogate key (IDENTITY)                     |
| `codigo_funcao`   | Código da função de governo                  |
| `nome_funcao`     | Ex: Saúde, Educação, Defesa Nacional         |
| `codigo_subfuncao`| Código da subfunção                          |
| `nome_subfuncao`  | Detalhamento da subfunção                    |
| `codigo_programa` | Código do programa governamental             |
| `nome_programa`   | Nome do programa                             |
| `codigo_acao`     | Código da ação orçamentária                  |
| `nome_acao`       | Descrição da ação                            |

**`dim_natureza_despesa`** — Categorização econômica e contábil das despesas.

| Coluna             | Descrição                                   |
|--------------------|---------------------------------------------|
| `natureza_sk`      | Surrogate key (IDENTITY)                    |
| `categoria_econ`   | Categoria econômica (corrente/capital)      |
| `grupo_desp`       | Grupo de despesa (pessoal, custeio etc.)    |
| `elemento`         | Elemento de despesa                         |
| `subelemento`      | Subelemento detalhado                       |
| `modalidade_aplic` | Modalidade de aplicação                     |

**`dim_localidade`** — Informações territoriais de execução do gasto.

| Coluna          | Descrição                                      |
|-----------------|------------------------------------------------|
| `localidade_sk` | Surrogate key (IDENTITY)                       |
| `uf_sigla`      | Sigla do estado (ex: SP, RJ, BA)              |
| `uf_nome`       | Nome do estado                                 |
| `municipio`     | Nome do município de execução                  |
| `pais`          | País (para despesas no exterior)               |
| `localizador`   | Código localizador do gasto                    |

**`dim_tempo`** — Calendário analítico mensal.

| Coluna       | Descrição                             |
|--------------|---------------------------------------|
| `tempo_sk`   | Surrogate key (formato YYYYMM)        |
| `ano_mes`    | Data de referência (YYYY-MM-01)       |
| `ano`        | Ano de competência                    |
| `mes`        | Número do mês (1–12)                  |
| `nome_mes`   | Nome por extenso                      |
| `trimestre`  | Trimestre (Q1–Q4)                     |
| `semestre`   | Semestre (S1/S2)                      |

### Tabela Fato

**`fct_despesas`** — Métricas financeiras federais no grão do empenho individual.

| Coluna           | Descrição                                                    |
|------------------|--------------------------------------------------------------|
| `despesa_sk`     | Surrogate key (IDENTITY)                                     |
| `orgao_sk`       | FK → dim_orgao                                               |
| `programa_sk`    | FK → dim_programa                                            |
| `natureza_sk`    | FK → dim_natureza_despesa                                    |
| `localidade_sk`  | FK → dim_localidade                                          |
| `tempo_sk`       | FK → dim_tempo                                               |
| `nr_empenho`     | Número do empenho (chave natural)                            |
| `vl_empenhado`   | Valor empenhado — compromisso orçamentário                   |
| `vl_liquidado`   | Valor liquidado — entrega do bem/serviço confirmada          |
| `vl_pago`        | Valor efetivamente pago ao credor                            |
| `vl_rp_inscrito` | Restos a Pagar inscritos                                     |
| `vl_rp_pago`     | Restos a Pagar pagos                                         |


---

## Notebooks

### `01_bronze_to_silver.ipynb` — PySpark

Responsável por transformar os arquivos CSV brutos da camada Bronze em uma Delta table limpa e tipada na camada Silver.

**Principais desafios tratados:**
- Encoding `latin1` dos arquivos governamentais
- Campos com valores "Não se aplica" tratados como `NULL`
- suporte a cargas incrementais mensais

---

## Decisões de Arquitetura

### 1. Ingestão manual para Bronze em vez de pipeline HTTP automatizado

**Decisão:** Upload manual dos arquivos CSV para `Files/bronze/` no Lakehouse.

**Por quê:** Os arquivos do Portal da Transparência apresentaram inconsistências de comportamento com o conector HTTP nativo do Data Factory no Fabric — falhas intermitentes, timeouts e variações no formato de resposta entre endpoints governamentais. Forçar automação aqui introduziria instabilidade na camada mais crítica do pipeline: a aquisição dos dados brutos.

**Trade-off aceito:** O processo de aquisição é semi-manual (download + upload mensal). Isso é aceitável porque os dados são estáticos por mês — não há streaming ou near-real-time neste domínio. 

**Padrão reconhecido:** Separar aquisição de transformação é uma prática consolidada em arquiteturas de dados com fontes instáveis ou legadas. Dados chegam exatamente como vieram da fonte, sem transformação, preservando rastreabilidade total.

---

### 2. PySpark para Bronze → Silver; T-SQL para Silver → Gold

**Decisão:** Dois engines diferentes para dois propósitos diferentes.

**PySpark no notebook:** Os arquivos governamentais têm encoding `latin1`, separadores de milhar e decimal no padrão brasileiro e colunas com valores textuais misturados com numéricos — problemas que exigem manipulação expressiva de strings antes do cast. PySpark + funções de regex resolvem isso de forma fluida e escalável.

**T-SQL no SQL Warehouse:** A camada Gold é pura modelagem dimensional — JOINs, surrogate keys com IDENTITY, MERGE com chaves de negócio e carga incremental determinística. T-SQL é a linguagem nativa para isso e o SQL Warehouse do Fabric entrega performance analítica otimizada para este padrão. Não faz sentido usar Spark para o que o banco relacional faz melhor.

---

### 3. Star Schema com surrogate keys no SQL Warehouse, não no Lakehouse

**Decisão:** Dimensões e fato criadas no SQL Warehouse, não como Delta tables no Lakehouse.

**Por quê:** O SQL Warehouse do Fabric oferece IDENTITY columns (auto-incremento gerenciado), constraints declarativas e otimizador de queries SQL nativo — features que o Lakehouse não tem de forma equivalente. Para um modelo dimensional com relacionamentos 1:N entre dimensões e fato, o Warehouse é o ambiente correto.

**Surrogate keys:** Implementadas via `IDENTITY(1,1)` no Warehouse. Diferente do Lakehouse (onde a prática é MD5 para idempotência), no Warehouse com carga controlada por T-SQL o IDENTITY é o padrão correto — a idempotência é garantida pelo MERGE na lógica de carga, não pelo hash da chave.

---

### 4. Granularidade da fato no empenho individual

**Decisão:** `fct_despesas` no grão do empenho, não do órgão ou do programa.

**Por quê:** O empenho é o evento transacional de menor granularidade no ciclo orçamentário federal — representa o compromisso legal do gasto. Modelar nesse grão permite agregar por qualquer combinação dimensional (órgão + programa + período + localidade) sem perda de precisão. Qualquer granularidade maior (por órgão/mês, por exemplo) destruiria informação que não pode ser recuperada depois.

---

## O que este projeto demonstra

### Componentes do Microsoft Fabric utilizados

| Feature Fabric                    | Onde aparece no projeto                            |
|-----------------------------------|----------------------------------------------------|
| Lakehouse (OneLake)               | Bronze (Files) e Silver (Delta Tables)            |
| PySpark Notebooks                 | Transformação Bronze → Silver                      |
| Delta Lake (MERGE, time travel)   | Carga incremental idempotente na Silver            |
| Fabric SQL Warehouse              | Star Schema completo em T-SQL                      |
| Semantic Model                    | Medidas DAX sobre a camada Gold                    |
| Power BI Report                   | Visualizações analíticas das despesas              |
| Workspace organization            | Separação de artefatos por responsabilidade        |

### Competências de Engenharia de Dados

- **Medallion Architecture** (Bronze / Silver / Gold) com responsabilidades bem definidas por camada
- **Ingestão incremental** com MERGE INTO — idempotência garantida mesmo em recargas
- **Tratamento de dados governamentais** — encoding não-padrão, formatos de moeda brasileiros, campos com valores textuais mistos
- **Modelagem dimensional (Kimball / Star Schema)** — 5 dimensões + 1 tabela fato no grão correto
- **Separação de engines por propósito** — PySpark para transformação, T-SQL para modelagem analítica
- **Decisões de arquitetura documentadas** com trade-offs explícitos

---

**Fonte dos dados:** [Portal da Transparência — CGU](https://portaldatransparencia.gov.br/download-de-dados/despesas)  
Os dados são públicos, de domínio governamental aberto, disponibilizados pela Controladoria-Geral da União.
