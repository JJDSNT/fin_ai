# fin_ai

Repositório pessoal de estudo e prática em trading algorítmico no **MetaTrader 5**, com foco na **B3**. Documentação em **português (pt-BR)**.

## Onde fica cada coisa

- `docs/` descreve o que é verdade **agora** (guias de MT5, MQL5, Python, backtest, risco).
- `estrategias/<nome>/README.md` é a **ficha** de cada estratégia (funciona como especificação).
- `AI_context/issues/` guarda o **trabalho em andamento**. Issues com frontmatter YAML (`status`, `priority`, `type`, `strategy`, `validation_stage`, `blockers`) e seções **Por quê / O quê / Próximos passos de validação / Critério de sucesso**. As encerradas vão para `AI_context/consolidated/history/`. Os comandos `grep` para ver o estado estão em `AI_context/README.md`.
- `diario/` registra sessões e experimentos (template em `diario/TEMPLATE.md`).
- `mql5/` espelha a pasta `MQL5/` do terminal (subpastas `FinAI/`). `python/` usa o pacote `MetaTrader5`.

## Regras

- **Critério de sucesso/falha é definido antes de rodar** um teste e registrado na issue. Regra alterada depois de ver resultado precisa de motivo registrado.
- Hipótese refutada também é resultado: consolidar, não apagar.
- Ao mudar uma regra de estratégia, atualizar a ficha **e** a issue relacionada.

## Ambiente

- MT5 e Python com `MetaTrader5` rodam no **Windows** (`C:\Program Files\MetaTrader 5`). Do WSL: `MetaEditor64.exe`, `terminal64.exe`, `python.exe` via interop; arquivos via `/mnt/c/...`.
- Pasta de dados do terminal: `/mnt/c/Users/User/AppData/Roaming/MetaQuotes/Terminal/D0E8209F77C8CF37AD8BF550E51FF075`. Sincronizar com `scripts/sync-mql5.sh`.
- Arquivos MQL5 só com **ASCII** (sem acentos), porque o MetaEditor pode ler UTF-8 sem BOM como ANSI.

## Segurança

- **Nunca enviar ordens em conta real.** Em demo, só com pedido explícito do usuário; para aprendizado, prefira `order_check`.
- Credenciais da corretora são digitadas pelo usuário no terminal. Não pedir, não gravar em arquivo, não commitar.
