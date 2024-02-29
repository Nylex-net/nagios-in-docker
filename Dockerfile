FROM ubuntu
LABEL maintainer="nylex.net"

# Required Nagiosql config files with host information.
COPY ./nagiosql /usr/local/nagios/etc/nagiosql

# File from original Nagios build.
COPY ./nagiosql_share/config/settings.php /usr/local/nagios/share/nagiosql/config/settings.php

# Nagios' configuration files.
COPY ./Configs /usr/local/nagios/etc/

# Commands ran upon starting nagios container.
COPY ./scripts/run.sh /scripts/run.sh

# Missing required file.
COPY ./loose_files/ping /usr/bin/ping

# COPY ./initial_setup/nagios-4.4.8 /tmp/setup
# COPY ./initial_setup/nagios-plugins-2.4.2 /tmp/plugins

# COPY ./apache2/envvars ./etc/apache2/envvars
# COPY ./apache2/apache2.conf ./etc/apache2/apache2.conf
# COPY ./apache2/ports.conf ./etc/apache2/ports.conf

# Required arguments and environmental variables.
ENV GEOGRAPHIC_AREA=11
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Variables used for debugging.
# ENV MAIL_RELAY_HOST=helpdesk@nylex.net
# ENV MAIL_INET_PROTOCOLS=
ENV NAGIOS_FQDN=NAGIOS-NVR
# ENV NAGIOS_TIMEZONE=Etc/UTC
ENV APACHE_RUN_USER=nagios
ENV APACHE_RUN_GROUP=www-data

RUN apt update && \
	#Checks for updates
    yes | apt-get update && \
	sed -i 's/10.10.99.69/$(hostname -I)/g' /usr/local/nagios/share/nagiosql/config/settings.php && \
    yes | apt-get install sendemail && \
	yes | apt-get dist-upgrade && \
	# yes | apt-get install send-email && \
	#Installs Prerequisites
    yes | apt-get install -y autoconf gcc libc6 make wget unzip php libgd-dev && \
	yes | apt-get install openssl libssl-dev && \
    apt-get purge openssh-server && \
    yes | apt-get install openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:$NAGIOS_PASSWORD' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
	#Installs nagios & compiles
    cd /tmp && \
    wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.5.1/nagios-4.5.1.tar.gz && \
	tar -xzf ./nagioscore.tar.gz && \
	cd ./nagios-4.5.1 && \
	./configure --with-httpd-conf=/etc/apache2/sites-enabled && \
	make all && \
	#Creates user and adjusts rights
	# cd ../.. && \
	make install-groups-users && \
	# cd .. && \
	usermod -a -G nagios www-data && \
	#Installs nagios packages & Apache config
	# cd /nagios-4.4.8 && \
    make install && \
    make install-daemoninit && \
	make install-commandmode && \
	make install-config && \
	make install-webconf && \
	a2enmod rewrite && \
	a2enmod cgi && \
    # cd ../.. && \
	#Installs and configures firewall, finishes base Nagios install
	# yes | apt-get install iptables && \
	# iptables -I INPUT -p tcp --destination 10.10.99.69/24 -j ACCEPT && \
	# yes | apt-get install -y iptables-persistent && \
	# htpasswd -b -c /usr/local/nagios/etc/htpasswd.users $NAGIOS_ADMIN $NAGIOS_PASSWORD && \
	# sed -i 's/check_for_updates=1/check_for_updates=0/' /usr/local/nagios/etc/nagios.cfg && \
	#Installs Nagios Plugins
    apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext && \
    # cd /tmp && \
	wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.8/nagios-plugins-2.4.8.tar.gz && \
	tar -zxf ./nagios-plugins.tar.gz && \
	cd ./nagios-plugins-2.4.8 && \
	./configure && \
	make && \
	make install && \
	cd ../.. && \
	server_name="Nagios-SVR" && \
	sed -i "/^# Global configuration$/a ServerName ${server_name}" /etc/apache2/apache2.conf && \
	apachectl configtest && \
	service apache2 restart && \
	service nagios start && \
	apt-get install -y php libmcrypt-dev php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-pear gcc php-dev php zlib1g-dev libssh2-1 libssh2-1-dev php-ssh2 mariadb-server build-essential php-ftp && \
	pear channel-update pear.php.net && \
	pear install HTML_Template_IT && \
	pecl install mcrypt | echo && \
	echo "extension=mcrypt.so" >> /etc/php/8.1/apache2/php.ini && \
	echo "date.timezone=Asia/Singapore"  >> /etc/php/8.1/apache2/php.ini && \
	service apache2 restart && \
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" && \
	mysql -u root -p $MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'Nagios-NVR' IDENTIFIED BY '$NAGIOS_PASSWORD';" && \
	mysql -u root -p $MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;" && \
	#Download NagiosQL
	cd /tmp && \
    wget -O nagiosql-3.5.0-.tar.gz https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.5.0/nagiosql-3.5.0-git2023-06-18.tar.gz/download && \
	tar -zxvf nagiosql-3.5.0-.tar.gz && \
	cp -vprf nagiosql-3.5.0/ /usr/local/nagios/share/nagiosql && \
	#Configure Files and Folders
	mkdir /usr/local/nagios/etc/nagiosql/backup && \
	mkdir /usr/local/nagios/etc/nagiosql/backup/hosts && \
	mkdir /usr/local/nagios/etc/nagiosql/backup/services && \
	mkdir /var/log/sendemail && \
    chmod -R 777 /usr/local/nagios/share/nagiosql/config && \
    chmod -R 6775 /usr/local/nagios/etc/nagiosql && \
    chown -R nagios.www-data /usr/local/nagios/etc/nagiosql && \
	chown nagios.www-data /usr/local/nagios/etc/nagios.cfg && \
	chown nagios.www-data /usr/local/nagios/etc/cgi.cfg && \
	chown nagios.www-data /usr/local/nagios/etc/resource.cfg && \
	chown nagios.www-data /usr/local/nagios/var/spool/checkresults && \
	chown nagios:www-data /usr/local/nagios/bin/nagios && \
	chmod 775 /usr/local/nagios/etc/ && \
	chmod 777 /usr/local/nagios/bin/nagios && \
	chmod -R 777 /usr/local/nagios/share/nagiosql/config && \
	chmod -R 6775 /usr/local/nagios/etc/nagiosql && \
	chmod 660 /usr/local/nagios/var/rw/nagios.cmd && \
	chmod 775 /usr/local/nagios/etc/ && \
	chmod 664 /usr/local/nagios/etc/nagios.cfg && \
	chmod 664 /usr/local/nagios/etc/cgi.cfg && \
	chmod g+x /usr/local/nagios/var/rw/ && \
	# chmod ug+s /usr/local/nagios/libexec/check_ping && \
	chgrp www-data /usr/local/nagios/etc/ && \
	chgrp www-data /usr/local/nagios/etc/nagios.cfg && \
	chgrp www-data /usr/local/nagios/etc/cgi.cfg && \
	sed -i 's/^cfg/#cfg/' /usr/local/nagios/etc/nagios.cfg && \
	echo "" >> /usr/local/nagios/etc/nagios.cfg && \
	echo "cfg_dir=/usr/local/nagios/etc/nagiosql" >> /usr/local/nagios/etc/nagios.cfg && \
	#Download Linux Check_service Plugin
    cd /tmp && \
    wget https://github.com/duffycop/nagios_plugins/files/1881453/check_service.tar.gz && \
    tar -xzf check_service.tar.gz && \
    mv ./check_service /usr/local/nagios/libexec && \
	sed -i 's/systemctl is-active \$SERVICE/service $SERVICE status/g' /usr/local/nagios/libexec/check_service

USER root

VOLUME ["/vol/web/static"]

# Nagios Port.
EXPOSE 80

# Secure Shell port.
EXPOSE 22

CMD ["/scripts/run.sh"]
# Remember to start the SSH service through the container's command prompt.