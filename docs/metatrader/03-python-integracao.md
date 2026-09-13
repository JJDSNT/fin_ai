# 03 — Python ↔ MetaTrader 5

O pacote oficial [`MetaTrader5`](https://pypi.org/project/MetaTrader5/) conecta um script Python a um terminal MT5 **instalado e logado na mesma máquina**.

## O que dá e o que não dá

| ✅ Dá | ❌ Não dá |
|---|---|
| Ler candles, ticks, especificações de símbolos | Rodar o Strategy Tester |
| Ler conta, posições, ordens, histórico | Receber eventos (é tudo por *polling*) |
| Validar (`order_check`) e enviar ordens (`order_send`) | Rodar no Linux/WSL nativamente |
| Usar pandas, scikit-learn, LLMs etc. sobre esses dados | Substituir a camada de risco dentro do terminal |

## ⚠️ Só funciona no Windows

O pacote só é distribuído para Windows e fala com o terminal pela própria máquina. No seu setup (WSL2):

**Opção A — Python do Windows chamado a partir do WSL** (mais simples)
```bash
# instale o Python para Windows (python.org) e, do WSL:
python.exe -m pip install -r python/requirements.txt
python.exe python/info_conta.py
```
A interoperabilidade do WSL deixa o `python.exe` rodar scripts que estão no filesystem Linux.

**Opção B — terminal do Windows (PowerShell)** com um venv próprio, abrindo o repo por `\\wsl$\...` ou clonando em `C:\`.

## Funções principais

| Função | Retorna |
|---|---|
| `mt5.initialize()` / `mt5.shutdown()` | conecta / desconecta |
| `mt5.last_error()` | último erro `(código, mensagem)` |
| `mt5.terminal_info()` / `mt5.account_info()` | dados do terminal e da conta |
| `mt5.symbol_info(s)` / `mt5.symbol_select(s, True)` | especificação / adiciona à Observação do Mercado |
| `mt5.copy_rates_from_pos(s, tf, 0, n)` | últimos `n` candles (array numpy) |
| `mt5.copy_rates_range(s, tf, inicio, fim)` | candles por intervalo de datas |
| `mt5.copy_ticks_range(s, inicio, fim, mt5.COPY_TICKS_ALL)` | ticks |
| `mt5.positions_get(symbol=s)` / `mt5.orders_get()` | posições / ordens pendentes |
| `mt5.history_deals_get(inicio, fim)` | negócios executados |
| `mt5.order_check(req)` / `mt5.order_send(req)` | valida / envia ordem |

## Exemplo mínimo

```python
import MetaTrader5 as mt5
import pandas as pd

if not mt5.initialize():
    raise RuntimeError(mt5.last_error())
try:
    rates = mt5.copy_rates_from_pos("EURUSD", mt5.TIMEFRAME_M5, 0, 500)
    df = pd.DataFrame(rates)
    df["time"] = pd.to_datetime(df["time"], unit="s")
    print(df.tail())
finally:
    mt5.shutdown()
```

Os scripts em [`python/`](../../python/) seguem esse padrão com um context manager (`mt5_conexao.conectar()`).

## 🇧🇷 Dados da B3

```python
rates = mt5.copy_rates_from_pos("WIN$N", mt5.TIMEFRAME_M5, 0, 5000)   # série contínua
df = pd.DataFrame(rates)
df["time"] = pd.to_datetime(df["time"], unit="s")

# Na B3 existe volume real (contratos negociados). Prefira-o ao tick_volume.
df["volume"] = df["real_volume"]
print(df.groupby(df["time"].dt.hour)["volume"].mean())   # liquidez por hora do pregão
```

- **Série contínua** (`WIN$N`, `WDO$N`) para análise. **Contrato vigente** (`WINV26`) para ordens.
- `real_volume` vem preenchido na B3. Em forex costuma ser 0 e só `tick_volume` tem informação.
- Descobrir contratos disponíveis: `[s.name for s in mt5.symbols_get(group="WIN*")]`.
- `copy_ticks_range` na B3 traz negócios (`COPY_TICKS_TRADE`), com preço e volume de cada negócio. É ótimo para estudar fluxo, mas pesado. Baixe por dia.

## Enviando ordens (com cuidado)

```python
tick = mt5.symbol_info_tick("EURUSD")
req = {
    "action": mt5.TRADE_ACTION_DEAL,
    "symbol": "EURUSD",
    "volume": 0.01,
    "type": mt5.ORDER_TYPE_BUY,
    "price": tick.ask,
    "sl": tick.ask - 0.0020,
    "tp": tick.ask + 0.0040,
    "deviation": 10,
    "magic": 777,
    "type_time": mt5.ORDER_TIME_GTC,
    "type_filling": mt5.ORDER_FILLING_IOC,   # confira o modo aceito pelo símbolo
}
print(mt5.order_check(req))                  # valida sem enviar
# res = mt5.order_send(req); res.retcode == mt5.TRADE_RETCODE_DONE
```

### 🇧🇷 Ordem limitada no WIN

```python
simbolo = "WINV26"                           # contrato vigente, nunca a série contínua
info = mt5.symbol_info(simbolo)
tick = mt5.symbol_info_tick(simbolo)

def no_tick(preco):                          # WIN anda de 5 em 5
    return round(preco / info.trade_tick_size) * info.trade_tick_size

preco = no_tick(tick.bid - 100)
req = {
    "action": mt5.TRADE_ACTION_PENDING,
    "symbol": simbolo,
    "volume": 1.0,                           # contratos inteiros
    "type": mt5.ORDER_TYPE_BUY_LIMIT,
    "price": preco,
    "sl": no_tick(preco - 200),
    "tp": no_tick(preco + 400),
    "magic": 777,
    "type_time": mt5.ORDER_TIME_DAY,         # expira no fim do pregão
    "type_filling": mt5.ORDER_FILLING_RETURN,
}
print(mt5.order_check(req))
```

Sempre `order_check` antes de `order_send`, e só em conta demo enquanto estiver aprendendo.

## Pegadinhas

- **Horário**: o `time` dos candles vem no **horário do servidor da corretora**, não em UTC local. Nas corretoras da B3 costuma ser o de Brasília. Cuidado ao cruzar com outras fontes.
- **Rolagem (B3)**: ao analisar a série contínua, os saltos entre vencimentos podem gerar "retornos" que não existiram. Verifique como a sua corretora monta a série.
- **Símbolo invisível**: se o ativo não está na Observação do Mercado, chame `symbol_select(s, True)` antes.
- **Histórico limitado**: o terminal só devolve o que tem baixado. Aumente *Ferramentas → Opções → Gráficos → Máx. de barras no gráfico* ou role o gráfico para trás.
- **Algo Trading** precisa estar ligado para `order_send` funcionar.
- **Polling**: para reagir em tempo real, prefira deixar a execução no EA e usar Python para decisões mais lentas (veja [arquitetura](../arquitetura-agentes-mt5.md)).

Documentação: https://www.mql5.com/pt/docs/python_metatrader5
