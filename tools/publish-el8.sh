#!/usr/bin/env bash
# publish-el8.sh
# EN: Signs every RPM under el8/ with the repository key, rebuilds the dnf metadata of el8/x86_64
#     (createrepo_c, plus modules.yaml when el8/modules.yaml exists) and signs repomd.xml.
#     Runs inside a throwaway CentOS 8 container (rpm-sign, createrepo_c), so the host only needs docker.
#     Commit and push the result afterwards.
# ES: Firma todos los RPM de el8/ con la clave del repositorio, regenera los metadatos dnf de
#     el8/x86_64 (createrepo_c, y modules.yaml si existe el8/modules.yaml) y firma repomd.xml.
#     Corre en un contenedor CentOS 8 de usar y tirar (rpm-sign, createrepo_c): en el anfitrión solo
#     hace falta docker. Después, commit y push.
#
# Usage / Uso:  tools/publish-el8.sh <private-key.asc|clave-privada.asc> [image|imagen]
#   image / imagen: any EL8 image with rpm-sign and createrepo_c (default / por defecto: php-rpm-c8:1)
#
# EN: Layout / ES: estructura:
#   el8/x86_64/<group>/*.rpm   el8/SRPMS/*.src.rpm   el8/modules.yaml (optional / opcional)
set -euo pipefail

KEY=${1:?private key / clave privada (.asc)}
IMG=${2:-php-rpm-c8:1}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
[ -r "$KEY" ] || { echo "STOP/PARA: cannot read / no se puede leer $KEY" >&2; exit 1; }

docker run --rm --name "publish-el8-$$" --cpus 2 --memory 1g \
  -v "$ROOT":/repo -v "$(realpath "$KEY")":/key.asc:ro "$IMG" bash -euo pipefail -c '
export GNUPGHOME=$(mktemp -d)
gpg -q --batch --import /key.asc 2>/dev/null
FPR=$(gpg --with-colons --list-secret-keys | awk -F: "/^fpr:/{print \$10; exit}")
gpg --with-colons --show-keys /repo/php-legacy-ubuntu.asc | grep -q "^fpr:::::::::$FPR:" \
  || { echo "STOP/PARA: key does not match php-legacy-ubuntu.asc / la clave no es la publicada"; exit 1; }
KID=$(echo "$FPR" | tail -c 17 | tr A-F a-f)
cd /repo/el8
# EN: sign only what is not signed with our key yet / ES: firmar solo lo que aún no lleva nuestra firma
n=0
while IFS= read -r -d "" f; do
  rpm -qp --qf "%{SIGPGP:pgpsig}%{RSAHEADER:pgpsig}\n" "$f" 2>/dev/null | grep -qi "key id $KID" && continue
  rpmsign --resign --define "_gpg_name $FPR" --define "_gpg_digest_algo sha256" "$f" >/dev/null 2>&1 \
    || { echo "STOP/PARA: cannot sign / no se pudo firmar $f"; exit 1; }
  n=$((n+1))
done < <(find . -name "*.rpm" -print0)
echo "signed / firmados: $n"
# EN: every package must verify against our public key alone / ES: todos verifican solo con nuestra clave pública
DB=$(mktemp -d); rpm --dbpath "$DB" --import /repo/php-legacy-ubuntu.asc
bad=$(find . -name "*.rpm" -print0 | xargs -0 rpm --dbpath "$DB" -K 2>&1 | grep -v ": digests signatures OK$" || true)
[ -z "$bad" ] || { echo "STOP/PARA: signature check failed / la firma no verifica:"; echo "$bad"; exit 1; }
for d in x86_64 SRPMS; do
  [ -d "$d" ] || continue
  rm -rf "$d/repodata"
  createrepo_c -q --general-compress-type=gz "$d"
  [ "$d" = x86_64 ] && [ -f modules.yaml ] && modifyrepo_c --mdtype=modules modules.yaml "$d/repodata" >/dev/null
  gpg -q --batch --yes -u "$FPR" --digest-algo SHA512 --armor --detach-sign -o "$d/repodata/repomd.xml.asc" "$d/repodata/repomd.xml"
  gpg -q --batch --verify "$d/repodata/repomd.xml.asc" "$d/repodata/repomd.xml" 2>/dev/null \
    || { echo "STOP/PARA: repomd signature / firma de repomd ($d)"; exit 1; }
  echo "OK $d: $(find "$d" -name "*.rpm" | wc -l) packages / paquetes, signed / firmado"
done
chown -R --reference=/repo/README.md /repo/el8 2>/dev/null || true
'
