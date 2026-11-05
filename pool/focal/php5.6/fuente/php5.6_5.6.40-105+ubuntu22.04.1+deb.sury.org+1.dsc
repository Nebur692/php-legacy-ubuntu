-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: php5.6
Binary: libapache2-mod-php5.6, libphp5.6-embed, php5.6, php5.6-bcmath, php5.6-bz2, php5.6-cgi, php5.6-cli, php5.6-common, php5.6-curl, php5.6-dba, php5.6-dev, php5.6-enchant, php5.6-fpm, php5.6-gd, php5.6-gmp, php5.6-imap, php5.6-interbase, php5.6-intl, php5.6-json, php5.6-ldap, php5.6-litespeed, php5.6-mbstring, php5.6-mcrypt, php5.6-mysql, php5.6-odbc, php5.6-opcache, php5.6-pgsql, php5.6-phpdbg, php5.6-pspell, php5.6-readline, php5.6-recode, php5.6-snmp, php5.6-soap, php5.6-sqlite3, php5.6-sybase, php5.6-tidy, php5.6-xml, php5.6-xmlrpc, php5.6-xsl, php5.6-zip
Architecture: any all
Version: 5.6.40-105+ubuntu22.04.1+deb.sury.org+1
Maintainer: Debian PHP Maintainers <team+pkg-php@tracker.debian.org>
Uploaders: Ondřej Surý <ondrej@debian.org>, Lior Kaplan <kaplan@debian.org>
Homepage: http://www.php.net/
Standards-Version: 4.5.0.0
Vcs-Browser: https://salsa.debian.org/php-team/php/-/tree/debian/main/5.6
Vcs-Git: https://salsa.debian.org/php-team/php.git -b debian/main/5.6
Testsuite: autopkgtest
Testsuite-Triggers: apache2, wget
Build-Depends: debhelper (>= 9.20160709~), dh-apache2, dpkg-dev (>= 1.16.1~), apache2-bin (>= 2.4), apache2-dev (>= 2.4), autoconf (>= 2.63), automake, bison, chrpath, default-libmysqlclient-dev | libmysqlclient-dev, firebird-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.5-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.1-dev [!hurd-any !m68k !hppa !ppc64], flex, freetds-dev, libacl1-dev, libapparmor-dev [linux-any], libapr1-dev (>= 1.2.7-8), libbz2-dev, libc-client-dev, libcurl4-openssl-dev | libcurl-dev, libdb-dev, libedit-dev (>= 2.11-20080614-4), libenchant-2-dev | libenchant-dev, libevent-dev (>= 1.4.11), libexpat1-dev (>= 1.95.2-2.1), libfreetype6-dev, libgcrypt20-dev (>> 1.6.3) | libgcrypt11-dev (<< 1.5.4), libgd-dev (>= 2.1.0) | libgd2-dev, libglib2.0-dev, libgmp3-dev, libicu-dev, libjpeg-dev | libjpeg62-dev, libkrb5-dev, libldap2-dev, libmagic-dev, libmcrypt-dev, libmhash-dev (>= 0.8.8), libnss-myhostname [linux-any], libonig-dev, libpam0g-dev, libpcre3-dev (>= 2:8.35), libpng-dev, libpq-dev, libpspell-dev, libqdbm-dev, librecode-dev, libsasl2-dev, libsnmp-dev, libsodium-dev, libsqlite3-dev, libssl-dev, libsystemd-dev [linux-any], libtidy-dev (>= 1:5.2.0), libtool (>= 2.2), libwebp-dev, libwrap0-dev, libxml2-dev, libxmlrpc-epi-dev, libxslt1-dev (>= 1.0.18), libzip-dev (>= 1.0.0), locales-all | language-pack-de, netbase, netcat-openbsd, php-common, re2c, systemtap-sdt-dev, tzdata, unixodbc-dev, zlib1g-dev
Build-Conflicts: bind-dev, libxmlrpc-core-c3-dev
Package-List:
 libapache2-mod-php5.6 deb httpd optional arch=any
 libphp5.6-embed deb php optional arch=any
 php5.6 deb php optional arch=all
 php5.6-bcmath deb php optional arch=any
 php5.6-bz2 deb php optional arch=any
 php5.6-cgi deb php optional arch=any
 php5.6-cli deb php optional arch=any
 php5.6-common deb php optional arch=any
 php5.6-curl deb php optional arch=any
 php5.6-dba deb php optional arch=any
 php5.6-dev deb php optional arch=any
 php5.6-enchant deb php optional arch=any
 php5.6-fpm deb php optional arch=any
 php5.6-gd deb php optional arch=any
 php5.6-gmp deb php optional arch=any
 php5.6-imap deb php optional arch=any
 php5.6-interbase deb php optional arch=any
 php5.6-intl deb php optional arch=any
 php5.6-json deb php optional arch=any
 php5.6-ldap deb php optional arch=any
 php5.6-litespeed deb php optional arch=any
 php5.6-mbstring deb php optional arch=any
 php5.6-mcrypt deb php optional arch=any
 php5.6-mysql deb php optional arch=any
 php5.6-odbc deb php optional arch=any
 php5.6-opcache deb php optional arch=any
 php5.6-pgsql deb php optional arch=any
 php5.6-phpdbg deb php optional arch=any
 php5.6-pspell deb php optional arch=any
 php5.6-readline deb php optional arch=any
 php5.6-recode deb php optional arch=any
 php5.6-snmp deb php optional arch=any
 php5.6-soap deb php optional arch=any
 php5.6-sqlite3 deb php optional arch=any
 php5.6-sybase deb php optional arch=any
 php5.6-tidy deb php optional arch=any
 php5.6-xml deb php optional arch=any
 php5.6-xmlrpc deb php optional arch=any
 php5.6-xsl deb php optional arch=all
 php5.6-zip deb php optional arch=any
Checksums-Sha1:
 0403ae06273fe8c1acdbd45b181a8a53f4b0b4d7 12472236 php5.6_5.6.40.orig.tar.xz
 ea5797982400dc033bf2c9e6091d790adbde63aa 1297056 php5.6_5.6.40-105+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Checksums-Sha256:
 1369a51eee3995d7fbd1c5342e5cc917760e276d561595b6052b21ace2656d1c 12472236 php5.6_5.6.40.orig.tar.xz
 e5932885bf735540f2e7a2b1a3523e4cfba172189fa512f6dc55efd005e9cbfe 1297056 php5.6_5.6.40-105+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Files:
 c7dde3afb16ce7b761abf2805125d372 12472236 php5.6_5.6.40.orig.tar.xz
 8361f22b2554e482ff1dc1ad3d2f70c8 1297056 php5.6_5.6.40-105+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz

-----BEGIN PGP SIGNATURE-----

iQKTBAEBCgB9FiEEahqteuW0AcbiWaeyVwZ7qhMUx/wFAmraCKBfFIAAAAAALgAo
aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDZB
MUFBRDdBRTVCNDAxQzZFMjU5QTdCMjU3MDY3QkFBMTMxNEM3RkMACgkQVwZ7qhMU
x/y/sxAAwyps4AhoKEwnA9wPqmXYV3Vfrj5QJF/gOGnr/MZa4BIS88N3qnH/0Erx
LkyJ+ssv8N4436jdUadZGDFj47SwYzal7Hg4jbnDnf9BVAtI3cOI3/0FFG2oFQGd
0mbmNUaF50G36nYorH0swDVEicqZJbeZIY09Lf6fnshIeqsu1yZACQRCH09eS2M/
07Knk4QCM/xrseP2oFuMCrPseRuLdhQmN655+QqIrYyNsjdecbPSA4JSHX4D2HB/
G5big8TrAuiAu1vUMB52eCANcUm/Y3SUvHyX3LadSOaUXQrsuMRRewkK5+UhL0Kj
qXYzC4B43LOWcRyw7RfD0c9zDxu3/TsWMmmbXLZF2bI7SuCcrnrO3dMosRfOlh+q
CMNrln+k03iPjCTYW8VjiChg4av62hSc3OCdVitluGB29GeANec8T6YoUAUquQMS
YzvkHinijj1EFN9EaGxBKzKF8RksRoA8m+wASSE2iehtdIyTsbjn11sqosmVCQUK
5rZBbqlfayy4jAeP6PzZ7EpOfdOMp6OgII+P1ZcpKYW32z58qXR9+3DDB61E/+iY
HVvnv7NXHBFbjuu+1glDD9NLolcu7BkTLi0oYisxqcLzw6JsKSfOeELiOe/DnzDc
QYvwtz8Gx2G+cf/hRgf6q5+b2K8thCVzGpDCKNckNm2L5teNeNI=
=gS5w
-----END PGP SIGNATURE-----
