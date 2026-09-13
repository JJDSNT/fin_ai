//+------------------------------------------------------------------+
//| RiskManager.mqh - dimensionamento de posicao e normalizacao      |
//| fin_ai                                                           |
//+------------------------------------------------------------------+
#ifndef FINAI_RISKMANAGER_MQH
#define FINAI_RISKMANAGER_MQH

//--- Arredonda um preco para o tick size do simbolo.
//--- Essencial na B3: o WIN anda de 5 em 5 pontos, o WDO de 0.5 em 0.5.
double NormalizePriceToTick(const string symbol, const double price)
  {
   double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   int    digits   = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   if(tickSize <= 0.0)
      return NormalizeDouble(price, digits);
   return NormalizeDouble(MathRound(price / tickSize) * tickSize, digits);
  }

//--- Ajusta o volume ao step do simbolo (arredonda para BAIXO) e ao maximo.
//--- Retorna 0 se ficar abaixo do minimo: arredondar para cima seria arriscar mais que o planejado.
double NormalizeVolume(const string symbol, const double volume)
  {
   double minVol  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double maxVol  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double stepVol = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   if(stepVol <= 0.0)
      stepVol = minVol;
   if(stepVol <= 0.0)
      return 0.0;

   double v = MathFloor(volume / stepVol + 1e-9) * stepVol;
   if(v < minVol)
      return 0.0;
   return NormalizeDouble(MathMin(v, maxVol), 8);
  }

//--- Volume tal que, se o stop for atingido, a perda seja ~riskPercent% do saldo.
//--- stopDistance em unidades de preco (ex.: 200.0 no WIN, 0.0020 no EURUSD).
double VolumeByRisk(const string symbol, const double riskPercent, const double stopDistance)
  {
   if(riskPercent <= 0.0 || stopDistance <= 0.0)
      return 0.0;

   double tickSize  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickSize <= 0.0 || tickValue <= 0.0)
      return 0.0;

   double riskMoney  = AccountInfoDouble(ACCOUNT_BALANCE) * riskPercent / 100.0;
   double lossPerLot = (stopDistance / tickSize) * tickValue;
   return NormalizeVolume(symbol, riskMoney / lossPerLot);
  }

//--- Resultado realizado hoje (horario do servidor) pelos negocios com este magic.
//--- Inclui comissao e swap. Nao inclui o resultado flutuante de posicoes abertas.
double TodayClosedProfit(const long magic)
  {
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;
   datetime dayStart = StructToTime(dt);

   if(!HistorySelect(dayStart, TimeCurrent()))
      return 0.0;

   double total = 0.0;
   int    deals = HistoryDealsTotal();
   for(int i = 0; i < deals; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0 || HistoryDealGetInteger(ticket, DEAL_MAGIC) != magic)
         continue;
      total += HistoryDealGetDouble(ticket, DEAL_PROFIT)
             + HistoryDealGetDouble(ticket, DEAL_COMMISSION)
             + HistoryDealGetDouble(ticket, DEAL_SWAP);
     }
   return total;
  }

//--- true se a perda realizada no dia atingiu maxLossPercent% do saldo (0 = desligado).
bool DailyLossLimitReached(const long magic, const double maxLossPercent)
  {
   if(maxLossPercent <= 0.0)
      return false;
   double limit = AccountInfoDouble(ACCOUNT_BALANCE) * maxLossPercent / 100.0;
   return TodayClosedProfit(magic) <= -limit;
  }

#endif // FINAI_RISKMANAGER_MQH
