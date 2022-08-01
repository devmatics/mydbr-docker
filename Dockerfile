FROM alpine:3.16 as mydbr-download

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add curl
RUN apk add unzip

RUN curl -o mydbr_php8_sg.zip https://mydbr.com/fileserve.php?get=mydbr_php8_sg.zip
RUN unzip mydbr_php8_sg.zip

RUN mkdir /sourceguardian
RUN curl -o sourceguardian.zip https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.zip
RUN unzip sourceguardian.zip -d /sourceguardian

RUN mkdir /chartdirector
RUN curl -o chartdirector.tar.gz https://www.advsofteng.net/chartdir_php_linux_64.tar.gz
RUN tar -xvzf chartdirector.tar.gz -C /chartdirector

FROM alpine:3.16 as base-php

# We pin to php 8.0 as MyDBR has different branches for 8.0 and 8.1. If Alpine's PHP8 package updates to 8.1, change our pinning here.

RUN apk update && apk upgrade

RUN apk add bash
RUN apk add curl

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

RUN apk add graphviz

FROM base-php as base-php-wkhtmltopdf
# WkHTMLToPDF lost Alpine support in 3.14 due to its primary dependecy Qt5-QtWebkit being unmainted for 3 years now.

# WkHTMLToPDF has been on life support since 2016 and the project is dead as of 2020 by admission of the maintainer
# See https://wkhtmltopdf.org/status.html#summary

# Ideally MyDBR updates to use weasyprint, athenapdf, or puppeteer
# the WkHTMLToPDF maintainer recommends weasyprint
# See https://wkhtmltopdf.org/status.html#recommendations
# See https://github.com/Kozea/WeasyPrint

# For now, needs testing, but we can pull down the Alpine 3.14 packages for WkHTMLToPDF and use those.
# This appears to work on a surface level but needs testing to determine if the seg-faulting issue
# Reported Here: https://gitlab.alpinelinux.org/alpine/aports/-/issues/12110
# occurs or not. If it does, we may need to build a patched QT ourselves similar to:
# https://github.com/RoseRocket/docker-alpine-wkhtmltopdf-patched-qt/blob/master/Dockerfile

RUN mkdir -p /download

RUN curl -o /download/icu-libs-67.1-r2.apk https://dl-cdn.alpinelinux.org/alpine/v3.14/main/x86_64/icu-libs-67.1-r2.apk
RUN apk add --allow-untrusted /download/icu-libs-67.1-r2.apk

RUN curl -o /download/qt5-qtbase-5.15.3_git20210406-r0.apk https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/qt5-qtbase-5.15.3_git20210406-r0.apk
RUN apk add --allow-untrusted /download/qt5-qtbase-5.15.3_git20210406-r0.apk

RUN curl -o /download/qt5-qtlocation-5.15.3_git20201109-r0.apk https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/qt5-qtlocation-5.15.3_git20201109-r0.apk
RUN apk add --allow-untrusted /download/qt5-qtlocation-5.15.3_git20201109-r0.apk

RUN curl -o /download/qt5-qtwebkit-5.212.0_alpha4-r14.apk https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/qt5-qtwebkit-5.212.0_alpha4-r14.apk
RUN apk add --allow-untrusted /download/qt5-qtwebkit-5.212.0_alpha4-r14.apk

RUN curl -o /download/wkhtmltopdf-0.12.6-r0.apk https://dl-cdn.alpinelinux.org/alpine/v3.14/community/x86_64/wkhtmltopdf-0.12.6-r0.apk
RUN apk add --allow-untrusted /download/wkhtmltopdf-0.12.6-r0.apk

RUN rm -r /download

RUN apk add libgcc
RUN apk add libstdc++
RUN apk add musl

RUN apk add ttf-liberation
RUN apk add ttf-droid
RUN apk add ttf-droid-nonlatin
RUN apk add ttf-cantarell
RUN apk add ttf-hack
RUN apk add ttf-freefont
RUN apk add ttf-tlwg
RUN apk add ttf-inconsolata
RUN apk add ttf-dejavu

RUN apk add fontconfig

FROM base-php-wkhtmltopdf as final

COPY src/nginx.conf /etc/nginx/nginx.conf
COPY src/sourceguardian.ini /etc/php8/conf.d/sourceguardian.ini
COPY src/chartdirector.ini /etc/php8/conf.d/chartdirector.ini
COPY src/php-fpm.conf /etc/php8/php-fpm.conf
COPY src/php-fpm-www.conf /etc/php8/php-fpm.d/www.conf

COPY src/phpinfo.php /usr/share/nginx/html/phpinfo.php

COPY --from=mydbr-download sourceguardian/ixed.8.0.lin /usr/lib/php8/modules/ixed.8.0.lin
COPY --from=mydbr-download chartdirector/ChartDirector/lib/phpchartdir800.dll /usr/lib/php8/modules/phpchartdir800.dll
COPY --from=mydbr-download chartdirector/ChartDirector/lib/phpchartdir.php /usr/lib/php8/modules/phpchartdir.php
COPY --from=mydbr-download chartdirector/ChartDirector/lib/libchartdir.so /usr/lib/php8/modules/libchartdir.so
COPY --from=mydbr-download chartdirector/ChartDirector/lib/fonts /usr/lib/php8/modules/fonts
COPY --from=mydbr-download mydbr /usr/share/nginx/html

RUN chown -R nobody /usr/share/nginx/html
RUN chmod -R u+w /usr/share/nginx/html

EXPOSE 80

STOPSIGNAL SIGTERM
CMD ["/bin/bash", "-c", "mkdir -p /var/run/php && php-fpm8 && chmod 777 /var/run/php/php8-fpm.sock && nginx -g 'daemon off;'"]
