#!/bin/bash

echo 'Enter desired password for Nagios & NagiosQL: ';
read password;

echo 'Enter IP of this Debian Nagios Controller Device: ';
read address;

#Checks for updates
function updateCheck(){
	yes | apt-get install sudo;
	yes | apt-get install sendemail;
	yes | apt-get update;
	yes | apt-get dist-upgrade;
	yes | apt-get install send-email;
}

#Installs Prerequisites
function prereq(){
	yes | apt-get install -y autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev;
	yes | apt-get install openssl libssl-dev;
}

#Installs nagios & compiles
function mainInstall(){
	cd /tmp/;
	wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.4.8/nagios-4.4.8.tar.gz;
	tar xzf nagioscore.tar.gz;

	cd /tmp/nagios-*;
	./configure --with-httpd-conf=/etc/apache2/sites-enabled;
	make all;
}

#Creates user and adjusts rights
function createUser(){
	sudo make install-groups-users;
	cd /tmp/;
	sudo usermod -a -G nagios www-data;
}

#Installs nagios packages & Apache config
function nagiosPackages(){
	cd /tmp/nagios-*;
	make install;
	make install-daemoninit;
	make install-commandmode;
	make install-config;

	make install-webconf;
	sudo a2enmod rewrite;
	sudo a2enmod cgi;
}

#Installs and configures firewall, finishes base Nagios install
function securityChange(){
	yes | apt-get install iptables;
	sudo iptables -I INPUT -p tcp --destination-port 80 -j ACCEPT;
	sudo apt-get install -y iptables-persistent;
	htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin $password;
	sed -i 's/check_for_updates=1/check_for_updates=0/' /usr/local/nagios/etc/nagios.cfg;
}

#Installs Nagios Plugins
function plugins(){
	apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext;
	cd /tmp;
	wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.2/nagios-plugins-2.4.2.tar.gz;
	tar zxf nagios-plugins.tar.gz;
	cd /tmp/nagios-plugins-*;
	./configure;
	make;
	make install;

	systemctl restart apache2.service;
	systemctl start nagios.service;	
}

#NagiosQL Install

#Install NagiosQL basic packages
function qlInit(){
	sudo apt update;
	apt-get install -y php libmcrypt-dev php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-pear gcc php-dev php zlib1g-dev libssh2-1 libssh2-1-dev php-ssh2  mariadb-server build-essential;
	pear channel-update pear.php.net;
	pear install HTML_Template_IT;
	pecl install mcrypt | echo;

	echo "extension=mcrypt.so" >> /etc/php/*/apache2/php.ini;
	echo "date.timezone=Asia/Singapore"  >> /etc/php/*/apache2/php.ini;
	systemctl restart apache2;
}

#Configure database
function mysqlConfig(){
	mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$password';";
	mysql -u root -p$password -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'$address' IDENTIFIED BY '$password';";
	mysql -u root -p$password -e "FLUSH PRIVILEGES;";
}

#Download NagiosQL
function qlDownload(){
	cd /tmp/;
	wget -O nagiosql-3.4.1.tar.gz https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.4.1/nagiosql-3.4.1-git2020-01-19.tar.gz/download;
	tar -zxvf nagiosql-3.4.1.tar.gz;
	cp -vprf nagiosql-3.4.1/ /usr/local/nagios/share/nagiosql;
}

#Configure Files and Folders
function qlConfig(){
	mkdir /usr/local/nagios/etc/nagiosql;
	mkdir /usr/local/nagios/etc/nagiosql/hosts;
	mkdir /usr/local/nagios/etc/nagiosql/services;
	mkdir /usr/local/nagios/etc/nagiosql/backup;
	mkdir /usr/local/nagios/etc/nagiosql/backup/hosts;
	mkdir /usr/local/nagios/etc/nagiosql/backup/services;

	chown -R nagios.www-data /usr/local/nagios/etc/nagiosql;
	chown nagios.www-data /usr/local/nagios/etc/nagios.cfg;
	chown nagios.www-data /usr/local/nagios/etc/cgi.cfg;
	chown nagios.www-data /usr/local/nagios/etc/resource.cfg;
	chown nagios.www-data /usr/local/nagios/var/spool/checkresults;
	chown nagios:www-data /usr/local/nagios/bin/nagios;

	chmod 775 /usr/local/nagios/etc/;
	chmod 777 /usr/local/nagios/bin/nagios;
	chmod -R 777 /usr/local/nagios/share/nagiosql/config;
	chmod -R 6775 /usr/local/nagios/etc/nagiosql;
	chmod 660 /usr/local/nagios/var/rw/nagios.cmd;
	chmod 775 /usr/local/nagios/etc/;
	chmod 664 /usr/local/nagios/etc/nagios.cfg;
	chmod 664 /usr/local/nagios/etc/cgi.cfg;
	chmod g+x /usr/local/nagios/var/rw/;

	chgrp www-data /usr/local/nagios/etc/;
	chgrp www-data /usr/local/nagios/etc/nagios.cfg;
	chgrp www-data /usr/local/nagios/etc/cgi.cfg;

	sed -i 's/^cfg/#cfg/' /usr/local/nagios/etc/nagios.cfg;
	echo "" >> /usr/local/nagios/etc/nagios.cfg;
	echo "cfg_dir=/usr/local/nagios/etc/nagiosql" >> /usr/local/nagios/etc/nagios.cfg;
}

#Download Linux Check_service Plugin
function checkServPlug(){

	cd /tmp/;
	wget https://github.com/duffycop/nagios_plugins/files/1881453/check_service.tar.gz;
	tar xzf check_service.tar.gz;
	mv ./check_service /usr/local/nagios/libexec;

}

updateCheck;
prereq;
mainInstall;
createUser;
nagiosPackages;
securityChange;
plugins;
qlInit;
mysqlConfig;
qlDownload;
qlConfig;
checkServPlug;