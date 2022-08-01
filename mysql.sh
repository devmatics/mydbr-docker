#!/bin/sh
docker container stop mydbr-mysql
docker container rm mydbr-mysql
docker run -d -p 3306:3306 --name mydbr-mysql --env MARIADB_ROOT_PASSWORD=mydbr --env MARIADB_DATABASE=mydbr mariadb:latest
docker inspect mydbr-mysql | grep "IPAddress"
