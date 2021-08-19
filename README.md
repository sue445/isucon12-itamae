# isucon11-itamae
ISUCON11の環境構築用Itamae

## Requirements
* isuconユーザでsshできるようにしておく

## Usage
```bash
$ bundle exec rake -T
rake itamae:all:apply     # Run Itamae to all hosts
rake itamae:all:dry_run   # Run Itamae to all hosts (dry-run)
rake itamae:test:apply    # Run Itamae to test
rake itamae:test:dry_run  # Run Itamae to test (dry-run)
```

初回実行時はrubyのビルドに時間がかかるのでビルド待ちの間にターミナルの別窓からsshして

```bash
cat ~/.ssh/id_ed25519.pub
```

の実行結果を https://github.com/settings/keys に登録する
