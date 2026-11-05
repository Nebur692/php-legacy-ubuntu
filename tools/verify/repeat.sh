#!/usr/bin/env bash
# repeat.sh <ref> <branch|rama> <times|veces> <test.phpt>...   (runs INSIDE a container, with suite.sh at /i.sh)
# EN: Same setup as suite.sh without the suite, then runs the given tests N times: tells a flaky test
#     (same pattern before and after) from a real change.
# ES: Monta lo mismo que suite.sh sin la suite y repite esas pruebas N veces: distingue una prueba
#     intermitente (el mismo patrón antes y después) de un cambio de verdad.
# docker run --rm -v "$PWD/tools/verify/suite.sh":/i.sh:ro -v "$PWD/tools/verify/repeat.sh":/r.sh:ro \
#   ubuntu:20.04 bash /r.sh main php7.0 5 ext/mysqli/tests/mysqli_character_set.phpt
set -uo pipefail
REF=$1; R=$2; N=$3; shift 3; V=${R#php}
SOLO_HUELLA=1 bash /i.sh "$REF" "$R" >/dev/null || { echo "MAL montaje"; exit 1; }
. /etc/os-release
export MYSQL_TEST_HOST=127.0.0.1 MYSQL_TEST_USER=php MYSQL_TEST_PASSWD=php MYSQL_TEST_DB=test MYSQL_TEST_SOCKET=/var/run/mysqld/mysqld.sock
export PDO_MYSQL_TEST_DSN="mysql:host=127.0.0.1;dbname=test" PDO_MYSQL_TEST_USER=php PDO_MYSQL_TEST_PASS=php PDO_MYSQL_TEST_HOST=127.0.0.1
export PGSQL_TEST_CONNSTR="host=localhost dbname=test port=5432 user=postgres password=postgres"
export PDO_PGSQL_TEST_DSN="pgsql:host=localhost port=5432 dbname=test user=postgres password=postgres"
export NO_INTERACTION=1 TEST_PHP_EXECUTABLE=/usr/bin/php$V TEST_PHP_CGI_EXECUTABLE=/usr/bin/php-cgi$V
G=${REPO_RAW:-https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu}
UP=$(dpkg-query -W -f='${Version}' $R-cli | sed -E 's/^[0-9]+://; s/-.*//')
curl -fsSL "$G/$REF/pool/$VERSION_CODENAME/$R/fuente/${R}_${UP}.orig.tar.xz" -o /tmp/orig.tar.xz || { echo "MAL orig.tar.xz"; exit 1; }
mkdir -p /t; tar -xJf /tmp/orig.tar.xz -C /t --strip-components=1; cd /t
for i in $(seq 1 $N); do
  php$V -d variables_order=EGPCS run-tests.php --set-timeout 300 "$@" 2>&1 | tr '\r' '\n' | grep -aE '^(PASS|FAIL|SKIP|BORK)' | sed "s/^/[$REF #$i] /"
done
