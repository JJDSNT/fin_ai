---
id: ISSUE-0005
title: "Corretora: o que o MT5 oferece para opções de PETR4 (gregas, SL/TP, histórico, demo)"
status: backlog
priority: medium
type: research
owner: agent
strategy: petr4-opcoes-atm
validation_stage: ideia
created_at: 2026-09-13
updated_at: 2026-09-13
tags:
  - opcoes
  - corretora
  - mt5
  - gregas
blockers:
  - "ISSUE-0001 — terminal conectado à corretora"
related_files:
  - estrategias/petr4-opcoes-atm/README.md
  - mql5/Scripts/FinAI/InfoSimbolo.mq5
---

# Por quê

Várias partes da estratégia dependem de recursos que **variam por corretora** e que a ficha marcou como "confirmar":

- as gregas vêm prontas (`SYMBOL_PRICE_DELTA`/`GAMMA`/`THETA`/`VEGA`/`VOLATILITY`) ou precisam ser calculadas?
- SL/TP é aceito em posições de opções (caminho A da OCO)?
- quanto histórico de opções existe no servidor?
- a conta demo tem opções e book realista?

Se algum desses faltar, o desenho do script e do EA gerente muda **antes** da implementação.

# O quê

Script de levantamento em MQL5 (ou extensão do `InfoSimbolo`) que, para as opções de PETR4 disponíveis, imprime:
- `SYMBOL_BASIS`, `SYMBOL_OPTION_RIGHT`, `SYMBOL_OPTION_STRIKE`, `SYMBOL_OPTION_MODE`, `SYMBOL_EXPIRATION_TIME`
- gregas `SYMBOL_PRICE_*`, bid/ask e volume do dia
- volume mínimo/step e modos de preenchimento

Mais testes manuais em demo: `order_check` com SL/TP numa opção e ordem limitada com `ORDER_FILLING_RETURN`.

# Próximos passos de validação

- [ ] Listar opções de PETR4 via `SYMBOL_BASIS` → quantidade por vencimento e tipo
- [ ] Verificar se `SYMBOL_PRICE_DELTA` etc. vêm preenchidos → sim/não por campo
- [ ] Comparar as gregas da corretora com o Black-Scholes próprio → diferença típica (define D1b)
- [ ] `order_check` de compra limitada com SL/TP numa call ATM → retcode
- [ ] Verificar histórico de candles de uma opção do vencimento anterior → existe ou não
- [ ] Verificar book (Alt+B) de opções ATM na demo → realista ou vazio

# Critério de sucesso / falha

- Sucesso se: todos os itens acima têm resposta registrada (sim/não + evidência). Não é sobre a corretora "ter tudo", e sim sobre **saber** o que ela tem.
- Consequências já previstas:
  - sem gregas da corretora → implementar `BlackScholes.mqh` (já planejado)
  - sem SL/TP em opções → OCO só pelo ativo-objeto; EA gerente vira obrigatório e precisa de VPS
  - demo sem opções → etapa de demo vira paper trading manual com preços reais

# Evidências

—

# Decisões tomadas

—

# Log

- 2026-09-13: criada a partir dos pontos "confirmar com a corretora" da ficha.
