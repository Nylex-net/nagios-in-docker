#!/bin/sh

set -e

service apache2 restart;
service nagios start;
service ssh start;
tail -f /usr/local/nagios/var/nagios.log;