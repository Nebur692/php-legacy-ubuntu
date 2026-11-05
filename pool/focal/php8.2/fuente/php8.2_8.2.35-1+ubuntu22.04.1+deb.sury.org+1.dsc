-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 3.0 (quilt)
Source: php8.2
Binary: libapache2-mod-php8.2, libphp8.2-embed, php8.2, php8.2-bcmath, php8.2-bz2, php8.2-cgi, php8.2-cli, php8.2-common, php8.2-curl, php8.2-dba, php8.2-dev, php8.2-enchant, php8.2-fpm, php8.2-gd, php8.2-gmp, php8.2-imap, php8.2-interbase, php8.2-intl, php8.2-ldap, php8.2-litespeed, php8.2-mbstring, php8.2-mysql, php8.2-odbc, php8.2-opcache, php8.2-pgsql, php8.2-phpdbg, php8.2-pspell, php8.2-readline, php8.2-snmp, php8.2-soap, php8.2-sqlite3, php8.2-sybase, php8.2-tidy, php8.2-xml, php8.2-xsl, php8.2-zip
Architecture: any all
Version: 8.2.35-1+ubuntu22.04.1+deb.sury.org+1
Maintainer: Debian PHP Maintainers <team+pkg-php@tracker.debian.org>
Uploaders: Ondřej Surý <ondrej@debian.org>, Lior Kaplan <kaplan@debian.org>
Homepage: http://www.php.net/
Standards-Version: 4.5.0.0
Vcs-Browser: https://salsa.debian.org/php-team/php/-/tree/debian/main/8.2
Vcs-Git: https://salsa.debian.org/php-team/php.git -b debian/main/8.2
Testsuite: autopkgtest
Testsuite-Triggers: apache2, wget
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
 550876878da81875fea950ee84d7f7c28ea27363 12216408 php8.2_8.2.35.orig.tar.xz
 13b6d5cb534632ec9e8451d16bedf0690ab0ae4a 78060 php8.2_8.2.35-1+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Checksums-Sha256:
 5737b98601fe5ab1b8c5db0c82ed3158acb9283ed3081ffe2faffb9ac81455e6 12216408 php8.2_8.2.35.orig.tar.xz
 21e2a07d76053b42eab2fcc2ab729e9e697249a43cd673e7bf4eb471f8a87257 78060 php8.2_8.2.35-1+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz
Files:
 cc0eb90f075ce2a7444db390c5edb696 12216408 php8.2_8.2.35.orig.tar.xz
 2ce78d388455c733360132dd75dc707f 78060 php8.2_8.2.35-1+ubuntu22.04.1+deb.sury.org+1.debian.tar.xz

-----BEGIN PGP SIGNATURE-----

iQKTBAEBCgB9FiEEahqteuW0AcbiWaeyVwZ7qhMUx/wFAmrYzHBfFIAAAAAALgAo
aXNzdWVyLWZwckBub3RhdGlvbnMub3BlbnBncC5maWZ0aGhvcnNlbWFuLm5ldDZB
MUFBRDdBRTVCNDAxQzZFMjU5QTdCMjU3MDY3QkFBMTMxNEM3RkMACgkQVwZ7qhMU
x/xsmA/+MggI7kznnEFsVbUpT2m9v/LmMsLZv+gPdMI62XMIqcQQSKuCqAI4+lCz
S1sNRWO1tP5jcyRHRGZlu5zSJlLGaYP21XqKpE0yvmEouE8oY/89FJMYscqwP0JZ
a0ApJ+RvYvfPz4Jzyb+iB7MpT56OR5vl390MJblJuPzmtIhkFHQqSCIZY9lLkdg+
aKV/ak6ocoIO0dqngpGOEr3He9CLx4kmnA/k79i2iWDeyAUUiguTNTtL4kU+6sYM
DEQyhGdvzmUs9MMnEd/ZPXMnmumFSD/SURvmyvF+grn208FdsDdXxvilZ9dgoS4D
k/cz7VjySS9i8pFEK1VDiLeNIK+RlzA37O3rEyI+F5jps2Kf/MN+MsNyaPl6rGUC
dKdjmboxeGDkUdIPnpxWQT27yK+thgtasi5WNy6+yhbYd0qK93NHhNzWCQaNeAoH
0pfOxIekwdqC6vrcUn1bwdZhfHRxdj7izTGhmfyBWpByfkUeNh5iLujwKNheNUY+
wNyV6y0Byah/B81vSLOl5B67JDHTK5RBqbeHYZ6XxGfJG0XVy5YbAUIk4NcRhcmv
IkqpXt1USuRSIYMZU6mgm5w6/LZn2EOevCZAKRj72WEtyiGV1vgKIT/JxiFh7uVi
ROascLuJ+eyVX/T0ISBgdn9pRcMoFCsHseC5h7L7M5WSD7Mbk4g=
=mbop
-----END PGP SIGNATURE-----
