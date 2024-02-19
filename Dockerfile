FROM jasonrivers/nagios
LABEL maintainer="nylex.net"

COPY ./nagiosql/ /opt/nagios/etc/nagiosql/

COPY ./nagiosql_share/config/settings.php /opt/nagios/share/nagiosql/config/settings.php

COPY ./Configs/nagios.cfg /opt/nagios/etc/nagios.cfg

COPY ./mysql/run.sh /opt/nagios/scripts/run.sh

ENV APACHE_RUN_USER=nagios

ENV APACHE_RUN_GROUP=www-data

ENV MYSQL_ROOT_PASSWORD=nagiosql_pass

RUN apt update && \
    apt-get install -y php libmcrypt-dev php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-pear gcc php-dev php zlib1g-dev libssh2-1 libssh2-1-dev php-ssh2  mariadb-server build-essential && \
    yes | apt-get install -y autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev && \
	yes | apt-get install openssl libssl-dev && \
    pear channel-update pear.php.net && \
	pear install HTML_Template_IT && \
	pecl install mcrypt | echo && \
	echo "extension=mcrypt.so" >> /etc/php/8.1/apache2/php.ini && \
	echo "date.timezone=Asia/Singapore"  >> /etc/php/8.1/apache2/php.ini && \
    cd /tmp && \
    wget -O nagiosql-3.5.0-.tar.gz https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.5.0/nagiosql-3.5.0-git2023-06-18.tar.gz/download && \
	tar -zxvf nagiosql-3.5.0-.tar.gz && \
	cp -vprf nagiosql-3.5.0/ /opt/nagios/share/nagiosql && \
    cd .. && \
	mkdir /opt/nagios/etc/nagiosql/backup && \
	mkdir /opt/nagios/etc/nagiosql/backup/hosts && \
	mkdir /opt/nagios/etc/nagiosql/backup/services && \
    chmod -R 777 /opt/nagios/share/nagiosql/config && \
    chmod -R 6775 /opt/nagios/etc/nagiosql && \
    cd /tmp && \
    wget https://github.com/duffycop/nagios_plugins/files/1881453/check_service.tar.gz && \
    tar xzf check_service.tar.gz && \
    mv ./check_service /opt/nagios/etc/nagiosql

    CMD ["/opt/nagios/scripts/run.sh"]