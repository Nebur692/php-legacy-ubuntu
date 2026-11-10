#!/usr/bin/env bash
# modules-el8.sh
# EN: Writes el8/modules.yaml: one modulemd document per stream with a folder el8/x86_64/module-<name>-<stream>/,
#     made of its header in tools/modules-el8/<name>-<stream>.yaml plus the list of the RPMs in that folder.
#     Same name, stream and context as Remi's (00000000) and its own version: dnf activates every version of an
#     enabled stream with the same context, so our packages join Remi's and the newest build wins, whatever
#     version Remi's document has that day. The packages here are only visible with that stream enabled.
#     Run it before tools/publish-el8.sh, which adds the file to the repository metadata.
# ES: Escribe el8/modules.yaml: un documento modulemd por cada flujo con carpeta el8/x86_64/module-<nombre>-<flujo>/,
#     hecho con su cabecera de tools/modules-el8/<nombre>-<flujo>.yaml y la lista de los RPM de esa carpeta.
#     Mismo nombre, flujo y contexto que el de Remi (00000000) y versión propia: dnf activa todas las versiones de
#     un flujo activado con el mismo contexto, así que nuestros paquetes se suman a los de Remi y gana la compilación
#     más nueva, tenga el documento de Remi la versión que tenga ese día. Los paquetes de aquí solo se ven con ese
#     flujo activado. Lánzalo antes de tools/publish-el8.sh, que añade el fichero a los metadatos del repositorio.
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd); OUT=$ROOT/el8/modules.yaml; n=0
: > "$OUT.new"
for d in "$ROOT"/el8/x86_64/module-*/; do
  [ -d "$d" ] || continue
  k=$(basename "$d"); k=${k#module-}; H=$ROOT/tools/modules-el8/$k.yaml
  [ -f "$H" ] || { echo "STOP/PARA: no header / falta la cabecera $H" >&2; rm -f "$OUT.new"; exit 1; }
  ls "$d"*.rpm >/dev/null 2>&1 || { echo "STOP/PARA: no RPM in / sin RPM en $d" >&2; rm -f "$OUT.new"; exit 1; }
  { cat "$H"; echo "  artifacts:"; echo "    rpms:"
    # EN: name-version-release.arch.rpm -> name-0:version-release.arch / ES: ídem
    for f in "$d"*.rpm; do b=$(basename "$f" .rpm); a=${b##*.}; b=${b%.*}; r=${b##*-}; b=${b%-*}; v=${b##*-}; echo "    - ${b%-*}-0:$v-$r.$a"; done | sort
    echo "..."; } >> "$OUT.new"
  n=$((n+1))
done
if [ $n = 0 ]; then rm -f "$OUT.new" "$OUT"; echo "no modules / sin módulos"; else mv "$OUT.new" "$OUT"; echo "OK $OUT: $n streams / flujos"; fi
