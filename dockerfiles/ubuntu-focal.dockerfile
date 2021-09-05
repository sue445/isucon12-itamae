FROM ubuntu:focal

RUN apt-get update \
 && apt-get install -y systemd-sysv \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ref. https://github.com/isucon/isucon11-prior/blob/main/infra/instance/cookbooks/user/default.rb
RUN groupadd isucon \
 && useradd --shell /bin/bash --create-home --gid isucon isucon
