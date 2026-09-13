---
id: ISSUE-0002
title: "PETR4 opções: fechar as decisões em aberto da ficha"
status: backlog
priority: high
type: research
owner: jaime
strategy: petr4-opcoes-atm
validation_stage: ideia
created_at: 2026-09-13
updated_at: 2026-09-13
tags:
  - petr4
  - opcoes
  - decisoes
blockers: []
related_files:
  - estrategias/petr4-opcoes-atm/README.md
---

# Por quê

A ficha tem decisões em aberto (seção 7) que definem **o que** vai ser testado. Sem elas fechadas, o teste do sinal (ISSUE-0003) e a simulação da put (ISSUE-0004) testam uma estratégia indefinida, e o risco é ajustar as regras depois de ver os resultados (overfitting).

# O quê

Decidir e registrar na ficha:

| # | Decisão | Sugestão atual | Bloqueia |
|---|---|---|---|
| D1 | Checagens das gregas sobre o strike mais próximo | Δ 0,40–0,60, \|Θ\| ≤ 3%/dia, IV ≤ 1,3×HV20 | ISSUE-0004 |
| D1b | Fonte das gregas | corretora + cálculo próprio | ISSUE-0005 |
| D3 | "Próximo vencimento" | série mais próxima com ≥ 10 d.u. | ISSUE-0004 |
| D4 | Timeframe e horizonte | swing H1 + filtro D1, 2–5 pregões | **ISSUE-0003** |
| D5 | Quais 4 indicadores | EMA20×50, RSI14, ADX14, volume real | **ISSUE-0003** |
| D6 | Saída | no ativo + SL/TP de emergência na opção | ISSUE-0003 |
| D7 | Risco por operação | 2% do capital em prêmio | ISSUE-0004 |
| D8 | Execução | script com confirmação | implementação |
| D10 | Quando comprar a put | sugerir quando piso ≥ 0; decisão manual | ISSUE-0004 |
| D11 | Comparação | piso × vender a call × CDI | ISSUE-0004 |

Já decididas: D2 (uma operação por vez; put só como perna protetora) e D9 (put equivalente = mesmo vencimento e quantidade, K_put ≥ K_call).

# Próximos passos de validação

- [ ] Usuário decide D4, D5 e D6 → registrado na ficha (desbloqueia ISSUE-0003)
- [ ] Usuário decide D1, D3, D7, D10 e D11 → registrado na ficha (desbloqueia ISSUE-0004)
- [ ] D1b depende do que a corretora fornece (ISSUE-0005)
- [ ] Congelar as regras: versão `v0.1` da ficha, com data

# Critério de sucesso / falha

- Sucesso se: todas as decisões que bloqueiam ISSUE-0003 e ISSUE-0004 estão registradas na ficha **antes** de qualquer resultado de teste.
- Falha se: alguma regra for alterada depois de ver resultados sem registrar o motivo na ficha e nesta issue.

# Evidências

—

# Decisões tomadas

- 2026-09-13: D2 e D9 decididas (ver ficha, seções 6 e 7).
- 2026-09-13: strike mais próximo é o padrão; gregas quantificam e servem como checagem.

# Log

- 2026-09-13: criada a partir da seção 7 da ficha.
