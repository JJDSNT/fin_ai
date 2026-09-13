"""Conexão com o terminal MetaTrader 5.

Requer Windows, o pacote MetaTrader5 e o terminal instalado (de preferência aberto e logado).

Por padrão usa a conta já logada no terminal. Para escolher terminal/conta, defina:
    MT5_PATH      caminho do terminal64.exe
    MT5_LOGIN     número da conta
    MT5_PASSWORD  senha
    MT5_SERVER    servidor da corretora
"""

import os
from contextlib import contextmanager

try:
    import MetaTrader5 as mt5
except ImportError as exc:
    raise ImportError(
        "Pacote MetaTrader5 não encontrado. Ele só funciona no Python para Windows: "
        "pip install -r python/requirements.txt"
    ) from exc

__all__ = ["conectar", "mt5"]


@contextmanager
def conectar():
    """Inicializa a conexão com o terminal e garante o shutdown ao sair do bloco."""
    args = [os.environ["MT5_PATH"]] if os.getenv("MT5_PATH") else []
    kwargs = {}
    if os.getenv("MT5_LOGIN"):
        kwargs["login"] = int(os.environ["MT5_LOGIN"])
        kwargs["password"] = os.environ.get("MT5_PASSWORD", "")
        kwargs["server"] = os.environ.get("MT5_SERVER", "")

    if not mt5.initialize(*args, **kwargs):
        erro = mt5.last_error()
        mt5.shutdown()
        raise ConnectionError(f"Falha ao conectar no MetaTrader 5: {erro}")
    try:
        yield mt5
    finally:
        mt5.shutdown()
