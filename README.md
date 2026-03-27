# 💰 Financial AI (agentic systems)

Agent-based architectures for trading, research, and financial decision-making.

---

## 🧠 Core frameworks (multi-agent trading)

- TradingAgents — https://github.com/TauricResearch/TradingAgents  
  → Multi-agent trading system (bull / bear / risk roles)  
  → Clear coordination between agents  
  → Melhor ponto de partida hoje  

- FinRobot — https://github.com/AI4Finance-Foundation/FinRobot  
  → Plataforma de agentes para finanças  
  → Equity research + reasoning  
  → Mais “produção” que paper  

---

## 🧠 Memory / context (stateful reasoning)

### Financial-specific (concept-driven)
- FinMem (paper-based, ver seção abaixo)

### General memory systems (usáveis hoje)
- MemGPT — https://github.com/cpacker/MemGPT  
- Letta — https://github.com/letta-ai/letta  

👉 essenciais para:
- memória de longo prazo  
- decisões financeiras sequenciais  

---

## 🤖 Agent frameworks (builders)

- AutoGen — https://github.com/microsoft/autogen  
- CrewAI — https://github.com/joaomdmoura/crewai  

👉 usados para:
- trading agents  
- research agents  
- risk agents  

---

## 📊 Trading / quant infrastructure

- Lean (QuantConnect) — https://github.com/QuantConnect/Lean  
  → Backtesting + execução  

- Backtrader — https://github.com/mementum/backtrader  
  → Estratégias e simulação  

- Freqtrade — https://github.com/freqtrade/freqtrade  
  → Bot de trading (crypto)  

---

## 📡 Data / signals

- yfinance — https://github.com/ranaroussi/yfinance  
- pandas-datareader — https://github.com/pydata/pandas-datareader  

---

## ⚙️ Execution / integration

- ccxt — https://github.com/ccxt/ccxt  
  → integração com exchanges  

---

## 📄 Research papers (financial agents)

- FinAgent — Multimodal Foundation Agent for Financial Trading  
  https://arxiv.org/abs/2402.18485  
  → multimodal (price + texto)  
  → tool use + memory + reasoning  

- https://arxiv.org/abs/2405.14767  
  → sistemas de agentes financeiros com LLM  

- https://arxiv.org/abs/2311.13743  
  → early-stage LLM trading agents  

- TradingAgents — Multi-Agent LLM Financial Trading Framework  
  https://arxiv.org/abs/2412.20138  
  → bull / bear / risk agents  
  → melhora Sharpe e drawdown  

- QuantAgents — Multi-agent Financial System via Simulated Trading  
  https://arxiv.org/abs/2509.09995  
  → simulação + aprendizado contínuo  
  → múltiplos agentes coordenados  

---

## 📌 Architecture pattern

Financial agent systems typically include:

- Signal agents (price, news, indicators)
- Strategy agents (bull / bear theses)
- Risk agents (exposure, drawdown control)
- Execution agents (orders, timing)
- Memory layer (market + decision history)

---

## 🔥 Key insight

Financial AI is not about:
- predicting prices  

It is about:
- managing decisions over time  
- coordinating agents  
- handling risk under uncertainty  
