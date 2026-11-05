-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: php7.1
Binary: libapache2-mod-php7.1, libphp7.1-embed, php7.1, php7.1-bcmath, php7.1-bz2, php7.1-cgi, php7.1-cli, php7.1-common, php7.1-curl, php7.1-dba, php7.1-dev, php7.1-enchant, php7.1-fpm, php7.1-gd, php7.1-gmp, php7.1-imap, php7.1-interbase, php7.1-intl, php7.1-json, php7.1-ldap, php7.1-litespeed, php7.1-mbstring, php7.1-mcrypt, php7.1-mysql, php7.1-odbc, php7.1-opcache, php7.1-pgsql, php7.1-phpdbg, php7.1-pspell, php7.1-readline, php7.1-recode, php7.1-snmp, php7.1-soap, php7.1-sqlite3, php7.1-sybase, php7.1-tidy, php7.1-xml, php7.1-xmlrpc, php7.1-xsl, php7.1-zip
Architecture: any all
Version: 7.1.33-80+ubuntu22.04.1+deb.sury.org+1
Maintainer: Debian PHP Maintainers <team+pkg-php@tracker.debian.org>
Uploaders: Ondřej Surý <ondrej@debian.org>, Lior Kaplan <kaplan@debian.org>
Homepage: http://www.php.net/
Standards-Version: 4.5.0.0
Vcs-Browser: https://salsa.debian.org/php-team/php/-/tree/debian/main/7.1
Vcs-Git: https://salsa.debian.org/php-team/php.git -b debian/main/7.1
Testsuite: autopkgtest
Testsuite-Triggers: apache2, wget
Build-Depends: debhelper (>= 9.20160709~), dh-apache2, dpkg-dev (>= 1.16.1~), apache2-bin (>= 2.4), apache2-dev (>= 2.4), autoconf (>= 2.63), automake, bison, chrpath, default-libmysqlclient-dev | libmysqlclient-dev, firebird-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.5-dev [!hurd-any !m68k !hppa !ppc64] | firebird2.1-dev [!hurd-any !m68k !hppa !ppc64], flex, freetds-dev, libacl1-dev, libapparmor-dev [linux-any], libapr1-dev (>= 1.2.7-8), libbz2-dev, libc-client-dev, libcurl4-openssl-dev | libcurl-dev, libdb-dev, libedit-dev (>= 2.11-20080614-4), libenchant-2-dev | libenchant-dev, libevent-dev (>= 1.4.11), libexpat1-dev (>= 1.95.2-2.1), libfreetype6-dev, libgcrypt20-dev (>> 1.6.3) | libgcrypt11-dev (<< 1.5.4), libgd-dev (>= 2.1.0) | libgd2-dev, libglib2.0-dev, libgmp3-dev, libicu-dev, libjpeg-dev | libjpeg62-dev, libkrb5-dev, libldap2-dev, libmagic-dev, libmcrypt-dev, libmhash-dev (>= 0.8.8), libnss-myhostname [linux-any], libonig-dev, libpam0g-dev, libpcre3-dev (>= 2:8.35), libpng-dev, libpq-dev, libpspell-dev, libqdbm-dev, librecode-dev, libsasl2-dev, libsnmp-dev, libsodium-dev, libsqlite3-dev, libssl-dev, libsystemd-dev [linux-any], libtidy-dev (>= 1:5.2.0), libtool (>= 2.2), libwebp-dev, libwrap0-dev, libxml2-dev, libxmlrpc-epi-dev, libxslt1-dev (>= 1.0.18), libzip-dev (>= 1.0.0), locales-all | language-pack-de, netbase, netcat-openbsd, php-common, re2c, systemtap-sdt-dev, tzdata, unixodbc-dev, zlib1g-dev
Build-Conflicts: bind-dev, libxmlrpc-core-c3-dev
Package-List:
 libapache2-mod-php7.1 deb httpd optional arch=any
 libphp7.1-embed deb php optional arch=any
 php7.1 deb php optional arch=all
 php7.1-bcmath deb php optional arch=any
 php7.1-bz2 deb php optional arch=any
 php7.1-cgi deb php optional arch=any
 php7.1-cli deb php optional arch=any
 php7.1-common deb php optional arch=any
 php7.1-curl deb php optional arch=any
 php7.1-dba deb php optional arch=any
 php7.1-dev deb php optional arch=any
 php7.1-enchant deb php optional arch=any
 php7.1-fpm deb php optional arch=any
 php7.1-gd deb php optional arch=any
 php7.1-gmp deb php optional arch=any
 php7.1-imap deb php optional arch=any
 php7.1-interbase deb php optional arch=any
 php7.1-intl deb php optional arch=any
 php7.1-json deb php optional arch=any
 php7.1-ldap deb php optional arch=any
 php7.1-litespeed deb php optional arch=any
 php7.1-mbstring deb php optional arch=any
 php7.1-mcrypt deb php optional arch=any
 php7.1-mysql deb php optional arch=any
 php7.1-odbc deb php optional arch=any
 php7.1-opcache deb php optional arch=any
 php7.1-pgsql deb php optional arch=any
 php7.1-phpdbg deb php optional arch=any
 php7.1-pspell deb php optional arch=any
 php7.1-readline deb php optional arch=any
 php7.1-recode deb php optional arch=any
 php7.1-snmp deb php optional arch=any
 php7.1-soap deb php optional arch=any
 php7.1-sqlite3 deb php optional arch=any
 php7.1-sybase deb php optional arch=any
 php7.1-tidy deb php optional arch=any
 php7.1-xml deb php optional arch=any
 php7.1-xmlrpc deb php optional arch=any
 php7.1-xsl deb php optional arch=all
 php7.1-zip deb php optional arch=any
Checksums-Sha1:
 fbcc9ab926f793e1031864c7c268ba7bfd244d70 12370228 php7.1_7.1.33.orig.tar.xz
 ac0ba46e77bcb29873d0e280595a30d7523e5f19 164976 php7.1_7.1.33-80+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Checksums-Sha256:
 bd7c0a9bd5433289ee01fd440af3715309faf583f75832b64fe169c100d52968 12370228 php7.1_7.1.33.orig.tar.xz
 0d5a59c0102a1042a6dcdd62f0799085ef502b4e4d4af29bf9402747fa6cee82 164976 php7.1_7.1.33-80+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Files:
 b27bb5ce72995bc0ea56276e156be889 12370228 php7.1_7.1.33.orig.tar.xz
 bec8daea0dd7c6b8c0b68352ac411379 164976 php7.1_7.1.33-80+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz

-----BEGIN PGP SIGNATURE-----

iQKTBAEBCgB9FiEEahqteuW0AcbiWaeyVwZ7qhMUx/wFAmrYySNfFIAAAAAALgAo
aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDZB
MUFBRDdBRTVCNDAxQzZFMjU5QTdCMjU3MDY3QkFBMTMxNEM3RkMACgkQVwZ7qhMU
x/wNZw//f4fT7Vgf5B2NgXxLGNBbSBZGY4vNcF8MJxyTXW10LdWW/A0zjTwCoGWc
cnPnrmpeiSm3sA5G09wMapy28M07mSAWF+UshqMxtq8a67rZiTedL/fX3cfAEBGd
gKiLdo7p/b3tjyjscBf22iwe8V++C26BXZ+YUSeI0PzhA5L1DO+O+1fdTmtnUEZl
vqx+9h3yUHseqD4Jqw6LASfQY3ykBdZm4enF2bkD2QtvZTqJRmd/1ux+i2w2sAwS
eAbe/7Ir+aqZGaBS7nxnvAjf5h4W0Jh4AHkQO3sCEglZ+G2ER8i+ULGQ4u4ubRgQ
XQ54JUS96YlHaVdJQHt96FcmlCCQfaJajsA1HanDl0sN2FVymQ+smpRjN3wzrrWh
jCorKtXz7bVe99CdEWfmWsjYf7uCtYAVmPBMDTALKum6s6+suJ/ABwF/Kt0pMnCv
rZNdej5MZOyKd92qtbWgi07WJF/i/SR1lDe8zYxydODnvcsSS0BeJlRhHbaasqyC
JcU6W5cCuMcn3v3XZQAi47L1+pLVSJp62Sy01ItvIBiHUqyKYj1Iy+d59cmIGj54
LxU/xd2Nm5oB4AU486t4SNKl90Bv0TAfRof0MWA/Y/RYGfwkcrDfFi1Ox34QsMVm
X4BqqxhG+TDLUtqext3lXsOO4zXXPsV+pd2LXbXXH0DD0aRdCBM=
=cWdO
-----END PGP SIGNATURE-----
