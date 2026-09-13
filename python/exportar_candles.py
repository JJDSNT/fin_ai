"""Exporta candles de um símbolo do MetaTrader 5 para CSV.

Uso (Python do Windows):
    python python/exportar_candles.py WIN$N M5 10000
    python python/exportar_candles.py WDO$N M1 20000 --saida data/wdo_m1.csv
    python python/exportar_candles.py EURUSD H1 5000

O horário da coluna `time` é o do servidor da corretora.
"""

import argparse
from pathlib import Path

import pandas as pd

from mt5_conexao import conectar, mt5

TIMEFRAMES = {
    "M1": mt5.TIMEFRAME_M1,
    "M5": mt5.TIMEFRAME_M5,
    "M15": mt5.TIMEFRAME_M15,
    "M30": mt5.TIMEFRAME_M30,
    "H1": mt5.TIMEFRAME_H1,
    "H4": mt5.TIMEFRAME_H4,
    "D1": mt5.TIMEFRAME_D1,
    "W1": mt5.TIMEFRAME_W1,
    "MN1": mt5.TIMEFRAME_MN1,
}


def candles(symbol: str, timeframe: str, n: int) -> pd.DataFrame:
    """Últimos `n` candles de `symbol` como DataFrame indexado por horário."""
    if not mt5.symbol_select(symbol, True):
        raise ValueError(f"Símbolo indisponível: {symbol} {mt5.last_error()}")

    rates = mt5.copy_rates_from_pos(symbol, TIMEFRAMES[timeframe], 0, n)
    if rates is None or len(rates) == 0:
        raise RuntimeError(f"Sem dados para {symbol} {timeframe}: {mt5.last_error()}")

    df = pd.DataFrame(rates)
    df["time"] = pd.to_datetime(df["time"], unit="s")
    return df.set_index("time")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("symbol", help="ex.: EURUSD, WIN$N, WDO$N")
    parser.add_argument("timeframe", choices=TIMEFRAMES)
    parser.add_argument("n", type=int, nargs="?", default=1000, help="quantidade de candles (padrão 1000)")
    parser.add_argument("--saida", type=Path, help="arquivo CSV (padrão data/<symbol>_<tf>.csv)")
    args = parser.parse_args()

    saida = args.saida or Path("data") / f"{args.symbol.replace('$', '_')}_{args.timeframe}.csv"

    with conectar():
        df = candles(args.symbol, args.timeframe, args.n)

    saida.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(saida)
    print(f"{len(df)} candles de {df.index[0]} a {df.index[-1]} salvos em {saida}")


if __name__ == "__main__":
    main()
