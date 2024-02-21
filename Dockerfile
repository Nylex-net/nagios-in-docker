FROM jasonrivers/nagios
LABEL maintainer="nylex.net"

COPY ./nagiosql /opt/nagios/etc/nagiosql

COPY ./nagiosql_share/config/settings.php /opt/nagios/share/nagiosql/config/settings.php

COPY ./Configs /opt/nagios/etc/

# Copy SSH configuration
# COPY ./ssh/sshd_config /etc/ssh/sshd_config

COPY ./apache2/envvars ./etc/apache2/envvars

ENV APACHE_RUN_USER=nagios

ENV APACHE_RUN_GROUP=www-data

ENV MYSQL_ROOT_PASSWORD=nagiosql_pass

RUN apt update && \
    yes | apt-get install sendemail && \
    yes | apt-get update && \
    apt-get install -y php libmcrypt-dev php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-pear gcc php-dev php zlib1g-dev libssh2-1 libssh2-1-dev php-ssh2  mariadb-server build-essential && \
    yes | apt-get install -y autoconf gcc libc6 make wget unzip php libgd-dev && \
	yes | apt-get install openssl libssl-dev && \
    apt-get purge openssh-server && \
    yes | apt-get install openssh-server && \
    service ssh start && \
    # yes | apt-get install iptables && \
    # iptables -A INPUT -p tcp  --destination-port 22 -j ACCEPT && \
    # iptables -A INPUT -p tcp  --destination-port 80 -j ACCEPT && \
    pear channel-update pear.php.net && \
	pear install HTML_Template_IT && \
	pecl install mcrypt | echo && \
	echo "extension=mcrypt.so" >> /etc/php/8.1/apache2/php.ini && \
	echo "date.timezone=Asia/Singapore"  >> /etc/php/8.1/apache2/php.ini && \
    # make install-groups-users && \
    cd /tmp && \
    wget -O nagiosql-3.5.0-.tar.gz https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.5.0/nagiosql-3.5.0-git2023-06-18.tar.gz/download && \
	tar -zxvf nagiosql-3.5.0-.tar.gz && \
	cp -vprf nagiosql-3.5.0/ /opt/nagios/share/nagiosql && \
	# usermod -a -G nagios www-data && \
    cd .. && \
    # mkdir /var/run/sshd && \
    # echo 'root:root' | chpasswd && \
    # sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
	mkdir /opt/nagios/etc/nagiosql/backup && \
	mkdir /opt/nagios/etc/nagiosql/backup/hosts && \
	mkdir /opt/nagios/etc/nagiosql/backup/services && \
    # chmod 755 /run/sshd && \
    chmod -R 777 /opt/nagios/share/nagiosql/config && \
    chmod -R 6775 /opt/nagios/etc/nagiosql && \
    chown -R nagios.www-data /opt/nagios/etc/nagiosql && \
	chown nagios.www-data /opt/nagios/etc/nagios.cfg && \
	chown nagios.www-data /opt/nagios/etc/cgi.cfg && \
	chown nagios.www-data /opt/nagios/etc/resource.cfg && \
	chown nagios.www-data /opt/nagios/var/spool/checkresults && \
	chown nagios:www-data /opt/nagios/bin/nagios && \
    cd /tmp && \
    wget https://github.com/duffycop/nagios_plugins/files/1881453/check_service.tar.gz && \
    tar -xzf check_service.tar.gz && \
    mv ./check_service /opt/nagios/libexec
    # /usr/sbin/sshd -D

USER root

# Start SSH service
# CMD ["/usr/sbin/sshd", "-D"]