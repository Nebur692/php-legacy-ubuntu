Format: 3.0 (quilt)
Source: libgd2
Binary: libgd-tools, libgd-dev, libgd3
Architecture: any
Version: 2.2.5-5.2ubuntu2.4+local1
Maintainer: Ubuntu Developers <ubuntu-devel-discuss@lists.ubuntu.com>
Uploaders: Ondřej Surý <ondrej@debian.org>
Homepage: http://www.libgd.org/
Standards-Version: 3.9.3
Vcs-Browser: https://salsa.debian.org/debian/libgd2
Vcs-Git: https://salsa.debian.org/debian/libgd2.git
Testsuite: autopkgtest
Testsuite-Triggers: @builddeps@, file, libtool-bin, valgrind
Build-Depends: autotools-dev, debhelper (>= 9), libpng-dev, libz-dev, libjpeg-dev, libfreetype6-dev, libxpm-dev, libx11-dev, libxt-dev, libfontconfig-dev, libwebp-dev, libtiff-dev, dh-autoreconf, html2text
Package-List:
 libgd-dev deb libdevel optional arch=any
 libgd-tools deb graphics optional arch=any
 libgd3 deb libs optional arch=any
Checksums-Sha1:
 281af8e7e9c798d368caf8758b983c4d8c24d9ec 3326856 libgd2_2.2.5.orig.tar.gz
 84c3184d71f58e4891bd62843bf75e4555645580 39536 libgd2_2.2.5-5.2ubuntu2.4+local1.debian.tar.xz
Checksums-Sha256:
 150e6952af874bbccb33cf0f87288b41a8fd54f0ce4cff914ef90a80ef9d0162 3326856 libgd2_2.2.5.orig.tar.gz
 af91490a3b7c1e262fd711e30974b0dcc43b5627197a765739bbad9d176986ff 39536 libgd2_2.2.5-5.2ubuntu2.4+local1.debian.tar.xz
Files:
 d851cf184ccb9272b728ccb938c25b25 3326856 libgd2_2.2.5.orig.tar.gz
 61725d16319d8096ffe6271b2044a801 39536 libgd2_2.2.5-5.2ubuntu2.4+local1.debian.tar.xz
Original-Maintainer: GD Team <team+gd@tracker.debian.org>
