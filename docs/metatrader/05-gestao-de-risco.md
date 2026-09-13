# 05 — Gestão de risco

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
risco_R$        = saldo × risco%
perda_por_lote  = (distância_do_stop / tick_size) × tick_value
volume          = risco_R$ / perda_por_lote   → arredondado para baixo no step
```

Implementado em `VolumeByRisk()` no [`RiskManager.mqh`](../../mql5/Include/FinAI/RiskManager.mqh).

### Exemplos

**Mini índice (WIN)**: saldo R$ 10.000, risco 1% = R$ 100, stop de 200 pontos
- 200 pontos / tick 5 = 40 ticks × R$ 1,00 = **R$ 40 por contrato**
- 100 / 40 = 2,5 → **2 contratos**

**Mini dólar (WDO)**: mesmo saldo e risco, stop de 5 pontos
- 5 / 0,5 = 10 ticks × R$ 5,00 = **R$ 50 por contrato**
- 100 / 50 = **2 contratos**

**EURUSD**: saldo US$ 10.000, risco 1% = US$ 100, stop de 20 pips (0,0020)
- 1 lote: 1 pip ≈ US$ 10 → 20 pips = **US$ 200 por lote**
- 100 / 200 = **0,50 lote**

⚠️ Se o volume calculado ficar **abaixo do mínimo**, não opere. Arredondar para cima é aceitar mais risco do que o planejado. Com saldo pequeno na B3, isso acontece muito: o stop precisa caber no risco.

## Stop baseado em volatilidade

Stop fixo em pontos ignora o regime do mercado. Usar **ATR × multiplicador** (como no `EMACross`) adapta o stop e, pelo cálculo acima, o volume diminui automaticamente quando a volatilidade sobe.

## Limites que todo EA deve ter

| Limite | Exemplo | Por quê |
|---|---|---|
| Risco por trade | 0,5%–1% do saldo | sobreviver a sequências de perdas |
| **Perda máxima diária** | 2%–3% | evita espiral em dia ruim ou bug |
| Posições simultâneas | 1 por símbolo | controla exposição |
| Janela de horário | ex.: evitar leilões de abertura/fechamento da B3 | spread e slippage altos |
| Notícias | pausar em payroll, Copom, FOMC | gaps e slippage |
| **Kill switch** | desligar Algo Trading / remover EA | resposta a comportamento inesperado |

O `EMACross` já implementa risco por trade e perda máxima diária (`TodayClosedProfit`).

## Sequências de perdas são normais

Com taxa de acerto de 40%, a chance de **10 perdas seguidas** em algum momento ao longo de 1.000 trades é bem alta. Com 1% de risco, isso é cerca de −10%. Com 5%, cerca de −40%. Calcule antes de começar e confira no Monte Carlo.

## Checklist antes de conta real

- [ ] Rodou em demo por tempo suficiente e o resultado é coerente com o backtest
- [ ] Limite diário testado (forçado em demo)
- [ ] Sabe o que acontece se a internet/VPS cair com posição aberta (stop está **no servidor**?)
- [ ] Sabe como zerar tudo manualmente em menos de 30 segundos
- [ ] Capital em risco é dinheiro que você pode perder
