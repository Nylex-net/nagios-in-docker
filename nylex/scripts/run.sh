#!/bin/sh

set -e

service apache2 restart;
service nagios start;
service ssh start;
# /scripts/docker-update-hosts.sh -a 127.0.0.1 -h /etc/hosts -q -v;
tail -f /usr/local/nagios/var/nagios.log;