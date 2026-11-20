-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: php7.0
Binary: libapache2-mod-php7.0, libphp7.0-embed, php7.0, php7.0-cgi, php7.0-cli, php7.0-dev, php7.0-fpm, php7.0-litespeed, php7.0-phpdbg, php7.0-xsl, php7.0-bcmath, php7.0-bz2, php7.0-common, php7.0-curl, php7.0-dba, php7.0-enchant, php7.0-gd, php7.0-gmp, php7.0-imap, php7.0-interbase, php7.0-intl, php7.0-json, php7.0-ldap, php7.0-mbstring, php7.0-mcrypt, php7.0-mysql, php7.0-odbc, php7.0-pgsql, php7.0-pspell, php7.0-readline, php7.0-recode, php7.0-snmp, php7.0-soap, php7.0-sqlite3, php7.0-sybase, php7.0-tidy, php7.0-xml, php7.0-xmlrpc, php7.0-zip, php7.0-opcache
Architecture: any all
Version: 7.0.33-97+ubuntu22.04.1+deb.sury.org+1
Maintainer: Debian PHP Maintainers <team+pkg-php@tracker.debian.org>
Uploaders: Ondřej Surý <ondrej@debian.org>, Lior Kaplan <kaplan@debian.org>
Homepage: http://www.php.net/
Standards-Version: 4.5.0.0
Vcs-Browser: https://salsa.debian.org/php-team/php/-/tree/debian/main/7.0
Vcs-Git: https://salsa.debian.org/php-team/php.git -b debian/main/7.0
Testsuite: autopkgtest
Testsuite-Triggers: apache2, base-files, language-pack-de, locales-all, netbase, openssl, tzdata-legacy, wget
Build-Depends: debhelper (>= 9.20160709~), dh-apache2, dpkg-dev (>= 1.16.1~), apache2-bin (>= 2.4), apache2-dev (>= 2.4), autoconf (>= 2.63), automake, bison, chrpath, default-libmysqlclient-dev | libmysqlclient-dev, firebird-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.5-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.1-dev [!hurd-any !m68k !hppa !ppc64], flex, freetds-dev, libacl1-dev, libapparmor-dev [linux-any], libapr1-dev (>= 1.2.7-8), libbz2-dev, libc-client-dev, libcurl4-openssl-dev | libcurl-dev, libdb-dev, libedit-dev (>= 2.11-20080614-4), libenchant-2-dev | libenchant-dev, libevent-dev (>= 1.4.11), libexpat1-dev (>= 1.95.2-2.1), libfreetype6-dev, libgcrypt20-dev (>> 1.6.3) | libgcrypt11-dev (<< 1.5.4), libgd-dev (>= 2.1.0) | libgd2-dev, libglib2.0-dev, libgmp3-dev, libicu-dev, libjpeg-dev | libjpeg62-dev, libkrb5-dev, libldap2-dev, libmagic-dev, libmcrypt-dev, libmhash-dev (>= 0.8.8), libnss-myhostname [linux-any], libonig-dev, libpam0g-dev, libpcre3-dev (>= 2:8.35), libpng-dev, libpq-dev, libpspell-dev, libqdbm-dev, librecode-dev, libsasl2-dev, libsnmp-dev, libsodium-dev, libsqlite3-dev, libssl-dev, libsystemd-dev [linux-any], libtidy-dev (>= 1:5.2.0), libtool (>= 2.2), libwebp-dev, libwrap0-dev, libxml2-dev, libxmlrpc-epi-dev, libxslt1-dev (>= 1.0.18), libzip-dev (>= 1.0.0), locales-all | language-pack-de, netbase, netcat-openbsd, php-common, re2c, systemtap-sdt-dev, tzdata, unixodbc-dev, zlib1g-dev
Build-Conflicts: bind-dev, libxmlrpc-core-c3-dev
Package-List:
 libapache2-mod-php7.0 deb httpd optional arch=any
 libphp7.0-embed deb php optional arch=any
 php7.0 deb php optional arch=all
 php7.0-bcmath deb php optional arch=any
 php7.0-bz2 deb php optional arch=any
 php7.0-cgi deb php optional arch=any
 php7.0-cli deb php optional arch=any
 php7.0-common deb php optional arch=any
 php7.0-curl deb php optional arch=any
 php7.0-dba deb php optional arch=any
 php7.0-dev deb php optional arch=any
 php7.0-enchant deb php optional arch=any
 php7.0-fpm deb php optional arch=any
 php7.0-gd deb php optional arch=any
 php7.0-gmp deb php optional arch=any
 php7.0-imap deb php optional arch=any
 php7.0-interbase deb php optional arch=any
 php7.0-intl deb php optional arch=any
 php7.0-json deb php optional arch=any
 php7.0-ldap deb php optional arch=any
 php7.0-litespeed deb php optional arch=any
 php7.0-mbstring deb php optional arch=any
 php7.0-mcrypt deb php optional arch=any
 php7.0-mysql deb php optional arch=any
 php7.0-odbc deb php optional arch=any
 php7.0-opcache deb php optional arch=any
 php7.0-pgsql deb php optional arch=any
 php7.0-phpdbg deb php optional arch=any
 php7.0-pspell deb php optional arch=any
 php7.0-readline deb php optional arch=any
 php7.0-recode deb php optional arch=any
 php7.0-snmp deb php optional arch=any
 php7.0-soap deb php optional arch=any
 php7.0-sqlite3 deb php optional arch=any
 php7.0-sybase deb php optional arch=any
 php7.0-tidy deb php optional arch=any
 php7.0-xml deb php optional arch=any
 php7.0-xmlrpc deb php optional arch=any
 php7.0-xsl deb php optional arch=all
 php7.0-zip deb php optional arch=any
Checksums-Sha1:
 fef2bfd1285325a4ac2c367fab6a9062c144a790 12033040 php7.0_7.0.33.orig.tar.xz
 5f8b411df5951ec2765c32eab30121b2926aae36 1051764 php7.0_7.0.33-97+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Checksums-Sha256:
 ab8c5be6e32b1f8d032909dedaaaa4bbb1a209e519abb01a52ce3914f9a13d96 12033040 php7.0_7.0.33.orig.tar.xz
 487920a62d2c936ca2b197198c985c6e8647580c7ed2aaeabdd5d08bea91ce54 1051764 php7.0_7.0.33-97+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Files:
 a6d7c355d023301a1a9ec8b4f32a4856 12033040 php7.0_7.0.33.orig.tar.xz
 d3ab95b2606ad424c93c16f7c01fc018 1051764 php7.0_7.0.33-97+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz

-----BEGIN PGP SIGNATURE-----

iQKTBAEBCgB9FiEEahqteuW0AcbiWaeyVwZ7qhMUx/wFAmr/VH1fFIAAAAAALgAo
aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDZB
MUFBRDdBRTVCNDAxQzZFMjU5QTdCMjU3MDY3QkFBMTMxNEM3RkMACgkQVwZ7qhMU
x/wCFQ//Zm6aVRtZ+xEFjENDTfBFgtlorqj5tzZIGFGcctdOu6uAPQHaV5XN3az/
BT5sGokRq6VwQ6VsPRYyOzP3RDBWYr5XG4Ow2ptdSgiFxX8uqt8FBR5/ijAXAF97
vZiSK0Hz1D7iC7tLtWwgVnCQxXnkMxo2N7R5iTiuGZ+VUbU8BvQfMFHbUgAqqhJy
5TktCoJfGU9B2vE7C8Ky9I4jG3qbQ0mA8NH7++FuyJb9vFvCXrKL0U3+RMqhSWPp
unbZwBpGCnXxmCYU8wOl5SAleMXmMJCovZopHlruY4uAinXk0eJTvLR8XhW3ndjf
j9ZxEM3B80KbLWC8QLboVvI7C7TSVEvA4LX5YLkulkxvJJ6Fy8gRXs2Ag4lMBVia
tG+JmzB+FV1m2q9mtPof+1unN6kcFUE6bGiuaOvIjBoU4o/KBJBmlc1y3QOFGc1P
RJA5hVmPyVHv6ojg0Pr/FVyDyuEmjwSjnh4dmn35T71tbCJcxk6JVkVUBS0ZrI1c
u6nJez/oIj+BUUa7FSn9BTd/n1jVXfXRnbd5xcM4wNE0cvUCRx0KWHkl9gv+vjCv
BbM55jurWgZ+cpXrXdp8bWbwAzjMPiGZtQVK1MmDK0mzppRGLkqZDWEujh8JXQAJ
yKYjW64jr7AtmWy/oZV8KGaxuK4ELm8Ag2Eco6v+25CG3V6/pg4=
=7VSw
-----END PGP SIGNATURE-----
