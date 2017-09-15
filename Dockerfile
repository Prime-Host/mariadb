FROM mariadb:latest
MAINTAINER Kevin Nordloh <info@prime-host.de>

RUN apt-get update
RUN apt-get -y upgrade

RUN apt-get -y install vim

RUN apt-get --purge autoremove -y

ADD ./my.cnf /etc/mysql/my.cnf
