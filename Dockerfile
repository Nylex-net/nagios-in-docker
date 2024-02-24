FROM ubuntu
LABEL maintainer="nylex.net"

COPY ./nagiosql /usr/local/nagios/etc/nagiosql

COPY ./nagiosql_share/config/settings.php /usr/local/nagios/share/nagiosql/config/settings.php

COPY ./Configs /usr/local/nagios/etc/

# COPY ./initial_setup/nagios-4.4.8 /tmp/setup
# COPY ./initial_setup/nagios-plugins-2.4.2 /tmp/plugins

COPY ./apache2/envvars ./etc/apache2/envvars

ENV APACHE_RUN_USER=nagios

ENV APACHE_RUN_GROUP=www-data

ENV MYSQL_ROOT_PASSWORD=nagiosql_pass

ENV GEOGRAPHIC_AREA=11

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt update && \
    yes | apt-get update && \
    yes | apt-get install sendemail && \
    apt-get install -y php libmcrypt-dev php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-pear gcc php-dev php zlib1g-dev libssh2-1 libssh2-1-dev php-ssh2 mariadb-server build-essential && \
    yes | apt-get install -y autoconf gcc libc6 make wget unzip php libgd-dev && \
	yes | apt-get install openssl libssl-dev && \
    apt-get purge openssh-server && \
    yes | apt-get install openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:$NAGIOS_PASSWORD' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    pear channel-update pear.php.net && \
	pear install HTML_Template_IT && \
	pecl install mcrypt | echo && \
	echo "extension=mcrypt.so" >> /etc/php/8.1/apache2/php.ini && \
	echo "date.timezone=Asia/Singapore"  >> /etc/php/8.1/apache2/php.ini && \
    cd /tmp && \
    wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.4.8/nagios-4.4.8.tar.gz && \
	tar -xzf ./nagioscore.tar.gz && \
	cd ./nagios-4.4.8 && \
	./configure --with-httpd-conf=/etc/apache2/sites-enabled && \
	make all && \
	# cd ../.. && \
	make install-groups-users && \
	# cd .. && \
	usermod -a -G nagios www-data && \
	# cd /nagios-4.4.8 && \
    make install && \
    make install-daemoninit && \
	make install-commandmode && \
	make install-config && \
	make install-webconf && \
	a2enmod rewrite && \
	a2enmod cgi && \
    cd .. && \
    apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext && \
    # cd /tmp && \
	wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.2/nagios-plugins-2.4.2.tar.gz && \
	tar -zxf ./nagios-plugins.tar.gz && \
	cd ./nagios-plugins-2.4.2 && \
	./configure && \
    cd ../.. && \
	htpasswd -cb /usr/local/nagios/etc/htpasswd.users $NAGIOS_ADMIN $NAGIOS_PASSWORD && \
	cd /tmp && \
    wget -O nagiosql-3.5.0-.tar.gz https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.5.0/nagiosql-3.5.0-git2023-06-18.tar.gz/download && \
	tar -zxvf nagiosql-3.5.0-.tar.gz && \
	cp -vprf nagiosql-3.5.0/ /usr/local/nagios/share/nagiosql && \
	mkdir /usr/local/nagios/etc/nagiosql/backup && \
	mkdir /usr/local/nagios/etc/nagiosql/backup/hosts && \
	mkdir /usr/local/nagios/etc/nagiosql/backup/services && \
    # chmod -R 777 /usr/local/nagios/share/nagiosql/config && \
    # chmod -R 6775 /usr/local/nagios/etc/nagiosql && \
    # chown -R nagios.www-data /usr/local/nagios/etc/nagiosql && \
	# chown nagios.www-data /usr/local/nagios/etc/nagios.cfg && \
	# chown nagios.www-data /usr/local/nagios/etc/cgi.cfg && \
	# chown nagios.www-data /usr/local/nagios/etc/resource.cfg && \
	# chown nagios.www-data /usr/local/nagios/var/spool/checkresults && \
	# chown nagios:www-data /usr/local/nagios/bin/nagios && \
    cd /tmp && \
    wget https://github.com/duffycop/nagios_plugins/files/1881453/check_service.tar.gz && \
    tar -xzf check_service.tar.gz && \
    mv ./check_service /usr/local/nagios/libexec

USER root

CMD ["service","apache2.service","start","&&","service","nagios.service","restart","&&","service","apache2","restart"]
# Remember to start the SSH service through the container's command prompt.