#!/usr/bin/env bash
# suite.sh <ref> <branch|rama>   (runs INSIDE a throwaway ubuntu:18.04/20.04 container / corre DENTRO de un contenedor)
# EN: Installs every package of <branch> from this repository as published at <ref> (a commit or "main"),
#     then writes the build fingerprint and runs PHP's FULL test suite against real MariaDB and PostgreSQL.
#     Results: /out/<release>-<branch>-<ref>.{paquetes,modulos,ini,phpi,ldd,libs,suite.log,diffs/}
# ES: Instala todos los paquetes de <rama> de este repositorio tal como estaba en <ref> (un commit o «main»),
#     saca la huella de compilación y pasa la suite COMPLETA de PHP con MariaDB y PostgreSQL de verdad.
# Env: TESTS="ext/pgsql ext/soap" limits the suite / limita la suite; SOLO_HUELLA=1 skips it / se la salta;
#      JOBS=8 run-tests processes at once (shards.sh; 1 = serial) / procesos de run-tests a la vez (1 = en serie);
#      /p mounted (run.sh PATCHES=<dir>): its *.patch go onto the test tree, so the fixes' own tests run on both refs
#      / con /p montada, sus *.patch se aplican al árbol de pruebas y las pruebas de cada arreglo corren en las dos refs.
set -uo pipefail
REF=$1; R=$2; V=${R#php}
. /etc/os-release; CN=$VERSION_CODENAME
export DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 TZ=UTC
mkdir -p /out; O=/out/$CN-$R-$REF
mal() { echo "MAL $*"; exit 1; }
G=${REPO_RAW:-https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu}
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq --no-install-recommends curl ca-certificates xz-utils mariadb-server postgresql locales tzdata patch >/dev/null 2>&1 || mal base
curl -fsSL $G/main/php-legacy-ubuntu.gpg -o /usr/share/keyrings/p.gpg || mal "clave del repo"
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/p.gpg] $G/$REF $CN main" > /etc/apt/sources.list.d/p.list
printf 'Package: php-common\nPin: release o=php-legacy-ubuntu\nPin-Priority: 99\n' > /etc/apt/preferences.d/p
apt-get update -qq >/dev/null 2>&1 || mal update
[ "$CN" = bionic ] && apt-get install -y -qq php-common=2:101~+ubuntu22.04.1+deb.sury.org+1 >/dev/null 2>&1
# EN: every package of the branch but -dev and -litespeed (its postinst restarts a service: fails without systemd)
# ES: todos los paquetes de la rama salvo -dev y -litespeed (su postinst reinicia un servicio: sin systemd falla)
P=$(apt-cache dumpavail | awk -v r="$R" '/^Package: /{p=$2} /^Source: /{if($2==r && p!~/-(dev|litespeed)$/) print p}' | sort -u)
[ -n "$P" ] || mal "no hay paquetes de $R en $REF"
apt-get install -y -qq --no-install-recommends $P >/tmp/i 2>&1 || { tail -5 /tmp/i; mal "instalar $R"; }
dpkg-query -W -f='${Package} ${Version}\n' | awk -v v="$V" 'index($1, "php" v) > 0 || $1 == "libgd3" || $1 == "php-common"' > $O.paquetes
n1=$(echo "$P" | wc -w); n2=$(grep -c "php$V" $O.paquetes); [ "$n1" = "$n2" ] || mal "pedidos $n1 paquetes de $R y hay $n2 instalados"
grep -q '^libgd3 ' $O.paquetes || mal "libgd3 no aparece en la lista"
echo "[$CN $R $REF] $(wc -l < $O.paquetes) paquetes; cli $(dpkg-query -W -f='${Version}' $R-cli); libgd3 $(dpkg-query -W -f='${Version}' libgd3)"
# EN: without /etc/snmp/snmp.conf (it ships with the "snmp" package), net-snmp on 18.04 loads every MIB and
#     prints ~40 KB of "Cannot adopt OID" on each PHP start: run-tests reads only stdout, the stderr pipe fills
#     up and the very first test hangs forever. "mibs :" is Ubuntu's own default.
# ES: sin /etc/snmp/snmp.conf (lo trae el paquete «snmp»), net-snmp en 18.04 carga todos los MIB y suelta
#     ~40 KB de «Cannot adopt OID» en cada arranque de PHP: run-tests solo lee stdout, la tubería de stderr se
#     llena y la primera prueba se queda colgada para siempre. «mibs :» es lo que trae Ubuntu por defecto.
[ -f /etc/snmp/snmp.conf ] || { mkdir -p /etc/snmp; printf 'mibs :\n' > /etc/snmp/snmp.conf; }
[ "$(php$V -r 'echo 1;' 2>&1)" = 1 ] || mal "php$V escribe algo al arrancar: $(php$V -r 'echo 1;' 2>&1 | head -2)"

# ---------- 1. Fingerprint / huella ----------
php$V -m > $O.modulos
php$V -r 'foreach (ini_get_all(null, false) as $k => $v) echo "$k=", var_export($v, true), "\n";' | sort > $O.ini
php$V -i | grep -vE '^(Build Date|System|_SERVER|_ENV|\$_|PHP_SELF|REQUEST_TIME|SCRIPT_|PATH_TRANSLATED|DOCUMENT_ROOT|HOSTNAME|HOME|PWD|OLDPWD|SHLVL|PATH|TERM|LANG|TZ|JOBS|TESTS|EXCLUDE|_ =>|argv|argc)' \
  | grep -vE 'PHP Version => |=> '"$(hostname)" | sed -E 's/\+local[0-9]+/+localN/g' > $O.phpi
ED=$(php$V -r 'echo ini_get("extension_dir");')
for f in /usr/bin/php$V /usr/sbin/php-fpm$V /usr/bin/php-cgi$V /usr/bin/phpdbg$V /usr/lib/apache2/modules/libphp$V.so /usr/lib/libphp$V.so $ED/*.so; do
  [ -f "$f" ] || continue
  echo "== $f"; ldd "$f" | awk '{print $1, ($3 ~ /^\// ? $3 : "")}' | sed 's/ (0x[0-9a-f]*)//' | sort
done > $O.ldd
# EN: package owning each linked library / ES: paquete dueño de cada librería enlazada
awk '$2 ~ /^\//{print $2}' $O.ldd | sort -u | while read -r l; do echo "$l $(dpkg -S "$(readlink -f "$l")" 2>/dev/null | cut -d: -f1 | head -1)"; done > $O.libs

# ---------- 2. Databases / bases de datos ----------
(service mariadb start || service mysql start) >/dev/null 2>&1
for i in $(seq 1 30); do mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done
mysql -e "CREATE DATABASE IF NOT EXISTS test; CREATE USER 'php'@'localhost' IDENTIFIED BY 'php'; CREATE USER 'php'@'127.0.0.1' IDENTIFIED BY 'php'; GRANT ALL ON *.* TO 'php'@'localhost'; GRANT ALL ON *.* TO 'php'@'127.0.0.1'; FLUSH PRIVILEGES;" || mal mariadb
service postgresql start >/dev/null 2>&1
for i in $(seq 1 30); do su postgres -c 'pg_isready -q' && break; sleep 1; done
su postgres -c "psql -qc \"ALTER USER postgres PASSWORD 'postgres'\"; createdb test" >/dev/null 2>&1 || mal postgresql
export MYSQL_TEST_HOST=127.0.0.1 MYSQL_TEST_USER=php MYSQL_TEST_PASSWD=php MYSQL_TEST_DB=test MYSQL_TEST_SOCKET=/var/run/mysqld/mysqld.sock
export PDO_MYSQL_TEST_DSN="mysql:host=127.0.0.1;dbname=test" PDO_MYSQL_TEST_USER=php PDO_MYSQL_TEST_PASS=php PDO_MYSQL_TEST_HOST=127.0.0.1
export PGSQL_TEST_CONNSTR="host=localhost dbname=test port=5432 user=postgres password=postgres"
export PDO_PGSQL_TEST_DSN="pgsql:host=localhost port=5432 dbname=test user=postgres password=postgres"
export NO_INTERACTION=1 REPORT_EXIT_STATUS=0 SKIP_ONLINE_TESTS=1 SKIP_SLOW_TESTS=0
export TEST_PHP_EXECUTABLE=/usr/bin/php$V TEST_PHP_CGI_EXECUTABLE=/usr/bin/php-cgi$V
c=$(php$V -r '$m = @mysqli_connect("127.0.0.1", "php", "php", "test"); $p = @pg_connect(getenv("PGSQL_TEST_CONNSTR")); echo ($m ? "mysqli OK" : "mysqli MAL"), " / ", ($p ? "pgsql OK" : "pgsql MAL");')
echo "  PHP -> DB: $c"; echo "$c" | grep -q MAL && mal "PHP no conecta con las bases de datos"
[ "${SOLO_HUELLA:-}" = 1 ] && exit 0

# ---------- 3. Full suite / suite completa ----------
UP=$(dpkg-query -W -f='${Version}' $R-cli | sed -E 's/^[0-9]+://; s/-.*//')
curl -fsSL "$G/$REF/pool/$CN/$R/fuente/${R}_${UP}.orig.tar.xz" -o /tmp/orig.tar.xz || mal "no se pudo bajar ${R}_${UP}.orig.tar.xz"
T=/t; mkdir -p $T; find $T -mindepth 1 -delete; tar -xJf /tmp/orig.tar.xz -C $T --strip-components=1 || mal "orig.tar.xz"
chown -R postgres $T 2>/dev/null; chmod -R a+rwX $T
cd $T
# EN: only the tests matter here (PHP is the installed package): hunks that do not fit the bare upstream tree are dropped
# ES: aquí solo cuentan las pruebas (PHP es el paquete instalado): lo que no entra en el árbol original se descarta
if [ -d /p ]; then n=0; for p in /p/*.patch; do patch -p1 -N -f -s --no-backup-if-mismatch -r - < "$p" >/dev/null 2>&1; n=$((n+1)); done
  echo "  parches de prueba / test patches: $n"; fi
# EN: phpdbg's run_* tests wait for a terminal that a container lacks: kill any phpdbg older than 2 min
# ES: las pruebas run_* de phpdbg esperan una terminal que el contenedor no tiene: se corta todo phpdbg de más de 2 min
( while sleep 30; do ps -eo pid=,etimes=,comm= | awk '$3 ~ /^phpdbg/ && $2 > 120 {print $1}' | xargs -r kill -9; done ) &
VIGIA=$!
# EN: variables_order with E, or 5.6/7.x run-tests does not pass the environment (DB settings) to the tests
#     --set-timeout 300: 60 s per test is too short for pgsql/01createdb on a busy host, and every later pgsql test fails with it
# ES: variables_order con E: si no, el run-tests de 5.6/7.x no pasa el entorno (conexiones) a las pruebas
#     --set-timeout 300: 60 s por prueba no le basta a pgsql/01createdb con la máquina cargada, y arrastra a las demás de pgsql
bash /v/shards.sh "${JOBS:-8}" $O.suite.log -- timeout 14000 php$V -d variables_order=EGPCS -d memory_limit=-1 run-tests.php --set-timeout 300
rc=$?; { kill $VIGIA; wait $VIGIA; } 2>/dev/null
echo "  suite rc=$rc $(tr '\r' '\n' < $O.suite.log | grep -caE '^(PASS|FAIL|SKIP|BORK|LEAK|XFAIL|WARN) .*\.phpt\]') resultados"
[ $rc = 0 ] || mal "suite incompleta: alguna prueba sin resultado o fuera de tiempo (rc=$rc)"
mkdir -p $O.diffs; find . -name '*.diff' -exec cp --parents {} $O.diffs/ \;
exit 0
