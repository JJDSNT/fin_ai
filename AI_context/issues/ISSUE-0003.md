---
id: ISSUE-0003
title: "PETR4: validar o sinal dos 4 indicadores no ativo-objeto"
status: backlog
priority: high
type: validation
owner: agent
strategy: petr4-opcoes-atm
validation_stage: sinal
created_at: 2026-09-13
updated_at: 2026-09-13
tags:
  - petr4
  - sinal
  - backtest
blockers:
  - "ISSUE-0001 — terminal conectado com histórico de PETR4"
  - "ISSUE-0002 — decisões D4, D5 e D6"
related_files:
  - estrategias/petr4-opcoes-atm/README.md
  - mql5/Include/FinAI/SignalScore.mqh
  - mql5/Experts/FinAI/Petr4SignalTest.mq5
---

# Por quê

A estratégia **compra opções**, então o sinal precisa prever movimentos de alta **grandes e rápidos o suficiente** para vencer o theta e o spread. Acertar só a direção não basta. Se o sinal não mostra isso na própria PETR4, não faz sentido seguir para as opções (etapa 1 do plano de validação da ficha).

# O quê

- `SignalScore.mqh`: os 4 indicadores e o score (tendência obrigatória + ≥ 2 de 3).
- `Petr4SignalTest.mq5`: EA que opera **PETR4 à vista** só com o sinal de alta e saídas por ATR (stop/alvo/tempo), para medir o comportamento do sinal.
- Backtest com ticks reais ou OHLC M1, período in-sample e out-of-sample definidos antes.
- Exportar os sinais (data/hora, preço, ATR, resultado) em CSV para a ISSUE-0004.

Fora do escopo: opções, otimização agressiva de parâmetros.

# Próximos passos de validação

- [ ] Implementar `SignalScore.mqh` e `Petr4SignalTest.mq5`; compilar → sem erros
- [ ] Definir períodos: in-sample (ex.: 2 anos) e out-of-sample (último ano, **não olhado antes**) → registrado nesta issue
- [ ] Backtest in-sample → relatório + entrada no `diario/`
- [ ] Medir, por sinal: movimento máximo a favor (MFE) e contra (MAE) em 1, 3 e 5 pregões, em múltiplos de ATR → CSV
- [ ] Backtest out-of-sample com os **mesmos parâmetros** → comparar com in-sample
- [ ] Sensibilidade: variar cada parâmetro ±20% → verificar se há platô ou pico isolado
- [ ] Exportar CSV de sinais → insumo da ISSUE-0004

# Critério de sucesso / falha

Proposta, a confirmar antes de rodar:

- Sucesso se, **out-of-sample**:
  - ≥ 30 sinais
  - mediana do MFE em 5 pregões ≥ 1,5 × ATR
  - payoff esperado positivo no ativo, após custos
  - resultado não depende de um único parâmetro exato (platô)
- Falha se: MFE mediano < 1 × ATR, ou o out-of-sample for muito pior que o in-sample (sinal de overfitting).

# Evidências

—

# Decisões tomadas

—

# Log

- 2026-09-13: criada a partir da etapa 1 do plano de validação da ficha.
