# 05 — Gestão de risco (B3)

> Uma estratégia medíocre com bom controle de risco sobrevive. Uma estratégia boa sem controle de risco quebra.

## Assimetria das perdas

| Perda | Ganho necessário para voltar |
|---|---|
| −10% | +11% |
| −25% | +33% |
| −50% | +100% |
| −75% | +300% |

Por isso o foco é **limitar a perda**, não maximizar o ganho.

## Dimensionamento por risco fixo

Arriscar uma fração fixa do saldo por trade (ex.: 0,5%–1%):

```
risco_R$            = saldo × risco%
perda_por_contrato  = (distância_do_stop / tick_size) × tick_value
contratos           = risco_R$ / perda_por_contrato   → arredondado para BAIXO
```

Implementado em `VolumeByRisk()` no [`RiskManager.mqh`](../../mql5/Include/FinAI/RiskManager.mqh).

### Exemplos

**Mini Índice (WIN)**: saldo R$ 10.000, risco 1% = R$ 100, stop de 200 pontos
- 200 pontos / tick 5 = 40 ticks × R$ 1,00 = **R$ 40 por contrato**
- 100 / 40 = 2,5 → **2 contratos**

**Mini Dólar (WDO)**: mesmo saldo e risco, stop de 5 pontos
- 5 / 0,5 = 10 ticks × R$ 5,00 = **R$ 50 por contrato**
- 100 / 50 = **2 contratos**

**EURUSD** (referência forex): saldo US$ 10.000, risco 1% = US$ 100, stop de 20 pips (0,0020)
- 1 lote: 1 pip ≈ US$ 10 → 20 pips = **US$ 200 por lote**
- 100 / 200 = **0,50 lote** (em forex o volume é fracionado, então o problema do capital pequeno abaixo quase não existe)

### Tabela rápida: risco de 1 contrato

| Stop WIN (pontos) | R$ | | Stop WDO (pontos) | R$ |
|---|---|---|---|---|
| 100 | 20 | | 2,0 | 20 |
| 200 | 40 | | 5,0 | 50 |
| 300 | 60 | | 10,0 | 100 |
| 500 | 100 | | 15,0 | 150 |

### O problema do capital pequeno

Na B3 o volume mínimo é **1 contrato**. Se o risco de 1 contrato passa do seu limite, **não opere**. Arredondar para cima é aceitar mais risco que o planejado (o `VolumeByRisk` devolve 0 nesse caso).

Exemplo: saldo R$ 2.000, risco 1% = R$ 20. Um stop de 300 pontos no WIN custa R$ 60 → volume 0. As saídas honestas são:
- stop menor, se a estratégia fizer sentido com ele (ex.: 100 pontos = R$ 20)
- aceitar risco maior **conscientemente** (3% aqui) e documentar no diário
- continuar em demo até ter capital compatível

## Margem ≠ risco

A corretora pede uma **margem de day trade** por contrato, bem menor que a garantia da B3. Margem baixa **não** significa risco baixo. Ela só determina quantos contratos você *consegue* abrir, não quantos *deve* abrir. O dimensionamento acima é o que define o tamanho.

⚠️ Se a posição passar para o dia seguinte (esquecimento, bug, zeragem que falhou), a exigência sobe para a **garantia cheia**. Sem saldo, a corretora pode liquidar a posição.

## Stop baseado em volatilidade

Stop fixo em pontos ignora o regime do mercado: 200 pontos no WIN é muito num dia calmo e pouco num dia de Copom. Usar **ATR × multiplicador** (como no `EMACross`) adapta o stop, e pelo cálculo acima o número de contratos diminui automaticamente quando a volatilidade sobe.

## Limites que todo EA deve ter

| Limite | Exemplo | Por quê |
|---|---|---|
| Risco por trade | 0,5%–1% do saldo | sobreviver a sequências de perdas |
| **Perda máxima diária** | 2%–3% | evita espiral em dia ruim ou bug |
| Posições simultâneas | 1 por símbolo | controla exposição |
| Contratos máximos | teto fixo além do cálculo | protege contra erro de parâmetro |
| Janela de horário | evitar os primeiros minutos e a proximidade do fechamento | spread, leilões e zeragem compulsória |
| **Zeragem no fim do dia** | fechar tudo X minutos antes do horário de zeragem da corretora | não carregar posição sem garantia |
| Agenda econômica | pausar em Copom, IPCA, payroll, FOMC | gaps e slippage |
| **Kill switch** | desligar Algo Trading / remover EA | resposta a comportamento inesperado |

O `EMACross` já implementa risco por trade e perda máxima diária (`TodayClosedProfit`). Janela de horário e zeragem no fim do dia são exercícios da [Fase 2 do roadmap](../../ROADMAP.md).

## Sequências de perdas são normais

Com taxa de acerto de 40%, a chance de **10 perdas seguidas** em algum momento ao longo de 1.000 trades é bem alta. Com 1% de risco, isso dá cerca de −10%. Com 5%, cerca de −40%. Calcule antes de começar e confira no Monte Carlo.

## Checklist antes de conta real

- [ ] Rodou em demo por tempo suficiente e o resultado é coerente com o backtest
- [ ] Limite diário e zeragem de fim de dia testados (forçados em demo)
- [ ] Sabe o horário de zeragem compulsória da sua corretora
- [ ] Sabe o que acontece se a internet/VPS cair com posição aberta (o stop está **no servidor**?)
- [ ] Sabe zerar tudo manualmente em menos de 30 segundos
- [ ] Custos (emolumentos, corretagem) e IR incluídos na conta de resultado
- [ ] Capital em risco é dinheiro que você pode perder
