# 01 — MetaTrader 5 na B3: visão geral

## O que é

O MetaTrader 5 (MT5), da MetaQuotes, é uma plataforma de trading com duas partes:

- **Terminal (cliente)**: roda na sua máquina. Mostra gráficos, executa robôs (Expert Advisors) e faz backtests.
- **Servidor MT5 da corretora**: recebe as ordens do terminal e as encaminha para a **B3** (bolsa). Em forex/CFD, a corretora executa contra ela mesma ou contra provedores de liquidez.

A linguagem nativa é o **MQL5**, parecida com C++. Existe também um pacote **Python** oficial para ler dados e enviar ordens.

> 🇧🇷 **Foco deste repositório: B3** (WIN e WDO). Forex aparece como referência secundária.

## MT4 × MT5

| | MT4 | MT5 |
|---|---|---|
| Linguagem | MQL4 | MQL5 (orientada a objetos, mais rápida) |
| Mercados | Forex/CFD | Forex, CFD, **bolsa (B3)**, futuros |
| Contas | só hedging | netting, exchange ou hedging |
| Strategy Tester | 1 thread, modelagem simples | multi-thread, **ticks reais**, rede de agentes, forward test |
| Python | não | pacote `MetaTrader5` |

👉 O MT4 não opera B3. Para a bolsa brasileira e para qualquer projeto novo: **MT5**.

## Instalação: Windows, não WSL

| | Onde |
|---|---|
| Terminal MT5 + MetaEditor | **Windows** |
| Python com o pacote `MetaTrader5` | **Windows** (o pacote não existe para Linux) |
| Este repositório, git, edição de código | WSL ou Windows, tanto faz |

O MT5 é um programa Windows. Existe um caminho via Wine no Linux, mas no WSL isso só acrescenta problemas (interface gráfica, desempenho, Python que não enxerga o terminal) sem nenhum ganho, já que o Windows está ali. O fluxo recomendado:

```
WSL: edita código no repo ──sync-mql5.sh──▶ Windows: MetaEditor compila, MT5 executa
WSL: python.exe python/...  ──────────────▶ Windows: Python conversa com o MT5
```

### Passo a passo

1. **Escolha a corretora** e habilite o MT5 na área do cliente. Em muitas corretoras a plataforma precisa ser ativada (e pode ter custo ou condições). Confira antes.
2. **Baixe o instalador indicado pela corretora** (ou o MT5 genérico em metatrader5.com e procure o servidor da corretora em *Arquivo → Abrir uma conta*).
3. **Conta demo / simulador B3**: peça à corretora. O servidor `MetaQuotes-Demo` **não** tem ativos da B3.
4. Faça login com o servidor informado (geralmente um de *produção* e outro de *demo*).
5. Na Observação do Mercado (Ctrl+M), adicione `WIN$N`, `WDO$N` e o contrato vigente (ex.: `WINV26`).

## Componentes do terminal

| Componente | Atalho | Uso |
|---|---|---|
| Observação do Mercado | Ctrl+M | lista de símbolos; clique direito → *Especificação* |
| Navegador | Ctrl+N | contas, indicadores, EAs, scripts |
| Caixa de Ferramentas | Ctrl+T | posições, histórico, **Diário** e **Experts** (logs) |
| Profundidade de mercado | Alt+B | livro de ofertas (book) |
| MetaEditor | F4 | editar e compilar MQL5 |
| Strategy Tester | Ctrl+R | backtest e otimização |
| Algo Trading | botão na barra | precisa estar **ligado** para EAs enviarem ordens |

**Pasta de dados**: *Arquivo → Abrir pasta de dados*. Dentro dela fica `MQL5/` (`Experts`, `Indicators`, `Scripts`, `Include`, `Files`, `Logs`). A pasta `mql5/` deste repositório espelha essa estrutura. Use `scripts/sync-mql5.sh` para copiar.

## Tipos de programa MQL5

| Tipo | Evento principal | Para quê |
|---|---|---|
| Expert Advisor (EA) | `OnTick` | robô que opera um gráfico |
| Indicador | `OnCalculate` | cálculo e desenho sobre o gráfico |
| Script | `OnStart` | executa uma vez e termina |
| Serviço | `OnStart` | roda em segundo plano sem gráfico |
| Include (`.mqh`) | — | código reutilizável |

## Modos de conta

| Modo | Como funciona | Onde aparece |
|---|---|---|
| **Exchange** / **Netting** | uma única posição por símbolo; ordens na direção oposta reduzem ou invertem | **B3 (exchange)** e algumas corretoras de forex |
| **Hedging** | várias posições independentes no mesmo símbolo, cada uma com ticket | maioria das corretoras de forex |

### 🇧🇷 Na B3: exchange

Na B3 existe **uma única posição por ativo**.

- Comprar 2 WIN e depois vender 3 WIN = posição final **vendida em 1**.
- Se você operar manualmente o mesmo ativo em que o EA está rodando, as posições **se misturam**. Use contas separadas ou não opere manualmente o ativo do robô.
- O código deve identificar suas posições por **símbolo + magic number**. O `EMACross.mq5` faz isso e funciona nos dois modos.

## Os contratos: WIN e WDO

| | Mini Índice (WIN) | Mini Dólar (WDO) |
|---|---|---|
| Objeto | Ibovespa futuro | taxa de câmbio R$/US$ futura |
| Tick mínimo | 5 pontos | 0,5 ponto |
| Valor do ponto | R$ 0,20 por contrato | R$ 10,00 por contrato |
| **Valor do tick** | **R$ 1,00** por contrato | **R$ 5,00** por contrato |
| Volume mínimo / step | 1 / 1 | 1 / 1 |
| Vencimento | meses pares, na quarta-feira mais próxima do dia 15 | todo mês, no 1º dia útil |
| Contrato cheio equivalente | IND (5× o WIN) | DOL (5× o WDO) |

⚠️ Especificações mudam: **sempre confira** com o script `InfoSimbolo` ou em *Especificação* do símbolo.

### Código de vencimento

`WIN` + **letra do mês** + **ano**. Ex.: `WINV26` = outubro/2026.

| F | G | H | J | K | M | N | Q | U | V | X | Z |
|---|---|---|---|---|---|---|---|---|---|---|---|
| jan | fev | mar | abr | mai | jun | jul | ago | set | out | nov | dez |

- **WIN** só tem vencimentos em meses pares: G, J, M, Q, V, Z.
- **WDO** vence todo mês. O contrato mais líquido costuma ser o do mês seguinte.

### Série contínua × contrato vigente

| | Série contínua (`WIN$N`, `WIN$`, `WDO$N`…) | Contrato vigente (`WINV26`) |
|---|---|---|
| Para quê | **backtest** e análise de longo prazo | **enviar ordens** |
| Negociável | ❌ não | ✅ sim |
| Observação | emenda vários vencimentos; pode ter saltos na rolagem. O nome e o tipo de ajuste variam por corretora | só tem histórico desde que foi lançado |

👉 Backtest na série contínua, EA rodando em demo/real no **gráfico do contrato vigente**, e troca de gráfico na **rolagem** (alguns dias antes do vencimento, quando a liquidez migra).

## Pregão e particularidades

- **Horário**: a grade da B3 muda ao longo do ano (acompanha o horário de verão dos EUA). Consulte o site da B3 e configure o EA para operar dentro da janela.
- **Leilões**: abertura e eventos de volatilidade suspendem a negociação contínua. Spread e slippage aumentam perto deles.
- **Day trade × posição**: a corretora exige **margem reduzida** para day trade, mas zera compulsoriamente perto do fim do pregão. Carregar posição para o dia seguinte exige a **garantia cheia da B3**.
- **Stops no MT5**: SL/TP ficam no servidor da corretora e, quando acionados, viram **ordens a mercado**. Em movimentos rápidos há slippage.
- **Custos**: corretagem (muitas corretoras zeram nos minicontratos), **emolumentos B3** por contrato e ISS. Não aparecem automaticamente no backtest.
- **Imposto de renda** (regras vigentes na escrita deste guia; confirme com um contador):
  - **day trade**: 20% sobre o lucro líquido mensal, com IRRF de 1% ("dedo-duro")
  - **swing trade**: 15%
  - a isenção de R$ 20 mil/mês vale só para **venda de ações** em swing trade, não para futuros
  - recolhimento via DARF (código 6015) até o último dia útil do mês seguinte

## B3 × Forex (referência)

| | 🇧🇷 B3 (ex.: WIN, WDO) | Forex (ex.: EURUSD) |
|---|---|---|
| Execução | bolsa, livro de ofertas real | corretora / provedores de liquidez |
| Contratos | futuros com **vencimento** (WINV26, WDOX26…) | spot/CFD sem vencimento |
| Série contínua | `WIN$`, `WIN$N`, `WDO$N`… (nome varia por corretora) | — |
| Valor do tick | WIN **R$ 1,00** / WDO **R$ 5,00** por contrato | depende do par e do lote |
| Lote | contratos inteiros (volume mínimo 1) | 1 lote = 100.000 da moeda base; mínimo geralmente 0,01 |
| Modo de conta | exchange | geralmente hedging |
| Custos | corretagem, emolumentos B3, IR | spread, comissão, swap overnight |
| Horário | pregão da B3 (com leilões) | ~24h de domingo a sexta |
| Regulação | CVM / B3 | corretoras de forex que atendem brasileiros costumam ser estrangeiras, fora da CVM |

## Checklist da fase

- [ ] MT5 instalado **no Windows** e conta demo B3 conectada (canto inferior direito mostra ping, não "sem conexão")
- [ ] `WIN$N`, `WDO$N` e contratos vigentes na Observação do Mercado
- [ ] Rodei `InfoSimbolo` e confirmei tick size, tick value e modo da conta (`ACCOUNT_MARGIN_MODE_EXCHANGE`)
- [ ] Sei o próximo vencimento do WIN e do WDO
- [ ] Anotei a grade horária atual da B3
- [ ] Encontrei a pasta de dados e sincronizei `mql5/`
