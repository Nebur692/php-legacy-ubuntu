#!/usr/bin/env bash
# compare-web.sh <before-dir> <after-dir>
# EN: Compares two web.sh walks page by page after masking what changes on every run (session ids, tokens,
#     timings, live server counters, InnoDB sizes). Exit 0 only if everything matches; 2 if a walk is incomplete.
# ES: Compara dos recorridos de web.sh página a página tras tapar lo que cambia en cada ejecución (sesiones,
#     tokens, tiempos, contadores en vivo, tamaños de InnoDB). Sale 0 solo si todo coincide; 2 si falta algo.
A=$1; D=$2; mal=0
norm() { # $1 fichero, $2 nombre de página
  tr -d '\r' < "$1" | sed -E \
    -e 's/[0-9a-f]{16,}/HEX/g' \
    -e 's/(phpMyAdmin|pmaUser|pmaAuth|PHPSESSID)[-_0-9A-Za-z]*=[^;"&]*/\1=X/g' \
    -e 's/local[12]/localN/g' \
    -e 's/(Generation Time|Tiempo de generación): .*/\1: X/' \
    -e 's/(Query took|La consulta tardó) [0-9.]+ (seconds|segundos)/\1 T \2/g' \
    -e 's/[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}/FECHAHORA/g' \
    -e 's/(Nov|Dec|Jan) [0-9]{2}, [0-9]{4} at [0-9:]+ (AM|PM)/FECHA/g' \
    -e 's/nocache=[0-9]+/nocache=N/g' \
    -e 's/(data-for|data-uniqueId)=(\\?)"[0-9]+/\1=\2"RND/g' \
    -e 's/\b[0-9a-f]{12}\b/HOST/g' \
    -e 's/([A-Za-z]_)[0-9]{6,}/\1RND/g' \
    -e 's/\b[a-z0-9]{26,40}\b/SID/g' \
    | { case "$2" in
          *estado*) sed -E 's/[0-9]+/N/g; s/N(,N)*(\.N)?(&nbsp;| )*(B|KiB|MiB|GiB|k|M|G)?\b/VAL/g; s/[[:space:]]+</</g';;  # contadores en vivo de MariaDB (1,234.5 o 12.3 k)
          *variables*|*inicio*|*usuarios*) sed -E 's/[0-9]+/N/g';;
          *estructura*) sed -E 's/\b[0-9]+\.[0-9]\b/SZ/g';;   # tamaños de InnoDB: varían entre ejecuciones con el mismo PHP
          *) cat;; esac; }
}
for x in "$A" "$D"; do for f in codigos php-errors.log apache-caidas.log; do [ -f "$x/$f" ] || { echo "  FALTA $x/$f: no se puede comparar"; exit 2; }; done; done
[ -f "$A/MAL" ] || [ -f "$D/MAL" ] && { echo "  una de las dos ejecuciones falló: $(cat $A/MAL $D/MAL 2>/dev/null)"; exit 1; }
[ "$(wc -l < "$A/codigos")" -ge 20 ] || { echo "  solo $(wc -l < "$A/codigos") páginas en $A: recorrido incompleto"; exit 2; }
cmp -s <(awk '{print $1, $2}' "$A/codigos") <(awk '{print $1, $2}' "$D/codigos") || { echo "  códigos HTTP distintos:"; diff <(cat "$A/codigos") <(cat "$D/codigos") | head; mal=1; }
n=0; dif=0
for fa in "$A"/*.body "$A"/*.body.txt; do
  [ -f "$fa" ] || continue; f=$(basename "$fa"); fd="$D/$f"; n=$((n+1))
  case "$f" in *export-zip.body|*export-gzip.body) continue;; esac   # se comparan descomprimidos (.txt)
  if ! cmp -s <(norm "$fa" "$f") <(norm "$fd" "$f"); then
    dif=$((dif+1)); mal=1; echo "  DISTINTA $f:"; diff <(norm "$fa" "$f") <(norm "$fd" "$f") | head -8 | cut -c1-200 | sed 's/^/    /'
  fi
done
ea=$(grep -c 'PHP ' "$A/php-errors.log"); ed=$(grep -c 'PHP ' "$D/php-errors.log")
[ "$ea" = "$ed" ] || { echo "  avisos de PHP: antes $ea, después $ed"; grep 'PHP ' "$D/php-errors.log" | sed 's/^\[[^]]*\] //' | sort | uniq -c | head -5; mal=1; }
cd=$(wc -l < "$D/apache-caidas.log"); [ "$cd" = 0 ] || { echo "  caídas de Apache después: $cd"; mal=1; }
[ "$n" -ge 20 ] || { echo "  solo $n respuestas comparadas: no vale"; exit 2; }
echo "  $n respuestas comparadas, $dif distintas; avisos PHP antes/después: $ea/$ed; caídas: $(wc -l < "$A/apache-caidas.log")/$cd"
exit $mal
