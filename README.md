# isucon-itamae
ISUCONの環境構築用Itamae

## Requirements
* isuconユーザでsshできるようにしておく

## Setup
```bash
bundle install
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
