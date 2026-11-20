-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: php8.2
Binary: libapache2-mod-php8.2, libphp8.2-embed, php8.2, php8.2-cgi, php8.2-cli, php8.2-dev, php8.2-fpm, php8.2-litespeed, php8.2-phpdbg, php8.2-xsl, php8.2-bcmath, php8.2-bz2, php8.2-common, php8.2-curl, php8.2-dba, php8.2-enchant, php8.2-gd, php8.2-gmp, php8.2-imap, php8.2-interbase, php8.2-intl, php8.2-ldap, php8.2-mbstring, php8.2-mysql, php8.2-odbc, php8.2-opcache, php8.2-pgsql, php8.2-pspell, php8.2-readline, php8.2-snmp, php8.2-soap, php8.2-sqlite3, php8.2-sybase, php8.2-tidy, php8.2-xml, php8.2-zip
Architecture: any all
Version: 8.2.36-2+ubuntu22.04.1+deb.sury.org+1
Maintainer: Debian PHP Maintainers <team+pkg-php@tracker.debian.org>
Uploaders: Ondřej Surý <ondrej@debian.org>, Lior Kaplan <kaplan@debian.org>
Homepage: http://www.php.net/
Standards-Version: 4.5.0.0
Vcs-Browser: https://salsa.debian.org/php-team/php/-/tree/debian/main/8.2
Vcs-Git: https://salsa.debian.org/php-team/php.git -b debian/main/8.2
Testsuite: autopkgtest
Testsuite-Triggers: apache2, base-files, language-pack-de, locales-all, netbase, openssl, tzdata-legacy, wget
Build-Depends: debhelper (>= 9.20160709~), dh-apache2, dpkg-dev (>= 1.16.1~), apache2-bin (>= 2.4), apache2-dev (>= 2.4), autoconf (>= 2.63), automake, bison, chrpath, default-libmysqlclient-dev | libmysqlclient-dev, firebird-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.5-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.1-dev [!hurd-any !m68k !hppa !ppc64], flex, freetds-dev, libacl1-dev, libapparmor-dev [linux-any], libapr1-dev (>= 1.2.7-8), libargon2-dev | libargon2-0-dev, libbz2-dev, libc-client-dev, libcurl4-openssl-dev | libcurl-dev, libdb-dev, libedit-dev (>= 2.11-20080614-4), libenchant-2-dev | libenchant-dev, libevent-dev (>= 1.4.11), libexpat1-dev (>= 1.95.2-2.1), libffi-dev, libfreetype6-dev, libgcrypt20-dev (>> 1.6.3) | libgcrypt11-dev (<< 1.5.4), libgd-dev (>= 2.1.0) | libgd2-dev, libglib2.0-dev, libgmp3-dev, libicu-dev, libjpeg-dev | libjpeg62-dev, libkrb5-dev, libldap2-dev, liblmdb-dev, libmagic-dev, libmhash-dev (>= 0.8.8), libnss-myhostname [linux-any], libonig-dev, libpam0g-dev, libpcre2-dev (>= 10.30), libpng-dev, libpq-dev, libpspell-dev, libqdbm-dev, libsasl2-dev, libsnmp-dev, libsodium-dev, libsqlite3-dev, libssl-dev, libsystemd-dev [linux-any], libtidy-dev (>= 1:5.2.0), libtool (>= 2.2), libwebp-dev, libwrap0-dev, libxml2-dev, libxslt1-dev (>= 1.0.18), libzip-dev (>= 1.0.0), locales-all | language-pack-de, netbase, netcat-openbsd, php-common, re2c, systemtap-sdt-dev, tzdata, unixodbc-dev, zlib1g-dev
Build-Conflicts: bind-dev, libxmlrpc-core-c3-dev
Package-List:
 libapache2-mod-php8.2 deb httpd optional arch=any
 libphp8.2-embed deb php optional arch=any
 php8.2 deb php optional arch=all
 php8.2-bcmath deb php optional arch=any
 php8.2-bz2 deb php optional arch=any
 php8.2-cgi deb php optional arch=any
 php8.2-cli deb php optional arch=any
 php8.2-common deb php optional arch=any
 php8.2-curl deb php optional arch=any
 php8.2-dba deb php optional arch=any
 php8.2-dev deb php optional arch=any
 php8.2-enchant deb php optional arch=any
 php8.2-fpm deb php optional arch=any
 php8.2-gd deb php optional arch=any
 php8.2-gmp deb php optional arch=any
 php8.2-imap deb php optional arch=any
 php8.2-interbase deb php optional arch=any
 php8.2-intl deb php optional arch=any
 php8.2-ldap deb php optional arch=any
 php8.2-litespeed deb php optional arch=any
 php8.2-mbstring deb php optional arch=any
 php8.2-mysql deb php optional arch=any
 php8.2-odbc deb php optional arch=any
 php8.2-opcache deb php optional arch=any
 php8.2-pgsql deb php optional arch=any
 php8.2-phpdbg deb php optional arch=any
 php8.2-pspell deb php optional arch=any
 php8.2-readline deb php optional arch=any
 php8.2-snmp deb php optional arch=any
 php8.2-soap deb php optional arch=any
 php8.2-sqlite3 deb php optional arch=any
 php8.2-sybase deb php optional arch=any
 php8.2-tidy deb php optional arch=any
 php8.2-xml deb php optional arch=any
 php8.2-xsl deb php optional arch=all
 php8.2-zip deb php optional arch=any
Checksums-Sha1:
 d22d34080c631d08a291c8e0adc6cbcdac2da33e 12229968 php8.2_8.2.36.orig.tar.xz
 3f6ba428285a64fac9c99bd38514af896014520b 90048 php8.2_8.2.36-2+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Checksums-Sha256:
 df50a00d2b453096608bf2bd98a9fab9a3df8678a77b93011b65c3cfe9a018fa 12229968 php8.2_8.2.36.orig.tar.xz
 0257efd249a307440ea274097f3927812f54597daafcb75f2e3843660cbf09b7 90048 php8.2_8.2.36-2+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Files:
 93d9cae76e6311dd6e3fb8e41fdcb6af 12229968 php8.2_8.2.36.orig.tar.xz
 f3030f4cf15f6ca567b92aa4a925f3b6 90048 php8.2_8.2.36-2+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz

-----BEGIN PGP SIGNATURE-----

iQKTBAEBCgB9FiEEahqteuW0AcbiWaeyVwZ7qhMUx/wFAmr/VbNfFIAAAAAALgAo
aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDZB
MUFBRDdBRTVCNDAxQzZFMjU5QTdCMjU3MDY3QkFBMTMxNEM3RkMACgkQVwZ7qhMU
x/z2YA//Z1PcX1RM5NCisw2ydUQh+rdYwCO4yuGEWYUYpssuRvR7t2ggT6Ep7WgX
bRJWo9QEC+EcFOvaQSYJ9krqgmsNAAjQw9INiKCW3NFTBsCV2bjBigj1WBhA166y
nF7/JJVln/kYuRQZseuu3jj8hr+VttaWfOXLtJnI8Dn370Vwj+vcmER6sEpgyWAW
hRW/GxjN8K3h5porB71mGfxmOVg+T3p+TMc0uvtVPewNcl8ithQbErmEaGysskJ5
HmADjH5aXbnJ0qqVav4C5kXMrgOjIKP7qKVo/waDGPf5ow0bpttV8b7PbDpeB8ct
udFCdfJUSsNpBKQYJ7AIW0K9LX1wP4AH7YXZOE2zWcE6w1udxlVzIs2eO6x3wHkZ
8cq5VYio6WQNk73858BAJY0e57KFiLFSES0QfClk4Ixtz6MhfQ/bk+tQ77ogRCzC
ByJfxKbJRtC89tE1CvpRFg7Td9exVF9dIdNVXbw6rHeqwFAqUAU6rNM9DhUbhpEl
KpCGGJJQ7787A6VQjCIzkV/hgERUd3xezX3vdl9suvIZhK9HJoERDPkefcSEkSeL
RmuOJnrsXsR7COoj92HYciU/5hV3BsHTPIrOGv66FcQehdQJZgwm1PN1IRiHMzux
UpBqc/KIr0qw9V2yZFMicL/1yNAnC4O/qUclkRsCYxtPcjm/OmU=
=qFPa
-----END PGP SIGNATURE-----
