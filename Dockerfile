FROM jasonrivers/nagios
LABEL maintainer="nylex.net"

COPY ./hosts/ /opt/nagios/etc/objects/