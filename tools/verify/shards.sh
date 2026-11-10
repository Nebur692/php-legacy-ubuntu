#!/usr/bin/env bash
# shards.sh <jobs|trozos> <out.log> -- <run-tests command / orden de run-tests...>
#   (run it from the root of a PHP source tree / se lanza desde la raíz de un árbol de código de PHP)
# EN: Runs PHP's test suite split into <jobs> run-tests processes at once and writes one log with every
#     result, as if it had run in one go. Splitting never breaks what the tests share:
#       - a folder is never split (tests of one folder share files and run in order);
#       - tests that need the same port or server run together: the PHP built-in server on port 8964
#         (sapi/cli, curl, opcache, soap, http, url, streams, tests/basic), fixed raw ports (openssl, sockets,
#         network, file, fpm, cgi, ftp, ldap, snmp, imap, firebird), MariaDB (mysqli, pdo_mysql, mysql,
#         mysqlnd) and PostgreSQL (pgsql, pdo_pgsql) get one process each;
#       - each process has its own TMPDIR, so files in the temp folder never collide.
#     With <jobs> 1 it is exactly the serial run (same list, same order): use it to check the split.
#     Exit 2 if any listed test has no result (a process died, timed out or hung).
#     Env: TESTS="ext/pgsql ext/soap" (only those paths), EXCLUDE=<file> (one test path per line, "#" comments).
# ES: Pasa la suite de PHP repartida en <trozos> procesos de run-tests a la vez y escribe un único registro con
#     todos los resultados, como si hubiera ido de una vez. El reparto nunca rompe lo que comparten las pruebas:
#       - una carpeta nunca se parte (sus pruebas comparten ficheros y van en orden);
#       - las que necesitan el mismo puerto o servidor van juntas: el servidor de PHP en el puerto 8964
#         (sapi/cli, curl, opcache, soap, http, url, streams, tests/basic), los puertos fijos (openssl, sockets,
#         network, file, fpm, cgi, ftp, ldap, snmp, imap, firebird), MariaDB (mysqli, pdo_mysql, mysql, mysqlnd)
#         y PostgreSQL (pgsql, pdo_pgsql) tienen un proceso cada uno;
#       - cada proceso tiene su propio TMPDIR: los ficheros temporales nunca chocan.
#     Con <trozos> 1 es exactamente la pasada en serie (misma lista, mismo orden): sirve para comprobar el reparto.
#     Sale con 2 si alguna prueba de la lista no tiene resultado (un proceso murió, se pasó de tiempo o se colgó).
#     Entorno: TESTS="ext/pgsql ext/soap" (solo esas rutas), EXCLUDE=<fichero> (una ruta por línea, «#» comenta).
set -uo pipefail
J=${1:?jobs / trozos}; LOG=${2:?out.log}; shift 2; [ "${1:-}" = -- ] && shift
[ $# -gt 0 ] || { echo "falta la orden de run-tests / missing run-tests command"; exit 2; }
S=$PWD; W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
# shellcheck disable=SC2086
find ${TESTS:-Zend tests ext sapi} -name '*.phpt' -not -path '*/.*' 2>/dev/null | sed 's#^\./##' | sort -u > "$W/todas"
# EN: --REDIRECTTEST-- files (pdo_*/tests/common.phpt) run other tests and print no result of their own
# ES: los --REDIRECTTEST-- (pdo_*/tests/common.phpt) pasan otras pruebas y no imprimen resultado propio
xargs -a "$W/todas" grep -l -- '^--REDIRECTTEST--' 2>/dev/null | sort > "$W/redir"
if [ -n "${EXCLUDE:-}" ]; then
  grep -v '^[[:space:]]*#' "$EXCLUDE" | awk 'NF{print $1}' > "$W/fuera"
  grep -vxF -f "$W/fuera" "$W/todas" > "$W/t2"; mv "$W/t2" "$W/todas"
  echo "  excluidas / excluded: $(wc -l < "$W/fuera")"
fi
N=$(wc -l < "$W/todas"); [ "$N" -gt 0 ] || { echo "no hay pruebas / no tests"; exit 2; }
if [ "$J" -lt 6 ]; then J=1; fi   # EN: 4 fixed groups + at least 2 general ones / ES: 4 grupos fijos + 2 generales como mínimo
if [ "$J" = 1 ]; then
  cp "$W/todas" "$W/s1"
else
  awk -v J="$J" -v W="$W" '
    function grupo(p) {
      if (p ~ /^(sapi\/cli|ext\/curl|ext\/opcache|ext\/soap|ext\/standard\/tests\/(http|url|streams)|tests\/basic)\//) return 1
      if (p ~ /^(ext\/(openssl|sockets|ftp|ldap|snmp|imap|pdo_firebird|interbase)|ext\/standard\/tests\/(network|file)|sapi\/(fpm|cgi))\//) return 2
      if (p ~ /^ext\/(mysqli|pdo_mysql|mysql|mysqlnd)\//) return 3
      if (p ~ /^ext\/(pgsql|pdo_pgsql)\//) return 4
      return 0
    }
    { d = $0; sub(/\/[^\/]*$/, "", d); g = grupo($0)
      if (g) print > (W "/s" g); else { n[d]++; l[d] = l[d] $0 "\n" } }
    END {
      # EN: general folders, biggest first, to the emptiest process / ES: carpetas generales, de mayor a menor, al proceso más vacío
      m = 0; for (d in n) orden[++m] = d
      for (i = 2; i <= m; i++) { x = orden[i]; for (k = i - 1; k >= 1 && n[orden[k]] < n[x]; k--) orden[k + 1] = orden[k]; orden[k + 1] = x }
      for (s = 5; s <= J; s++) carga[s] = 0
      for (i = 1; i <= m; i++) { b = 5; for (s = 6; s <= J; s++) if (carga[s] < carga[b]) b = s
        carga[b] += n[orden[i]]; printf "%s", l[orden[i]] > (W "/g" b) }
      for (s = 5; s <= J; s++) if ((W "/g" s) != "") close(W "/g" s)
    }' "$W/todas"
  for s in $(seq 5 "$J"); do [ -f "$W/g$s" ] && sort "$W/g$s" > "$W/s$s"; done
fi
# EN: absolute paths, so the list works from any working folder / ES: rutas absolutas, valen desde cualquier carpeta
for f in "$W"/s*; do sed -i "s#^#$S/#" "$f"; done
i=0; for f in "$W"/s*; do
  [ -s "$f" ] || continue; i=$((i + 1)); mkdir -p "$W/tmp$i"
  ( cd "$S" && TMPDIR="$W/tmp$i" "$@" -r "$f" > "$W/log$i" 2>&1 ) &
done
echo "  $N pruebas en $i procesos / tests in processes"
wait
cat "$W"/log* > "$LOG"
# EN: every listed test must have a result / ES: cada prueba de la lista tiene que tener resultado
# EN: titles of several lines: result and path come on different lines (same join as compare-suite.sh)
# ES: títulos de varias líneas: resultado y ruta salen en líneas distintas (la misma unión que compare-suite.sh)
tr '\r' '\n' < "$LOG" | awk '/^(PASS|FAIL|SKIP|BORK|LEAK|XFAIL|WARN|XLEAK)[ &]/ { b = $0; n = 0; if (b ~ /\.phpt\]/) { print b; b = "" }; next }
    b != "" { b = b " " $0; if (b ~ /\.phpt\]/ || ++n > 5) { print b; b = "" } }' \
  | grep -aoE '^(PASS|FAIL|SKIP|BORK|LEAK|XFAIL|WARN|XLEAK)[ &].*\[[^]]+\.phpt\]' \
  | sed -E 's/^.*\[([^]]+\.phpt)\]$/\1/; s#^'"$S"'/##' | sort -u > "$W/hechas"
comm -23 "$W/todas" "$W/hechas" | comm -23 - "$W/redir" > "$W/faltan"
falta=$(wc -l < "$W/faltan")
echo "  resultados / results: $(wc -l < "$W/hechas") de $N; sin resultado / missing: $falta"
[ "$falta" = 0 ] || { head -10 "$W/faltan" | sed 's/^/    falta: /'; exit 2; }
exit 0
