# 01 — MetaTrader 5: visão geral

## O que é

O MetaTrader 5 (MT5), da MetaQuotes, é uma plataforma de trading com duas partes:

- **Terminal (cliente)**: roda na sua máquina. Mostra gráficos, executa robôs (Expert Advisors) e faz backtests.
- **Servidor da corretora**: recebe as ordens e manda para o mercado (bolsa) ou executa contra a própria corretora (forex/CFD).

A linguagem nativa é o **MQL5**, parecida com C++. Existe também um pacote **Python** oficial para ler dados e enviar ordens.

## MT4 × MT5

| | MT4 | MT5 |
|---|---|---|
| Linguagem | MQL4 | MQL5 (orientada a objetos, mais rápida) |
| Mercados | Forex/CFD | Forex, CFD, **bolsa (B3)**, futuros |
| Contas | só hedging | netting, exchange ou hedging |
| Strategy Tester | 1 thread, modelagem simples | multi-thread, **ticks reais**, rede de agentes, forward test |
| Python | não | pacote `MetaTrader5` |

👉 Para B3 e para qualquer projeto novo: **MT5**.

## Componentes do terminal

| Componente | Atalho | Uso |
|---|---|---|
| Observação do Mercado | Ctrl+M | lista de símbolos; clique direito → *Especificação* |
| Navegador | Ctrl+N | contas, indicadores, EAs, scripts |
| Caixa de Ferramentas | Ctrl+T | posições, histórico, **Diário** e **Experts** (logs) |
| MetaEditor | F4 | editar e compilar MQL5 |
| Strategy Tester | Ctrl+R | backtest e otimização |
| Algo Trading | botão na barra | precisa estar **ligado** para EAs enviarem ordens |

**Pasta de dados**: *Arquivo → Abrir pasta de dados*. Dentro dela fica `MQL5/` (`Experts`, `Indicators`, `Scripts`, `Include`, `Files`, `Logs`). A pasta `mql5/` deste repositório espelha essa estrutura — use `scripts/sync-mql5.sh` para copiar.

## Tipos de programa MQL5

| Tipo | Evento principal | Para quê |
|---|---|---|
| Expert Advisor (EA) | `OnTick` | robô que opera um gráfico |
| Indicador | `OnCalculate` | cálculo e desenho sobre o gráfico |
| Script | `OnStart` | executa uma vez e termina |
| Serviço | `OnStart` | roda em segundo plano sem gráfico |
| Include (`.mqh`) | — | código reutilizável |

## Modos de conta (importante!)

| Modo | Como funciona | Onde aparece |
|---|---|---|
| **Netting** / **Exchange** | uma única posição por símbolo; ordens na direção oposta reduzem ou invertem | B3 (exchange) e algumas corretoras de forex |
| **Hedging** | várias posições independentes no mesmo símbolo, cada uma com ticket | maioria das corretoras de forex |

Consequências práticas:
- Em netting, se você operar manualmente o mesmo ativo que o EA, as posições se **misturam**.
- O código deve identificar suas posições por **símbolo + magic number** (o `EMACross.mq5` faz isso e funciona nos dois modos).

## B3 × Forex

| | B3 (ex.: WIN, WDO) | Forex (ex.: EURUSD) |
|---|---|---|
| Execução | bolsa, livro de ofertas real | corretora / provedores de liquidez |
| Contratos | futuros com **vencimento** (WINV26, WDOX26…) | spot/CFD sem vencimento |
| Série contínua | `WIN$`, `WIN$N`, `WDO$N`… (nome varia por corretora) | — |
| Mini índice (WIN) | tick 5 pontos; 1 ponto = R$ 0,20 → **R$ 1,00 por tick** por contrato | — |
| Mini dólar (WDO) | tick 0,5 ponto; 1 ponto = R$ 10 → **R$ 5,00 por tick** por contrato | — |
| Lote | contratos inteiros (volume mínimo 1) | 1 lote = 100.000 da moeda base; mínimo geralmente 0,01 |
| Custos | corretagem, emolumentos B3, IR | spread, comissão, swap overnight |
| Horário | pregão da B3 (com leilões de abertura/fechamento) | ~24h de domingo a sexta |
| Regulação | CVM / B3 | corretoras de forex que atendem brasileiros costumam ser estrangeiras, fora da CVM |

⚠️ Especificações mudam: **sempre confira** com o script `InfoSimbolo` ou em *Especificação* do símbolo.

⚠️ Em backtest, use a série contínua. Em conta real/demo da B3, ordens vão para o **contrato vigente**, e é preciso lidar com a rolagem.

## Checklist da fase

- [ ] Conta demo aberta e conectada (canto inferior direito mostra ping, não "sem conexão")
- [ ] Sei o modo da conta (rode `InfoSimbolo` ou `python/info_conta.py`)
- [ ] Anotei as especificações dos ativos que vou estudar
- [ ] Encontrei a pasta de dados e sincronizei `mql5/`
