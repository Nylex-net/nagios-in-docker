#!/bin/sh

set -e

mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';";
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'Nagios-NVR' IDENTIFIED BY '$NAGIOS_PASSWORD';";
mysql -u root -p$MYSQL_ROOT_PASSWORD -e "FLUSH PRIVILEGES;";