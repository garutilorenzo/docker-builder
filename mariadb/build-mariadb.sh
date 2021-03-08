#!/bin/bash

cd /target/mariadb-$MARIADB_VERSION && \
    cmake  -DBUILD_CONFIG=mysql_release -B/target/mariadb-$MARIADB_VERSION -S/source/mariadb-$MARIADB_VERSION && \
    make -j$(nproc)

exit 0