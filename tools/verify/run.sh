#!/usr/bin/env bash
# run.sh <ubuntu:18.04|ubuntu:20.04> <branch|rama> <old-ref|ref-antes> <new-ref|ref-después>
# EN: Checks that a rebuilt branch behaves exactly like the previous one. Everything runs in throwaway Docker
#     containers (--rm) that install the packages straight from this repository at each git ref:
#       1. build fingerprint: modules, every ini default, php -i, linked libraries and their packages;
#       2. PHP's full test suite against real MariaDB and PostgreSQL, compared test by test;
#       3. a real website (Apache + mod_php and PHP-FPM, MariaDB, phpMyAdmin 4.9.11 + mezcla.php), page by page.
#     Example: tools/verify/run.sh ubuntu:20.04 php5.6 1174f7d main   (the suite runs split in JOBS=8 processes per ref, see shards.sh)
#     Env: OUT (default ./verify-out), TESTS="ext/pgsql ext/soap" (subset), SKIP_SUITE=1, SKIP_WEB=1, JOBS (8), CPUS (8),
#     WORK (host dir for the test trees, instead of the container layer).
#     Exit 0 = identical; 1 = differences listed above (a fix's own tests may change on purpose: check each one,
#     and rerun anything unexpected with repeat.sh on both refs); 2 = a step failed or is incomplete.
# ES: Comprueba que una rama recompilada se comporta exactamente igual que la anterior. Todo corre en
#     contenedores Docker de usar y tirar (--rm) que instalan los paquetes de este repositorio en cada ref de git:
#       1. huella de compilación: módulos, cada valor de ini, php -i, librerías enlazadas y sus paquetes;
#       2. la suite completa de PHP con MariaDB y PostgreSQL de verdad, comparada prueba a prueba;
#       3. una web de verdad (Apache + mod_php y PHP-FPM, MariaDB, phpMyAdmin 4.9.11 + mezcla.php), página a página.
#     Ejemplo: tools/verify/run.sh ubuntu:20.04 php5.6 1174f7d main   (la suite va repartida en JOBS=8 procesos por ref, ver shards.sh)
#     Entorno: OUT (por defecto ./verify-out), TESTS="ext/pgsql ext/soap" (una parte), SKIP_SUITE=1, SKIP_WEB=1, JOBS (8),
#     CPUS (8), WORK (carpeta del host para los árboles de pruebas, en vez de la capa del contenedor).
#     Sale 0 = idéntico; 1 = diferencias, listadas arriba (las pruebas de un arreglo pueden cambiar a propósito:
#     revisar cada una y repetir lo inesperado con repeat.sh en las dos refs); 2 = un paso falló o está incompleto.
set -uo pipefail
IMG=$1; R=$2; A=$3; D=$4
case "$IMG" in *18.04) CN=bionic;; *20.04) CN=focal;; *) echo "imagen: ubuntu:18.04 o ubuntu:20.04"; exit 2;; esac
H=$(cd "$(dirname "$0")" && pwd)
OUT=$(mkdir -p "${OUT:-./verify-out}" && cd "${OUT:-./verify-out}" && pwd)
PMA=phpMyAdmin-4.9.11-english.tar.xz
PMA_SHA=b20ea93022cba7735481c543faad573610d958daebbc0c3952d864e7cfa8acbf
corre() { # name, extra docker args..., -- , command / nombre, args de docker..., --, orden
  local n=$1; shift; local args=(); while [ "$1" != -- ]; do args+=("$1"); shift; done; shift
  docker run --rm --name "verify-$$-$n" --cpus "${C:-2}" --memory "${M:-2g}" -e REPO_RAW -e TESTS -e JOBS -v "$H":/v:ro -v "$OUT":/out "${args[@]}" "$IMG" "$@"
}
mal=0; roto=0

if [ "${SKIP_SUITE:-}" != 1 ]; then
  echo "== 1+2. Huella y suite / fingerprint and suite: $IMG $R, $A frente a $D"
  for ref in "$A" "$D"; do
    # EN: WORK=<host dir>: the test tree goes there, not into the container layer / ES: el árbol de pruebas va ahí, no a la capa
    t=(); [ -n "${WORK:-}" ] && { mkdir -p "$WORK/suite-$ref"; t=(-v "$(realpath "$WORK")/suite-$ref":/t); }
    C=${CPUS:-8} M=4g corre suite-$ref -v "$H/suite.sh":/i.sh:ro "${t[@]}" -- bash /i.sh "$ref" "$R" > "$OUT/$CN-$R-$ref.run.txt" 2>&1 &
  done; wait
  for ref in "$A" "$D"; do sed "s/^/  /" "$OUT/$CN-$R-$ref.run.txt"; grep -q '^MAL' "$OUT/$CN-$R-$ref.run.txt" && roto=1; done
  if [ $roto = 0 ]; then
    p="$OUT/$CN-$R"
    echo "  paquetes / packages (solo la versión debe cambiar / only the version should change):"
    diff <(awk '{print $1}' "$p-$A.paquetes") <(awk '{print $1}' "$p-$D.paquetes") >/dev/null || { echo "    LISTA DISTINTA"; mal=1; }
    join <(sort "$p-$A.paquetes") <(sort "$p-$D.paquetes") | awk '$2 != $3 {print "    " $1 ": " $2 " -> " $3}' | sort -u -k3 | head -20
    for x in modulos ini phpi libs; do
      n=$(diff "$p-$A.$x" "$p-$D.$x" | grep -c '^[<>]')
      echo "  $x: $n líneas distintas de $(wc -l < "$p-$D.$x")"; [ "$n" = 0 ] || { diff "$p-$A.$x" "$p-$D.$x" | head -10 | sed 's/^/    /'; mal=1; }
    done
    n=$(diff <(awk '{print $1}' "$p-$A.ldd") <(awk '{print $1}' "$p-$D.ldd") | grep -c '^[<>]')
    echo "  ldd: $n distintas"; [ "$n" = 0 ] || mal=1
    if [ -z "${TESTS:-}" ]; then MIN_TESTS=1000; else MIN_TESTS=1; fi
    MIN_TESTS=$MIN_TESTS "$H/compare-suite.sh" "$p-$A.suite.log" "$p-$D.suite.log"; rc=$?
    [ $rc = 2 ] && roto=1; [ $rc = 1 ] && mal=1
  fi
fi

if [ "${SKIP_WEB:-}" != 1 ] && [ $roto = 0 ]; then
  echo "== 3. Web: $IMG $R, $A frente a $D"
  mkdir -p "$OUT/w"
  [ -f "$OUT/w/$PMA" ] || curl -fsSL "https://files.phpmyadmin.net/phpMyAdmin/4.9.11/$PMA" -o "$OUT/w/$PMA"
  echo "$PMA_SHA  $OUT/w/$PMA" | sha256sum -c --quiet || { echo "  sha256 de phpMyAdmin no coincide / mismatch"; exit 2; }
  cp "$H/mezcla.php" "$OUT/w/mezcla.php"
  for s in modphp fpm; do for ref in "$A" "$D"; do
    corre web-$s-$ref -v "$H/web.sh":/web.sh:ro -v "$OUT/w":/w:ro -- bash /web.sh "$ref" "$R" "$s" > "$OUT/$CN-$R-$ref-$s.web.txt" 2>&1 &
  done; wait; done
  for s in modphp fpm; do
    for ref in "$A" "$D"; do sed "s/^/  /" "$OUT/$CN-$R-$ref-$s.web.txt"; done
    echo "  -- $s:"; "$H/compare-web.sh" "$OUT/web/$CN-$R-$A-$s" "$OUT/web/$CN-$R-$D-$s"; rc=$?
    [ $rc = 2 ] && roto=1; [ $rc = 1 ] && mal=1
  done
fi

if [ $roto = 1 ]; then echo ">>> INCOMPLETO / INCOMPLETE: un paso falló, ver arriba / a step failed, see above"; exit 2; fi
if [ $mal = 1 ]; then echo ">>> HAY DIFERENCIAS / DIFFERENCES: revisar cada una / check each one"; exit 1; fi
echo ">>> IDÉNTICO / IDENTICAL: $R $A = $D"
