#!/usr/bin/env bash
# php-focal.sh - Recompila para Ubuntu 20.04 (focal) el codigo de Sury publicado para jammy
# e instala el resultado conservando la configuracion. Procedimiento validado con php7.1.
#
# Uso:  php-focal.sh <fase> <rama> <revision>
#   fases (en este orden):
#     prep     descarga, verifica firma y sha256, extrae, dependencias y version local
#     build    compila en el chroot (log en /root/build-<rama>.log)
#     sim      repo local + simulacion apt (NO instala)
#     install  copias + instalacion + restaura php-fpm.conf + comprobaciones
#     check    solo comprobaciones
#     export   copia .deb + Packages + fuente + log + SHA256SUMS a /root/php-focal-paquetes/<rama>
#              y regenera /root/php-focal-paquetes.tar (para llevarlo al PC / repo git)
#   ejemplos: php-focal.sh prep php7.0 7.0.33-92
#             php-focal.sh prep php5.6 5.6.40-105
set -euo pipefail

FASE=${1:?fase}; B=${2:?rama (php7.0)}; V=${3:?revision (7.0.33-92)}
X=${B#php}                                   # 7.0
CH=/srv/chroot-focal; BD=$CH/build
PPA=http://ppa.launchpad.net/ondrej/php/ubuntu
F=${B}_${V}+ubuntu22.04.1+deb.sury.org+1     # nombre base en el PPA
LV=${V}+ubuntu20.04.1+local1                 # version que instalaremos
SRC=src-${B}
REPO=/srv/repo-local-${B}
BK=/root/${B}-antes                          # prefijo de copias
LOG=/root/build-${B}.log

ok()  { echo "OK   $*"; }
die() { echo "PARA $*" >&2; exit 1; }

# Paquetes instalados cuyo paquete fuente es esta rama (excluye PECL: apcu, xdebug...)
pkgs() {
  dpkg-query -W -f='${db:Status-Abbrev} ${Package} ${source:Package}\n' 2>/dev/null \
    | awk -v s="$B" '$1=="ii" && $3==s {print $2}'
}

mount_proc() { mountpoint -q $CH/proc || mount -t proc proc $CH/proc; }

case "$FASE" in
prep)
  mount_proc; cd "$BD"
  curl -fsSLO "$PPA/dists/jammy/InRelease"; curl -fsSLO "$PPA/dists/jammy/main/source/Sources.xz"
  good=0
  for k in /etc/apt/trusted.gpg.d/*ondrej* /etc/apt/trusted.gpg; do
    [ -f "$k" ] || continue
    out=$(gpgv --keyring "$k" InRelease 2>&1 || true)
    echo "$out" | grep -q 'Good signature from "Launchpad PPA for Ondřej Surý"' && { good=1; break; }
  done
  [ $good = 1 ] && ok "firma InRelease" || die "firma InRelease"
  grep -q "$(sha256sum Sources.xz | cut -d' ' -f1)" InRelease && ok "Sources.xz" || die "Sources.xz"
  xz -dc Sources.xz > Sources   # descomprimido aparte: "xz | grep -q" falla con pipefail (SIGPIPE)
  curl -fsSLO "$PPA/pool/main/p/$B/$F.dsc" || die "no existe $F.dsc en el PPA"
  awk '/^Checksums-Sha256:/{s=1;next} /^[A-Z]/{s=0} s{print $3}' "$F.dsc" \
    | while read -r x; do [ -f "$x" ] || curl -fsSLO "$PPA/pool/main/p/$B/$x"; done
  for f in $(awk '/^Checksums-Sha256:/{s=1;next} /^[A-Z]/{s=0} s{print $3}' "$F.dsc") "$F.dsc"; do
    grep -q "$(sha256sum "$f" | cut -d' ' -f1)" Sources && ok "$f" || die "sha256 $f"
  done
  rm -rf "$BD/$SRC"
  chroot $CH bash -c "export LANG=C; cd /build && dpkg-source -x $F.dsc $SRC >/dev/null 2>&1" || die "dpkg-source -x"
  grep -q 'CVE-2026-109618' "$BD/$SRC/debian/changelog" && ok "trae php2shell" || die "el changelog NO trae CVE-2026-109618"
  grep -q 'TELEMETRY_HOST' "$BD/$SRC/debian/rules" && die "debian/rules define TELEMETRY_HOST" || ok "sin TELEMETRY_HOST en rules"
  chroot $CH bash -c "export LANG=C DEBIAN_FRONTEND=noninteractive; cd /build/$SRC && \
    mk-build-deps -i -r -t 'apt-get -y --no-install-recommends' debian/control >/tmp/deps-$B.log 2>&1" \
    && ok "dependencias de compilacion" || die "dependencias: ver $CH/tmp/deps-$B.log"
  chroot $CH bash -c "export LANG=C; cd /build/$SRC && DEBEMAIL=root@localhost DEBFULLNAME=local \
    dch -b -v $LV -D focal --force-distribution 'Rebuild of Sury jammy source for focal' 2>/dev/null"
  head -1 "$BD/$SRC/debian/changelog"
  ;;

build)
  mount_proc
  echo "Compilando $B (log: $LOG)..."; s=$(date +%s)
  choom -n 1000 -- nice -n 10 ionice -c3 chroot $CH bash -c \
    "export LANG=C; cd /build/$SRC && DEB_BUILD_OPTIONS='nocheck parallel=4' dpkg-buildpackage -b -uc -us" \
    > "$LOG" 2>&1 || die "compilacion fallida: tail -40 $LOG"
  echo "Tiempo: $(( ($(date +%s)-s)/60 )) min"
  n=$(grep -c 'TELEMETRY_HOST' "$LOG" || true); [ "$n" = 0 ] && ok "sin telemetria" || die "TELEMETRY_HOST en el log"
  ls -1 "$BD"/*_"${LV}"_*.deb | sed 's#.*/##'
  ;;

sim)
  mount_proc
  rm -rf "$REPO" "$CH/tmp/repo-$B"; mkdir -p "$REPO"
  cp "$BD"/*_"${LV}"_*.deb "$REPO"/
  cp -r "$REPO" "$CH/tmp/repo-$B"
  chroot $CH bash -c "cd /tmp/repo-$B && dpkg-scanpackages . /dev/null 2>/dev/null" > "$REPO/Packages"
  echo "deb [trusted=yes] file:$REPO ./" > /etc/apt/sources.list.d/local-${B}.list
  apt-get update -qq -o Dir::Etc::sourcelist=sources.list.d/local-${B}.list \
    -o Dir::Etc::sourceparts=- -o APT::Get::List-Cleanup=0
  P=$(pkgs); [ -n "$P" ] || die "no hay paquetes $B instalados"
  echo "Paquetes a actualizar: $(echo $P | wc -w)"
  out=$(apt-get -s install --no-install-recommends $P)
  echo "$out" | grep -E '^(Inst|Remv)|^E:'
  echo "$out" | grep -qE '^(Remv|E:)' && die "la simulacion elimina paquetes o da error"
  echo "$out" | grep -E '^Inst' | grep -vE "^Inst (php${X}|libphp${X}|libapache2-mod-php${X})[ -]" | grep -E '^Inst \S+ \[' \
    && die "actualiza paquetes ajenos a $B (revisar arriba)" || ok "simulacion limpia"
  ;;

install)
  X_FPM=php-fpm$X
  [ -d "$BK-etc" ] || cp -a /etc/php/$X "$BK-etc"
  php$X -m > "$BK-mods-cli.txt"; command -v $X_FPM >/dev/null && $X_FPM -m > "$BK-mods-fpm.txt"
  tar czpf "$BK-apache-logrotate.tgz" /etc/apache2/conf-available/php$X* /etc/apache2/mods-available/php$X* \
    /etc/logrotate.d/php$X* 2>/dev/null || true
  ok "copias en $BK-*"
  P=$(pkgs)
  UCF_FORCE_CONFFOLD=1 DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef $P
  # Leccion 7.1: el php-fpm.conf nuevo trae "pid" comentado con un placeholder sin sustituir
  if [ -f "$BK-etc/fpm/php-fpm.conf" ] && ! cmp -s "$BK-etc/fpm/php-fpm.conf" /etc/php/$X/fpm/php-fpm.conf; then
    cp -a "$BK-etc/fpm/php-fpm.conf" /etc/php/$X/fpm/php-fpm.conf; ok "php-fpm.conf original restaurado"
  fi
  systemctl restart php$X-fpm 2>/dev/null || true
  exec "$0" check "$B" "$V"
  ;;

check)
  echo "--- paquetes $B que NO son local1 (deben ser solo PECL):"
  dpkg -l "php$X*" 2>/dev/null | awk '/^ii/{print $2,$3}' | grep -v local1 || true
  php$X -m | diff - "$BK-mods-cli.txt" >/dev/null && ok "modulos CLI iguales" || echo "DIFF modulos CLI"
  if command -v php-fpm$X >/dev/null; then
    php-fpm$X -m | diff - "$BK-mods-fpm.txt" >/dev/null && ok "modulos FPM iguales" || echo "DIFF modulos FPM"
    php-fpm$X -t 2>&1 | tail -1 || true
    systemctl is-active php$X-fpm || true
    pid=$(systemctl show -p MainPID --value php$X-fpm); ls -l /proc/$pid/exe | grep -q deleted && echo "AVISO FPM con binario antiguo" || ok "FPM con binario nuevo"
    ls -l /run/php/php$X-fpm.pid || echo "AVISO sin fichero pid"
    journalctl -u php$X-fpm --since "-15 min" --no-pager | grep -iE 'error|warn|denied' | tail || true
  fi
  zgrep -q 109618 /usr/share/doc/php$X-common/changelog.Debian.gz && ok "changelog con php2shell" || echo "FALTA php2shell"
  diff -ru "$BK-etc" /etc/php/$X && ok "/etc/php/$X igual que antes" || echo "DIFF en /etc/php/$X (revisar)"
  ;;

export)
  D=/root/php-focal-paquetes; O=$D/$B
  ls "$BD"/*_"${LV}"_*.deb >/dev/null 2>&1 || die "no hay .deb $LV en $BD (falta build)"
  rm -rf "$O" "$CH/tmp/exp-$B"; mkdir -p "$O/fuente" "$CH/tmp/exp-$B"
  cp "$BD"/*_"${LV}"_*.deb "$O"/; cp "$O"/*.deb "$CH/tmp/exp-$B"/
  chroot $CH bash -c "cd /tmp/exp-$B && dpkg-scanpackages . /dev/null 2>/dev/null" > "$O/Packages"
  rm -rf "$CH/tmp/exp-$B"
  cp "$BD/$F.dsc" "$BD/$F.debian.tar.xz" "$BD"/${B}_*.orig.tar.* "$O/fuente"/
  L=$LOG; [ -f "$L" ] || L=/root/build${X//./}.log
  [ -f "$L" ] && gzip -c "$L" > "$O/build.log.gz" || echo "AVISO sin log de compilacion"
  (cd "$O" && sha256sum *.deb Packages fuente/* > SHA256SUMS)
  cp "$0" "$D/php-focal.sh"; printf '* -text\n' > "$D/.gitattributes"
  T=/root/php-focal-paquetes.tar; tar cf "$T" -C /root php-focal-paquetes
  ok "$B exportado en $O ($(ls "$O"/*.deb | wc -l) .deb)"; ls -lh "$T"; sha256sum "$T"
  ;;

*) die "fase desconocida: $FASE" ;;
esac
