#!/bin/bash

# Usage:
# bash build.sh <environment> <version>
#   bash build.sh nginx 1.19.7         compile nginx version 1.19.7 
#   bash build.sh mysql 8.0.23         compile MySQL version  8.0.23
# Supported build environment:
#   MySQL
#   MariaDB
#   Nginx

nocache=""
pull=""

get_arguments() {
    while getopts e:v:o:pnm: option
    do
        case "${option}"
            in
            (e) environment=${OPTARG};;
            (v) version=${OPTARG};;
            (o) os=${OPTARG};;
            (p) pull=1;;
            (n) nocache=1;;
            (m) memory=${OPTARG};;
        esac
    done
}

print_help() {
    echo " Usage:"
    echo " bash build.sh -e <environment>  -v <version> -o <os>"
    echo "   bash build.sh -e nginx -v 1.19.7         compile nginx version 1.19.7 "
    echo "   bash build.sh -e mysql -v 8.0.23         compile MySQL version  8.0.23 "
    echo " -o (optional) Only Ngnix supports multiple os (CentOS, Ububnu)."
    echo " If no option is passed to -o argument Ubuntu will used as default"
    echo ""
    echo " -p (optional) flag tells docker to pull base images from registry "
    echo " -n (optional) flag tells docker to not use the cache "
    echo " -m (optional - default set to 1024m) set maximum RAM assigned to docker container "
    echo " Supported build environment: "
    echo "   MySQL "
    echo "   MariaDB "
    echo "   Nginx "
}

check_arguments() {
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

    if [ -z "$os" ]; then
        os='ubuntu'
    fi
   
    if [ ! -z "$pull" ]; then
        pull='--pull'
    fi

    if [ ! -z "$nocache" ]; then
        nocache='--no-cache'
    fi

    if [ -z "$memory" ]; then
        memory='1024m'
    fi
}

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

download_sources() {
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

build() {
    mkdir -p sources
    mkdir -p target

    case "$environment" in
    "mysql")
        check_wget
        download_sources $environment $version

        docker_target="mysql:$version"
        mysql_builder_target=mysql-builder:latest
        docker build --memory=$memory $pull $nocache mysql/ -f mysql/Dockerfile.mysql.builder --target mysql_builder_stage1 -t "${mysql_builder_target}"

        mkdir -p target/mysql-$version

        #Run container for build
        docker run --rm --memory=$memory -e MYSQL_VERSION=$version \
            -v $(pwd)/sources/mysql-$version:/source/mysql-$version/ \
            -v $(pwd)/target/mysql-$version:/target/mysql-$version/ \
            $mysql_builder_target \
            /build-mysql.sh
         
        docker build --memory=$memory $pull $nocache target/ -f mysql/Dockerfile.mysql --target final  --build-arg MYSQL_VERSION=$version -t "${docker_target}"
        ;;
    "mariadb")
        check_git
        download_sources $environment $version
        docker_target="mariadb:$version"
        docker build --memory=$memory $pull $nocache mariadb/ -f mariadb/Dockerfile.mariadb -t "${docker_target}" --build-arg MARIADB_VERSION=$version
        ;;
    "nginx")
        check_wget
        download_sources $environment $version
        docker_target="nginx:$os-$version"
        docker build --memory=$memory $pull $nocache nginx/ -f nginx/Dockerfile.$os.nginx -t "${docker_target}" --build-arg NGINX_VERSION=$version
        ;;
    *)
        print_help
        exit 1
    esac
}

get_arguments $@
check_arguments
build