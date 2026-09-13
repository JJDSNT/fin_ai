# 02 — MQL5 essencial

O suficiente para ler e escrever um Expert Advisor. Código de referência: [`mql5/Experts/FinAI/EMACross.mq5`](../../mql5/Experts/FinAI/EMACross.mq5).

## Modelo de eventos

Um EA não tem `main()`. O terminal chama funções quando algo acontece:

| Evento | Quando dispara | Uso típico |
|---|---|---|
| `OnInit()` | EA carregado / parâmetros alterados | criar handles de indicadores, validar inputs |
| `OnDeinit(reason)` | EA removido / gráfico fechado | liberar handles, limpar objetos |
| `OnTick()` | novo tick do símbolo do gráfico | lógica principal |
| `OnTimer()` | a cada N segundos (`EventSetTimer`) | tarefas periódicas, ler sinais externos |
| `OnTradeTransaction()` | ordem/posição/negócio mudou | reagir a execuções, logar trades |
| `OnTester()` | fim de um backtest | retornar critério de otimização próprio |

## Inputs

```mql5
input group "Sinal"
input int InpFastPeriod = 9;   // o comentario vira o rotulo na janela do EA
```

`input` pode ser alterado pelo usuário e **otimizado** no Strategy Tester.

## Indicadores: handles + CopyBuffer

Em MQL5, indicadores não retornam valores diretamente. Você cria um **handle** uma vez e copia os valores quando precisa:

```mql5
int hMa;                                   // global

int OnInit() {
   hMa = iMA(_Symbol, PERIOD_M5, 21, 0, MODE_EMA, PRICE_CLOSE);
   return hMa == INVALID_HANDLE ? INIT_FAILED : INIT_SUCCEEDED;
}

void OnTick() {
   double ma[];
   ArraySetAsSeries(ma, true);             // indice 0 = candle mais recente
   if(CopyBuffer(hMa, 0, 1, 2, ma) != 2)   // a partir do candle 1 (fechado), 2 valores
      return;
   // ma[0] = candle 1 (ultimo fechado), ma[1] = candle 2
}
```

Regras:
- **Candle 0 ainda está em formação.** Sinais baseados nele "piscam" e o backtest fica diferente da conta real. Use candles fechados (índice ≥ 1).
- `CopyBuffer` pode retornar menos dados logo após o carregamento. Verifique o retorno e tente de novo no próximo tick.
- Libere os handles em `OnDeinit` com `IndicatorRelease`.

## Detectar novo candle

```mql5
static datetime lastBar = 0;
datetime bar = iTime(_Symbol, _Period, 0);
if(bar == lastBar) return;
lastBar = bar;
```

Processar só na abertura do candle deixa o EA mais simples, previsível e rápido no tester.

## Enviando ordens com CTrade

```mql5
#include <Trade\Trade.mqh>
CTrade trade;

// OnInit
trade.SetExpertMagicNumber(123456);      // identifica as ordens deste EA
trade.SetDeviationInPoints(10);          // slippage aceito
trade.SetTypeFillingBySymbol(_Symbol);   // FOK/IOC/RETURN conforme o simbolo (essencial na B3)

// OnTick
if(!trade.Buy(1.0, _Symbol, 0.0, sl, tp))           // preco 0 = preco atual
   Print("Falhou: ", trade.ResultRetcodeDescription());
```

- `trade.Buy()` retornar `true` significa que a ordem **passou na validação**. Confirme com `trade.ResultRetcode()` (`TRADE_RETCODE_DONE` ou `TRADE_RETCODE_PLACED`).
- Retcodes comuns: `10004` requote, `10006` rejeitada, `10014` volume inválido, `10015` preço inválido, `10016` stops inválidos, `10018` mercado fechado, `10027` Algo Trading desligado no terminal, `10030` modo de preenchimento não suportado.

## Posições: símbolo + magic

```mql5
for(int i = PositionsTotal() - 1; i >= 0; i--) {
   ulong ticket = PositionGetTicket(i);               // tambem seleciona a posicao
   if(ticket == 0) continue;
   if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
   if(PositionGetInteger(POSITION_MAGIC) != 123456) continue;
   // PositionGetInteger(POSITION_TYPE), PositionGetDouble(POSITION_PROFIT)...
}
```

Esse padrão funciona em contas netting e hedging.

## Normalização (fonte de muitos erros)

- **Preço** precisa ser múltiplo do tick size. No WIN o tick é 5: `128432` é inválido, `128430` é válido.
- **Volume** precisa respeitar mínimo, máximo e step (`SYMBOL_VOLUME_MIN/MAX/STEP`).
- As funções `NormalizePriceToTick` e `NormalizeVolume` estão em [`RiskManager.mqh`](../../mql5/Include/FinAI/RiskManager.mqh).

## Armadilhas

| Armadilha | Sintoma | Solução |
|---|---|---|
| Algo Trading desligado | retcode 10027 | ligar o botão na barra / permitir na aba *Comum* do EA |
| Usar candle 0 no sinal | backtest lindo, conta real ruim | usar candles fechados |
| Preço fora do tick | "Invalid price" | normalizar pelo tick size |
| Filling mode errado | "Unsupported filling mode" | `SetTypeFillingBySymbol` |
| Stop muito perto | "Invalid stops" | respeitar `SYMBOL_TRADE_STOPS_LEVEL` |
| Acentos no código | texto corrompido no log | MetaEditor pode ler UTF-8 sem BOM como ANSI; os arquivos deste repo usam só ASCII |
| Esquecer magic number | EA mexe em posição manual | filtrar sempre por símbolo + magic |

## Referências

- Documentação oficial: https://www.mql5.com/pt/docs
- Biblioteca padrão (`CTrade`, `CPositionInfo`…): https://www.mql5.com/pt/docs/standardlibrary
- Artigos: https://www.mql5.com/pt/articles
