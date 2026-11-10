#!/usr/bin/env bash
# compare-suite.sh <before.suite.log> <after.suite.log>
# EN: Compares two run-tests logs test by test and lists every test whose result changed. Exit 2 if a log is
#     incomplete (fewer than ${MIN_TESTS:-1000} results).
# ES: Compara dos registros de run-tests prueba a prueba y lista cada prueba que cambia de resultado. Sale con 2
#     si un registro está incompleto (menos de ${MIN_TESTS:-1000} resultados).
resultados() { # "path status" per test, sorted / "ruta estado" por prueba, ordenado
  # EN: a test whose title has several lines prints its result on one line and its path a few lines below: join them
  # ES: una prueba con título de varias líneas imprime el resultado en una línea y la ruta unas líneas más abajo: se juntan
  tr '\r' '\n' < "$1" | awk '/^(PASS|FAIL|SKIP|BORK|LEAK|XFAIL|WARN|XLEAK)[ &]/ { b = $0; n = 0; if (b ~ /\.phpt\]/) { print b; b = "" }; next }
    b != "" { b = b " " $0; if (b ~ /\.phpt\]/ || ++n > 5) { print b; b = "" } }' \
    | grep -aE '^(PASS|FAIL|SKIP|BORK|LEAK|XFAIL|WARN|XLEAK)[ &].*\[[^]]+\.phpt\]' \
    | sed -E 's/^([A-Z&]+) .*\[([^]]+\.phpt)\].*$/\2 \1/' | sort -u \
    | awk '{ if ($1 == p) s = s "," $2; else { if (p != "") print p, s; p = $1; s = $2 } } END { if (p != "") print p, s }'
}
a=$(mktemp); d=$(mktemp); c=$(mktemp); trap 'rm -f "$a" "$d" "$c"' EXIT
resultados "$1" > "$a"; resultados "$2" > "$d"
na=$(wc -l < "$a"); nd=$(wc -l < "$d")
[ "$na" -ge "${MIN_TESTS:-1000}" ] && [ "$nd" -ge "${MIN_TESTS:-1000}" ] || { echo "  solo $na/$nd resultados: no vale / incomplete"; exit 2; }
for f in "$a" "$d"; do awk '{print $2}' "$f" | sort | uniq -c | tr -s ' \n' ' '; echo; done | sed 's/^/  /'
join -a1 -a2 -e AUSENTE -o 0,1.2,2.2 "$a" "$d" | awk '$2 != $3' > "$c"
echo "  $na/$nd pruebas; cambian de estado / changed: $(wc -l < "$c")"; sed 's/^/    /' "$c"
[ -s "$c" ] && exit 1 || exit 0
