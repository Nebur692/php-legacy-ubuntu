#!/usr/bin/env bash
# run-el8.sh <before-dir|carpeta-antes> <after-dir|carpeta-después> <scl: php56|php70|...|module stream / flujo de módulo: php:remi-7.3>
# EN: Checks that a rebuilt EL8 branch behaves like the previous build. Each folder holds the output of
#     tools/build-el8.sh (RPMs + src.tar.gz). Both are installed at the same time in throwaway centos:8 containers
#     and compared: build fingerprint (modules, ini defaults, php -i, linked libraries) and PHP's full suite with
#     real MariaDB and PostgreSQL, test by test. Tests listed in el8-exclude.txt are left out on both sides.
#     Env: OUT (./verify-out), JOBS (8 run-tests processes per side), CPUS (8 per side), MEM (4g per side), TESTS (subset),
#     WORK (host dir for the test trees, instead of the container layer), SERIE=1 (one side after the other, e.g. MEM=14g each).
#     Checking the split itself: run-el8.sh DIR DIR <scl> with JOBS_BEFORE=1 must be identical (serial vs split).
#     Exit 0 = identical; 1 = differences (a fix's own tests may change on purpose: check each one); 2 = a step failed.
# ES: Comprueba que una rama de EL8 recompilada se comporta como la compilación anterior. Cada carpeta tiene la
#     salida de tools/build-el8.sh (RPM + src.tar.gz). Las dos se instalan a la vez en contenedores centos:8 de usar
#     y tirar y se comparan: huella de compilación (módulos, valores de ini, php -i, librerías enlazadas) y la suite
#     completa de PHP con MariaDB y PostgreSQL de verdad, prueba a prueba. Lo de el8-exclude.txt queda fuera en los dos.
#     Entorno: OUT (./verify-out), JOBS (8 procesos de run-tests por lado), CPUS (8 por lado), MEM (4g por lado), TESTS (una parte),
#     WORK (carpeta del host para los árboles de pruebas, en vez de la capa del contenedor), SERIE=1 (un lado tras otro, p. ej. MEM=14g cada uno).
#     Para comprobar el propio reparto: run-el8.sh DIR DIR <scl> con JOBS_BEFORE=1 tiene que salir idéntico (serie frente a reparto).
#     Sale 0 = idéntico; 1 = diferencias (las pruebas de un arreglo pueden cambiar a propósito: revisar cada una);
#     2 = un paso falló.
set -uo pipefail
A=$(realpath "${1:?before-dir}"); D=$(realpath "${2:?after-dir}"); SCL=${3:?scl}
H=$(cd "$(dirname "$0")" && pwd)
OUT=$(mkdir -p "${OUT:-./verify-out}" && cd "${OUT:-./verify-out}" && pwd)
L=${SCL//:/-}; na=$L-antes; nd=$L-despues; roto=0; mal=0
for x in "$na:$A" "$nd:$D"; do
  n=${x%%:*}; dir=${x#*:}; j=${JOBS:-8}; [ "$n" = "$na" ] && j=${JOBS_BEFORE:-$j}
  # EN: WORK=<host dir>: the test tree goes there, not into the container layer / ES: el árbol de pruebas va ahí, no a la capa
  t=(); [ -n "${WORK:-}" ] && { mkdir -p "$WORK/$n"; t=(-v "$(realpath "$WORK")/$n":/t); }
  docker run --rm --name "verify-el8-$$-$n" --cpus "${CPUS:-8}" --memory "${MEM:-4g}" -e JOBS="$j" -e TESTS \
    -e EXCLUDE=/v/el8-exclude.txt -v "$dir":/rpms:ro -v "$H":/v:ro -v "$OUT":/out "${t[@]}" centos:8 \
    bash /v/suite-el8.sh "$n" "$SCL" > "$OUT/$n.run.txt" 2>&1 &
  [ "${SERIE:-}" = 1 ] && wait
done; wait
for n in $na $nd; do sed 's/^/  /' "$OUT/$n.run.txt"; grep -q '^MAL' "$OUT/$n.run.txt" && roto=1; done
if [ $roto = 0 ]; then
  echo "  paquetes / packages:"; join <(sort "$OUT/$na.paquetes") <(sort "$OUT/$nd.paquetes") | awk '$2 != $3 {print "    " $1 ": " $2 " -> " $3}' | head -5
  for x in modulos ini phpi libs; do
    n=$(diff "$OUT/$na.$x" "$OUT/$nd.$x" | grep -c '^[<>]')
    echo "  $x: $n líneas distintas de $(wc -l < "$OUT/$nd.$x")"; [ "$n" = 0 ] || { diff "$OUT/$na.$x" "$OUT/$nd.$x" | head -10 | sed 's/^/    /'; mal=1; }
  done
  n=$(diff <(awk '{print $1}' "$OUT/$na.ldd") <(awk '{print $1}' "$OUT/$nd.ldd") | grep -c '^[<>]')
  echo "  ldd: $n distintas"; [ "$n" = 0 ] || mal=1
  if [ -z "${TESTS:-}" ]; then MIN_TESTS=1000; else MIN_TESTS=1; fi
  MIN_TESTS=$MIN_TESTS "$H/compare-suite.sh" "$OUT/$na.suite.log" "$OUT/$nd.suite.log"; rc=$?
  [ $rc = 2 ] && roto=1; [ $rc = 1 ] && mal=1
fi
if [ $roto = 1 ]; then echo ">>> INCOMPLETO / INCOMPLETE"; exit 2; fi
if [ $mal = 1 ]; then echo ">>> HAY DIFERENCIAS / DIFFERENCES: revisar cada una / check each one"; exit 1; fi
echo ">>> IDÉNTICO / IDENTICAL"
