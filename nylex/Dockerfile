FROM ubuntu
LABEL maintainer="nylex.net"

# Required NagiosQL config files with host information.
COPY ./nagiosql /usr/local/nagios/etc/nagiosql

# File from original Nagios build.
COPY ./nagiosql_share/config/settings.php /usr/local/nagios/share/nagiosql/config/settings.php

# Nagios' configuration files.
COPY ./Configs /usr/local/nagios/etc/

# Commands ran upon starting nagios container.
COPY ./scripts/run.sh /scripts/run.sh

# Missing required file.
COPY ./loose_files/ping /usr/bin/ping

# Required arguments and environmental variables.
ENV GEOGRAPHIC_AREA=11
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV NAGIOS_FQDN=NAGIOS-NVR
ENV APACHE_RUN_USER=nagios
ENV APACHE_RUN_GROUP=www-data

# Install dependencies and Nagios
RUN apt-get update -y && \
    apt-get install -y autoconf gcc libc6 make wget unzip php libgd-dev openssl libssl-dev \
    openssh-server php-cli php-gd php-curl php-mysql php-ldap php-zip php-fileinfo php-pear \
    php-dev php zlib1g-dev libssh2-1 libssh2-1-dev php-ssh2 mariadb-server build-essential \
    snmp libnet-snmp-perl gettext && \
    apt-get purge -y openssh-server && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:$NAGIOS_PASSWORD' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    wget -O /tmp/nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.5.4/nagios-4.5.4.tar.gz && \
    tar -xzf /tmp/nagioscore.tar.gz -C /tmp && \
    cd /tmp/nagios-4.5.4 && \
    ./configure --with-httpd-conf=/etc/apache2/sites-enabled && \
    make all && \
    make install-groups-users && \
    usermod -a -G nagios www-data && \
    make install && \
    make install-daemoninit && \
    make install-commandmode && \
    make install-config && \
    make install-webconf && \
    a2enmod rewrite cgi && \
    wget --no-check-certificate -O /tmp/nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.12/nagios-plugins-2.4.12.tar.gz && \
    tar -zxf /tmp/nagios-plugins.tar.gz -C /tmp && \
    cd /tmp/nagios-plugins-2.4.12 && \
    ./configure && \
    make && \
    make install && \
    cd /tmp && \
    wget -O /tmp/nagiosql-3.5.0-.tar.gz https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.5.0/nagiosql-3.5.0-git2023-06-18.tar.gz/download && \
    tar -zxvf /tmp/nagiosql-3.5.0-.tar.gz -C /usr/local/nagios/share/nagiosql && \
    mkdir -p /usr/local/nagios/etc/nagiosql/backup/{hosts,services} /var/log/sendemail && \
    chmod -R 777 /usr/local/nagios/share/nagiosql/config && \
    chmod -R 6775 /usr/local/nagios/etc/nagiosql && \
    chown -R nagios:www-data /usr/local/nagios/etc/nagiosql && \
    chown nagios:www-data /usr/local/nagios/etc/nagios.cfg /usr/local/nagios/etc/cgi.cfg /usr/local/nagios/etc/resource.cfg && \
    chown nagios:www-data /usr/local/nagios/var/spool/checkresults && \
    chown nagios:www-data /usr/local/nagios/bin/nagios && \
    chmod 775 /usr/local/nagios/etc/ && \
    chmod 777 /usr/local/nagios/bin/nagios && \
    chmod -R 777 /usr/local/nagios/share/nagiosql/config && \
    chmod -R 6775 /usr/local/nagios/etc/nagiosql && \
    sed -i 's/^cfg/#cfg/' /usr/local/nagios/etc/nagios.cfg && \
    echo "cfg_dir=/usr/local/nagios/etc/nagiosql" >> /usr/local/nagios/etc/nagios.cfg && \
    wget -O /tmp/check_service.tar.gz https://github.com/duffycop/nagios_plugins/files/1881453/check_service.tar.gz && \
    tar -xzf /tmp/check_service.tar.gz -C /usr/local/nagios/libexec && \
    sed -i 's/systemctl is-active \$SERVICE/service \$SERVICE status/g' /usr/local/nagios/libexec/check_service && \
    chmod ug+s /usr/local/nagios/libexec/check_service && \
    sed -i '/# Global configuration/i ServerName ${APACHE_HOSTNAME}' /etc/apache2/apache2.conf && \
    sed -i 'export APACHE_HOSTNAME=Nagios-SVR' /etc/apache2/envvars

# Expose ports
EXPOSE 80 22

# Set the default command
CMD ["/scripts/run.sh"]
