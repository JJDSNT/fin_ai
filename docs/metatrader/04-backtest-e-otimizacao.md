# 04 — Backtest e otimização

> O objetivo do backtest não é achar a estratégia perfeita. É **tentar derrubar** a sua hipótese.

## Modos de modelagem (Strategy Tester)

| Modo | Precisão | Velocidade | Quando usar |
|---|---|---|---|
| **Cada tick baseado em ticks reais** | ⭐⭐⭐⭐ | lenta | validação final; obrigatório para stops curtos |
| Cada tick (gerado) | ⭐⭐⭐ | média | quando não há ticks reais |
| OHLC em M1 | ⭐⭐ | rápida | primeira triagem |
| Somente preços de abertura | ⭐ | muito rápida | EAs que operam só na abertura do candle (como o `EMACross`) |
| Cálculos matemáticos | — | — | otimizações sem dados de mercado |

Fluxo sugerido: triagem com OHLC M1 → validação com **ticks reais**. Se o resultado muda muito entre os dois, desconfie.

## 🇧🇷 Backtest na B3

- **Símbolo**: use a série contínua (`WIN$N`, `WDO$N`). O contrato vigente tem histórico de poucos meses.
- **Ticks reais**: o histórico de ticks vem do servidor da corretora e costuma ser limitado a alguns anos. Veja até onde vai antes de definir o período (o tester avisa quando faltam ticks e passa a gerar sintéticos).
- **Rolagem**: a série contínua emenda vencimentos. Um EA que carrega posição pode "lucrar" ou "perder" com o salto da rolagem, algo que não acontece na vida real. EAs day trade que zeram todo dia evitam o problema.
- **Horário**: restrinja entradas à janela de pregão e force a zeragem no fim do dia, **igual ao que fará em conta real**.
- **Book e fila**: o tester não simula a fila do livro. Ordens limitadas são consideradas executadas quando o preço toca, o que é otimista. Em estratégias de poucos ticks, isso muda tudo.
- **Mudança de regime**: horário do pregão, tamanho do contrato e margens mudaram ao longo dos anos. Períodos muito antigos podem não representar o mercado atual.

## Custos realistas

- **B3**: corretagem e emolumentos, que em geral não vêm embutidos. Some manualmente ao analisar ou desconte no `OnTester()`. Referência para calcular: custo por contrato × 2 (entrada e saída) × nº de contratos × nº de trades.
- **Forex**: spread (use o real dos ticks), comissão por lote, swap.
- **Slippage**: em ativos com pouca liquidez ou em notícias, o preço executado piora.
- **Atraso de execução**: o tester tem opção de delay aleatório. Use para ver se a estratégia sobrevive.

## Lendo o relatório

| Métrica | O que diz | Referência grosseira |
|---|---|---|
| Lucro líquido | resultado final | sozinho não significa nada |
| Profit factor | lucro bruto / prejuízo bruto | < 1,2 é frágil; > 3 costuma ser overfitting |
| Payoff esperado | resultado médio por trade | precisa cobrir custos com folga |
| Rebaixamento (drawdown) máximo | pior queda do pico ao vale | você aguentaria isso **psicologicamente**? |
| Fator de recuperação | lucro líquido / drawdown máx. | > 3 é interessante |
| Nº de trades | tamanho da amostra | < 100 dá pouca confiança estatística |
| Correlação LR | quão reta é a curva de capital | curva perfeita demais = suspeita |

## Otimização

- **Algoritmo completo**: testa todas as combinações. Só com poucos parâmetros.
- **Algoritmo genético**: busca heurística, bem mais rápido. É o padrão.
- **Forward**: o tester separa o final do período (1/2, 1/3, 1/4 ou data customizada) e roda os melhores parâmetros **fora da amostra**.
- **Critério customizado**: retorne um número em `OnTester()`:

```mql5
double OnTester()
{
   double trades = TesterStatistics(STAT_TRADES);
   double dd     = TesterStatistics(STAT_EQUITY_DDREL_PERCENT);
   double profit = TesterStatistics(STAT_PROFIT);
   if(trades < 100 || dd <= 0) return 0.0;   // descarta amostras pequenas
   return profit / dd;                        // lucro por unidade de drawdown
}
```

## Evitando se enganar

- [ ] **Poucos parâmetros.** Cada parâmetro a mais é um grau de liberdade para ajustar ruído.
- [ ] **Platô, não pico.** Bons parâmetros têm vizinhos também bons. Se só `EMA 17/43` funciona e `16/43` quebra, é ruído.
- [ ] **Out-of-sample.** Use sempre o forward ou separe manualmente um período que você nunca olhou.
- [ ] **Walk-forward.** Otimize em janelas móveis (ex.: 12 meses in-sample → 3 meses out-of-sample, anda 3 meses, repete) e junte só os resultados out-of-sample.
- [ ] **Regimes diferentes.** Teste em alta, baixa, lateral, alta volatilidade (ex.: 2020) e baixa volatilidade.
- [ ] **Outros ativos.** Uma lógica robusta costuma funcionar razoavelmente em ativos parecidos (WIN ↔ IND, WDO ↔ DOL, EURUSD ↔ GBPUSD).
- [ ] **Monte Carlo.** Embaralhe a ordem dos trades (dá para fazer em Python com o histórico exportado) e veja a distribuição de drawdowns.
- [ ] **Demo antes de real.** Compare o resultado em demo com o backtest do mesmo período.

## Registro

Todo backtest relevante vai para o `diario/` com parâmetros, período, modelagem e métricas ([template](../../diario/TEMPLATE.md)). Sem registro, você vai reotimizar a mesma ideia várias vezes sem perceber.
