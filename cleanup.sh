#!/bin/sh
docker container stop mydbr
docker container rm mydbr
docker volume rm mydbr-wwwroot
docker image rm mydbr
docker container stop mydbr-mysql
docker container rm mydbr-mysql
