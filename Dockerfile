FROM alpine:latest as mydbr-download

RUN apk update && apk upgrade
RUN apk add curl
run apk add unzip

RUN curl -o mydbr_php8_sg.zip https://mydbr.com/fileserve.php?get=mydbr_php8_sg.zip
RUN unzip mydbr_php8_sg.zip

FROM alpine:latest

# We pin to php 8.0 as MyDBR has different branches for 8.0 and 8.1. If Alpine's PHP8 package updates to 8.1, change our pinning here.

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add nginx
RUN apk add 'php8=~8.0'

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY php.ini /etc/php8/php.ini

COPY mydbr /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
