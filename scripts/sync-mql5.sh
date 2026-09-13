#!/usr/bin/env bash
# Sincroniza a pasta mql5/ do repositório com a pasta de dados do MetaTrader 5.
#
#   push  repositório -> terminal (padrão)
#   pull  terminal -> repositório (se você editou direto no MetaEditor)
#
# Só copia as subpastas FinAI/, sem tocar no resto do terminal.
#
# Descubra a pasta de dados em: MT5 > Arquivo > Abrir pasta de dados. No WSL, algo como:
#   export MT5_DATA_DIR="/mnt/c/Users/<voce>/AppData/Roaming/MetaQuotes/Terminal/<ID>"
set -euo pipefail

: "${MT5_DATA_DIR:?Defina MT5_DATA_DIR com a pasta de dados do terminal (Arquivo > Abrir pasta de dados)}"

mode="${1:-push}"
repo_mql5="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/mql5"
term_mql5="$MT5_DATA_DIR/MQL5"

if [[ ! -d "$term_mql5" ]]; then
  echo "Pasta não encontrada: $term_mql5" >&2
  exit 1
fi

case "$mode" in
  push) from="$repo_mql5"; to="$term_mql5" ;;
  pull) from="$term_mql5"; to="$repo_mql5" ;;
  *) echo "Uso: $0 [push|pull]" >&2; exit 2 ;;
esac

for kind in Experts Include Indicators Scripts; do
  src="$from/$kind/FinAI"
  [[ -d "$src" ]] || continue
  mkdir -p "$to/$kind/FinAI"
  # ex5 são binários compilados: ficam só no terminal
  find "$src" -type f ! -name '*.ex5' -printf '%P\n' | while read -r rel; do
    mkdir -p "$(dirname "$to/$kind/FinAI/$rel")"
    cp "$src/$rel" "$to/$kind/FinAI/$rel"
  done
  echo "✔ $kind/FinAI ($mode)"
done

[[ "$mode" == "push" ]] && echo "Pronto. No MetaEditor (F4), compile (F7) os arquivos em Experts/FinAI e Scripts/FinAI."
exit 0
