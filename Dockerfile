FROM alpine:3.16 as mydbr-download

RUN apk update && apk upgrade
RUN apk add bash
RUN apk add curl
RUN apk add unzip

RUN curl -o mydbr_php81_sg.zip https://mydbr.com/fileserve.php?get=mydbr_php81_sg.zip
RUN unzip mydbr_php81_sg.zip

RUN mkdir /sourceguardian
RUN curl -o sourceguardian.zip https://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.zip
RUN unzip sourceguardian.zip -d /sourceguardian

RUN mkdir /chartdirector
RUN curl -o chartdirector.tar.gz https://www.advsofteng.net/chartdir_php_linux_64.tar.gz
RUN tar -xvzf chartdirector.tar.gz -C /chartdirector

FROM alpine:3.16 as base-php

RUN apk update && apk upgrade

RUN apk add bash
RUN apk add curl

RUN apk add nginx

RUN apk add php81
RUN apk add php81-bcmath
RUN apk add php81-calendar
RUN apk add php81-ctype
RUN apk add php81-curl
RUN apk add php81-dom
RUN apk add php81-exif
RUN apk add php81-ffi
RUN apk add php81-fileinfo
RUN apk add php81-fpm
RUN apk add php81-ftp
RUN apk add php81-gd
RUN apk add php81-gettext
RUN apk add php81-iconv
# Cannot use the php 8.x intl package with wkhtmltopdf as they require different icu-libs versions
#RUN apk add php81-intl
RUN apk add php81-imap
RUN apk add php81-ldap
RUN apk add php81-mbstring
RUN apk add php81-mysqli
RUN apk add php81-mysqlnd
RUN apk add php81-openssl
RUN apk add php81-pcntl
RUN apk add php81-pdo
RUN apk add php81-pdo_mysql
RUN apk add php81-phar
RUN apk add php81-posix
RUN apk add php81-session
RUN apk add php81-shmop
RUN apk add php81-simplexml
RUN apk add php81-sockets
RUN apk add php81-sodium
RUN apk add php81-sysvmsg
RUN apk add php81-sysvsem
RUN apk add php81-sysvshm
RUN apk add php81-tokenizer
RUN apk add php81-xml
RUN apk add php81-xmlreader
RUN apk add php81-xmlwriter
RUN apk add php81-xsl
RUN apk add php81-zip

RUN apk add graphviz

FROM base-php as base-wkhtml
# WkHTMLToPDF lost Alpine support in 3.15 due to its primary dependecy Qt5-QtWebkit being unmainted for 3 years now.

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

# For reference
# Debian deprecated QtWebkit in 2018 and Ubuntu has maintained their own custom fork since:
# See https://git.launchpad.net/ubuntu/+source/qtwebkit-opensource-src/?h=ubuntu/jammy

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

FROM base-wkhtml as final

COPY src/nginx.conf /etc/nginx/nginx.conf
COPY src/sourceguardian.ini /etc/php81/conf.d/sourceguardian.ini
COPY src/chartdirector.ini /etc/php81/conf.d/chartdirector.ini
COPY src/php-fpm.conf /etc/php81/php-fpm.conf
COPY src/php-fpm-www.conf /etc/php81/php-fpm.d/www.conf

COPY src/phpinfo.php /usr/share/nginx/html/phpinfo.php

COPY --from=mydbr-download sourceguardian/ixed.8.1.lin /usr/lib/php81/modules/ixed.8.1.lin
COPY --from=mydbr-download chartdirector/ChartDirector/lib/phpchartdir810.dll /usr/lib/php81/modules/phpchartdir810.dll
COPY --from=mydbr-download chartdirector/ChartDirector/lib/phpchartdir.php /usr/lib/php81/modules/phpchartdir.php
COPY --from=mydbr-download chartdirector/ChartDirector/lib/libchartdir.so /usr/lib/php81/modules/libchartdir.so
COPY --from=mydbr-download chartdirector/ChartDirector/lib/fonts /usr/lib/php81/modules/fonts
COPY --from=mydbr-download mydbr /usr/share/nginx/html

RUN chown -R nobody /usr/share/nginx/html
RUN chmod -R u+w /usr/share/nginx/html

EXPOSE 80

STOPSIGNAL SIGTERM
CMD ["/bin/bash", "-c", "mkdir -p /var/run/php && php-fpm81 && chmod 777 /var/run/php/php81-fpm.sock && nginx -g 'daemon off;'"]
