# isucon-itamae
ISUCONの環境構築用Itamae

[![Build Status](https://github.com/sue445/isucon-itamae/workflows/test/badge.svg?branch=main)](https://github.com/sue445/isucon-itamae/actions?query=workflow%3Atest)

## Requirements
* isuconユーザでsshできるようにしておく
* 下記のような `~/.ssh/config` を作っておく

```
Host isucon-01
  Hostname xx.xx.xx.xx
  Port 22
  User isucon
  ForwardAgent yes

Host isucon-02
  Hostname xx.xx.xx.xx
  Port 22
  User isucon
  ForwardAgent yes

Host isucon-03
  Hostname xx.xx.xx.xx
  Port 22
  User isucon
  ForwardAgent yes

Host isucon-bench
  Hostname xx.xx.xx.xx
  Port 22
  User isucon
  ForwardAgent yes
```

## Setup
```bash
bundle install
cp .env.example .env
vi .env
```

## Config
* [hosts.yml](hosts.yml) : Itamae実行対象のサーバ（事前にisuconユーザでsshできるようにしておく）
* [node.yml](node.yml) : 全サーバに適用する設定

## Usage
```bash
$ bundle exec rake -T
rake itamae:all:apply       # Run Itamae to all hosts
rake itamae:all:dry_run     # Run Itamae to all hosts (dry-run)
rake itamae:host01:apply    # Run Itamae to host01
rake itamae:host01:dry_run  # Run Itamae to host01 (dry-run)
rake itamae:host02:apply    # Run Itamae to host02
rake itamae:host02:dry_run  # Run Itamae to host02 (dry-run)
rake itamae:host03:apply    # Run Itamae to host03
rake itamae:host03:dry_run  # Run Itamae to host03 (dry-run)
rake print_public_keys      # Print all server's public keys
rake test:boot              # Boot container
rake test:clean             # Clean a docker container for test
rake test:itamae            # Run itamae
```

初回実行時はrubyのビルドに時間がかかるのでビルド待ちの間にターミナルの別窓で

```bash
bundle exec rake print_public_keys
```

の実行結果を https://github.com/settings/keys かデプロイ対象のリポジトリの `/settings/keys` に登録する

## Testing
```bash
bundle exec rake test
```
