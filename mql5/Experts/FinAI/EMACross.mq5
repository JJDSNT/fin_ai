//+------------------------------------------------------------------+
//| EMACross.mq5 - cruzamento de medias exponenciais                 |
//| EA didatico do fin_ai. Use apenas em conta DEMO / Strategy Tester|
//+------------------------------------------------------------------+
//| Logica:                                                          |
//|  - EMA rapida cruza EMA lenta para cima  -> compra               |
//|  - EMA rapida cruza EMA lenta para baixo -> venda                |
//|  - Sinal contrario fecha a posicao atual e inverte               |
//|  - Stop e alvo baseados em ATR; volume pelo % de risco do saldo  |
//|  - Para de abrir posicoes ao atingir a perda maxima diaria       |
//+------------------------------------------------------------------+
#property copyright "fin_ai"
#property version   "1.00"
#property description "Cruzamento de EMAs com stop por ATR e risco fixo por trade (didatico)."

#include <Trade\Trade.mqh>
#include <FinAI\RiskManager.mqh>

input group "Sinal"
input ENUM_TIMEFRAMES InpTimeframe       = PERIOD_CURRENT; // Timeframe do sinal
input int             InpFastPeriod      = 9;              // EMA rapida
input int             InpSlowPeriod      = 21;             // EMA lenta

input group "Risco"
input double          InpRiskPercent     = 1.0;            // Risco por trade (% do saldo)
input int             InpAtrPeriod       = 14;             // Periodo do ATR
input double          InpStopAtrMult     = 2.0;            // Stop = ATR x mult
input double          InpTakeAtrMult     = 3.0;            // Alvo = ATR x mult (0 = sem alvo)
input double          InpMaxDailyLossPct = 3.0;            // Perda maxima diaria (% do saldo, 0 = off)

input group "Execucao"
input ulong           InpMagic           = 20260913;       // Magic number
input int             InpDeviationPoints = 10;             // Slippage maximo (points)

CTrade   trade;
int      hFast       = INVALID_HANDLE;
int      hSlow       = INVALID_HANDLE;
int      hAtr        = INVALID_HANDLE;
datetime lastBarTime = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpFastPeriod <= 0 || InpFastPeriod >= InpSlowPeriod)
     {
      Print("Parametros invalidos: EMA rapida deve ser > 0 e menor que a lenta.");
      return INIT_PARAMETERS_INCORRECT;
     }

   hFast = iMA(_Symbol, InpTimeframe, InpFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
   hSlow = iMA(_Symbol, InpTimeframe, InpSlowPeriod, 0, MODE_EMA, PRICE_CLOSE);
   hAtr  = iATR(_Symbol, InpTimeframe, InpAtrPeriod);
   if(hFast == INVALID_HANDLE || hSlow == INVALID_HANDLE || hAtr == INVALID_HANDLE)
     {
      Print("Falha ao criar indicadores. Erro: ", GetLastError());
      return INIT_FAILED;
     }

   trade.SetExpertMagicNumber(InpMagic);
   trade.SetDeviationInPoints(InpDeviationPoints);
   trade.SetTypeFillingBySymbol(_Symbol);
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(hFast);
   IndicatorRelease(hSlow);
   IndicatorRelease(hAtr);
  }

//+------------------------------------------------------------------+
void OnTick()
  {
//--- So decide na abertura de um novo candle: evita sinais repetidos e
//--- permite backtest rapido no modo "somente precos de abertura".
   datetime barTime = iTime(_Symbol, InpTimeframe, 0);
   if(barTime == 0 || barTime == lastBarTime)
      return;

   double fast[], slow[], atr[];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);
   ArraySetAsSeries(atr, true);

//--- A partir do candle 1 (ultimo fechado). Indice 0 do array = candle 1.
   if(CopyBuffer(hFast, 0, 1, 2, fast) != 2 ||
      CopyBuffer(hSlow, 0, 1, 2, slow) != 2 ||
      CopyBuffer(hAtr,  0, 1, 1, atr)  != 1)
      return; // dados ainda nao prontos; tenta de novo no proximo tick

   lastBarTime = barTime;

   bool crossUp   = fast[1] <= slow[1] && fast[0] > slow[0];
   bool crossDown = fast[1] >= slow[1] && fast[0] < slow[0];
   if(!crossUp && !crossDown)
      return;

//--- Sinal contrario: fecha a posicao na direcao oposta
   ClosePositions(crossUp ? POSITION_TYPE_SELL : POSITION_TYPE_BUY);

   if(CountPositions() > 0)
      return; // ja posicionado na direcao do sinal

   if(DailyLossLimitReached((long)InpMagic, InpMaxDailyLossPct))
     {
      Print("Perda maxima diaria atingida. Sem novas entradas hoje.");
      return;
     }

   OpenPosition(crossUp, atr[0]);
  }

//+------------------------------------------------------------------+
//| Abre posicao com stop/alvo por ATR e volume pelo risco           |
//+------------------------------------------------------------------+
void OpenPosition(const bool isBuy, const double atrValue)
  {
   double stopDist = atrValue * InpStopAtrMult;
   double volume   = VolumeByRisk(_Symbol, InpRiskPercent, stopDist);
   if(volume <= 0.0)
     {
      PrintFormat("Volume abaixo do minimo (risco %.2f%%, stop %.5f). Entrada ignorada.",
                  InpRiskPercent, stopDist);
      return;
     }

   double price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK)
                        : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double dir   = isBuy ? 1.0 : -1.0;
   double sl    = NormalizePriceToTick(_Symbol, price - dir * stopDist);
   double tp    = 0.0;
   if(InpTakeAtrMult > 0.0)
      tp = NormalizePriceToTick(_Symbol, price + dir * atrValue * InpTakeAtrMult);

   bool sent = isBuy ? trade.Buy(volume, _Symbol, 0.0, sl, tp, "EMACross")
                     : trade.Sell(volume, _Symbol, 0.0, sl, tp, "EMACross");
   ReportResult(sent, isBuy ? "Compra" : "Venda");
  }

//+------------------------------------------------------------------+
//| Posicoes deste EA: mesmo simbolo + mesmo magic                   |
//| (funciona em contas netting e hedging)                           |
//+------------------------------------------------------------------+
bool IsOwnSelectedPosition()
  {
   return PositionGetString(POSITION_SYMBOL) == _Symbol &&
          PositionGetInteger(POSITION_MAGIC) == (long)InpMagic;
  }

int CountPositions()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
      if(PositionGetTicket(i) != 0 && IsOwnSelectedPosition())
         count++;
   return count;
  }

void ClosePositions(const ENUM_POSITION_TYPE type)
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !IsOwnSelectedPosition())
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type)
         continue;
      ReportResult(trade.PositionClose(ticket), "Fechamento");
     }
  }

//+------------------------------------------------------------------+
void ReportResult(const bool sent, const string action)
  {
   uint code = trade.ResultRetcode();
   if(sent && (code == TRADE_RETCODE_DONE || code == TRADE_RETCODE_PLACED))
      return;
   PrintFormat("%s falhou: retcode %u - %s", action, code, trade.ResultRetcodeDescription());
  }
//+------------------------------------------------------------------+
