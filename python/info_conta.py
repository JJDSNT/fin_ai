"""Mostra terminal, conta e posições abertas.

Uso (Python do Windows):
    python python/info_conta.py
"""

from mt5_conexao import conectar

# Valores dos enums ENUM_ACCOUNT_TRADE_MODE e ENUM_ACCOUNT_MARGIN_MODE do MQL5
TRADE_MODES = {0: "DEMO", 1: "CONCURSO", 2: "REAL"}
MARGIN_MODES = {0: "netting", 1: "exchange (bolsa)", 2: "hedging"}


def main():
    with conectar() as mt5:
        term = mt5.terminal_info()
        conta = mt5.account_info()

        print(f"Terminal : {term.name} (build {term.build})")
        print(f"Conectado: {'sim' if term.connected else 'NÃO'}"
              f" | Algo Trading: {'ligado' if term.trade_allowed else 'DESLIGADO'}")
        print()
        print(f"Conta    : {conta.login} @ {conta.server} ({conta.company})")
        print(f"Tipo     : {TRADE_MODES.get(conta.trade_mode, conta.trade_mode)}"
              f" | modo: {MARGIN_MODES.get(conta.margin_mode, conta.margin_mode)}"
              f" | alavancagem 1:{conta.leverage}")
        print(f"Saldo    : {conta.balance:,.2f} {conta.currency}"
              f" | patrimônio: {conta.equity:,.2f} | margem livre: {conta.margin_free:,.2f}")

        posicoes = mt5.positions_get() or ()
        print(f"\nPosições abertas: {len(posicoes)}")
        for p in posicoes:
            lado = "COMPRA" if p.type == mt5.POSITION_TYPE_BUY else "VENDA"
            print(f"  #{p.ticket} {p.symbol} {lado} {p.volume} @ {p.price_open}"
                  f" | SL {p.sl} TP {p.tp} | resultado {p.profit:,.2f} | magic {p.magic}")


if __name__ == "__main__":
    main()
