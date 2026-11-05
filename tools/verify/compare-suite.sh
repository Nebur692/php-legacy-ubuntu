#!/usr/bin/env bash
# compare-suite.sh <before.suite.log> <after.suite.log>
# EN: Compares two run-tests logs test by test and lists every test whose result changed. Exit 2 if a log is
#     incomplete (fewer than ${MIN_TESTS:-1000} results).
# ES: Compara dos registros de run-tests prueba a prueba y lista cada prueba que cambia de resultado. Sale con 2
#     si un registro está incompleto (menos de ${MIN_TESTS:-1000} resultados).
resultados() { # "path status" per test, sorted / "ruta estado" por prueba, ordenado
  tr '\r' '\n' < "$1" | grep -aE '^(PASS|FAIL|SKIP|BORK|LEAK|XFAIL|WARN|XLEAK)[ &].*\[[^]]+\.phpt\]' \
    | sed -E 's/^([A-Z&]+) .*\[([^]]+\.phpt)\].*$/\2 \1/' | sort -u
}
a=$(mktemp); d=$(mktemp); c=$(mktemp); trap 'rm -f "$a" "$d" "$c"' EXIT
resultados "$1" > "$a"; resultados "$2" > "$d"
na=$(wc -l < "$a"); nd=$(wc -l < "$d")
[ "$na" -ge "${MIN_TESTS:-1000}" ] && [ "$nd" -ge "${MIN_TESTS:-1000}" ] || { echo "  solo $na/$nd resultados: no vale / incomplete"; exit 2; }
for f in "$a" "$d"; do awk '{print $2}' "$f" | sort | uniq -c | tr -s ' \n' ' '; echo; done | sed 's/^/  /'
join -a1 -a2 -e AUSENTE -o 0,1.2,2.2 "$a" "$d" | awk '$2 != $3' > "$c"
echo "  $na/$nd pruebas; cambian de estado / changed: $(wc -l < "$c")"; sed 's/^/    /' "$c"
[ -s "$c" ] && exit 1 || exit 0
