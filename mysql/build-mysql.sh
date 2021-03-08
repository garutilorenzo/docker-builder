#!/bin/bash
cd /target/mysql-$MYSQL_VERSION/ && \
    pwd && \
    cmake  \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DMYSQL_UNIX_ADDR=/var/run/mysqld/mysqld.sock \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_CONFIG=mysql_release \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql	\
    -DWITH_LIBWRAP=OFF \
    -DWITH_ZLIB=system \
    -DWITH_LZ4=system \
    -DWITH_EDITLINE=system \
    -DWITH_LIBEVENT=system \
    -DWITH_SSL=system \
    -DWITH_MECAB=system \
    -DWITH_BOOST=/source/mysql-$MYSQL_VERSION/boost \
    -DWITH_RAPIDJSON=bundled \
    -DINSTALL_LAYOUT=STANDALONE \
    -DINSTALL_DOCDIR=share/mysql/docs \
    -DINSTALL_DOCREADMEDIR=share/mysql \
    -DINSTALL_INCLUDEDIR=include/mysql \
    -DINSTALL_INFODIR=share/mysql/docs \
    -DINSTALL_LIBDIR=lib/x86_64-linux-gnu  \
    -DINSTALL_MANDIR=share/man \
    -DINSTALL_MYSQLSHAREDIR=share/mysql \
    -DINSTALL_MYSQLTESTDIR=lib/mysql-test \
    -DINSTALL_PLUGINDIR=lib/mysql/plugin \
    -DINSTALL_SBINDIR=sbin \
    -DINSTALL_SCRIPTDIR=bin \
    -DINSTALL_SUPPORTFILESDIR=share/mysql \
    -DSYSCONFDIR=/etc/mysql \
    -DWITH_EMBEDDED_SERVER=ON \
    -DWITH_ARCHIVE_STORAGE_ENGINE=ON \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=ON \
    -DWITH_FEDERATED_STORAGE_ENGINE=ON \
    -DWITH_INNODB_MEMCACHED=1 \
    -DWITH_EXTRA_CHARSETS=all \
    -DROUTER_INSTALL_LIBDIR=lib/mysql-router \
    /source/mysql-$MYSQL_VERSION/  && \
    make -j$(nproc)

exit 0