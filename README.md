# 💰 fin_ai — de agentes financeiros ao MetaTrader 5

Repositório pessoal de estudo e prática em trading algorítmico.

Começou como um mapa de **sistemas de agentes de IA para finanças** e do **ecossistema quant/HFT**.
Agora evolui para a prática: **construir, testar e operar estratégias no MetaTrader 5** (MQL5 + Python),
usando os conceitos de agentes como arquitetura de referência.

> 🇧🇷 **Foco: B3**, com mini índice (WIN) e mini dólar (WDO). Forex aparece como referência.

---

## 🧭 Jornada

```
Fase 0  Fundamentos: agentes de IA, firmas quant        ✅ docs/fundamentos
Fase 1  MetaTrader 5: plataforma, contas, símbolos      ⏳ docs/metatrader
Fase 2  MQL5: primeiro Expert Advisor                   ⏳ mql5/
Fase 3  Backtest e otimização sem se enganar            ⏳
Fase 4  Python + dados do MT5                           ⏳ python/
Fase 5  Arquitetura de agentes sobre o MT5              ⏳
Fase 6  Operação: demo → VPS → conta real pequena       ⏳
```

Detalhes e checklists em [ROADMAP.md](ROADMAP.md).

---

## 📁 Estrutura

```
fin_ai/
├── ROADMAP.md                    # trilha de evolução com checklists
├── docs/
│   ├── fundamentos/              # base conceitual (conteúdo original)
│   │   ├── agentes-financeiros.md
│   │   └── landscape-quant.md
│   ├── metatrader/               # guias práticos do MT5
│   │   ├── 01-visao-geral.md
│   │   ├── 02-mql5-essencial.md
│   │   ├── 03-python-integracao.md
│   │   ├── 04-backtest-e-otimizacao.md
│   │   └── 05-gestao-de-risco.md
│   └── arquitetura-agentes-mt5.md  # ponte: agentes de IA ↔ MT5
├── mql5/                         # espelha a pasta MQL5/ do terminal
│   ├── Experts/FinAI/EMACross.mq5
│   ├── Include/FinAI/RiskManager.mqh
│   └── Scripts/FinAI/InfoSimbolo.mq5
├── python/                       # integração via pacote MetaTrader5 (Windows)
│   ├── mt5_conexao.py
│   ├── info_conta.py
│   └── exportar_candles.py
├── scripts/sync-mql5.sh          # copia mql5/ ↔ pasta de dados do terminal
└── diario/TEMPLATE.md            # registro de estudos e backtests
```

---

## 🚀 Começando

1. **Instale o MetaTrader 5 no Windows** (não no WSL) e peça uma **conta demo B3** à sua corretora. O servidor `MetaQuotes-Demo` só tem forex/CFD. Detalhes em [01-visao-geral](docs/metatrader/01-visao-geral.md#instalação-windows-não-wsl).
2. **Leve o código MQL5 para o terminal** (a partir do WSL):
   ```bash
   # MT5 > Arquivo > Abrir pasta de dados  → copie o caminho
   export MT5_DATA_DIR="/mnt/c/Users/<voce>/AppData/Roaming/MetaQuotes/Terminal/<ID>"
   ./scripts/sync-mql5.sh push
   ```
3. **No MetaEditor (F4)**, compile `Scripts/FinAI/InfoSimbolo.mq5` e rode em um gráfico para ver as especificações do ativo.
4. **Compile `Experts/FinAI/EMACross.mq5`** e rode no Strategy Tester (Ctrl+R).
5. **Python** (no Python *do Windows*, com o terminal aberto):
   ```bash
   pip install -r python/requirements.txt
   python python/info_conta.py
   python python/exportar_candles.py WIN\$N M5 5000
   ```
6. Registre cada experimento em `diario/` usando o [template](diario/TEMPLATE.md).

---

## 📚 Guias

| Tema | Documento |
|---|---|
| Agentes de IA em finanças | [docs/fundamentos/agentes-financeiros.md](docs/fundamentos/agentes-financeiros.md) |
| Firmas quant / HFT | [docs/fundamentos/landscape-quant.md](docs/fundamentos/landscape-quant.md) |
| MT5 na B3: instalação, WIN/WDO, vencimentos, B3 vs forex | [docs/metatrader/01-visao-geral.md](docs/metatrader/01-visao-geral.md) |
| MQL5 essencial | [docs/metatrader/02-mql5-essencial.md](docs/metatrader/02-mql5-essencial.md) |
| Python ↔ MT5 | [docs/metatrader/03-python-integracao.md](docs/metatrader/03-python-integracao.md) |
| Backtest e otimização | [docs/metatrader/04-backtest-e-otimizacao.md](docs/metatrader/04-backtest-e-otimizacao.md) |
| Gestão de risco | [docs/metatrader/05-gestao-de-risco.md](docs/metatrader/05-gestao-de-risco.md) |
| Agentes de IA sobre o MT5 | [docs/arquitetura-agentes-mt5.md](docs/arquitetura-agentes-mt5.md) |

---

## 🔥 Princípio

> Estratégia é hipótese. Backtest é evidência fraca. Gestão de risco é o que mantém você no jogo.

⚠️ Material de estudo. Nada aqui é recomendação de investimento. Rode tudo em **conta demo** antes de pensar em dinheiro real.
