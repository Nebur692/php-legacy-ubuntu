<div align="center">

# php-legacy-ubuntu

*Signed apt repository with patched PHP 5.6–8.2 builds for Ubuntu 18.04 and 20.04*

[![Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/nebur69265723)
[![PayPal](https://img.shields.io/badge/PayPal-donate-00457C?logo=paypal&logoColor=white)](https://paypal.me/0SkillS)

🇬🇧 [English](#english) · 🇪🇸 [Español](#español)

</div>

---

## English

### ✨ What it is

The [Ondřej Surý PHP PPA](https://launchpad.net/~ondrej/+archive/ubuntu/php) no longer publishes packages
for Ubuntu 18.04 (bionic) or 20.04 (focal), but it still maintains the source of the old PHP branches for
newer releases. This repository holds **those exact sources rebuilt for bionic and focal**, so machines that
still run them can get the latest fixes, including **PHP2Shell (CVE-2026-109618 and CVE-2026-109619)**.

| Ubuntu | Branch | Version |
|---|---|---|
| 18.04 bionic | php7.1 | `7.1.33-80+ubuntu18.04.1+local1` |
| 18.04 bionic | php7.2 | `7.2.34-66+ubuntu18.04.1+local1` |
| 20.04 focal | php5.6 | `5.6.40-105+ubuntu20.04.1+local1` |
| 20.04 focal | php7.0 | `7.0.33-92+ubuntu20.04.1+local1` |
| 20.04 focal | php7.1 | `7.1.33-80+ubuntu20.04.1+local1` |
| 20.04 focal | php7.3 | `7.3.33-35+ubuntu20.04.1+local1` |
| 20.04 focal | php8.2 | `8.2.35-1+ubuntu20.04.1+local1` (with `php8.2-imagick` 3.8.1) |

- The source is the PPA's, unchanged: the `.dsc`, `.orig` and `.debian.tar.xz` files sit next to each
  build in `pool/<ubuntu>/<branch>/fuente/` and match the PPA's signed index byte for byte. The only change
  is the version suffix (`+ubuntuXX.04.1+local1`).
- Each branch folder also has its `SHA256SUMS` and the gzipped build log.
- The repository is **signed** with its own key. apt checks every index against it.
- **amd64 only.**

### 📦 Installation

Run as root (or put `sudo` in front) on every machine. **1. The key.** Download it and check the
fingerprint, which must be exactly `FD5D E92B 886F 8114 4ECB  14D2 85CC A24C 9890 D527`:

```bash
curl -fsSL https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu/main/php-legacy-ubuntu.gpg \
  -o /usr/share/keyrings/php-legacy-ubuntu.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/php-legacy-ubuntu.gpg --fingerprint
```

**2. The repository and its pin.** `$(lsb_release -cs)` picks `bionic` or `focal` on its own:

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/php-legacy-ubuntu.gpg] https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu/main $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/php-legacy-ubuntu.list
printf 'Package: php-common\nPin: release o=php-legacy-ubuntu\nPin-Priority: 99\n' \
  > /etc/apt/preferences.d/php-legacy-ubuntu
apt-get update
```

The pin makes sure this repository's `php-common` **never replaces one that is already installed** (it
declares `Breaks` against old PECL extensions such as `php-apcu` or `php-redis`).

**3. Ubuntu 18.04 only: `php-common`.** These builds need `php-common` 1:81 or newer, and stock bionic ships
1:60. Machines that used to have the Surý PPA already have it; this line only installs it when it is
missing or too old:

```bash
v=$(dpkg-query -W -f='${Version}' php-common 2>/dev/null); dpkg --compare-versions "${v:-0}" ge 1:81~ \
  || apt-get install php-common=2:101~+ubuntu22.04.1+deb.sury.org+1
```

Ubuntu 20.04 needs nothing extra: its stock `php-common` (2:75) is enough.

**4. Update.** First simulate it, then apply it:

```bash
apt-get -s upgrade | grep -E '^(Inst|Remv)'   # must not list any "Remv"
apt-get upgrade
systemctl restart 'php*-fpm' apache2 2>/dev/null; true
```

New installs work as usual, for example `apt-get install php8.2-fpm php8.2-mysql`.

### 🧭 Checking it

```bash
dpkg -l 'php*' | awk '/^ii/ && /local1/ {print $2, $3}'
zgrep -c 'CVE-2026-109618' /usr/share/doc/php7.1-common/changelog.Debian.gz   # >= 1 (use your branch)
```

If PHP-FPM still runs the old binary, `ls -l /proc/$(systemctl show -p MainPID --value php7.1-fpm)/exe`
shows `(deleted)`: restart it.

### 🩹 Troubleshooting

- **Ubuntu 18.04 with Ubuntu's own PHP 7.2** (`7.2.24-0ubuntu0.18.04.x`): `apt-get upgrade` keeps it back
  because it needs the newer `php-common`. Installing it (step 3) **removes Ubuntu's `php-apcu` and
  `php-apcu-bc`**. Check it with `apt-get -s` first.
- **Ubuntu 20.04's own PHP 7.4** is not in this repository and is not touched.
- **PECL extensions** (apcu, redis, xdebug…) already installed from the old PPA keep working: they are not
  replaced, and the PHP API of each branch does not change.
- `NO_PUBKEY` or `is not signed` in `apt-get update`: the key is missing or is not the one in
  `/usr/share/keyrings/php-legacy-ubuntu.gpg`. Repeat step 1.

### ⚙️ Maintaining the repository

- `tools/php-bionic.sh` and `tools/php-focal.sh` rebuild a branch on the target release
  (`prep` → `build` → `sim` → `install` → `export`). `prep` checks the PPA's signature and sha256 sums.
- Copy the exported folder to `pool/<bionic|focal>/<branch>/` and run
  `tools/publish-repo.sh <private-key.asc>`. It rebuilds `dists/` and signs it in a throwaway
  `ubuntu:24.04` container. Then commit and push.

### 🗑️ Removing it

```bash
rm /etc/apt/sources.list.d/php-legacy-ubuntu.list /etc/apt/preferences.d/php-legacy-ubuntu \
   /usr/share/keyrings/php-legacy-ubuntu.gpg && apt-get update
```

The installed packages stay as they are.

### 💙 Support

None of this would be possible without the community's support. If this project has been useful to you,
consider supporting it on [Ko-fi](https://ko-fi.com/nebur69265723) or [PayPal](https://paypal.me/0SkillS) —
every bit helps keep it maintained.

### ⚠️ Disclaimer

Unofficial rebuilds. Not affiliated with the PHP project, Ondřej Surý, Debian or Canonical. All the packaging
work is Ondřej Surý's and the Debian PHP team's; this repository only rebuilds it for older Ubuntu releases.
Use at your own risk.

---

## Español

### ✨ Qué es

El [PPA de PHP de Ondřej Surý](https://launchpad.net/~ondrej/+archive/ubuntu/php) ya no publica paquetes para
Ubuntu 18.04 (bionic) ni 20.04 (focal), pero sigue manteniendo el código de las ramas antiguas de PHP para
versiones más nuevas. Este repositorio tiene **ese mismo código recompilado para bionic y focal**, para que las
máquinas que todavía los usan reciban los últimos arreglos, entre ellos **PHP2Shell (CVE-2026-109618 y
CVE-2026-109619)**.

| Ubuntu | Rama | Versión |
|---|---|---|
| 18.04 bionic | php7.1 | `7.1.33-80+ubuntu18.04.1+local1` |
| 18.04 bionic | php7.2 | `7.2.34-66+ubuntu18.04.1+local1` |
| 20.04 focal | php5.6 | `5.6.40-105+ubuntu20.04.1+local1` |
| 20.04 focal | php7.0 | `7.0.33-92+ubuntu20.04.1+local1` |
| 20.04 focal | php7.1 | `7.1.33-80+ubuntu20.04.1+local1` |
| 20.04 focal | php7.3 | `7.3.33-35+ubuntu20.04.1+local1` |
| 20.04 focal | php8.2 | `8.2.35-1+ubuntu20.04.1+local1` (con `php8.2-imagick` 3.8.1) |

- El código es el del PPA, sin cambios: los `.dsc`, `.orig` y `.debian.tar.xz` están junto a cada compilación
  en `pool/<ubuntu>/<rama>/fuente/` y coinciden byte a byte con el índice firmado del PPA. Lo único que cambia
  es el sufijo de la versión (`+ubuntuXX.04.1+local1`).
- Cada carpeta de rama lleva también su `SHA256SUMS` y el registro de compilación comprimido.
- El repositorio está **firmado** con una clave propia y apt comprueba con ella cada índice.
- **Solo amd64.**

### 📦 Instalación

Como root (o con `sudo` delante) en cada máquina. **1. La clave.** Se descarga y se comprueba la huella, que
tiene que ser exactamente `FD5D E92B 886F 8114 4ECB  14D2 85CC A24C 9890 D527`:

```bash
curl -fsSL https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu/main/php-legacy-ubuntu.gpg \
  -o /usr/share/keyrings/php-legacy-ubuntu.gpg
gpg --no-default-keyring --keyring /usr/share/keyrings/php-legacy-ubuntu.gpg --fingerprint
```

**2. El repositorio y su prioridad.** `$(lsb_release -cs)` elige solo `bionic` o `focal`:

```bash
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/php-legacy-ubuntu.gpg] https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu/main $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/php-legacy-ubuntu.list
printf 'Package: php-common\nPin: release o=php-legacy-ubuntu\nPin-Priority: 99\n' \
  > /etc/apt/preferences.d/php-legacy-ubuntu
apt-get update
```

La prioridad garantiza que el `php-common` de este repositorio **nunca sustituya a uno ya instalado** (declara
`Breaks` contra extensiones PECL antiguas como `php-apcu` o `php-redis`).

**3. Solo Ubuntu 18.04: `php-common`.** Estas compilaciones necesitan `php-common` 1:81 o posterior, y bionic
trae de serie la 1:60. Las máquinas que tuvieron el PPA de Surý ya lo tienen; esta línea solo lo instala si
falta o es antiguo:

```bash
v=$(dpkg-query -W -f='${Version}' php-common 2>/dev/null); dpkg --compare-versions "${v:-0}" ge 1:81~ \
  || apt-get install php-common=2:101~+ubuntu22.04.1+deb.sury.org+1
```

Ubuntu 20.04 no necesita nada más: su `php-common` de serie (2:75) ya vale.

**4. Actualizar.** Primero se simula y después se aplica:

```bash
apt-get -s upgrade | grep -E '^(Inst|Remv)'   # no debe salir ningún "Remv"
apt-get upgrade
systemctl restart 'php*-fpm' apache2 2>/dev/null; true
```

Las instalaciones nuevas funcionan como siempre, por ejemplo `apt-get install php8.2-fpm php8.2-mysql`.

### 🧭 Comprobarlo

```bash
dpkg -l 'php*' | awk '/^ii/ && /local1/ {print $2, $3}'
zgrep -c 'CVE-2026-109618' /usr/share/doc/php7.1-common/changelog.Debian.gz   # >= 1 (con tu rama)
```

Si PHP-FPM sigue con el binario viejo, `ls -l /proc/$(systemctl show -p MainPID --value php7.1-fpm)/exe`
muestra `(deleted)`: reinícialo.

### 🩹 Problemas

- **Ubuntu 18.04 con el PHP 7.2 del propio Ubuntu** (`7.2.24-0ubuntu0.18.04.x`): `apt-get upgrade` lo retiene
  porque necesita el `php-common` nuevo. Instalarlo (paso 3) **desinstala `php-apcu` y `php-apcu-bc` de
  Ubuntu**. Compruébalo antes con `apt-get -s`.
- **El PHP 7.4 del propio Ubuntu 20.04** no está en este repositorio y no se toca.
- **Las extensiones PECL** (apcu, redis, xdebug…) ya instaladas del PPA antiguo siguen funcionando: no se
  sustituyen y la API de PHP de cada rama no cambia.
- `NO_PUBKEY` o `is not signed` en `apt-get update`: falta la clave o no es la de
  `/usr/share/keyrings/php-legacy-ubuntu.gpg`. Repite el paso 1.

### ⚙️ Mantener el repositorio

- `tools/php-bionic.sh` y `tools/php-focal.sh` recompilan una rama en la versión de destino
  (`prep` → `build` → `sim` → `install` → `export`). `prep` comprueba la firma y los sha256 del PPA.
- La carpeta exportada se copia a `pool/<bionic|focal>/<rama>/` y se ejecuta
  `tools/publish-repo.sh <clave-privada.asc>`, que regenera `dists/` y lo firma en un contenedor
  `ubuntu:24.04` de usar y tirar. Después, commit y push.

### 🗑️ Quitarlo

```bash
rm /etc/apt/sources.list.d/php-legacy-ubuntu.list /etc/apt/preferences.d/php-legacy-ubuntu \
   /usr/share/keyrings/php-legacy-ubuntu.gpg && apt-get update
```

Los paquetes instalados se quedan como están.

### 💙 Apoya el proyecto

Sin el apoyo de la comunidad estos proyectos no serían posibles. Si te ha resultado útil, puedes apoyarlo en
[Ko-fi](https://ko-fi.com/nebur69265723) o [PayPal](https://paypal.me/0SkillS) — cualquier aportación ayuda a
seguir manteniéndolo.

### ⚠️ Aviso

Recompilaciones no oficiales. Sin relación con el proyecto PHP, Ondřej Surý, Debian ni Canonical. Todo el
trabajo de empaquetado es de Ondřej Surý y del equipo PHP de Debian; este repositorio solo lo recompila para
versiones antiguas de Ubuntu. Úsalo bajo tu responsabilidad.
