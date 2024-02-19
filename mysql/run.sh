#!/bin/sh

set -e

User ${APACHE_RUN_USER};
Group ${APACHE_RUN_GROUP};

service apache2 restart;

hostname=$(hostname);

mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';";
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'$hostname' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';";
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;";