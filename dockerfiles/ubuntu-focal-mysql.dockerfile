FROM ubuntu:focal

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y systemd-sysv mysql-server # NOTE: MySQL 8が入る
