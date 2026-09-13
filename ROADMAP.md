# 🧭 Roadmap

Trilha de evolução. Marque os itens conforme avança e registre os detalhes em [`diario/`](diario/TEMPLATE.md).

---

## Fase 0 — Fundamentos ✅

- [x] Mapear frameworks de agentes financeiros (TradingAgents, FinRobot, AutoGen, CrewAI)
- [x] Entender o padrão signal → strategy → risk → execution → memory
- [x] Estudar o ecossistema de firmas quant / HFT / market making

📄 [docs/fundamentos/](docs/fundamentos/)

---

## Fase 1 — MetaTrader 5: a plataforma

- [ ] Instalar o MT5 e abrir conta demo
- [ ] Entender terminal × servidor da corretora, pasta de dados, MetaEditor, Strategy Tester
- [ ] Saber se a conta é **netting**, **exchange** ou **hedging** e o que isso muda
- [ ] Rodar `Scripts/FinAI/InfoSimbolo` nos ativos que interessam (ex.: WIN, WDO, EURUSD)
- [ ] Anotar tick size, tick value, volume mínimo e modos de preenchimento de cada ativo

📄 [docs/metatrader/01-visao-geral.md](docs/metatrader/01-visao-geral.md)

---

## Fase 2 — MQL5: primeiro Expert Advisor

- [ ] Entender o modelo de eventos (`OnInit`, `OnTick`, `OnDeinit`, `OnTradeTransaction`)
- [ ] Usar indicadores via *handles* + `CopyBuffer`
- [ ] Enviar ordens com `CTrade` e tratar `retcode`
- [ ] Compilar e ler o `EMACross.mq5` linha a linha
- [ ] Modificar o EA: adicionar filtro de horário
- [ ] Criar um EA próprio a partir de uma ideia sua

📄 [docs/metatrader/02-mql5-essencial.md](docs/metatrader/02-mql5-essencial.md)

---

## Fase 3 — Backtest e otimização

- [ ] Rodar backtest com **ticks reais** e custos realistas
- [ ] Interpretar o relatório (profit factor, drawdown, recovery factor, nº de trades)
- [ ] Otimizar com algoritmo genético + período **forward**
- [ ] Criar critério de otimização próprio com `OnTester()`
- [ ] Fazer um walk-forward manual (janelas móveis in-sample / out-of-sample)
- [ ] Registrar pelo menos 3 backtests no diário

📄 [docs/metatrader/04-backtest-e-otimizacao.md](docs/metatrader/04-backtest-e-otimizacao.md)

---

## Fase 4 — Python + dados

- [ ] Configurar Python no Windows com o pacote `MetaTrader5`
- [ ] Rodar `info_conta.py` e `exportar_candles.py`
- [ ] Analisar candles com pandas (retornos, volatilidade, sazonalidade intraday)
- [ ] Prototipar um sinal em Python e comparar com o resultado do Strategy Tester

📄 [docs/metatrader/03-python-integracao.md](docs/metatrader/03-python-integracao.md)

---

## Fase 5 — Agentes de IA sobre o MT5

- [ ] Definir a divisão: o que roda no EA (rápido, determinístico) × em Python (lento, analítico)
- [ ] Implementar ponte Python → EA (arquivo em `Common/Files` ou socket)
- [ ] EA como **guardião de risco**: executa sinais externos só dentro dos limites
- [ ] Agente de contexto (notícias / regime de mercado) atuando em cadência lenta
- [ ] Memória: histórico de decisões + resultados consultável

📄 [docs/arquitetura-agentes-mt5.md](docs/arquitetura-agentes-mt5.md)

---

## Fase 6 — Operação

- [ ] Rodar um EA em demo por no mínimo 1–3 meses e comparar com o backtest
- [ ] VPS (MetaQuotes ou própria) + monitoramento e alertas
- [ ] Kill switch e limites diários testados
- [ ] Conta real com o menor tamanho possível

📄 [docs/metatrader/05-gestao-de-risco.md](docs/metatrader/05-gestao-de-risco.md)
