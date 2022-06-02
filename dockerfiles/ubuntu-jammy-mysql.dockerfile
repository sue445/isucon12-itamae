FROM ubuntu:jammy

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y systemd-sysv mysql-server
