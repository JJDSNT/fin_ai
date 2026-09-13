---
id: ISSUE-0004
title: "PETR4 opções: simular call + put protetora e a frequência do piso positivo"
status: backlog
priority: medium
type: validation
owner: agent
strategy: petr4-opcoes-atm
validation_stage: simulacao
created_at: 2026-09-13
updated_at: 2026-09-13
tags:
  - petr4
  - opcoes
  - gregas
  - put-protetora
  - simulacao
blockers:
  - "ISSUE-0003 — CSV de sinais validados"
  - "ISSUE-0002 — decisões D1, D3, D7, D10 e D11"
related_files:
  - estrategias/petr4-opcoes-atm/README.md
  - python/simular_opcoes.py
---

# Por quê

A premissa central é: **"com a put equivalente aberta, na pior hipótese tenho renda fixa"**. A conta da seção 6 da ficha mostra que isso é verdade **só quando** K_put > K_call e PETR4 já subiu o suficiente para que `(K_put − K_call) − prêmio_call − prêmio_put ≥ 0`. Falta saber **com que frequência** isso acontece nos sinais reais e se vale mais que simplesmente vender a call.

Como o MT5 não guarda histórico de opções vencidas, a validação precisa ser por simulação (etapa 2 do plano).

# O quê

`python/simular_opcoes.py`, que para cada sinal da ISSUE-0003:

1. Escolhe a call pelo strike mais próximo e aplica as checagens das gregas (D1), usando Black-Scholes com IV estimada (HV20 × fator, ou IV real se houver).
2. Simula a evolução diária da call com o preço real de PETR4 (theta incluso) e aplica spread estimado.
3. A cada dia, calcula o **piso** que uma put equivalente (strike mais próximo ≥ K_call) travaria.
4. Compara três políticas:
   - **A**: só call, saídas por ATR/tempo
   - **B**: call + put quando piso ≥ 0, saída perto do vencimento ou em movimento forte
   - **C**: vender a call no momento em que a B compraria a put
5. Compara com o **CDI** do período sobre o capital empregado.

Fora do escopo: dados reais de book de opções (tratados na ISSUE-0005 e na etapa de demo).

# Próximos passos de validação

- [ ] Validar a implementação do Black-Scholes contra os exemplos da ficha (seções 2 e 6) → mesmos números
- [ ] Rodar a simulação com os sinais in-sample → distribuição de resultados das políticas A, B e C
- [ ] Medir: % de operações em que o piso ≥ 0 foi atingido, dias até atingir, valor médio do piso travado
- [ ] Sensibilidade a IV (±5 pontos) e spread (2%, 5%, 10%) → a conclusão muda?
- [ ] Rodar out-of-sample → confirmar
- [ ] Registrar no `diario/` e atualizar a ficha

# Critério de sucesso / falha

Proposta, a confirmar antes de rodar:

- Sucesso se:
  - política A tem payoff esperado positivo após spread e theta
  - política B tem pior resultado (percentil 5) melhor que A, sem reduzir o resultado médio em mais de 30%
  - a conclusão se mantém com spread de 5% e IV ±5 pontos
- Falha se: A é negativa (o sinal não sustenta compra de opção), ou B é consistentemente pior que C (vender a call domina a put protetora).
- Inconclusivo se: menos de 30 operações simuladas.

# Evidências

Cálculo de referência (Black-Scholes, IV 28%, juros 14%), já na ficha:

- call 38,50 a 1,50; PETR4 a 42,40 com 21 dias → put 42,50 a 1,02 → **piso +1,48**; vender a call daria +2,78
- mesmo strike (put 38,50) → piso −1,57: não trava nada

# Decisões tomadas

- 2026-09-13: "put equivalente" exige K_put ≥ K_call (mesmo strike não gera piso).

# Log

- 2026-09-13: criada a partir das seções 6 e 9 da ficha.
