#!/usr/bin/env bash
# web.sh <ref> <branch|rama> <modphp|fpm>   (runs INSIDE a throwaway container / corre DENTRO de un contenedor)
# EN: Apache + PHP (mod_php or PHP-FPM) + MariaDB + phpMyAdmin from /w, then a fixed walk of 24 pages
#     (login, browse, query, insert, search, export plain/zip/gzip, import, logout...) plus /w/mezcla.php.
#     Saves each body, HTTP code and PHP warnings in /out/web/<release>-<branch>-<ref>-<sapi>/.
# ES: Apache + PHP (mod_php o PHP-FPM) + MariaDB + phpMyAdmin de /w y un recorrido fijo de 24 páginas
#     (entrar, navegar, consultar, insertar, buscar, exportar normal/zip/gzip, importar, salir...) más mezcla.php.
#     Guarda cada cuerpo, código HTTP y avisos de PHP en /out/web/<versión>-<rama>-<ref>-<sapi>/.
set -uo pipefail
REF=$1; R=$2; V=${R#php}; SAPI=$3
. /etc/os-release; CN=$VERSION_CODENAME
export DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 TZ=UTC
O=/out/web/$CN-$R-$REF-$SAPI; rm -rf $O; mkdir -p $O
mal() { echo "MAL $*" | tee $O/MAL; exit 1; }
G=${REPO_RAW:-https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu}
apt-get update -qq >/dev/null 2>&1
apt-get install -y -qq --no-install-recommends curl ca-certificates xz-utils apache2 mariadb-server unzip locales >/dev/null 2>&1 || mal base
locale-gen es_ES.UTF-8 >/dev/null 2>&1
curl -fsSL $G/main/php-legacy-ubuntu.gpg -o /usr/share/keyrings/p.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/p.gpg] $G/$REF $CN main" > /etc/apt/sources.list.d/p.list
printf 'Package: php-common\nPin: release o=php-legacy-ubuntu\nPin-Priority: 99\n' > /etc/apt/preferences.d/p
apt-get update -qq >/dev/null 2>&1
[ "$CN" = bionic ] && apt-get install -y -qq php-common=2:101~+ubuntu22.04.1+deb.sury.org+1 >/dev/null 2>&1
P="$R-cli $R-mysql $R-mbstring $R-xml $R-zip $R-gd $R-bz2 $R-curl $R-intl $R-bcmath $R-opcache"
for x in mcrypt json; do apt-cache show $R-$x >/dev/null 2>&1 && P="$P $R-$x"; done
[ $SAPI = modphp ] && P="$P libapache2-mod-$R" || P="$P $R-fpm"
apt-get install -y -qq --no-install-recommends $P >/tmp/i 2>&1 || { tail -5 /tmp/i; mal "instalar $P"; }
echo "[$CN $R $REF $SAPI] $(dpkg-query -W -f='${Version}' $R-cli); libgd3 $(dpkg-query -W -f='${Version}' libgd3)" | tee $O/version

# Avisos de PHP a un registro propio, en los dos SAPI
for d in apache2 fpm; do [ -d /etc/php/$V/$d/conf.d ] && printf 'log_errors=On\nerror_log=/tmp/php-errors.log\nerror_reporting=E_ALL & ~E_DEPRECATED & ~E_STRICT\ndisplay_errors=Off\n' > /etc/php/$V/$d/conf.d/99-prueba.ini; done
touch /tmp/php-errors.log; chmod 666 /tmp/php-errors.log

# MariaDB con datos fijos
(service mariadb start || service mysql start) >/dev/null 2>&1
for i in $(seq 1 30); do mysqladmin ping >/dev/null 2>&1 && break; sleep 1; done
mysql -e "CREATE DATABASE test CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci; CREATE USER 'php'@'localhost' IDENTIFIED BY 'php'; CREATE USER 'php'@'127.0.0.1' IDENTIFIED BY 'php'; GRANT ALL ON *.* TO 'php'@'localhost'; GRANT ALL ON *.* TO 'php'@'127.0.0.1'; FLUSH PRIVILEGES;" || mal mariadb
mysql test <<'SQL' || mal "datos"
CREATE TABLE clientes (id INT PRIMARY KEY AUTO_INCREMENT, nombre VARCHAR(80), saldo DECIMAL(10,2), alta DATE, notas TEXT, foto BLOB, KEY (nombre));
CREATE TABLE pedidos (id INT PRIMARY KEY AUTO_INCREMENT, cliente INT, total DOUBLE, creado DATETIME, FOREIGN KEY (cliente) REFERENCES clientes(id)) ENGINE=InnoDB;
CREATE VIEW grandes AS SELECT nombre, saldo FROM clientes WHERE saldo > 500;
SQL
for i in $(seq 1 120); do echo "INSERT INTO clientes (nombre, saldo, alta, notas, foto) VALUES ('Cliente $i ñandú €', $((i*37 % 1000)).$((i % 100)), DATE_ADD('2020-01-01', INTERVAL $i DAY), 'Línea 1\nLínea \"2\" <b>$i</b>', UNHEX(REPEAT('ABCD', $i))); INSERT INTO pedidos (cliente, total, creado) VALUES ($i, $i/7, DATE_ADD('2024-02-29 10:00:00', INTERVAL $i HOUR));"; done | mysql test || mal "filas"

# phpMyAdmin
mkdir -p /var/www/html/pma && tar -xJf /w/phpMyAdmin-4.9.11-english.tar.xz -C /var/www/html/pma --strip-components=1
mkdir -p /var/www/html/pma/tmp && chown -R www-data /var/www/html/pma/tmp
cat > /var/www/html/pma/config.inc.php <<'EOF'
<?php
$cfg['blowfish_secret'] = 'abcdefghijklmnopqrstuvwxyz012345';
$cfg['Servers'][1]['auth_type'] = 'cookie';
$cfg['Servers'][1]['host'] = '127.0.0.1';
$cfg['Servers'][1]['AllowNoPassword'] = false;
$cfg['TempDir'] = '/var/www/html/pma/tmp';
$cfg['VersionCheck'] = false;
$cfg['SendErrorReports'] = 'never';
$cfg['ShowServerInfo'] = false;
$cfg['ShowPhpInfo'] = false;
EOF
cp /w/mezcla.php /var/www/html/mezcla.php

# SAPI
if [ $SAPI = modphp ]; then
  a2dismod -q mpm_event >/dev/null 2>&1; a2enmod -q mpm_prefork php$V >/dev/null 2>&1
else
  a2dismod -q php$V >/dev/null 2>&1; a2enmod -q mpm_event proxy_fcgi setenvif >/dev/null 2>&1; a2enconf -q php$V-fpm >/dev/null 2>&1
  /usr/sbin/php-fpm$V -D || mal "php-fpm$V"
fi
apachectl start >/dev/null 2>&1 || mal apache
for i in $(seq 1 20); do curl -fs -o /dev/null http://127.0.0.1/ && break; sleep 1; done
c=$(curl -s http://127.0.0.1/mezcla.php | grep '^sapi:'); echo "  $c"; case "$SAPI:$c" in modphp:*apache2handler*|fpm:*fpm-fcgi*) ;; *) mal "SAPI inesperado: $c";; esac

# ---------- Recorrido ----------
J=/tmp/cj; U=http://127.0.0.1/pma
n=0
pide() { # nombre, url, [args de curl]
  local nom=$1 url=$2; shift 2; n=$((n+1))
  local code; code=$(curl -s -b $J -c $J -o "$O/$(printf %02d $n)-$nom.body" -w '%{http_code} %{content_type}' "$@" "$url")
  echo "$(printf %02d $n)-$nom $code" >> $O/codigos
}
tok() { grep -oE 'name="token" value="[0-9a-f]+"|token=[0-9a-f]{16,}|"token":"[0-9a-f]+"' "$1" | head -1 | grep -oE '[0-9a-f]{16,}'; }
for i in 1 2 3; do pide mezcla-$i http://127.0.0.1/mezcla.php; done
pide login-form "$U/index.php"
T=$(tok "$O/$(printf %02d $n)-login-form.body"); [ -n "$T" ] || mal "sin token en el formulario"
pide login-post "$U/index.php" -L --data-urlencode "pma_username=php" --data-urlencode "pma_password=php" --data-urlencode "server=1" --data-urlencode "token=$T" --data-urlencode "target=index.php"
T=$(tok "$O/$(printf %02d $n)-login-post.body"); [ -n "$T" ] || mal "sin token tras entrar (¿login fallido?)"
grep -q 'pma_username' "$O/$(printf %02d $n)-login-post.body" && mal "sigue en el formulario de login"
pide inicio "$U/index.php?token=$T"
pide bases "$U/server_databases.php?token=$T"
pide estructura-db "$U/db_structure.php?db=test&token=$T"
pide estructura-tabla "$U/tbl_structure.php?db=test&table=clientes&token=$T"
pide navegar "$U/sql.php?db=test&table=clientes&pos=0&token=$T"
pide navegar-p2 "$U/sql.php?db=test&table=clientes&pos=25&session_max_rows=25&token=$T"
pide vista "$U/sql.php?db=test&table=grandes&pos=0&token=$T"
pide consulta "$U/import.php" --data-urlencode "token=$T" --data-urlencode "db=test" --data-urlencode "sql_query=SELECT c.nombre, COUNT(p.id) n, ROUND(SUM(p.total),4) s, MAX(p.creado) m FROM clientes c JOIN pedidos p ON p.cliente=c.id GROUP BY c.id ORDER BY s DESC LIMIT 30" --data-urlencode "ajax_request=true"
pide insertar "$U/import.php" --data-urlencode "token=$T" --data-urlencode "db=test" --data-urlencode "sql_query=INSERT INTO clientes (nombre, saldo, alta) VALUES ('Añadido «web»', 12.34, '2026-11-05')" --data-urlencode "ajax_request=true"
pide buscar "$U/sql.php" --data-urlencode "token=$T" --data-urlencode "db=test" --data-urlencode "sql_query=SELECT * FROM clientes WHERE nombre LIKE '%web%' OR notas LIKE '%<b>7</b>%'"
for comp in none zip gzip; do
  pide export-$comp "$U/export.php" --data-urlencode "token=$T" --data-urlencode "db=test" --data-urlencode "export_type=database" --data-urlencode "export_method=quick" --data-urlencode "what=sql" --data-urlencode "output_format=sendit" --data-urlencode "compression=$comp" --data-urlencode "sql_structure_or_data=structure_and_data" --data-urlencode "sql_type=INSERT" --data-urlencode "sql_insert_syntax=both" --data-urlencode "sql_max_query_size=50000" --data-urlencode "sql_hex_for_binary=something" --data-urlencode "charset=utf-8" --data-urlencode "filename_template=@DATABASE@" \
    --data-urlencode "table_select[]=clientes" --data-urlencode "table_select[]=pedidos" --data-urlencode "table_structure[]=clientes" --data-urlencode "table_structure[]=pedidos" --data-urlencode "table_data[]=clientes" --data-urlencode "table_data[]=pedidos"
done
printf "CREATE TABLE importada (a INT, b VARCHAR(20));\nINSERT INTO importada VALUES (1,'uno'),(2,'dós');\n" > /tmp/imp.sql
pide importar "$U/import.php" -F "token=$T" -F "db=test" -F "format=sql" -F "import_type=database" -F "import_file=@/tmp/imp.sql" -F "charset_of_file=utf-8" -F "noplugin=" -F "ajax_request=true"
pide tras-importar "$U/sql.php" --data-urlencode "token=$T" --data-urlencode "db=test" --data-urlencode "sql_query=SELECT * FROM importada ORDER BY a"
pide variables "$U/server_variables.php?token=$T"
pide estado "$U/server_status.php?token=$T"
pide usuarios "$U/server_privileges.php?token=$T"
pide salir "$U/index.php?token=$T&old_usr=php"
# las exportaciones comprimidas se guardan también descomprimidas, para compararlas por contenido
for f in $O/*-export-zip.body; do mkdir -p /tmp/z && (cd /tmp/z && unzip -o -q "$f" 2>/dev/null) && cat /tmp/z/* > "$f.txt" 2>/dev/null; done
for f in $O/*-export-gzip.body; do gzip -dc < "$f" > "$f.txt" 2>/dev/null; done
cp /tmp/php-errors.log $O/php-errors.log
[ $SAPI = fpm ] && grep -iE 'warning|error|notice' /var/log/php$V-fpm.log > $O/fpm.log 2>/dev/null
grep -iE 'segfault|exit signal|child pid .* exit' /var/log/apache2/error.log > $O/apache-caidas.log
echo "  $(wc -l < $O/codigos) páginas; códigos: $(awk '{print $2}' $O/codigos | sort | uniq -c | tr -s ' \n' ' '); avisos PHP: $(grep -c 'PHP ' $O/php-errors.log); caídas apache: $(wc -l < $O/apache-caidas.log)"
