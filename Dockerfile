FROM debian:bullseye
LABEL maintainer="nylex.net"

COPY ./scripts/NagiosInstall.sh /usr/local/bin/

ENV TERM xterm

# Expose the port your Django app will run on
EXPOSE 8000

RUN chmod +x /usr/local/bin/NagiosInstall.sh

USER root

CMD ["/usr/local/bin/NagiosInstall.sh"]