//+------------------------------------------------------------------+
//| InfoSimbolo.mq5 - imprime as especificacoes de um simbolo        |
//| Arraste para um grafico; o resultado aparece na aba "Experts".   |
//+------------------------------------------------------------------+
#property copyright   "fin_ai"
#property version     "1.00"
#property description "Especificacoes do simbolo e modo da conta (tick size, tick value, volumes, filling)."
#property script_show_inputs

input string InpSymbol = ""; // Simbolo (vazio = simbolo do grafico)

void OnStart()
  {
   string s = (InpSymbol == "") ? _Symbol : InpSymbol;
   if(!SymbolSelect(s, true))
     {
      PrintFormat("Simbolo '%s' nao encontrado.", s);
      return;
     }

   string ccy     = AccountInfoString(ACCOUNT_CURRENCY);
   long   filling = SymbolInfoInteger(s, SYMBOL_FILLING_MODE);

   PrintFormat("================ %s ================", s);
   PrintFormat("Descricao ............ %s", SymbolInfoString(s, SYMBOL_DESCRIPTION));
   PrintFormat("Digitos / point ...... %d / %g", (int)SymbolInfoInteger(s, SYMBOL_DIGITS),
               SymbolInfoDouble(s, SYMBOL_POINT));
   PrintFormat("Tick size ............ %g", SymbolInfoDouble(s, SYMBOL_TRADE_TICK_SIZE));
   PrintFormat("Tick value ........... %g %s (por lote/contrato)",
               SymbolInfoDouble(s, SYMBOL_TRADE_TICK_VALUE), ccy);
   PrintFormat("Tamanho do contrato .. %g", SymbolInfoDouble(s, SYMBOL_TRADE_CONTRACT_SIZE));
   PrintFormat("Volume min/max/step .. %g / %g / %g",
               SymbolInfoDouble(s, SYMBOL_VOLUME_MIN),
               SymbolInfoDouble(s, SYMBOL_VOLUME_MAX),
               SymbolInfoDouble(s, SYMBOL_VOLUME_STEP));
   PrintFormat("Stops level (points) . %d", (int)SymbolInfoInteger(s, SYMBOL_TRADE_STOPS_LEVEL));
   PrintFormat("Spread atual (points)  %d", (int)SymbolInfoInteger(s, SYMBOL_SPREAD));
   PrintFormat("Modo de execucao ..... %s",
               EnumToString((ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(s, SYMBOL_TRADE_EXEMODE)));
   PrintFormat("Filling FOK / IOC .... %s / %s",
               (filling & SYMBOL_FILLING_FOK) != 0 ? "sim" : "nao",
               (filling & SYMBOL_FILLING_IOC) != 0 ? "sim" : "nao");
   PrintFormat("Modo da conta ........ %s",
               EnumToString((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)));
   PrintFormat("Saldo ................ %.2f %s", AccountInfoDouble(ACCOUNT_BALANCE), ccy);
  }
//+------------------------------------------------------------------+
