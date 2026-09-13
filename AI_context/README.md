# AI_context — fin_ai

## Propósito

Memória operacional do projeto: o que está em andamento, **por quê**, **o quê** e **quais são os próximos passos de validação**.

- `docs/` descreve o que é verdade **agora** (guias).
- `estrategias/` descreve **cada estratégia** (a ficha funciona como especificação).
- `diario/` registra **sessões e experimentos** (o que foi feito num dia).
- `AI_context/` rastreia o **trabalho em andamento** e o que foi validado ou descartado.

## Fluxo

```text
Ideia / dúvida
 ↓
Issue (por quê, o quê, critério de sucesso definido ANTES)
 ↓
Validação (backtest, simulação, demo) → evidências no diario/
 ↓
Revisão: critério atingido? falhou?
 ↓
Consolidação (conhecimento validado ou descartado)
 ↓
Atualização de docs/ e da ficha da estratégia
```

> Em trading, uma hipótese **refutada** também é resultado. A issue é consolidada com o motivo, não apagada.

## Estrutura

- `issues/`: trabalho ativo. Documentos vivos, editáveis por agentes.
- `consolidated/`: conhecimento estabilizado. Regra de promoção em `consolidated/README.md`.
- `consolidated/history/`: issues encerradas, movidas de `issues/` com `status: consolidated`.
- `templates/`: modelos de issue e de documento consolidado.

## Status permitidos

`backlog`, `ready`, `doing`, `review`, `done`, `consolidated`, `blocked`

## Prioridades

`low`, `medium`, `high`, `critical`

## Tipos

| Tipo | Uso |
|---|---|
| `validation` | testar uma hipótese (sinal, backtest, simulação, demo) |
| `research` | levantar informação ou tomar uma decisão |
| `strategy` | criar ou alterar a ficha de uma estratégia |
| `feature` | código novo (EA, script, include, Python) |
| `bug` | algo que não funciona como deveria |
| `infra` | ambiente: MT5, corretora, Python, VPS |
| `docs` | guias e documentação |

## Campos específicos deste repositório

```yaml
strategy: petr4-opcoes-atm      # pasta em estrategias/, ou "none"
validation_stage: sinal         # ideia | sinal | simulacao | demo | real-minimo | n/a
```

`validation_stage` acompanha o plano de validação das fichas de estratégia.

## Bloqueios (`blockers`)

Lista curta em texto livre com o que está travado e por quê. Não substitui o `status`: uma issue `doing` pode ter um item específico travado.

```yaml
blockers:
  - "conta demo B3 com opções — aguardando corretora"
```

## Visão rápida do estado

Sem ferramenta nenhuma, só `grep` no cabeçalho (`head` limita a busca ao frontmatter):

Quantidade de issues por status:

```bash
for f in AI_context/issues/ISSUE-*.md; do head -10 "$f" | grep "^status:"; done | sort | uniq -c
```

Tabela rápida (id, título, status, prioridade, estágio):

```bash
for f in AI_context/issues/ISSUE-*.md; do
  head -14 "$f" | grep -E "^(id|title|status|priority|validation_stage):"
  echo
done
```

Issues de uma estratégia:

```bash
grep -l "^strategy: petr4-opcoes-atm" AI_context/issues/ISSUE-*.md
```

Issues com bloqueio:

```bash
grep -L "^blockers: \[\]" AI_context/issues/ISSUE-*.md | xargs grep -A3 "^blockers:"
```

## Numeração

`ISSUE-0001`, `ISSUE-0002`… sequencial, nunca reutilizado. Próximo número:

```bash
ls AI_context/issues AI_context/consolidated/history | grep -o 'ISSUE-[0-9]*' | sort | tail -1
```
