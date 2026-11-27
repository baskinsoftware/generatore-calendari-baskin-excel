#!/usr/bin/env bash
# build_site.sh by Daniele Lolli (UncleDan) <uncledan74@gmail.com> feat. Claude by Anthropic - Release 26.3.2 - 2026-11-27 14-44-03
# Prepara la cartella _site per GitHub Pages con il solo generatore HTML, come negli altri progetti Baskin:
#   cartella pwa/ del ramo principale (master; se manca, main) -> / (radice del sito)
#   cartella pwa/ del ramo beta                                 -> /beta/
#   /pwa/ -> reindirizza a / se il ramo principale ha l'app, altrimenti a /beta/ (retrocompatibilita')
# Se il ramo principale non ha l'app la radice rimanda a /beta/.
# Retrocompatibilita': un ramo che ha ancora l'HTML alla radice del repository (fino alla v26.3.1)
# viene pubblicato lo stesso; i vecchi nomi del file restano raggiungibili.
set -euo pipefail
NEW=pwa/index.html
F=Generatore_Calendari_Baskin_Excel.html
OLD=Generatore_Campionato_Baskin.html
OUT=${1:-_site}
rm -rf "$OUT"; mkdir -p "$OUT"
sorgente() {  # sorgente <ramo>: percorso dell'HTML nel ramo (pwa/index.html o, se manca, il file alla radice)
  local p
  git rev-parse --verify --quiet "origin/$1" >/dev/null || return 1
  for p in "$NEW" "$F"; do
    if git cat-file -e "origin/$1:$p" 2>/dev/null; then echo "$p"; return 0; fi
  done
  return 1
}
estrai() {  # estrai <ramo> <cartella>: copia l'HTML del ramo, se ramo e file esistono
  local p; p=$(sorgente "$1") || return 1
  mkdir -p "$2"; git show "origin/$1:$p" > "$2/index.html"; cp "$2/index.html" "$2/$F"
  cp "$2/index.html" "$2/$OLD"   # vecchio nome (fino alla v26.2, ex Release 1.41): i link salvati continuano a funzionare
}
PRINC=""
if estrai master "$OUT"; then PRINC=master; elif estrai main "$OUT"; then PRINC=main; fi
BETA=""
if estrai beta "$OUT/beta"; then BETA=beta; fi
if [ -z "$PRINC" ] && [ -z "$BETA" ]; then echo "Nessun ramo main, master o beta con $NEW (o $F): niente da pubblicare." >&2; exit 1; fi
if [ -z "$PRINC" ]; then
  printf '<!DOCTYPE html><meta charset="utf-8"><meta http-equiv="refresh" content="0; url=beta/"><title>Generatore Calendari Baskin Excel</title><a href="beta/">Generatore Calendari Baskin Excel (beta)</a>\n' > "$OUT/index.html"
  DEST="../beta/"
else
  DEST="../"
fi
# /pwa/ -> app corrente (conserva ?parametri e #ancora)
mkdir -p "$OUT/pwa"
cat > "$OUT/pwa/index.html" <<HTML
<!DOCTYPE html><html lang="it"><head><meta charset="utf-8">
<title>Generatore Calendari Baskin Excel</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="refresh" content="0; url=${DEST}">
<script>location.replace('${DEST}' + location.search + location.hash);</script></head>
<body><p>Il generatore si e' spostato: <a href="${DEST}">Generatore Calendari Baskin Excel</a></p></body></html>
HTML
touch "$OUT/.nojekyll"
echo "Ramo principale: ${PRINC:-nessuno} - ramo beta: ${BETA:-nessuno} - /pwa/ -> ${DEST}"
find "$OUT" -type f | sort
