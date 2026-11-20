-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: php7.2
Binary: libapache2-mod-php7.2, libphp7.2-embed, php7.2, php7.2-cgi, php7.2-cli, php7.2-dev, php7.2-fpm, php7.2-litespeed, php7.2-phpdbg, php7.2-xsl, php7.2-bcmath, php7.2-bz2, php7.2-common, php7.2-curl, php7.2-dba, php7.2-enchant, php7.2-gd, php7.2-gmp, php7.2-imap, php7.2-interbase, php7.2-intl, php7.2-json, php7.2-ldap, php7.2-mbstring, php7.2-mysql, php7.2-odbc, php7.2-pgsql, php7.2-pspell, php7.2-readline, php7.2-recode, php7.2-snmp, php7.2-soap, php7.2-sqlite3, php7.2-sybase, php7.2-tidy, php7.2-xml, php7.2-xmlrpc, php7.2-zip, php7.2-opcache
Architecture: any all
Version: 7.2.34-70+ubuntu22.04.1+deb.sury.org+1
Maintainer: Debian PHP Maintainers <team+pkg-php@tracker.debian.org>
Uploaders: Ondřej Surý <ondrej@debian.org>, Lior Kaplan <kaplan@debian.org>
Homepage: http://www.php.net/
Standards-Version: 4.5.0.0
Vcs-Browser: https://salsa.debian.org/php-team/php/-/tree/debian/main/7.2
Vcs-Git: https://salsa.debian.org/php-team/php.git -b debian/main/7.2
Testsuite: autopkgtest
Testsuite-Triggers: apache2, base-files, language-pack-de, locales-all, netbase, openssl, tzdata-legacy, wget
Build-Depends: debhelper (>= 9.20160709~), dh-apache2, dpkg-dev (>= 1.16.1~), apache2-bin (>= 2.4), apache2-dev (>= 2.4), autoconf (>= 2.63), automake, bison, chrpath, default-libmysqlclient-dev | libmysqlclient-dev, firebird-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.5-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.1-dev [!hurd-any !m68k !hppa !ppc64], flex, freetds-dev, libacl1-dev, libapparmor-dev [linux-any], libapr1-dev (>= 1.2.7-8), libargon2-dev | libargon2-0-dev, libbz2-dev, libc-client-dev, libcurl4-openssl-dev | libcurl-dev, libdb-dev, libedit-dev (>= 2.11-20080614-4), libenchant-2-dev | libenchant-dev, libevent-dev (>= 1.4.11), libexpat1-dev (>= 1.95.2-2.1), libfreetype6-dev, libgcrypt20-dev (>> 1.6.3) | libgcrypt11-dev (<< 1.5.4), libgd-dev (>= 2.1.0) | libgd2-dev, libglib2.0-dev, libgmp3-dev, libicu-dev, libjpeg-dev | libjpeg62-dev, libkrb5-dev, libldap2-dev, liblmdb-dev, libmagic-dev, libmhash-dev (>= 0.8.8), libnss-myhostname [linux-any], libonig-dev, libpam0g-dev, libpcre3-dev (>= 2:8.35), libpng-dev, libpq-dev, libpspell-dev, libqdbm-dev, librecode-dev, libsasl2-dev, libsnmp-dev, libsodium-dev, libsqlite3-dev, libssl-dev, libsystemd-dev [linux-any], libtidy-dev (>= 1:5.2.0), libtool (>= 2.2), libwebp-dev, libwrap0-dev, libxml2-dev, libxmlrpc-epi-dev, libxslt1-dev (>= 1.0.18), libzip-dev (>= 1.0.0), locales-all | language-pack-de, netbase, netcat-openbsd, php-common, re2c, systemtap-sdt-dev, tzdata, unixodbc-dev, zlib1g-dev
Build-Conflicts: bind-dev, libxmlrpc-core-c3-dev
Package-List:
 libapache2-mod-php7.2 deb httpd optional arch=any
 libphp7.2-embed deb php optional arch=any
 php7.2 deb php optional arch=all
 php7.2-bcmath deb php optional arch=any
 php7.2-bz2 deb php optional arch=any
 php7.2-cgi deb php optional arch=any
 php7.2-cli deb php optional arch=any
 php7.2-common deb php optional arch=any
 php7.2-curl deb php optional arch=any
 php7.2-dba deb php optional arch=any
 php7.2-dev deb php optional arch=any
 php7.2-enchant deb php optional arch=any
 php7.2-fpm deb php optional arch=any
 php7.2-gd deb php optional arch=any
 php7.2-gmp deb php optional arch=any
 php7.2-imap deb php optional arch=any
 php7.2-interbase deb php optional arch=any
 php7.2-intl deb php optional arch=any
 php7.2-json deb php optional arch=any
 php7.2-ldap deb php optional arch=any
 php7.2-litespeed deb php optional arch=any
 php7.2-mbstring deb php optional arch=any
 php7.2-mysql deb php optional arch=any
 php7.2-odbc deb php optional arch=any
 php7.2-opcache deb php optional arch=any
 php7.2-pgsql deb php optional arch=any
 php7.2-phpdbg deb php optional arch=any
 php7.2-pspell deb php optional arch=any
 php7.2-readline deb php optional arch=any
 php7.2-recode deb php optional arch=any
 php7.2-snmp deb php optional arch=any
 php7.2-soap deb php optional arch=any
 php7.2-sqlite3 deb php optional arch=any
 php7.2-sybase deb php optional arch=any
 php7.2-tidy deb php optional arch=any
 php7.2-xml deb php optional arch=any
 php7.2-xmlrpc deb php optional arch=any
 php7.2-xsl deb php optional arch=all
 php7.2-zip deb php optional arch=any
Checksums-Sha1:
 3dfe7bbed49e53f6ff76ca0b8c9162f78b1cc679 12309432 php7.2_7.2.34.orig.tar.xz
 bb32292e5220135ca5cb3c8c8c9bfbbdaa44bccf 306140 php7.2_7.2.34-70+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Checksums-Sha256:
 409e11bc6a2c18707dfc44bc61c820ddfd81e17481470f3405ee7822d8379903 12309432 php7.2_7.2.34.orig.tar.xz
 273d3880be725ba4ceb0b0a17dc74c0fbd5340a28f7accba5d83681f9455ca69 306140 php7.2_7.2.34-70+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Files:
 adb64072b9b7e4634844a72512239a34 12309432 php7.2_7.2.34.orig.tar.xz
 b56c285b0bfc35d92b15000dee7b67a9 306140 php7.2_7.2.34-70+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz

-----BEGIN PGP SIGNATURE-----

iQKTBAEBCgB9FiEEahqteuW0AcbiWaeyVwZ7qhMUx/wFAmr/VNhfFIAAAAAALgAo
aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDZB
MUFBRDdBRTVCNDAxQzZFMjU5QTdCMjU3MDY3QkFBMTMxNEM3RkMACgkQVwZ7qhMU
x/wheg//an4ZfH0nbkApkBbZfxp2fMNV/qD2Jub0nLY66bp1CTTFfyUWFGhvOAn3
/lPK9U59IUNSYDi15oBit88GxPsj/mG5RnEMXvtp2JOyoMUh3Ev2Dv8NFtGeeWAn
jTLJqGBDO+rs3Uxp3k7kCKgWadEeN+JAqgLTkdZ9pY1hOW0Ja5+kk1rLWC0qwbGy
kLqKFVkmoB5hnGTs/In+BoKLDWSOG7w/Cei4N23T2OAPy/0M7aynW0tqfxjxnI/R
bzk6ImWTJHE5KjLimnQGXI5DNEUJ5wTbZVi2aG47fZ9jOixsRJfK/TvqhFJ9iGnL
nAB4JkSUks1lr6Ftfr1FAKfaLlOIL/ZY3ZLhhOGA1BUnEpXLzN88R2SPx5RN7pgE
1l882qnmxuL45coeHrR60xJAFUF8qb+g+XvSdTmVHH4Yi44VbQdxLZJHjxVXLVb1
HQZBn49a15IjPfTk2pmKZGu5d0Uurbv8LkvKkDS967EHpXAzKhNhrE+W4rLUoV1X
djBzrU0BqTC9ALqJ8Zglui+9HtGEtkTH4hrY/DqqjIANzzqTyV5KX8vD6eHAm/Qg
jYCnh+yOQBjkrV2DJUUCbjGd/PSGJ9l/JY2p1csNCreBevIkiI+cJv4mPD2pIYId
La6nj9oj5cLRftzCVufdLBs452iFLDwSLbmUg7j+lSzckIwYQ/c=
=vvgR
-----END PGP SIGNATURE-----
