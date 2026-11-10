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
| 20.04 focal | php7.4 | `1:7.4.33-31+ubuntu20.04.1+local1` (replaces Ubuntu's own 7.4.3, see below) |
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

> ⚠️ **Installing a new branch can change the whole machine** (it is how the PPA's packages work, and these are
> the same packages):
> - **`/usr/bin/php`:** every `phpX.Y-cli` (and `phpX.Y-fpm` brings it) registers itself in `update-alternatives`,
>   and the newest branch wins. Installing `php8.2-fpm` on a machine with PHP 7.4 turns `php` into 8.2 for cron
>   jobs, composer and every script. Pin it back afterwards:
>   `for b in php phar phar.phar; do update-alternatives --set $b /usr/bin/${b}7.4; done` (with your branch).
> - **Apache:** never install the bare `phpX.Y` package on a web server. It brings `libapache2-mod-phpX.Y`, and if
>   Apache was serving PHP with FPM it **switches Apache to the prefork MPM and enables mod_php for every site**
>   (tested: Apache did not come back up and no site answered). Install `phpX.Y-fpm` and the extensions you need by name, and check
>   first with `apt-get -s install …` that `libapache2-mod-php` is not in the list. If it already happened:
>   `a2dismod phpX.Y mpm_prefork && a2enmod mpm_event && systemctl restart apache2`.
> - The FPM of the new branch starts on its own but is **not** wired into Apache: `a2enconf phpX.Y-fpm` does it
>   for every site, or set its socket (`/run/php/phpX.Y-fpm.sock`) in each vhost.

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
- **Ubuntu 20.04's own PHP 7.4** (`7.4.3-4ubuntu2.x`, no longer fixed without Ubuntu Pro) **is replaced by this
  repository's 7.4.33** on the next `apt-get upgrade`: the PPA's source, which already has every fix of the 7.4
  branch. Tested from a stock 20.04 with Apache (PHP-FPM and mod_php) and Ubuntu's own PECL extensions (xdebug,
  apcu, redis, igbinary, memcached, imagick, msgpack, memcache): nothing removed, every extension loads, and
  1300 requests with xdebug on gave no crash. Restart Apache and PHP-FPM afterwards (`systemctl restart`, not
  `reload`: Apache keeps the old `libphp7.4.so` loaded otherwise). To stay on Ubuntu's 7.4, pin it before upgrading:
  `printf 'Package: php7.4* libapache2-mod-php7.4 libphp7.4-embed\nPin: release o=php-legacy-ubuntu\nPin-Priority: 99\n' > /etc/apt/preferences.d/php-legacy-ubuntu-74`.
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
| `php72-php-*`, `php71-php-*`, `php70-php-*`, `php56-php-*` (SCL) | `7.2.34-31.1`, `7.1.33-34.1`, `7.0.33-47.1`, `5.6.40-47.1` (`.el8.legacy`) | Remi's last build of each branch plus 28-32 backported fixes: the same as php73, plus mysqlnd (CVE-2024-8929) and, in 7.1/7.0/5.6, PHP2Shell (CVE-2026-109618/109619), pgsql and phar (5.6 also soap) |
| `php74-php-*` (SCL) | `7.4.33-31.el8.remi` | Remi's build, unchanged: it already has all those fixes |
| `php82-php-*` (SCL) | `8.2.35-1.el8.remi` | Remi's build, unchanged |
| `gd3php` | `2.3.3-8.1.el8.legacy` | the GD library that every `php-gd` from Remi uses (SCL **and** the `php:remi-7.4` / `php:remi-8.2` modules), with the fix for CVE-2026-9672 (GIF reader) |
| `libicu69`, `libicu74`, `oniguruma5php`, `qdbm` | Remi's | libraries the branches above need |

- Every package is **signed** with the same key as the apt repository, and so is the metadata.
- The sources (`.src.rpm`) are in `el8/SRPMS/` and the build log is next to the packages, in `el8/x86_64/<branch>/`.
- The `oci8` extensions are not here (they need Oracle's client). If Remi's `php73-php-oci8` is installed, `dnf`
  cannot update php73 until it is removed.
- The modular `php:remi-7.2` / `php:remi-7.3` streams are on their way.

**What you need, depending on what the machine runs:**

| The machine runs… | Do this |
|---|---|
| PHP 7.4 or 8.2 from the **module** (`php:remi-7.4`, `php:remi-8.2`: `php-fpm`, `/etc/php.ini`) | Stay on the module. Add this repository and run `dnf upgrade gd3php`: the module already has every PHP fix, and GD is the only thing it lacks. **Do not install `php74-php-*` or `php82-php-*`** (see the warning below). |
| PHP 5.6, 7.0, 7.1, 7.2 or 7.3 from Remi's **SCL** (`php56-php-*` … `php73-php-*`) | `dnf upgrade 'php56*' 'php7*' gd3php` |
| PHP 7.4 or 8.2 from Remi's **SCL** | `dnf upgrade gd3php` (the `php74`/`php82` here are the same builds as Remi's) |
| PHP 7.2 or 7.3 from the **module** | `dnf upgrade gd3php` for now; the patched modular streams are coming |

**Before you start.** These packages are built and tested on **CentOS 8.5.2111**; they also work on CentOS Stream 8,
which is newer. Both live in `vault.centos.org` now (`mirrorlist.centos.org` no longer resolves). On 8.0–8.4, first
update to 8.5, `rpm` and `dnf` before the rest:

```bash
sed -i -e 's|^mirrorlist=|#mirrorlist=|' -e 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' /etc/yum.repos.d/CentOS-*
dnf upgrade --releasever=8.5.2111 rpm dnf && dnf upgrade --releasever=8.5.2111
```

Repeat the `sed` after any update that brings new `.repo` files with `mirrorlist=` back.

The packages of this repository verify with the rpm of CentOS 8.0–8.2 too (their signature header is 4 KB; the
`signature hdr data: BAD … out of range` error comes from CentOS Stream packages, not from these). Remi's
`remi-release` asks for EL 8.10, which CentOS 8 never reached: if it is installed, add `excludepkgs=remi-release`
to `/etc/dnf/dnf.conf` so `dnf upgrade` does not stop on it. This repository does not need Remi's.

**Installation** (as root). It needs **EPEL**, like Remi:

```bash
dnf install -y epel-release
curl -fsSL https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu/main/php-legacy-el8.repo \
  -o /etc/yum.repos.d/php-legacy-el8.repo
dnf upgrade gd3php 'php73*'     # what the table above says; it shows the key's fingerprint, accept it only if it is
                                # FD5D E92B 886F 8114 4ECB  14D2 85CC A24C 9890 D527
systemctl restart php73-php-fpm httpd 2>/dev/null; true
```

It can stay next to Remi's repository: the versions here are newer, so `dnf` takes them, and PECL extensions from
Remi (`php73-php-pecl-*`) keep working.

> ⚠️ **Installing `phpXX-php-fpm` changes Apache for every site.** Like Remi's own packages, it adds
> `/etc/httpd/conf.d/phpXX-php.conf`, which sends **every** `.php` to
> `/var/opt/remi/phpXX/run/php-fpm/www.sock` as soon as Apache reloads, and it does **not** start that service.
> On a machine that serves PHP from the module (`php.conf` → `/run/php-fpm/www.sock`) the sites answer 502/503.
> Either move to the SCL first (below) and only then reload Apache, or keep the module for every site: comment
> out the `<FilesMatch>` block of `phpXX-php.conf` and point each vhost that should use the SCL at its socket.

**A new SCL install** is not started for you: `systemctl enable --now php73-php-fpm`. Its commands are not in the
`PATH`: use the full path (`/opt/remi/php73/root/usr/sbin/php-fpm -t`), `scl enable php73 -- php-fpm -t`, or the
`php73` command for the CLI.

**Moving a site from the module to the SCL** (only if you really need the SCL branch):
- extensions: `diff <(php -m) <(php73 -m)` and install the missing `php73-php-<ext>`;
- `php.ini` and `php.d/`: copy your changes (`memory_limit`, `max_execution_time`, `upload_max_filesize`…) to
  `/etc/opt/remi/php73/php.ini` and `/etc/opt/remi/php73/php.d/`;
- the pool: `/etc/php-fpm.d/www.conf` → `/etc/opt/remi/php73/php-fpm.d/www.conf` (`user`, `group`, `listen`,
  `slowlog`, `php_admin_value[error_log]`, `php_value[session.save_path]`);
- `systemctl enable --now php73-php-fpm`, then `systemctl reload httpd`, then `systemctl disable --now php-fpm`;
- the sessions move to `/var/opt/remi/php73/lib/php/session`: logged-in users have to log in again.

**Checking it:** `rpm -q php73-php-common gd3php` (or `php56`/`php70`/`php71`/`php72`) must end in `.el8.legacy` (`php74-*` and `php82-*` end in
`.el8.remi`: they are Remi's builds, and that is right), and `rpm -q --changelog php73-php-common | head` lists the
added fixes.

**Maintaining it:** `tools/build-el8.sh <file.src.rpm> <scl> <out-dir>` rebuilds a branch in a throwaway CentOS 8.5
container, and `tools/verify/run-el8.sh <before-dir> <after-dir> <scl>` installs both builds on a clean CentOS 8.5
and compares them (fingerprint and PHP's full suite with MariaDB and PostgreSQL, test by test). Put the packages in
`el8/x86_64/<branch>/` (sources in `el8/SRPMS/`) and run `tools/publish-el8.sh <private-key.asc>`. It signs whatever
is not signed yet, checks every package against the published key and rebuilds and signs the metadata. Then
commit and push.

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
| 20.04 focal | php7.4 | `1:7.4.33-31+ubuntu20.04.1+local1` (sustituye a la 7.4.3 del propio Ubuntu, ver abajo) |
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

> ⚠️ **Instalar una rama nueva puede cambiar toda la máquina** (así funcionan los paquetes del PPA, y estos son los
> mismos paquetes):
> - **`/usr/bin/php`:** cada `phpX.Y-cli` (y `phpX.Y-fpm` lo trae) se apunta en `update-alternatives`, y gana la
>   rama más nueva. Instalar `php8.2-fpm` en una máquina con PHP 7.4 hace que `php` pase a ser la 8.2 para el cron,
>   composer y todos los guiones. Después, déjalo fijo:
>   `for b in php phar phar.phar; do update-alternatives --set $b /usr/bin/${b}7.4; done` (con tu rama).
> - **Apache:** nunca instales el paquete `phpX.Y` a secas en un servidor web. Trae `libapache2-mod-phpX.Y` y, si
>   Apache servía PHP con FPM, **cambia Apache al MPM prefork y activa mod_php para todas las webs** (probado: Apache
>   no volvió a arrancar y ninguna web respondía). Instala `phpX.Y-fpm` y las extensiones que necesites por su nombre, y comprueba
>   antes con `apt-get -s install …` que no aparece `libapache2-mod-php`. Si ya ha pasado:
>   `a2dismod phpX.Y mpm_prefork && a2enmod mpm_event && systemctl restart apache2`.
> - El FPM de la rama nueva arranca solo, pero **no** se engancha a Apache: `a2enconf phpX.Y-fpm` lo hace para
>   todas las webs, o pon su socket (`/run/php/phpX.Y-fpm.sock`) en cada vhost.

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
- **El PHP 7.4 del propio Ubuntu 20.04** (`7.4.3-4ubuntu2.x`, sin arreglos si no se tiene Ubuntu Pro) **lo sustituye
  la 7.4.33 de este repositorio** en el siguiente `apt-get upgrade`: el código del PPA, que ya trae todos los arreglos
  de la rama 7.4. Probado desde un 20.04 de serie con Apache (PHP-FPM y mod_php) y las extensiones PECL del propio
  Ubuntu (xdebug, apcu, redis, igbinary, memcached, imagick, msgpack, memcache): no se quita nada, cargan todas y
  1300 peticiones con xdebug activo no dieron ningún fallo. Después, reinicia Apache y PHP-FPM (`systemctl restart`, no
  `reload`: si no, Apache sigue con la `libphp7.4.so` antigua cargada). Para quedarte con la 7.4 de Ubuntu, fíjala antes
  de actualizar:
  `printf 'Package: php7.4* libapache2-mod-php7.4 libphp7.4-embed\nPin: release o=php-legacy-ubuntu\nPin-Priority: 99\n' > /etc/apt/preferences.d/php-legacy-ubuntu-74`.
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
| `php72-php-*`, `php71-php-*`, `php70-php-*`, `php56-php-*` (SCL) | `7.2.34-31.1`, `7.1.33-34.1`, `7.0.33-47.1`, `5.6.40-47.1` (`.el8.legacy`) | la última compilación de Remi de cada rama con 28-32 arreglos portados: los mismos que php73, más mysqlnd (CVE-2024-8929) y, en 7.1/7.0/5.6, PHP2Shell (CVE-2026-109618/109619), pgsql y phar (5.6, también soap) |
| `php74-php-*` (SCL) | `7.4.33-31.el8.remi` | la compilación de Remi, sin tocar: ya trae todos esos arreglos |
| `php82-php-*` (SCL) | `8.2.35-1.el8.remi` | la compilación de Remi, sin tocar |
| `gd3php` | `2.3.3-8.1.el8.legacy` | la librería GD que usan todos los `php-gd` de Remi (los SCL **y** los módulos `php:remi-7.4` / `php:remi-8.2`), con el arreglo de CVE-2026-9672 (lector GIF) |
| `libicu69`, `libicu74`, `oniguruma5php`, `qdbm` | las de Remi | librerías que necesitan las ramas de arriba |

- Todos los paquetes están **firmados** con la misma clave que el repositorio apt, y los metadatos también.
- El código (`.src.rpm`) está en `el8/SRPMS/` y el registro de la compilación, junto a los paquetes, en
  `el8/x86_64/<rama>/`.
- Las extensiones `oci8` no están (necesitan el cliente de Oracle). Si está instalado el `php73-php-oci8` de Remi,
  `dnf` no puede actualizar php73 hasta quitarlo.
- Los flujos modulares `php:remi-7.2` / `php:remi-7.3` están en camino.

**Qué necesitas, según lo que tenga la máquina:**

| La máquina usa… | Haz esto |
|---|---|
| PHP 7.4 u 8.2 del **módulo** (`php:remi-7.4`, `php:remi-8.2`: `php-fpm`, `/etc/php.ini`) | Sigue con el módulo. Añade este repositorio y haz `dnf upgrade gd3php`: el módulo ya tiene todos los arreglos de PHP y solo le falta el de GD. **No instales `php74-php-*` ni `php82-php-*`** (mira el aviso de abajo). |
| PHP 5.6, 7.0, 7.1, 7.2 o 7.3 del **SCL** de Remi (`php56-php-*` … `php73-php-*`) | `dnf upgrade 'php56*' 'php7*' gd3php` |
| PHP 7.4 u 8.2 del **SCL** de Remi | `dnf upgrade gd3php` (los `php74`/`php82` de aquí son las mismas compilaciones que las de Remi) |
| PHP 7.2 o 7.3 del **módulo** | De momento `dnf upgrade gd3php`; los flujos modulares parcheados están en camino |

**Antes de empezar.** Estos paquetes se compilan y se prueban en **CentOS 8.5.2111**; también funcionan en CentOS
Stream 8, que es más nuevo. Los dos están ya en `vault.centos.org` (`mirrorlist.centos.org` ya no resuelve). En
8.0–8.4, primero hay que subir a 8.5, `rpm` y `dnf` antes que lo demás:

```bash
sed -i -e 's|^mirrorlist=|#mirrorlist=|' -e 's|^#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' /etc/yum.repos.d/CentOS-*
dnf upgrade --releasever=8.5.2111 rpm dnf && dnf upgrade --releasever=8.5.2111
```

Repite el `sed` después de cualquier actualización que vuelva a traer ficheros `.repo` con `mirrorlist=`.

Los paquetes de este repositorio también se verifican con el rpm de CentOS 8.0–8.2 (su cabecera de firma ocupa
4 KB; el error `signature hdr data: BAD … out of range` viene de paquetes de CentOS Stream, no de estos). El
`remi-release` de Remi pide EL 8.10, que CentOS 8 nunca tuvo: si está instalado, añade `excludepkgs=remi-release` a
`/etc/dnf/dnf.conf` para que `dnf upgrade` no se pare en él. Este repositorio no necesita el de Remi.

**Instalación** (como root). Necesita **EPEL**, igual que Remi:

```bash
dnf install -y epel-release
curl -fsSL https://raw.githubusercontent.com/Nebur692/php-legacy-ubuntu/main/php-legacy-el8.repo \
  -o /etc/yum.repos.d/php-legacy-el8.repo
dnf upgrade gd3php 'php73*'     # lo que diga la tabla de arriba; enseña la huella de la clave, acéptala solo si es
                                # FD5D E92B 886F 8114 4ECB  14D2 85CC A24C 9890 D527
systemctl restart php73-php-fpm httpd 2>/dev/null; true
```

Puede convivir con el repositorio de Remi: las versiones de aquí son más nuevas, así que `dnf` elige estas, y las
extensiones PECL de Remi (`php73-php-pecl-*`) siguen funcionando.

> ⚠️ **Instalar `phpXX-php-fpm` cambia Apache para todas las webs.** Igual que los paquetes de Remi, añade
> `/etc/httpd/conf.d/phpXX-php.conf`, que manda **todos** los `.php` a
> `/var/opt/remi/phpXX/run/php-fpm/www.sock` en cuanto Apache se recarga, y **no** arranca ese servicio. En una
> máquina que sirve PHP con el módulo (`php.conf` → `/run/php-fpm/www.sock`) las webs dan 502/503. O pasas antes al
> SCL (abajo) y solo entonces recargas Apache, o mantienes el módulo para todas las webs: comenta el bloque
> `<FilesMatch>` de `phpXX-php.conf` y apunta al socket del SCL solo los vhost que lo vayan a usar.

**Una instalación nueva del SCL** no se arranca sola: `systemctl enable --now php73-php-fpm`. Sus órdenes no están en
el `PATH`: usa la ruta completa (`/opt/remi/php73/root/usr/sbin/php-fpm -t`), `scl enable php73 -- php-fpm -t`, o la
orden `php73` para la línea de órdenes.

**Pasar una web del módulo al SCL** (solo si de verdad necesitas la rama del SCL):
- extensiones: `diff <(php -m) <(php73 -m)` e instala los `php73-php-<ext>` que falten;
- `php.ini` y `php.d/`: copia tus cambios (`memory_limit`, `max_execution_time`, `upload_max_filesize`…) a
  `/etc/opt/remi/php73/php.ini` y `/etc/opt/remi/php73/php.d/`;
- el pool: `/etc/php-fpm.d/www.conf` → `/etc/opt/remi/php73/php-fpm.d/www.conf` (`user`, `group`, `listen`,
  `slowlog`, `php_admin_value[error_log]`, `php_value[session.save_path]`);
- `systemctl enable --now php73-php-fpm`, después `systemctl reload httpd` y después `systemctl disable --now php-fpm`;
- las sesiones pasan a `/var/opt/remi/php73/lib/php/session`: quien estuviera conectado tendrá que volver a entrar.

**Comprobarlo:** `rpm -q php73-php-common gd3php` (o `php56`/`php70`/`php71`/`php72`) tiene que acabar en `.el8.legacy` (`php74-*` y `php82-*` acaban en
`.el8.remi`: son las compilaciones de Remi y está bien), y `rpm -q --changelog php73-php-common | head` enseña los
arreglos añadidos.

**Mantenerlo:** `tools/build-el8.sh <fichero.src.rpm> <scl> <carpeta-salida>` recompila una rama en un contenedor
CentOS 8.5 de usar y tirar, y `tools/verify/run-el8.sh <carpeta-antes> <carpeta-después> <scl>` instala las dos
compilaciones en un CentOS 8.5 limpio y las compara (huella y la suite completa de PHP con MariaDB y PostgreSQL,
prueba a prueba). Deja los paquetes en `el8/x86_64/<rama>/` (el código en `el8/SRPMS/`) y ejecuta
`tools/publish-el8.sh <clave-privada.asc>`. Firma lo que aún no esté firmado, comprueba cada paquete contra la clave
publicada y regenera y firma los metadatos. Después, commit y push.

**Quitarlo:** `rm /etc/yum.repos.d/php-legacy-el8.repo`. Los paquetes instalados se quedan como están.

### 💙 Apoya el proyecto

Sin el apoyo de la comunidad estos proyectos no serían posibles. Si te ha resultado útil, puedes apoyarlo en
[Ko-fi](https://ko-fi.com/nebur69265723) o [PayPal](https://paypal.me/0SkillS) — cualquier aportación ayuda a
seguir manteniéndolo.

### ⚠️ Aviso

Recompilaciones no oficiales. Sin relación con el proyecto PHP, Ondřej Surý, Debian, Canonical, Remi Collet ni Red Hat. Todo el
trabajo de empaquetado es de Ondřej Surý y del equipo PHP de Debian (Ubuntu) y de Remi Collet (CentOS); este repositorio solo lo recompila para
versiones antiguas. Úsalo bajo tu responsabilidad.
