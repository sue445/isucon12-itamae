FROM ubuntu:focal

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y systemd-sysv sudo mysql-server

# ref. https://github.com/isucon/isucon11-prior/blob/main/infra/instance/cookbooks/user/default.rb
RUN groupadd isucon \
 && useradd --shell /bin/bash --create-home --gid isucon isucon

RUN echo "isucon ALL=(ALL) NOPASSWD:ALL\n" >> /etc/sudoers
