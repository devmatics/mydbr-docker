#!/bin/sh
docker container stop mydbr-mysql
docker container rm mydbr-mysql
docker run -d -p 3306:3306 --name mydbr-mysql --env MYSQL_ROOT_PASSWORD=mydbr --env MYSQL_DATABASE=mydbr mysql:8
docker inspect mydbr-mysql | grep "IPAddress"
