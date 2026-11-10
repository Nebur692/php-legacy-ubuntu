#!/usr/bin/env bash
# build-el8.sh <file.src.rpm> <scl: php56|php70|...|-> <out-dir|carpeta-salida> [ccache-dir]
# EN: Rebuilds a Remi SRPM for CentOS 8.5 in a throwaway container: the RPMs (without debuginfo) go to
#     <out-dir>, the build log to <out-dir>/build.log and the prepared source tree (for the test suite) to
#     <out-dir>/src.tar.gz. Remi's %check is skipped (--nocheck): it only tests the minimal FPM build, so the
#     real test is tools/verify/run-el8.sh on the INSTALLED packages, with every extension loaded.
#     With [ccache-dir], rebuilding the same branch with a few patches only recompiles what changed.
#     Env: IMG (default centos:8; any EL8 image), CPUS (8), MEM (6g), WORK (host dir for the ~3-4 GB build tree;
#     without it, it grows inside the container layer), PRE (packages installed before builddep, e.g.
#     libicu74-devel so that php74 links against the same ICU as Remi's build and not the newest one), MOD (module
#     stream enabled before builddep, e.g. php:remi-7.3 for the modular build, with scl "-"), DIST (default .el8.legacy;
#     .module_php.7.3.el8.legacy for the modular build, like Remi's .module_php.7.3.el8.remi).
# ES: Recompila un SRPM de Remi para CentOS 8.5 en un contenedor de usar y tirar: los RPM (sin debuginfo) van a
#     <carpeta-salida>, el registro a <carpeta-salida>/build.log y el árbol de código preparado (para la suite)
#     a <carpeta-salida>/src.tar.gz. El %check de Remi se salta (--nocheck): solo prueba la compilación mínima de
#     FPM, así que la prueba de verdad es tools/verify/run-el8.sh con los paquetes INSTALADOS y todas las
#     extensiones cargadas. Con [ccache-dir], recompilar la misma rama con unos parches solo compila lo cambiado.
#     Entorno: IMG (por defecto centos:8; cualquier imagen EL8), CPUS (8), MEM (6g), WORK (carpeta del host para el
#     árbol de compilación, ~3-4 GB; sin ella crece dentro de la capa del contenedor), PRE (paquetes que se instalan
#     antes de builddep, p. ej. libicu74-devel para que php74 enlace con la misma ICU que Remi y no con la más nueva),
#     MOD (flujo de módulo que se activa antes de builddep, p. ej. php:remi-7.3 para la compilación modular, con scl
#     "-"), DIST (por defecto .el8.legacy; .module_php.7.3.el8.legacy para la modular, como .module_php.7.3.el8.remi).
set -euo pipefail
SRPM=$(realpath "${1:?file.src.rpm}"); SCL=${2:?scl|-}; OUT=${3:?out-dir}; CC_DIR=${4:-}
mkdir -p "$OUT"; OUT=$(realpath "$OUT")
V=(-v "$SRPM":/in.src.rpm:ro -v "$OUT":/out)
[ -n "$CC_DIR" ] && { mkdir -p "$CC_DIR"; V+=(-v "$(realpath "$CC_DIR")":/ccache); }
# EN: WORK=<host dir>: the build tree and the dnf cache go there, not into the container layer (docker.img)
# ES: WORK=<carpeta del host>: el árbol de compilación y la caché de dnf van ahí, no a la capa del contenedor (docker.img)
if [ -n "${WORK:-}" ]; then
  mkdir -p "$WORK/rpmbuild" "$WORK/dnf"; W=$(realpath "$WORK")
  V+=(-v "$W/rpmbuild":/root/rpmbuild -v "$W/dnf":/var/cache/dnf)
fi
docker run --rm --name "build-el8-$$" --cpus "${CPUS:-8}" --memory "${MEM:-6g}" --memory-swap "${MEM:-6g}" \
  -e SCL="$SCL" -e J="${CPUS:-8}" -e PRE="${PRE:-}" -e MOD="${MOD:-}" -e DIST="${DIST:-.el8.legacy}" "${V[@]}" "${IMG:-centos:8}" bash -c '
set -uo pipefail
exec > >(tee /out/build.log) 2>&1
fin() { echo "== FIN $1"; exit "$1"; }
# EN: CentOS 8 is archived: vault, EPEL and Remi (remi-release asks for 8.10, so --nodeps)
# ES: CentOS 8 está archivado: vault, EPEL y Remi (remi-release pide 8.10, de ahí --nodeps)
if [ ! -f /etc/yum.repos.d/remi.repo ]; then
  sed -i -e "s|^mirrorlist=|#mirrorlist=|" -e "s|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|" /etc/yum.repos.d/CentOS-*
  dnf -q -y install epel-release dnf-plugins-core rpm-build >/dev/null || fin 1
  curl -fsSLo /tmp/r.rpm https://rpms.remirepo.net/enterprise/remi-release-8.rpm && rpm -i --nodeps /tmp/r.rpm || fin 1
  sed -i "s/\$releasever/8/g" /etc/yum.repos.d/remi*.repo
fi
dnf config-manager -q --set-enabled powertools >/dev/null 2>&1 || true
D=(); [ "$SCL" != - ] && { D=(--define "scl $SCL" --define "scl_prefix $SCL-"); dnf -q -y install "$SCL-build" "$SCL-runtime" || fin 2; }
rpm -i --nosignature /in.src.rpm || fin 3
SP=$(ls /root/rpmbuild/SPECS/*.spec)
[ -n "$MOD" ] && { dnf -q -y module enable "$MOD" >/dev/null || fin 4; }
[ -n "$PRE" ] && { dnf -q -y --enablerepo=remi install $PRE || fin 4; }
R=(); [ -n "$MOD" ] && R=(--enablerepo=remi)
dnf -q -y builddep "${R[@]}" "${D[@]}" "$SP" || fin 4
if [ -d /ccache ]; then
  dnf -q -y install ccache || fin 5
  export PATH=/usr/lib64/ccache:$PATH CCACHE_DIR=/ccache CCACHE_BASEDIR=/root/rpmbuild/BUILD CCACHE_COMPILERCHECK=content CCACHE_MAXSIZE=8G
  ccache -z >/dev/null
fi
t0=$(date +%s)
rpmbuild -ba --nocheck --define "dist $DIST" --define "_smp_mflags -j$J" "${D[@]}" "$SP" || fin 6
echo "== rpmbuild: $(( $(date +%s) - t0 )) s"
[ -d /ccache ] && ccache -s | grep -E "cache hit|cache miss|hit rate"
cp /root/rpmbuild/RPMS/*/*.rpm /out/ && rm -f /out/*-debug{info,source}-*.rpm
# EN: the prepared tree with the tests, without the build folders / ES: el árbol preparado con las pruebas, sin las carpetas de compilación
cd /root/rpmbuild/BUILD && T=$(ls -d php-*/ | head -1) && tar --exclude="${T}build-*" -czf /out/src.tar.gz "$T" || fin 7
chown -R --reference=/out /out 2>/dev/null
echo "== $(ls /out/*.rpm | wc -l) RPM"
fin 0
'
