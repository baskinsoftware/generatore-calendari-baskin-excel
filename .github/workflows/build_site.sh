#!/usr/bin/env bash
# build_site.sh by Daniele Lolli (UncleDan) <uncledan74@gmail.com> feat. Claude by Anthropic - Release 26.3.2 - 2026-11-27 14-44-03
# Prepara la cartella _site per GitHub Pages con il solo generatore HTML:
#   ramo master (predefinito; se manca, main) -> radice del sito
#   ramo beta                       -> sottocartella beta/
# Se manca il ramo principale si pubblica solo beta (la radice rimanda a beta/).
set -euo pipefail
F=Generatore_Calendari_Baskin_Excel.html
OLD=Generatore_Campionato_Baskin.html
OUT=${1:-_site}
rm -rf "$OUT"; mkdir -p "$OUT"
estrai() {  # estrai <ramo> <cartella>: copia l'HTML del ramo, se ramo e file esistono
  if git rev-parse --verify --quiet "origin/$1" >/dev/null && git cat-file -e "origin/$1:$F" 2>/dev/null; then
    mkdir -p "$2"; git show "origin/$1:$F" > "$2/index.html"; cp "$2/index.html" "$2/$F"
    cp "$2/index.html" "$2/$OLD"   # vecchio nome (fino alla v26.2, ex Release 1.41): i link salvati continuano a funzionare
    return 0
  fi
  return 1
}
PRINC=""
if estrai master "$OUT"; then PRINC=master; elif estrai main "$OUT"; then PRINC=main; fi
BETA=""
if estrai beta "$OUT/beta"; then BETA=beta; fi
if [ -z "$PRINC" ] && [ -z "$BETA" ]; then echo "Nessun ramo main, master o beta con $F: niente da pubblicare." >&2; exit 1; fi
if [ -z "$PRINC" ]; then
  printf '<!DOCTYPE html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=beta/"><title>Generatore Calendari Baskin Excel</title><a href="beta/">Generatore Calendari Baskin Excel (beta)</a>\n' > "$OUT/index.html"
fi
touch "$OUT/.nojekyll"
echo "Ramo principale: ${PRINC:-nessuno} - ramo beta: ${BETA:-nessuno}"
find "$OUT" -type f | sort
