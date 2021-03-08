# 1. MySQL Builder
FROM ubuntu:focal as mariadb_builder_stage1

RUN sed -i '/deb-src/s/^# //' /etc/apt/sources.list && apt update && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \ 
    apt-get install -y --no-install-recommends ca-certificates  \
    build-essential pkg-config cmake libssl-dev wget libncurses-dev git openssh-client && \
    apt build-dep -y mariadb-server

RUN mkdir -p /source /target
VOLUME /target
WORKDIR /source

COPY ./build-mariadb.sh /build-mariadb.sh

ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} builder 
RUN useradd -u ${UID} -g ${GID} -m -d /source -s /bin/bash builder
RUN chown -R  builder:builder /source /target 
USER builder
