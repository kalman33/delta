#!/bin/sh
# Emballe une fiche (format artifact : fragment HTML sans <head>) en un
# fichier .html autonome, ouvrable dans n'importe quel navigateur.
#   ./build.sh index.html                       -> dist/index-autonome.html
#   ./build.sh index.html docs/index.html      -> chemin explicite
set -e
SRC="${1:-index.html}"
OUT="${2:-dist/$(basename "${SRC%.html}")-autonome.html}"
mkdir -p "$(dirname "$OUT")"
{
  cat <<'HEAD'
<!doctype html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<style>
  :root{color-scheme:light dark;padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}
  body{margin:0;font:14px system-ui,sans-serif;background:#fafaf9}
  img{max-width:100%}
  [hidden]{display:none!important}
</style>
HEAD
  sed -n '/<\/style>/,$p' "$SRC" | sed -n '2,$p' > /tmp/delta-body.$$
  sed -n '1,/<\/style>/p' "$SRC"
  echo '</head>'
  echo '<body>'
  cat /tmp/delta-body.$$
  rm -f /tmp/delta-body.$$
  echo '</body>'
  echo '</html>'
} > "$OUT"
echo "$OUT"
