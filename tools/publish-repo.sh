#!/usr/bin/env bash
# publish-repo.sh
# EN: Rebuilds the apt indexes (Packages, Release) for every suite under pool/ and signs them
#     (InRelease + Release.gpg). Runs the apt tools inside a throwaway ubuntu:24.04 container,
#     so the host only needs docker. Commit and push the result afterwards.
# ES: Regenera los índices apt (Packages, Release) de cada distribución que haya en pool/ y los
#     firma (InRelease + Release.gpg). Las herramientas apt corren en un contenedor ubuntu:24.04
#     de usar y tirar: en el anfitrión solo hace falta docker. Después, commit y push.
#
# Usage / Uso:  tools/publish-repo.sh <private-key.asc|clave-privada.asc>
#
# EN: Layout expected / ES: estructura esperada:
#   pool/<suite>/<branch>/*.deb   (bionic, focal...)   (any subfolder / cualquier subcarpeta, e.g. pool/bionic/common)
set -euo pipefail

KEY=${1:?private key / clave privada (.asc)}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
[ -r "$KEY" ] || { echo "STOP/PARA: cannot read / no se puede leer $KEY" >&2; exit 1; }

docker run --rm --name "publish-php-legacy-$$" --cpus 2 --memory 1g \
  -v "$ROOT":/repo -v "$(realpath "$KEY")":/key.asc:ro ubuntu:24.04 bash -euo pipefail -c '
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq >/dev/null
apt-get install -y -qq --no-install-recommends gnupg apt-utils >/dev/null 2>&1
export GNUPGHOME=$(mktemp -d)
gpg -q --batch --import /key.asc 2>/dev/null
FPR=$(gpg --with-colons --list-secret-keys | awk -F: "/^fpr:/{print \$10; exit}")
# EN: the key that signs must be the one published in the repo
# ES: la clave que firma tiene que ser la publicada en el repo
gpg --with-colons --show-keys /repo/php-legacy-ubuntu.asc | grep -q "^fpr:::::::::$FPR:" \
  || { echo "STOP/PARA: key does not match php-legacy-ubuntu.asc / la clave no es la publicada"; exit 1; }
cd /repo
for d in pool/*/; do
  S=$(basename "$d")
  O=dists/$S/main/binary-amd64; rm -rf "dists/$S"; mkdir -p "$O"
  apt-ftparchive packages "pool/$S" > "$O/Packages"
  gzip -9nk "$O/Packages"
  apt-ftparchive \
    -o APT::FTPArchive::Release::Origin=php-legacy-ubuntu \
    -o APT::FTPArchive::Release::Label=php-legacy-ubuntu \
    -o APT::FTPArchive::Release::Suite="$S" \
    -o APT::FTPArchive::Release::Codename="$S" \
    -o APT::FTPArchive::Release::Architectures=amd64 \
    -o APT::FTPArchive::Release::Components=main \
    -o APT::FTPArchive::Release::Description="Patched PHP rebuilds for Ubuntu $S" \
    release "dists/$S" > /tmp/Release
  mv /tmp/Release "dists/$S/Release"
  gpg -q --batch --yes -u "$FPR" --digest-algo SHA512 --clearsign -o "dists/$S/InRelease" "dists/$S/Release"
  gpg -q --batch --yes -u "$FPR" --digest-algo SHA512 -abs -o "dists/$S/Release.gpg" "dists/$S/Release"
  gpgv --keyring /repo/php-legacy-ubuntu.gpg "dists/$S/InRelease" 2>/dev/null \
    || { echo "STOP/PARA: signature check failed / la firma no verifica ($S)"; exit 1; }
  echo "OK $S: $(grep -c "^Package:" "$O/Packages") packages / paquetes, signed / firmado"
done
chown -R --reference=/repo/README.md /repo/dists 2>/dev/null || true
'
