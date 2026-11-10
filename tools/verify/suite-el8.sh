#!/usr/bin/env bash
# suite-el8.sh <name|nombre> <scl: php56|...|module stream: php:remi-7.3>   (runs INSIDE a throwaway centos:8 container / corre DENTRO de un contenedor centos:8)
#     A module stream (name:stream) enables it first and checks the packages in /usr, not /opt/remi/<scl>.
#     Un flujo de módulo (nombre:flujo) se activa antes y los paquetes se miran en /usr, no en /opt/remi/<scl>.
# EN: Installs the RPMs in /rpms (from tools/build-el8.sh) on a clean CentOS 8.5, writes the build fingerprint and
#     runs PHP's full test suite from /rpms/src.tar.gz against real MariaDB and PostgreSQL, split with shards.sh.
#     Results: /out/<name>.{paquetes,modulos,ini,phpi,ldd,libs,suite.log}
#     Env: JOBS (default 8), TESTS (subset), EXCLUDE (file, see el8-exclude.txt), SOLO_HUELLA=1 (no suite).
# ES: Instala los RPM de /rpms (de tools/build-el8.sh) en un CentOS 8.5 limpio, saca la huella de compilación y
#     pasa la suite completa de PHP de /rpms/src.tar.gz con MariaDB y PostgreSQL de verdad, repartida con shards.sh.
#     Entorno: JOBS (por defecto 8), TESTS (una parte), EXCLUDE (fichero, ver el8-exclude.txt), SOLO_HUELLA=1.
set -uo pipefail
N=$1; SCL=$2; O=/out/$N
MOD=; case $SCL in *:*) MOD=$SCL; SCL=php;; esac
export LANG=C.UTF-8 TZ=UTC
mal() { echo "MAL $*"; exit 1; }
sed -i -e "s|^mirrorlist=|#mirrorlist=|" -e "s|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|" /etc/yum.repos.d/CentOS-*
dnf -q -y install epel-release >/dev/null 2>&1 || mal epel
curl -fsSLo /tmp/r.rpm https://rpms.remirepo.net/enterprise/remi-release-8.rpm && rpm -i --nodeps /tmp/r.rpm >/dev/null 2>&1 || mal remi
sed -i 's/\$releasever/8/g' /etc/yum.repos.d/remi*.repo
[ -n "$MOD" ] && { dnf -q -y module enable "$MOD" >/dev/null 2>&1 || mal "module $MOD"; }
dnf -q -y install mariadb-server postgresql-server procps-ng openssl which diffutils >/dev/null 2>&1 || mal "bases de datos"
# EN: every package built but -devel (like the apt check, which leaves out -dev)
# ES: todos los paquetes compilados salvo -devel (como la de apt, que deja fuera -dev)
P=$(ls /rpms/*.rpm | grep -v -- '-devel-')
dnf -q -y install $P >/tmp/i 2>&1 || { tail -5 /tmp/i; mal "instalar $N"; }
rpm -qa --qf '%{NAME} %{VERSION}-%{RELEASE}\n' | grep -E "^($SCL|gd3php|libicu|oniguruma)" | sort > $O.paquetes
n1=$(echo "$P" | wc -w); n2=$(rpm -q $(for f in $P; do rpm -qp --qf '%{NAME} ' "$f"; done) | grep -vc 'not installed')
[ "$n1" = "$n2" ] || mal "pedidos $n1 paquetes y hay $n2 instalados"
B=/opt/remi/$SCL/root/usr; CLI=$SCL-php-cli; [ -n "$MOD" ] && { B=/usr; CLI=php-cli; }; PHP=$B/bin/php
[ "$($PHP -r 'echo 1;' 2>&1)" = 1 ] || mal "php escribe algo al arrancar: $($PHP -r 'echo 1;' 2>&1 | head -2)"
echo "[$N] $(wc -l < $O.paquetes) paquetes; $($PHP -r 'echo PHP_VERSION;'); $(rpm -q --qf '%{VERSION}-%{RELEASE}' $CLI)"

# ---------- 1. Fingerprint / huella ----------
$PHP -m > $O.modulos
$PHP -r 'foreach (ini_get_all(null, false) as $k => $v) echo "$k=", var_export($v, true), "\n";' | sort > $O.ini
$PHP -i | grep -vE '^(Build Date|System|_SERVER|_ENV|\$_|PHP_SELF|REQUEST_TIME|SCRIPT_|PATH_TRANSLATED|DOCUMENT_ROOT|HOSTNAME|HOME|PWD|OLDPWD|SHLVL|PATH|TERM|LANG|TZ|JOBS|TESTS|EXCLUDE|_ =>|argv|argc)' \
  | grep -vE 'PHP Version => |=> '"$(hostname)" > $O.phpi
ED=$($PHP -r 'echo ini_get("extension_dir");')
for f in $PHP $B/sbin/php-fpm $B/bin/php-cgi $B/bin/phpdbg $B/lib64/libphp*.so $B/lib64/httpd/modules/libphp*.so $ED/*.so; do
  [ -f "$f" ] || continue
  echo "== $f"; ldd "$f" | awk '{print $1, ($3 ~ /^\// ? $3 : "")}' | sed 's/ (0x[0-9a-f]*)//' | sort
done > $O.ldd
awk '$2 ~ /^\//{print $2}' $O.ldd | sort -u | while read -r l; do echo "$l $(rpm -qf --qf '%{NAME}' "$(readlink -f "$l")" 2>/dev/null)"; done > $O.libs

# ---------- 2. Databases / bases de datos ----------
mysql_install_db --user=mysql --datadir=/var/lib/mysql >/dev/null 2>&1
(/usr/libexec/mysqld --user=mysql --datadir=/var/lib/mysql --socket=/var/lib/mysql/mysql.sock >/tmp/my.log 2>&1 &)
for i in $(seq 1 30); do mysqladmin -S /var/lib/mysql/mysql.sock ping >/dev/null 2>&1 && break; sleep 1; done
mysql -S /var/lib/mysql/mysql.sock -e "CREATE DATABASE IF NOT EXISTS test; CREATE USER 'php'@'localhost' IDENTIFIED BY 'php'; CREATE USER 'php'@'127.0.0.1' IDENTIFIED BY 'php'; GRANT ALL ON *.* TO 'php'@'localhost'; GRANT ALL ON *.* TO 'php'@'127.0.0.1'; FLUSH PRIVILEGES;" || mal mariadb
echo postgres > /tmp/pgpw; chmod 644 /tmp/pgpw
su postgres -c 'initdb -D /var/lib/pgsql/data -A md5 --pwfile=/tmp/pgpw -E UTF8 --locale=C >/dev/null && pg_ctl -D /var/lib/pgsql/data -l /tmp/pg.log start >/dev/null' || mal postgresql
for i in $(seq 1 30); do su postgres -c 'pg_isready -q' && break; sleep 1; done
su postgres -c 'PGPASSWORD=postgres createdb test' || mal "createdb"
export MYSQL_TEST_HOST=127.0.0.1 MYSQL_TEST_USER=php MYSQL_TEST_PASSWD=php MYSQL_TEST_DB=test MYSQL_TEST_SOCKET=/var/lib/mysql/mysql.sock
export PDO_MYSQL_TEST_DSN="mysql:host=127.0.0.1;dbname=test" PDO_MYSQL_TEST_USER=php PDO_MYSQL_TEST_PASS=php PDO_MYSQL_TEST_HOST=127.0.0.1
export PGSQL_TEST_CONNSTR="host=localhost dbname=test port=5432 user=postgres password=postgres"
export PDO_PGSQL_TEST_DSN="pgsql:host=localhost port=5432 dbname=test user=postgres password=postgres"
export NO_INTERACTION=1 REPORT_EXIT_STATUS=0 SKIP_ONLINE_TESTS=1 SKIP_SLOW_TESTS=0 TEST_FPM_RUN_AS_ROOT=1
export TEST_PHP_EXECUTABLE=$PHP TEST_PHP_CGI_EXECUTABLE=$B/bin/php-cgi
c=$($PHP -r '$m = @mysqli_connect("127.0.0.1", "php", "php", "test"); $p = @pg_connect(getenv("PGSQL_TEST_CONNSTR")); echo ($m ? "mysqli OK" : "mysqli MAL"), " / ", ($p ? "pgsql OK" : "pgsql MAL");')
echo "  PHP -> DB: $c"; echo "$c" | grep -q MAL && mal "PHP no conecta con las bases de datos"
[ "${SOLO_HUELLA:-}" = 1 ] && exit 0

# ---------- 3. Full suite, split / suite completa, repartida ----------
mkdir -p /t && tar -xzf /rpms/src.tar.gz -C /t --strip-components=1 || mal "src.tar.gz"
chmod -R a+rwX /t; cd /t
( while sleep 30; do ps -eo pid=,etimes=,comm= | awk '$3 ~ /^phpdbg/ && $2 > 120 {print $1}' | xargs -r kill -9; done ) &
VIGIA=$!
t0=$(date +%s)
# EN: variables_order with E, or the 5.6/7.x run-tests does not pass the environment (DB settings) to the tests;
#     --set-timeout 300: pgsql/01createdb needs more than 60 s on a busy host
# ES: variables_order con E: si no, el run-tests de 5.6/7.x no pasa el entorno (conexiones) a las pruebas;
#     --set-timeout 300: pgsql/01createdb necesita más de 60 s con la máquina cargada
timeout 14000 bash /v/shards.sh "${JOBS:-8}" $O.suite.log -- $PHP -d variables_order=EGPCS -d memory_limit=-1 run-tests.php --set-timeout 300
rc=$?; { kill $VIGIA; wait $VIGIA; } 2>/dev/null
echo "  suite rc=$rc en $(( $(date +%s) - t0 )) s"
[ $rc = 0 ] || mal "suite incompleta (rc=$rc)"
exit 0
