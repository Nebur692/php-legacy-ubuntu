-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: php7.3
Binary: libapache2-mod-php7.3, libphp7.3-embed, php7.3, php7.3-bcmath, php7.3-bz2, php7.3-cgi, php7.3-cli, php7.3-common, php7.3-curl, php7.3-dba, php7.3-dev, php7.3-enchant, php7.3-fpm, php7.3-gd, php7.3-gmp, php7.3-imap, php7.3-interbase, php7.3-intl, php7.3-json, php7.3-ldap, php7.3-litespeed, php7.3-mbstring, php7.3-mysql, php7.3-odbc, php7.3-opcache, php7.3-pgsql, php7.3-phpdbg, php7.3-pspell, php7.3-readline, php7.3-recode, php7.3-snmp, php7.3-soap, php7.3-sqlite3, php7.3-sybase, php7.3-tidy, php7.3-xml, php7.3-xmlrpc, php7.3-xsl, php7.3-zip
Architecture: any all
Version: 7.3.33-35+ubuntu22.04.1+deb.sury.org+1
Maintainer: Debian PHP Maintainers <team+pkg-php@tracker.debian.org>
Uploaders: Ondřej Surý <ondrej@debian.org>, Lior Kaplan <kaplan@debian.org>
Homepage: http://www.php.net/
Standards-Version: 4.5.0.0
Vcs-Browser: https://salsa.debian.org/php-team/php/-/tree/debian/main/7.3
Vcs-Git: https://salsa.debian.org/php-team/php.git -b debian/main/7.3
Testsuite: autopkgtest
Testsuite-Triggers: apache2, wget
Build-Depends: debhelper (>= 9.20160709~), dh-apache2, dpkg-dev (>= 1.16.1~), apache2-bin (>= 2.4), apache2-dev (>= 2.4), autoconf (>= 2.63), automake, bison, chrpath, default-libmysqlclient-dev | libmysqlclient-dev, firebird-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.5-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.1-dev [!hurd-any !m68k !hppa !ppc64], flex, freetds-dev, libacl1-dev, libapparmor-dev [linux-any], libapr1-dev (>= 1.2.7-8), libargon2-dev | libargon2-0-dev, libbz2-dev, libc-client-dev, libcurl4-openssl-dev | libcurl-dev, libdb-dev, libedit-dev (>= 2.11-20080614-4), libenchant-2-dev | libenchant-dev, libevent-dev (>= 1.4.11), libexpat1-dev (>= 1.95.2-2.1), libfreetype6-dev, libgcrypt20-dev (>> 1.6.3) | libgcrypt11-dev (<< 1.5.4), libgd-dev (>= 2.1.0) | libgd2-dev, libglib2.0-dev, libgmp3-dev, libicu-dev, libjpeg-dev | libjpeg62-dev, libkrb5-dev, libldap2-dev, liblmdb-dev, libmagic-dev, libmhash-dev (>= 0.8.8), libnss-myhostname [linux-any], libonig-dev, libpam0g-dev, libpcre2-dev (>= 10.30), libpng-dev, libpq-dev, libpspell-dev, libqdbm-dev, librecode-dev, libsasl2-dev, libsnmp-dev, libsodium-dev, libsqlite3-dev, libssl-dev, libsystemd-dev [linux-any], libtidy-dev (>= 1:5.2.0), libtool (>= 2.2), libwebp-dev, libwrap0-dev, libxml2-dev, libxmlrpc-epi-dev, libxslt1-dev (>= 1.0.18), libzip-dev (>= 1.0.0), locales-all | language-pack-de, netbase, netcat-openbsd, php-common, re2c, systemtap-sdt-dev, tzdata, unixodbc-dev, zlib1g-dev
Build-Conflicts: bind-dev, libxmlrpc-core-c3-dev
Package-List:
 libapache2-mod-php7.3 deb httpd optional arch=any
 libphp7.3-embed deb php optional arch=any
 php7.3 deb php optional arch=all
 php7.3-bcmath deb php optional arch=any
 php7.3-bz2 deb php optional arch=any
 php7.3-cgi deb php optional arch=any
 php7.3-cli deb php optional arch=any
 php7.3-common deb php optional arch=any
 php7.3-curl deb php optional arch=any
 php7.3-dba deb php optional arch=any
 php7.3-dev deb php optional arch=any
 php7.3-enchant deb php optional arch=any
 php7.3-fpm deb php optional arch=any
 php7.3-gd deb php optional arch=any
 php7.3-gmp deb php optional arch=any
 php7.3-imap deb php optional arch=any
 php7.3-interbase deb php optional arch=any
 php7.3-intl deb php optional arch=any
 php7.3-json deb php optional arch=any
 php7.3-ldap deb php optional arch=any
 php7.3-litespeed deb php optional arch=any
 php7.3-mbstring deb php optional arch=any
 php7.3-mysql deb php optional arch=any
 php7.3-odbc deb php optional arch=any
 php7.3-opcache deb php optional arch=any
 php7.3-pgsql deb php optional arch=any
 php7.3-phpdbg deb php optional arch=any
 php7.3-pspell deb php optional arch=any
 php7.3-readline deb php optional arch=any
 php7.3-recode deb php optional arch=any
 php7.3-snmp deb php optional arch=any
 php7.3-soap deb php optional arch=any
 php7.3-sqlite3 deb php optional arch=any
 php7.3-sybase deb php optional arch=any
 php7.3-tidy deb php optional arch=any
 php7.3-xml deb php optional arch=any
 php7.3-xmlrpc deb php optional arch=any
 php7.3-xsl deb php optional arch=all
 php7.3-zip deb php optional arch=any
Checksums-Sha1:
 d28e7e4bcfd2b4d344dde373064865fc63d7dbca 12143820 php7.3_7.3.33.orig.tar.xz
 f296ce4db528ecf3f76ccf7b0c4e3398d9de6fa0 850 php7.3_7.3.33.orig.tar.xz.asc
 b07ed03859813fc382f4e38b1fcd52e4b9ac2e5b 142892 php7.3_7.3.33-35+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Checksums-Sha256:
 166eaccde933381da9516a2b70ad0f447d7cec4b603d07b9a916032b215b90cc 12143820 php7.3_7.3.33.orig.tar.xz
 3d15cc09b4c35343ad15fd80b681f126a8efec8efde757e21c04fd54a56ba8d4 850 php7.3_7.3.33.orig.tar.xz.asc
 41cb0f371fe501a7c9c2f9ae9119f1467b45556fcc201bf33db3f49aa89f47aa 142892 php7.3_7.3.33-35+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Files:
 eeabb2140c04da85c86389197421f890 12143820 php7.3_7.3.33.orig.tar.xz
 cf49e6f80faff36d6e56fc75cbeb230e 850 php7.3_7.3.33.orig.tar.xz.asc
 7d19ffa21be5aff2bbc497f45d27bf08 142892 php7.3_7.3.33-35+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz

-----BEGIN PGP SIGNATURE-----

iQKTBAEBCgB9FiEEahqteuW0AcbiWaeyVwZ7qhMUx/wFAmrYyjJfFIAAAAAALgAo
aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDZB
MUFBRDdBRTVCNDAxQzZFMjU5QTdCMjU3MDY3QkFBMTMxNEM3RkMACgkQVwZ7qhMU
x/yRVA//XEiYb8jsmp9hyCE4eUhzp8B3jHpFNOEVVCGHDMfpAmqbeYXSTtEEarpC
6l+xy5R9Mk7J1s8e7fwc6XWsg+rad6oe2As29ohLJM4sA9c7f6uTycjvqW+DDhH8
dWPNsx43DWrcuz2R/73Gk3RkaI86C3YRqNtaklMPqrL3SspM5MA/R36GOymRJ9/B
P/+VjuNx4gi4zOxZELaDPc3BojsOCipzMjjGeTJMNtDrOkZ5EdRuSISHs+wDhEpH
TJXHrMqp0HpCPgF37wsBK6hls0skiMOu8mzoNfAeZKcfGX4vU09XgyqITxS0rOxi
w604JJCfRG07rbOG0+QGiqnc7kaGpmo8WgNv+UXA70BdmBco3EbXg3/iVH36gP6k
Bj8UqWJ0AJwoY3cik7ov1XbDHdDR2lduez5DQNgSYkbUYqPbNdZqRUjz6i94EgTn
9S48rqYgUm4xlEW1YYaU5LWdNInbimxgZmEdloC/NJRWp9zSUBWOTmJ4nGpwvFi6
UIeMoMsJMbCIRF0rdu90xrycEMvs8wEcGht0G5Tx41/xIXUws8ZC5viTshit5q+m
cBA9igwb7ar/NOkpSDnBgvvgwfbQvsHD5Eo6R1x4W/UTBPbor28grV3sRQVvydpi
Tu/80YxOh/O6YoLQfvrF7fpunCl6xqrUAzWDluMwITtLaPNOtzE=
=DisD
-----END PGP SIGNATURE-----
