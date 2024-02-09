FROM Debian:bullseye
LABEL maintainer="nylex.net"

RUN apt-get update && \
    apt-get install -y autoconf gcc libc6 make wget unzip apache2 apache2-utils php libgd-dev && \
    apt-get install openssl libssl-dev