FROM debian:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php \
    libgd-dev libmcrypt-dev libssl-dev snmp build-essential libperl-dev && \
    apt-get clean

RUN useradd nagios && groupadd nagcmd && \
    usermod -a -G nagcmd nagios && usermod -a -G nagcmd www-data

WORKDIR /tmp

# Descargar y compilar Nagios
RUN wget https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.6.tar.gz && \
    tar xzf nagios-4.4.6.tar.gz && \
    cd nagios-4.4.6 && \
    ./configure --with-command-group=nagcmd && \
    make all && \
    make install && \
    make install-init && \
    make install-commandmode && \
    make install-config && \
    make install-webconf && \
    htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin admin

RUN a2enmod cgi

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]

