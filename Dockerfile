FROM jasonrivers/nagios
LABEL maintainer="nylex.net"

COPY ./hosts/A1AA-NMSG.cfg /opt/nagios/etc/objects/A1AA-NMSG.cfg

COPY ./Configs/nagios.cfg /opt/nagios/etc/nagios.cfg

# RUN cd /tmp/ && \
# 	wget -O nagiosql-3.5.0.tar.gz https://sourceforge.net/projects/nagiosql/files/nagiosql/NagiosQL%203.5.0/nagiosql-3.5.0-git2023-06-18.tar.gz/download && \
# 	tar -zxvf nagiosql-3.5.0.tar.gz && \
# 	mkdir /usr/local/nagios && \
# 	mkdir /usr/local/nagios/share && \
# 	mkdir /usr/local/nagios/share/nagiosql && \
# 	cp -vprf nagiosql-3.5.0/ /usr/local/nagios/share/nagiosql && \
# 	mkdir /usr/local/nagios/etc && \
#     mkdir /usr/local/nagios/etc/nagiosql && \
# 	mkdir /usr/local/nagios/etc/nagiosql/hosts && \
# 	mkdir /usr/local/nagios/etc/nagiosql/services && \
# 	mkdir /usr/local/nagios/etc/nagiosql/backup && \
# 	mkdir /usr/local/nagios/etc/nagiosql/backup/hosts && \
# 	mkdir /usr/local/nagios/etc/nagiosql/backup/services && \
# 	chown -R nagios.www-data /usr/local/nagios/etc/nagiosql && \
# 	chown nagios.www-data /usr/local/nagios/etc/nagios.cfg && \
# 	chown nagios.www-data /usr/local/nagios/etc/cgi.cfg && \
# 	chown nagios.www-data /usr/local/nagios/etc/resource.cfg && \
# 	chown nagios.www-data /usr/local/nagios/var/spool/checkresults && \
# 	chown nagios:www-data /usr/local/nagios/bin/nagios && \
# 	chmod 775 /usr/local/nagios/etc/ && \
# 	chmod 777 /usr/local/nagios/bin/nagios && \
# 	chmod -R 777 /usr/local/nagios/share/nagiosql/config && \
# 	chmod -R 6775 /usr/local/nagios/etc/nagiosql && \
# 	chmod 660 /usr/local/nagios/var/rw/nagios.cmd && \
# 	chmod 775 /usr/local/nagios/etc/ && \
# 	chmod 664 /usr/local/nagios/etc/nagios.cfg && \
# 	chmod 664 /usr/local/nagios/etc/cgi.cfg && \
# 	chmod g+x /usr/local/nagios/var/rw/ && \
# 	chgrp www-data /usr/local/nagios/etc/ && \
# 	chgrp www-data /usr/local/nagios/etc/nagios.cfg && \
# 	chgrp www-data /usr/local/nagios/etc/cgi.cfg && \
# 	sed -i 's/^cfg/#cfg/' /usr/local/nagios/etc/nagios.cfg && \
# 	echo "" >> /usr/local/nagios/etc/nagios.cfg && \
# 	echo "cfg_dir=/usr/local/nagios/etc/nagiosql" >> /usr/local/nagios/etc/nagios.cfg && \
#     cd /tmp/ && \
# 	wget https://github.com/duffycop/nagios_plugins/files/1881453/check_service.tar.gz && \
# 	tar xzf check_service.tar.gz && \
# 	mv ./check_service /usr/local/nagios/libexec
