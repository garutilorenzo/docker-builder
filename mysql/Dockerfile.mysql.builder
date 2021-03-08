# 1. MySQL Builder
FROM ubuntu:focal as mysql_builder_stage1

RUN sed -i '/deb-src/s/^# //' /etc/apt/sources.list && apt update && \
    DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \ 
    apt-get install -y --no-install-recommends ca-certificates  \
    build-essential pkg-config cmake libssl-dev libncurses-dev  && \
    DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    apt build-dep -y mysql-server-8.0

RUN mkdir -p /source /target
VOLUME /target
WORKDIR /source

COPY ./build-mysql.sh /build-mysql.sh

ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} builder 
RUN useradd -u ${UID} -g ${GID} -m -d /source -s /bin/bash builder
RUN chown -R  builder:builder /source /target 
USER builder

#RUN wget  -c https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-boost-$MYSQL_VERSION.tar.gz -O - | \
#    tar -xz -C /builder

#ADD mysql-boost-$MYSQL_VERSION.tar.gz /builder/

# RUN mkdir /builder/mysql-$MYSQL_VERSION/bld
# RUN cd /builder/mysql-$MYSQL_VERSION/bld && \
#     cmake  \
#     -DCMAKE_VERBOSE_MAKEFILE=ON \
#     -DMYSQL_UNIX_ADDR=/var/run/mysqld/mysqld.sock \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DBUILD_CONFIG=mysql_release \
#     -DWITH_LIBWRAP=OFF \
#     -DWITH_ZLIB=system \
#     -DWITH_LZ4=system \
#     -DWITH_EDITLINE=system \
#     -DWITH_LIBEVENT=system \
#     -DWITH_SSL=system \
#     -DWITH_MECAB=system \
#     -DWITH_BOOST=../boost \
#     -DWITH_RAPIDJSON=bundled \
#     -DINSTALL_LAYOUT=DEB \
#     -DINSTALL_DOCDIR=share/mysql/docs \
#     -DINSTALL_DOCREADMEDIR=share/mysql \
#     -DINSTALL_INCLUDEDIR=include/mysql \
#     -DINSTALL_INFODIR=share/mysql/docs \
#     -DINSTALL_LIBDIR=lib/x86_64-linux-gnu  \
#     -DINSTALL_MANDIR=share/man \
#     -DINSTALL_MYSQLSHAREDIR=share/mysql \
#     -DINSTALL_MYSQLTESTDIR=lib/mysql-test \
#     -DINSTALL_PLUGINDIR=lib/mysql/plugin \
#     -DINSTALL_SBINDIR=sbin \
#     -DINSTALL_SCRIPTDIR=bin \
#     -DINSTALL_SUPPORTFILESDIR=share/mysql \
#     -DSYSCONFDIR=/etc/mysql \
#     -DWITH_EMBEDDED_SERVER=ON \
#     -DWITH_ARCHIVE_STORAGE_ENGINE=ON \
#     -DWITH_BLACKHOLE_STORAGE_ENGINE=ON \
#     -DWITH_FEDERATED_STORAGE_ENGINE=ON \
#     -DWITH_INNODB_MEMCACHED=1 \
#     -DWITH_EXTRA_CHARSETS=all \
#     -DROUTER_INSTALL_LIBDIR=lib/mysql-router \

#     ../ && \
#     make -j$(nproc) && \
#     make install

# # 2. MySQL final container
# FROM ubuntu:focal as mysql_base
# COPY --from=mysql_builder /usr/local/mysql /usr/local/mysql