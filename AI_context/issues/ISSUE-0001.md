---
id: ISSUE-0001
title: "Ambiente MT5: conta demo B3, compilação dos MQL5 e Python no Windows"
status: ready
priority: high
type: infra
owner: jaime
strategy: none
validation_stage: n/a
created_at: 2026-09-13
updated_at: 2026-09-13
tags:
  - mt5
  - b3
  - ambiente
blockers:
  - "conta demo B3 (de preferência com opções) — o usuário precisa solicitar à corretora e fazer o primeiro login"
related_files:
  - mql5/Experts/FinAI/EMACross.mq5
  - mql5/Include/FinAI/RiskManager.mqh
  - mql5/Scripts/FinAI/InfoSimbolo.mq5
  - python/requirements.txt
  - scripts/sync-mql5.sh
---

# Por quê

Nada do repositório foi executado de verdade ainda. Os arquivos MQL5 **nunca foram compilados** (escritos sem MetaEditor) e os scripts Python nunca rodaram. Todas as validações das estratégias dependem de um terminal conectado à B3 com histórico de dados.

# O quê

- MT5 no Windows (já instalado em `C:\Program Files\MetaTrader 5`) conectado a uma **conta demo B3**.
- Compilar os três arquivos MQL5 via linha de comando do MetaEditor e corrigir erros.
- Instalar o Python para Windows e o pacote `MetaTrader5`.
- Rodar `InfoSimbolo` e os scripts Python contra a conta demo.

Fora do escopo: VPS, conta real.

# Próximos passos de validação

- [ ] Compilar `EMACross.mq5`, `RiskManager.mqh` e `InfoSimbolo.mq5` com `MetaEditor64.exe /compile` → log sem erros (não depende da conta)
- [ ] Usuário: pedir conta demo B3 e fazer o primeiro login no MT5 → terminal conectado
- [ ] Rodar `InfoSimbolo` em `WIN$N`, `WDO$N`, `PETR4` e uma opção de PETR4 → especificações conferidas com `docs/metatrader/01-visao-geral.md`
- [ ] Instalar Python para Windows (`winget`) + `pip install -r python/requirements.txt` → `python.exe python/info_conta.py` mostra conta `DEMO` e modo `exchange`
- [ ] `exportar_candles.py PETR4 H1` → CSV com histórico; anotar até que data vai
- [ ] Rodar `EMACross` no Strategy Tester em `WIN$N` → teste termina sem erros de ordem

# Critério de sucesso / falha

- Sucesso se: os três MQL5 compilam sem erros, `info_conta.py` conecta na demo e existe histórico de PETR4 H1 de pelo menos 2 anos.
- Falha se: a corretora não oferece demo B3 → abrir issue para avaliar outra corretora.

# Evidências

—

# Decisões tomadas

- MT5 e Python rodam no **Windows**. O WSL fica para o repositório e a edição (ver `docs/metatrader/01-visao-geral.md`).
- Credenciais da corretora são digitadas pelo usuário no terminal, nunca passadas ao agente.

# Log

- 2026-09-13: criada. MT5 detectado instalado, nunca conectado a corretora. Python do Windows não instalado (só o atalho da Microsoft Store).
