#!/bin/bash

# Usage:
# bash build.sh <environment> <version>
#   bash build.sh nginx 1.19.7         compile nginx version 1.19.7 
#   bash build.sh mysql 8.0.23         compile MySQL version  8.0.23
# Supported build environment:
#   MySQL
#   MariaDB
#   Nginx


environment="$1"
version=$2

print_help() {
    echo " Usage:"
    echo " bash build.sh <environment> <version>"
    echo "   bash build.sh nginx 1.19.7         compile nginx version 1.19.7 "
    echo "   bash build.sh mysql 8.0.23         compile MySQL version  8.0.23 "
    echo " Supported build environment: "
    echo "   MySQL "
    echo "   MariaDB "
    echo "   Nginx "
}

if [ -z "$environment" ]; then
    echo "You have to specify an environment to build: mysql, nginx, mariadb"
    print_help
    exit 1
fi

if [ -z "$version" ]; then
    echo "You have to specify a version to build. Eg. for MySQL: 8.0.23"
    print_help
    exit 1
fi

check_git() {
    if ! [ -x "$(command -v git)" ]; then
        echo 'Git is  needed to download MariaDB' >&2
        exit 1
    fi
}

check_wget() {
    if ! [ -x "$(command -v wget)" ]; then
        echo 'Wget is  needed to download Source packages' >&2
        exit 1
    fi
}

download_soruces() {
    #https://downloads.mysql.com/archives/get/p/23/file/mysql-boost-8.0.22.tar.gz
    #https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-boost-8.0.23.tar.gz

    #https://github.com/MariaDB/server.git -b $version

    #http://nginx.org/download/nginx-1.19.7.tar.gz

    environment="$1"
    version=$2
    
    MYSQL_LATEST='8.0.23' # at today (2021-03-05)

    if [ $environment = 'mysql' ] && [ "$version" = "$MYSQL_LATEST" ]; then
        if [ -f "mysql/mysql-boost-8.0.23.tar.gz" ]; then
            echo "MySQL source alredy exist"
        else
            wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-boost-8.0.23.tar.gz -P mysql/
        fi
    elif [ $environment = 'mysql' ]; then
        if [ -f "mysql/mysql-boost-$version.tar.gz" ]; then
            echo "MySQL source alredy exist"
        else
            wget https://downloads.mysql.com/archives/get/p/23/file/mysql-boost-$version.tar.gz -P mysql/
        fi
    elif [ $environment = 'nginx' ]; then
        if [ -f "nginx/nginx-$version.tar.gz" ]; then
            echo "Nginx source alredy exist"
        else
            wget http://nginx.org/download/nginx-$version.tar.gz -P nginx/
        fi
    elif [ $environment = 'mariadb' ]; then
        if [ -d "mariadb/mariadb-soruce" ]; then
            echo "Mariadb source alredy exist"
        else
            git clone https://github.com/MariaDB/server.git -b $version mariadb/mariadb-soruce
        fi
    fi
}

case "$environment" in
  "mysql")
    check_wget
    download_soruces $environment $version
    docker_target="mysql:$version"
    docker build --memory=1024m mysql/ -f mysql/Dockerfile.mysql -t "${docker_target}" --build-arg MYSQL_VERSION=$version
    ;;
  "mariadb")
    check_git
    download_soruces $environment $version
    docker_target="mariadb:$version"
    docker build --memory=1024m mariadb/ -f mariadb/Dockerfile.mariadb -t "${docker_target}" --build-arg MARIADB_VERSION=$version
    ;;
  "nginx")
    check_wget
    download_soruces $environment $version
    docker_target="nginx:$version"
    docker build --memory=1024m nginx/ -f nginx/Dockerfile.nginx -t "${docker_target}" --build-arg NGINX_VERSION=$version
    ;;
  *)
    print_help
    exit 1
esac