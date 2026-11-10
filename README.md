<div align="center">

# php-legacy-ubuntu

*Signed apt and dnf repositories with patched PHP 5.6–8.2 builds for Ubuntu 18.04 and 20.04 and CentOS 8*

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
| 18.04 bionic | php7.1 | `7.1.33-80+ubuntu18.04.1+local2` |
| 18.04 bionic | php7.2 | `7.2.34-66+ubuntu18.04.1+local1` |
| 18.04 bionic | libgd3 | `2.2.5-4ubuntu0.5+local1` |
| 20.04 focal | php5.6 | `5.6.40-105+ubuntu20.04.1+local2` |
| 20.04 focal | php7.0 | `7.0.33-92+ubuntu20.04.1+local2` |
| 20.04 focal | php7.1 | `7.1.33-80+ubuntu20.04.1+local2` |
| 20.04 focal | php7.3 | `7.3.33-35+ubuntu20.04.1+local1` |
| 20.04 focal | php8.2 | `8.2.35-1+ubuntu20.04.1+local1` (with `php8.2-imagick` 3.8.1) |
| 20.04 focal | libgd3 | `2.2.5-5.2ubuntu2.4+local1` |

- The source is the PPA's: the `.dsc`, `.orig` and `.debian.tar.xz` files sit next to each build in
  `pool/<ubuntu>/<branch>/fuente/`. The `+local1` builds are the PPA's source unchanged, byte for byte.
- The `+local2` builds (php5.6, php7.0, php7.1) add the fixes the PPA ships for php7.2 and newer but not
  for these branches: CVE-2026-17543 (pgsql), CVE-2026-7260 (phar) and, for php5.6, CVE-2026-6722 (soap).
  The pgsql, phar and soap fixes for php5.6 are adapted to its engine. The extra patches are in `patches/`.
- **`libgd3`** is the system GD library: every `php*-gd` uses it (and so do other programs). It is
  Ubuntu's own package with Debian's fix for CVE-2026-9672 (GIF reader) added; `apt-get upgrade` installs it.
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
dpkg -l 'php*' 'libgd3' | awk '/^ii/ && /local[0-9]/ {print $2, $3}'
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
- **php5.6, php7.0 and php7.1:** after `prep`, copy `patches/<ubuntu>-<branch>/*.patch` into the source's
  `debian/patches/` and append their names to `debian/patches/series`; otherwise the build goes back to the
  PPA's source without the extra fixes. Drop a patch once the PPA ships that fix for the branch.
- Copy the exported folder to `pool/<bionic|focal>/<branch>/` and run
  `tools/publish-repo.sh <private-key.asc>`. It rebuilds `dists/` and signs it in a throwaway
  `ubuntu:24.04` container. Then commit and push.
- **Before relying on a rebuild**, push it and check it behaves like the previous commit:
  `tools/verify/run.sh ubuntu:20.04 php5.6 <previous-commit> main`. In throwaway Docker containers it installs
  both versions from this repository and compares the build fingerprint (modules, ini defaults, linked
  libraries), PHP's full test suite with real MariaDB and PostgreSQL, test by test, and a real website
  (phpMyAdmin under mod_php and PHP-FPM), page by page. It takes about 2 hours per branch. Only the tests of
  the fixes you added should change; rerun anything else with `tools/verify/repeat.sh` on both commits.

### 🗑️ Removing it

```bash
rm /etc/apt/sources.list.d/php-legacy-ubuntu.list /etc/apt/preferences.d/php-legacy-ubuntu \
   /usr/share/keyrings/php-legacy-ubuntu.gpg && apt-get update
```

The installed packages stay as they are.

### 🎩 CentOS 8 (EL8)

The same idea for **CentOS 8.5** and other EL8 systems, on top of [Remi's](https://rpms.remirepo.net/)
packages. Remi no longer updates the old PHP branches for EL8; the packages here are Remi's own sources with
the missing fixes added, or Remi's latest builds unchanged where they already have every fix.

| Package | Version | What it is |
|---|---|---|
| `php73-php-*` (SCL, `/opt/remi/php73`) | `7.3.33-24.1.el8.legacy` | Remi's 7.3.33-24 plus 24 backported fixes (pgsql, phar, soap, openssl, mysqlnd, sockets, http, libxml, filters, ctype…) |
| `php74-php-*` (SCL) | `7.4.33-31.el8.remi` | Remi's build, unchanged |
| `php82-php-*` (SCL) | `8.2.35-1.el8.remi` | Remi's build, unchanged |
| `gd3php` | `2.3.3-8.1.el8.legacy` | the GD library every `phpXX-php-gd` uses, with the fix for CVE-2026-9672 (GIF reader) |
| `libicu69`, `libicu74`, `oniguruma5php`, `qdbm` | Remi's | libraries the branches above need |

- Every package is **signed** with the same key as the apt repository, and so is the metadata.
- The sources (`.src.rpm`) are in `el8/SRPMS/`; the build log, with PHP's full test suite, is next to the
  packages in `el8/x86_64/<branch>/`.
- The `oci8` extensions are not here (they need Oracle's client). If Remi's `php73-php-oci8` is installed, `dnf` cannot update php73 until it is removed.
- The other branches (5.6, 7.0, 7.1, 7.2) and the modular `php:remi-7.x` streams are on their way.

**Installation** (as root). It needs **EPEL**, like Remi:

```bash
dnf install -y epel-release
curl -fsSL https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu/main/php-legacy-el8.repo \
  -o /etc/yum.repos.d/php-legacy-el8.repo
dnf upgrade 'php73*' gd3php     # if you already have Remi's; it shows the key's fingerprint, accept it if it is
                                # FD5D E92B 886F 8114 4ECB  14D2 85CC A24C 9890 D527
dnf install php73-php-fpm php73-php-mysqlnd   # new installs work as usual
```

It can stay next to Remi's repository: the versions here are newer, so `dnf` takes them, and PECL extensions
from Remi (`php73-php-pecl-*`) keep working. Restart PHP-FPM afterwards (`systemctl restart php73-php-fpm`).

**Checking it:** `rpm -q php73-php-common gd3php` must end in `.el8.legacy`, and
`rpm -q --changelog php73-php-common | head` lists the added fixes.

**Maintaining it:** put the packages in `el8/x86_64/<branch>/` (sources in `el8/SRPMS/`) and run
`tools/publish-el8.sh <private-key.asc>`. It signs whatever is not signed yet, checks every package against the
published key and rebuilds and signs the metadata in a throwaway CentOS 8 container. Then commit and push.

**Removing it:** `rm /etc/yum.repos.d/php-legacy-el8.repo`. The installed packages stay as they are.

### 💙 Support

None of this would be possible without the community's support. If this project has been useful to you,
consider supporting it on [Ko-fi](https://ko-fi.com/nebur69265723) or [PayPal](https://paypal.me/0SkillS) —
every bit helps keep it maintained.

### ⚠️ Disclaimer

Unofficial rebuilds. Not affiliated with the PHP project, Ondřej Surý, Debian, Canonical, Remi Collet or Red Hat. All the packaging
work is Ondřej Surý's and the Debian PHP team's (Ubuntu) and Remi Collet's (CentOS); this repository only rebuilds it for older releases.
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
| 18.04 bionic | php7.1 | `7.1.33-80+ubuntu18.04.1+local2` |
| 18.04 bionic | php7.2 | `7.2.34-66+ubuntu18.04.1+local1` |
| 18.04 bionic | libgd3 | `2.2.5-4ubuntu0.5+local1` |
| 20.04 focal | php5.6 | `5.6.40-105+ubuntu20.04.1+local2` |
| 20.04 focal | php7.0 | `7.0.33-92+ubuntu20.04.1+local2` |
| 20.04 focal | php7.1 | `7.1.33-80+ubuntu20.04.1+local2` |
| 20.04 focal | php7.3 | `7.3.33-35+ubuntu20.04.1+local1` |
| 20.04 focal | php8.2 | `8.2.35-1+ubuntu20.04.1+local1` (con `php8.2-imagick` 3.8.1) |
| 20.04 focal | libgd3 | `2.2.5-5.2ubuntu2.4+local1` |

- El código es el del PPA: los `.dsc`, `.orig` y `.debian.tar.xz` están junto a cada compilación en
  `pool/<ubuntu>/<rama>/fuente/`. Las compilaciones `+local1` son el código del PPA sin cambios, byte a byte.
- Las `+local2` (php5.6, php7.0, php7.1) añaden los arreglos que el PPA publica para php7.2 y posteriores pero
  no para estas ramas: CVE-2026-17543 (pgsql), CVE-2026-7260 (phar) y, en php5.6, CVE-2026-6722 (soap). Los
  de pgsql, phar y soap de php5.6 están adaptados a su motor. Los parches añadidos están en `patches/`.
- **`libgd3`** es la librería GD del sistema: la usan todos los `php*-gd` (y otros programas). Es el paquete de
  Ubuntu con el arreglo de Debian para CVE-2026-9672 (lector GIF); `apt-get upgrade` la instala.
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
dpkg -l 'php*' 'libgd3' | awk '/^ii/ && /local[0-9]/ {print $2, $3}'
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
- **php5.6, php7.0 y php7.1:** después de `prep`, copia `patches/<ubuntu>-<rama>/*.patch` a `debian/patches/`
  del código y añade sus nombres al final de `debian/patches/series`; si no, la compilación vuelve al código del
  PPA sin los arreglos añadidos. Quita un parche cuando el PPA publique ese arreglo para la rama.
- La carpeta exportada se copia a `pool/<bionic|focal>/<rama>/` y se ejecuta
  `tools/publish-repo.sh <clave-privada.asc>`, que regenera `dists/` y lo firma en un contenedor
  `ubuntu:24.04` de usar y tirar. Después, commit y push.
- **Antes de fiarte de una recompilación**, súbela y comprueba que se comporta como el commit anterior:
  `tools/verify/run.sh ubuntu:20.04 php5.6 <commit-anterior> main`. En contenedores Docker de usar y tirar
  instala las dos versiones desde este repositorio y compara la huella de compilación (módulos, valores de
  ini, librerías enlazadas), la suite completa de PHP con MariaDB y PostgreSQL de verdad, prueba a prueba, y
  una web de verdad (phpMyAdmin con mod_php y con PHP-FPM), página a página. Tarda unas 2 horas por rama. Solo
  deben cambiar las pruebas de los arreglos que hayas añadido; lo demás, repítelo con `tools/verify/repeat.sh`
  en los dos commits.

### 🗑️ Quitarlo

```bash
rm /etc/apt/sources.list.d/php-legacy-ubuntu.list /etc/apt/preferences.d/php-legacy-ubuntu \
   /usr/share/keyrings/php-legacy-ubuntu.gpg && apt-get update
```

Los paquetes instalados se quedan como están.

### 🎩 CentOS 8 (EL8)

La misma idea para **CentOS 8.5** y otros sistemas EL8, sobre los paquetes de
[Remi](https://rpms.remirepo.net/). Remi ya no actualiza las ramas antiguas de PHP para EL8; los paquetes de
aquí son el mismo código de Remi con los arreglos que faltaban, o las últimas compilaciones de Remi sin tocar
cuando ya los tienen todos.

| Paquete | Versión | Qué es |
|---|---|---|
| `php73-php-*` (SCL, `/opt/remi/php73`) | `7.3.33-24.1.el8.legacy` | el 7.3.33-24 de Remi con 24 arreglos portados (pgsql, phar, soap, openssl, mysqlnd, sockets, http, libxml, filtros, ctype…) |
| `php74-php-*` (SCL) | `7.4.33-31.el8.remi` | la compilación de Remi, sin tocar |
| `php82-php-*` (SCL) | `8.2.35-1.el8.remi` | la compilación de Remi, sin tocar |
| `gd3php` | `2.3.3-8.1.el8.legacy` | la librería GD que usan todos los `phpXX-php-gd`, con el arreglo de CVE-2026-9672 (lector GIF) |
| `libicu69`, `libicu74`, `oniguruma5php`, `qdbm` | las de Remi | librerías que necesitan las ramas de arriba |

- Todos los paquetes están **firmados** con la misma clave que el repositorio apt, y los metadatos también.
- El código (`.src.rpm`) está en `el8/SRPMS/`; el registro de la compilación, con la batería completa de
  pruebas de PHP, está junto a los paquetes en `el8/x86_64/<rama>/`.
- Las extensiones `oci8` no están (necesitan el cliente de Oracle). Si está instalado el `php73-php-oci8` de Remi, `dnf` no puede actualizar php73 hasta quitarlo.
- Las demás ramas (5.6, 7.0, 7.1, 7.2) y los flujos modulares `php:remi-7.x` están en camino.

**Instalación** (como root). Necesita **EPEL**, igual que Remi:

```bash
dnf install -y epel-release
curl -fsSL https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu/main/php-legacy-el8.repo \
  -o /etc/yum.repos.d/php-legacy-el8.repo
dnf upgrade 'php73*' gd3php     # si ya tienes los de Remi; enseña la huella de la clave, acéptala si es
                                # FD5D E92B 886F 8114 4ECB  14D2 85CC A24C 9890 D527
dnf install php73-php-fpm php73-php-mysqlnd   # las instalaciones nuevas, como siempre
```

Puede convivir con el repositorio de Remi: las versiones de aquí son más nuevas, así que `dnf` elige estas, y
las extensiones PECL de Remi (`php73-php-pecl-*`) siguen funcionando. Después, reinicia PHP-FPM
(`systemctl restart php73-php-fpm`).

**Comprobarlo:** `rpm -q php73-php-common gd3php` tiene que acabar en `.el8.legacy`, y
`rpm -q --changelog php73-php-common | head` enseña los arreglos añadidos.

**Mantenerlo:** deja los paquetes en `el8/x86_64/<rama>/` (el código en `el8/SRPMS/`) y ejecuta
`tools/publish-el8.sh <clave-privada.asc>`. Firma lo que aún no esté firmado, comprueba cada paquete contra la
clave publicada y regenera y firma los metadatos en un contenedor CentOS 8 de usar y tirar. Después, commit y
push.

**Quitarlo:** `rm /etc/yum.repos.d/php-legacy-el8.repo`. Los paquetes instalados se quedan como están.

### 💙 Apoya el proyecto

Sin el apoyo de la comunidad estos proyectos no serían posibles. Si te ha resultado útil, puedes apoyarlo en
[Ko-fi](https://ko-fi.com/nebur69265723) o [PayPal](https://paypal.me/0SkillS) — cualquier aportación ayuda a
seguir manteniéndolo.

### ⚠️ Aviso

Recompilaciones no oficiales. Sin relación con el proyecto PHP, Ondřej Surý, Debian, Canonical, Remi Collet ni Red Hat. Todo el
trabajo de empaquetado es de Ondřej Surý y del equipo PHP de Debian (Ubuntu) y de Remi Collet (CentOS); este repositorio solo lo recompila para
versiones antiguas. Úsalo bajo tu responsabilidad.
