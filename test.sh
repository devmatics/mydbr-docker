#!/bin/sh
docker build -t mydbr .

docker container stop mydbr
docker container rm mydbr
docker run -d -p 8080:80 --name mydbr -v mydbr-wwwroot:/usr/share/nginx/html mydbr
