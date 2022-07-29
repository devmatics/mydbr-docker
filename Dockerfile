FROM alpine:latest as mydbr-download

RUN apk update && apk upgrade
RUN apk add curl
RUN apk add unzip

RUN curl -o mydbr_php8_sg.zip https://mydbr.com/fileserve.php?get=mydbr_php8_sg.zip
RUN unzip mydbr_php8_sg.zip

RUN mkdir /sourceguardian
RUN curl -o sourceguardian.zip https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.zip
RUN unzip sourceguardian.zip -d /sourceguardian

FROM alpine:latest as base

# We pin to php 8.0 as MyDBR has different branches for 8.0 and 8.1. If Alpine's PHP8 package updates to 8.1, change our pinning here.

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add nginx
RUN apk add 'php8=~8.0'
RUN apk add 'php8-bcmath=~8.0'
RUN apk add 'php8-calendar=~8.0'
RUN apk add 'php8-ctype=~8.0'
RUN apk add 'php8-curl=~8.0'
RUN apk add 'php8-dom=~8.0'
RUN apk add 'php8-exif=~8.0'
RUN apk add 'php8-ffi=~8.0'
RUN apk add 'php8-fileinfo=~8.0'
RUN apk add 'php8-fpm=~8.0'
RUN apk add 'php8-ftp=~8.0'
RUN apk add 'php8-gd=~8.0'
RUN apk add 'php8-gettext=~8.0'
RUN apk add 'php8-iconv=~8.0'
RUN apk add 'php8-imap=~8.0'
RUN apk add 'php8-mbstring=~8.0'
RUN apk add 'php8-mysqli=~8.0'
RUN apk add 'php8-mysqlnd=~8.0'
RUN apk add 'php8-pcntl=~8.0'
RUN apk add 'php8-pdo=~8.0'
RUN apk add 'php8-pdo_mysql=~8.0'
RUN apk add 'php8-phar=~8.0'
RUN apk add 'php8-posix=~8.0'
RUN apk add 'php8-session=~8.0'
RUN apk add 'php8-shmop=~8.0'
RUN apk add 'php8-simplexml=~8.0'
RUN apk add 'php8-sockets=~8.0'
RUN apk add 'php8-sodium=~8.0'
RUN apk add 'php8-sysvmsg=~8.0'
RUN apk add 'php8-sysvsem=~8.0'
RUN apk add 'php8-sysvshm=~8.0'
RUN apk add 'php8-tokenizer=~8.0'
RUN apk add 'php8-xml=~8.0'
RUN apk add 'php8-xmlreader=~8.0'
RUN apk add 'php8-xmlwriter=~8.0'
RUN apk add 'php8-xsl=~8.0'
RUN apk add 'php8-zip=~8.0'

FROM base as final

COPY src/nginx.conf /etc/nginx/nginx.conf
COPY src/sourceguardian.ini /etc/php8/conf.d/sourceguardian.ini
COPY src/php-fpm.conf /etc/php8/php-fpm.conf
COPY src/php-fpm-www.conf /etc/php8/php-fpm.d/www.conf

COPY src/phpinfo.php /usr/share/nginx/html/phpinfo.php

COPY --from=mydbr-download sourceguardian/ixed.8.0.lin /usr/lib/php8/modules/ixed.8.0.lin
COPY --from=mydbr-download mydbr /usr/share/nginx/html

RUN chown -R nobody /usr/share/nginx/html
RUN chmod -R u+w /usr/share/nginx/html

EXPOSE 80

STOPSIGNAL SIGTERM
CMD ["/bin/bash", "-c", "mkdir -p /var/run/php && php-fpm8 && chmod 777 /var/run/php/php8-fpm.sock && nginx -g 'daemon off;'"]
