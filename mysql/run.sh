#!/bin/sh

set -e

mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'nagios' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';";
mysql -u root -p $MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'nagios' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';";
mysql -u root -p $MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;";